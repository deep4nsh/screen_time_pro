import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usage_provider.dart';
import '../widgets/weekly_usage_bar_chart.dart';
import '../models/app_usage.dart';
import '../services/usage_service.dart';
import 'dart:convert';
import 'dart:typed_data';

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  final UsageService _service = UsageService();
  Map<String, List<double>> _categoryData = {};
  List<String> _days = [];
  List<Map<String, dynamic>> _topApps = [];
  bool _loading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    setState(() => _loading = true);

    // Check permission
    _hasPermission = await _service.checkPermission();

    if (!_hasPermission) {
      setState(() => _loading = false);
      return;
    }

    // Prepare last 7 days labels
    final now = DateTime.now();
    _days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day.weekday % 7];
    });

    // Initialize categories
    final categoryData = {
      'Entertainment': List.generate(7, (_) => 0.0),
      'Games': List.generate(7, (_) => 0.0),
      'Learning': List.generate(7, (_) => 0.0),
      'Communication': List.generate(7, (_) => 0.0),
      'Other': List.generate(7, (_) => 0.0),
    };

    // Fetch data for each day
    final allApps = <AppUsage>[];

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      try {
        final dailyApps = await _service.fetchUsageForDateRange(startOfDay, endOfDay);

        // Fill category data for this day
        for (var app in dailyApps) {
          final cat = app.category.isNotEmpty ? app.category : 'Other';
          if (categoryData.containsKey(cat)) {
            categoryData[cat]![i] += app.timeInForeground / 3600000; // ms to hours
          }
        }

        allApps.addAll(dailyApps);
      } catch (e) {
        print('Error fetching data for day $i: $e');
      }
    }

    // Aggregate top 10 apps by total usage across all 7 days
    final appUsageMap = <String, int>{}; // packageName -> total ms
    final appDetailsMap = <String, AppUsage>{}; // packageName -> AppUsage (for icon/name)

    for (var app in allApps) {
      appUsageMap[app.packageName] = (appUsageMap[app.packageName] ?? 0) + app.timeInForeground;
      appDetailsMap[app.packageName] = app; // Keep app details
    }

    // Convert to list and sort
    final topAppsList = appUsageMap.entries.map((entry) {
      final app = appDetailsMap[entry.key]!;
      return {
        'appName': app.appName,
        'iconBase64': app.iconBase64,
        'timeInForeground': entry.value,
        'packageName': entry.key,
      };
    }).toList();

    topAppsList.sort((a, b) => (b['timeInForeground'] as int).compareTo(a['timeInForeground'] as int));
    final topAppsData = topAppsList.length > 10 ? topAppsList.sublist(0, 10) : topAppsList;

    setState(() {
      _categoryData = categoryData;
      _topApps = topAppsData;
      _loading = false;
    });
  }

  String formatDuration(int millis) {
    final seconds = millis ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    return "${hours}h ${minutes % 60}m";
  }

  Uint8List decodeIcon(String base64Str) => base64Decode(base64Str);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Usage Access Permission Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please grant usage access permission to view weekly statistics.',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await _service.openSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }

    if (_categoryData.isEmpty) {
      return const Center(child: Text("No weekly usage data"));
    }

    return RefreshIndicator(
      onRefresh: _loadWeeklyData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Weekly Usage by Category',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          WeeklyUsageBarChart(
            categoryData: _categoryData,
            days: _days,
            topApps: _topApps,
          ),
          const SizedBox(height: 24),
          const Text(
            'Top Apps This Week',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._topApps.map((app) {
            return ListTile(
              leading: app['iconBase64'].isNotEmpty
                  ? Image.memory(
                decodeIcon(app['iconBase64']),
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.apps);
                },
              )
                  : const Icon(Icons.apps),
              title: Text(app['appName']),
              trailing: Text(
                formatDuration(app['timeInForeground']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}