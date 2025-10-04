import 'package:flutter/material.dart';
import '../models/app_usage.dart';
import '../services/usage_service.dart';

class UsageProvider extends ChangeNotifier {
  final UsageService _service = UsageService();

  // Daily usage data
  List<AppUsage> _dailyApps = [];
  List<AppUsage> get dailyApps => _dailyApps;

  // Weekly usage data
  Map<String, List<double>> _weeklyCategoryData = {};
  Map<String, List<double>> get weeklyCategoryData => _weeklyCategoryData;

  bool _loading = true;
  bool get loading => _loading;

  bool _loadingWeekly = false;
  bool get loadingWeekly => _loadingWeekly;

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  UsageProvider() {
    _init();
  }

  Future<void> _init() async {
    _hasPermission = await _service.checkPermission();
    if (_hasPermission) {
      await refreshDaily();
      await refreshWeekly(); // Load weekly data on init
      _startRealTimeUpdates();
    }
    _loading = false;
    notifyListeners();
  }

  /// Refresh daily usage once
  Future<void> refreshDaily() async {
    _loading = true;
    notifyListeners();

    _dailyApps = await _service.fetchUsageOnce();

    _loading = false;
    notifyListeners();
  }

  /// Refresh weekly usage data
  Future<void> refreshWeekly() async {
    _loadingWeekly = true;
    notifyListeners();

    _weeklyCategoryData = await _fetchWeeklyCategorySeries();

    _loadingWeekly = false;
    notifyListeners();
  }

  /// Open Android usage settings
  Future<void> openSettings() async {
    await _service.openSettings();
  }

  /// Real-time usage updates for daily data
  void _startRealTimeUpdates() {
    _service.getUsageStream().listen((apps) {
      _dailyApps = apps;
      notifyListeners();
    });
  }

  /// Weekly aggregation by category
  Future<Map<String, List<double>>> _fetchWeeklyCategorySeries() async {
    final now = DateTime.now();
    final Map<String, List<double>> categoryData = {
      'Entertainment': List.filled(7, 0),
      'Games': List.filled(7, 0),
      'Communication': List.filled(7, 0),
      'Learning': List.filled(7, 0),
      'Other': List.filled(7, 0),
    };

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      // Fetch usage for specific date range
      final dailyList = await _service.fetchUsageForDateRange(startOfDay, endOfDay);

      for (var app in dailyList) {
        final category = app.category.isNotEmpty ? app.category : 'Other';
        if (categoryData.containsKey(category)) {
          categoryData[category]![i] += app.timeInForeground / 3600000; // convert ms → hours
        }
      }
    }

    return categoryData;
  }
}