import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:intl/intl.dart';
import '../models/usage_models.dart';

class UsageService extends ChangeNotifier {
  bool _initialized = false;
  bool get initialized => _initialized;

  List<AppUsageEntry> mostUsed = [];
  List<DailyBucket> dailyBuckets = [];
  Map<String, Duration> categoryTotals = {};
  DateTime? lastFetch;

  // Simple package -> category map (extendable)
  final Map<String, String> _categoryMap = {
    'com.whatsapp': 'Communication',
    'com.facebook.katana': 'Social',
    'com.instagram.android': 'Social',
    'com.google.android.youtube': 'Entertainment',
    'com.netflix.mediaclient': 'Entertainment',
  };

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Prompt user to grant Usage Access (opens settings)
    try {
      UsageStats.grantUsagePermission();
    } catch (_) {}

    // non-async check (per package docs)
    bool hasPermission = false;
    try {
      // checkUsagePermission is synchronous in the package example
      hasPermission = UsageStats.checkUsagePermission() as bool;
    } catch (_) {}

    // If user hasn't granted permission, still continue (grantUsagePermission opens settings).
    await fetchUsage();

    // optional: periodic refresh
    Timer.periodic(const Duration(seconds: 30), (t) async {
      await fetchUsage(updateOnly: true);
    });
  }

  Future<void> fetchUsage({bool updateOnly = false}) async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 7)); // weekly range

      // Query usage stats (returns List<UsageInfo>)
      List<UsageInfo> infos = await UsageStats.queryUsageStats(startDate, endDate);

      // Convert to plain maps (serializable) before sending to compute()
      final serializableInfos = infos.map((i) {
        return <String, String>{
          'packageName': i.packageName ?? '',
          'firstTimeStamp': i.firstTimeStamp ?? '0',
          'lastTimeStamp': i.lastTimeStamp ?? '0',
          'lastTimeUsed': i.lastTimeUsed ?? '0',
          'totalTimeInForeground': i.totalTimeInForeground ?? '0', // note: string in plugin
        };
      }).toList();

      final processed = await compute(_processInfos, {
        'infos': serializableInfos,
        'categoryMap': _categoryMap,
      });

      // Reconstruct typed objects from the serialized result returned by the isolate
      final List<dynamic> mostUsedRaw = (processed['mostUsed'] ?? []) as List<dynamic>;
      mostUsed = mostUsedRaw.map((m) {
        final map = Map<String, dynamic>.from(m as Map);
        return AppUsageEntry(
          packageName: map['packageName'] as String,
          appName: map['appName'] as String,
          totalTime: Duration(milliseconds: map['totalMs'] as int),
          category: map['category'] as String,
        );
      }).toList();

      final List<dynamic> dailyBucketsRaw = (processed['dailyBuckets'] ?? []) as List<dynamic>;
      dailyBuckets = dailyBucketsRaw.map((b) {
        final bm = Map<String, dynamic>.from(b as Map);
        final startMs = bm['startMs'] as int;
        final endMs = bm['endMs'] as int;
        final byCategoryMs = Map<String, dynamic>.from(bm['byCategory'] as Map).map((k, v) => MapEntry(k.toString(), v as int));
        final byAppMs = Map<String, dynamic>.from(bm['byApp'] as Map).map((k, v) => MapEntry(k.toString(), v as int));
        return DailyBucket(
          start: DateTime.fromMillisecondsSinceEpoch(startMs),
          end: DateTime.fromMillisecondsSinceEpoch(endMs),
          byCategory: byCategoryMs.map((k, v) => MapEntry(k, Duration(milliseconds: v))),
          byApp: byAppMs.map((k, v) => MapEntry(k, Duration(milliseconds: v))),
        );
      }).toList();

      final Map<String, dynamic> catTotalsRaw = Map<String, dynamic>.from(processed['categoryTotals'] as Map? ?? {});
      categoryTotals = catTotalsRaw.map((k, v) => MapEntry(k.toString(), Duration(milliseconds: v as int)));

      lastFetch = DateTime.now();
      notifyListeners();
    } catch (e, st) {
      if (kDebugMode) {
        print('fetchUsage error: $e\n$st');
      }
    }
  }
}

/// Runs inside the isolate: MUST only use/send serializable types (maps, lists, numbers)
Map<String, dynamic> _processInfos(dynamic payload) {
  final List<dynamic> infosJson = payload['infos'] as List<dynamic>;
  final Map<String, String> categoryMap = Map<String, String>.from(payload['categoryMap'] as Map);

  // dayKey -> package -> totalMs
  final Map<String, Map<String, int>> dayAppMs = {};

  for (final raw in infosJson) {
    final Map<String, dynamic> j = Map<String, dynamic>.from(raw as Map);
    final String pkg = (j['packageName'] as String?) ?? 'unknown';
    final int totalMs = int.tryParse((j['totalTimeInForeground'] ?? '0').toString()) ?? 0;
    final int firstMs = int.tryParse((j['firstTimeStamp'] ?? '0').toString()) ?? 0;

    if (totalMs <= 0) continue;

    final DateTime first = DateTime.fromMillisecondsSinceEpoch(firstMs);
    final String dayKey = DateFormat('yyyy-MM-dd').format(first);

    dayAppMs.putIfAbsent(dayKey, () => {});
    dayAppMs[dayKey]![pkg] = (dayAppMs[dayKey]![pkg] ?? 0) + totalMs;
  }

  // Build daily buckets (today split into 12 x 2-hour slots) — values in ms
  final String todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final Map<String, int> todayApps = Map<String, int>.from(dayAppMs[todayKey] ?? {});

  final int slotMs = 2 * 60 * 60 * 1000; // 2 hours
  final DateTime now = DateTime.now();
  final DateTime slotStart = DateTime(now.year, now.month, now.day);

  final List<Map<String, dynamic>> dailyBuckets = [];
  for (int i = 0; i < 12; i++) {
    final DateTime s = slotStart.add(Duration(milliseconds: i * slotMs));
    final DateTime e = s.add(Duration(milliseconds: slotMs));

    final Map<String, int> byCategory = {};
    final Map<String, int> byApp = {};

    todayApps.forEach((pkg, ms) {
      final String cat = categoryMap[pkg] ?? 'Other';
      final int perSlot = ms ~/ 12; // even distribution placeholder
      byApp[pkg] = (byApp[pkg] ?? 0) + perSlot;
      byCategory[cat] = (byCategory[cat] ?? 0) + perSlot;
    });

    dailyBuckets.add({
      'startMs': s.millisecondsSinceEpoch,
      'endMs': e.millisecondsSinceEpoch,
      'byCategory': byCategory,
      'byApp': byApp,
    });
  }

  // Aggregate across all collected days
  final Map<String, int> aggMs = {};
  dayAppMs.forEach((_, map) {
    map.forEach((pkg, ms) {
      aggMs[pkg] = (aggMs[pkg] ?? 0) + ms;
    });
  });

  final sorted = aggMs.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final mostUsed = sorted.map((e) {
    final String pkg = e.key;
    final int ms = e.value;
    return <String, dynamic>{
      'packageName': pkg,
      'appName': pkg,
      'totalMs': ms,
      'category': categoryMap[pkg] ?? 'Other',
    };
  }).toList();

  // category totals (ms)
  final Map<String, int> catMs = {};
  aggMs.forEach((pkg, ms) {
    final String cat = categoryMap[pkg] ?? 'Other';
    catMs[cat] = (catMs[cat] ?? 0) + ms;
  });

  return {
    'mostUsed': mostUsed,
    'dailyBuckets': dailyBuckets,
    'categoryTotals': catMs,
  };
}
