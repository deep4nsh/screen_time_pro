import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/app_usage.dart';

class UsageService {
  static const _eventChannel = EventChannel("screen_time_pro/usage_stream");
  static const _methodChannel = MethodChannel("screen_time_pro/usage");

  Stream<List<AppUsage>> getUsageStream() {
    return _eventChannel.receiveBroadcastStream().map((event) {
      try {
        final list = event is String ? jsonDecode(event) : event;
        if (list is! List) {
          print('ERROR: Expected List but got ${list.runtimeType}');
          return <AppUsage>[];
        }
        return List<AppUsage>.from(
            list.map((e) => AppUsage.fromJson(Map<String, dynamic>.from(e as Map)))
        );
      } catch (e) {
        print('ERROR parsing usage stream: $e');
        return <AppUsage>[];
      }
    });
  }

  Future<List<AppUsage>> fetchUsageOnce() async {
    try {
      final result = await _methodChannel.invokeMethod('getUsageStats');
      final list = result is String ? jsonDecode(result) : result;
      if (list is! List) {
        print('ERROR: Expected List but got ${list.runtimeType}');
        return <AppUsage>[];
      }
      return List<AppUsage>.from(
          list.map((e) => AppUsage.fromJson(Map<String, dynamic>.from(e as Map)))
      );
    } catch (e) {
      print('ERROR fetching usage stats: $e');
      return <AppUsage>[];
    }
  }

  Future<List<AppUsage>> fetchUsageForDateRange(DateTime start, DateTime end) async {
    try {
      final result = await _methodChannel.invokeMethod('getUsageStatsForRange', {
        'startTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
      });
      final list = result is String ? jsonDecode(result) : result;
      if (list is! List) {
        print('ERROR: Expected List but got ${list.runtimeType}');
        return <AppUsage>[];
      }
      return List<AppUsage>.from(
          list.map((e) => AppUsage.fromJson(Map<String, dynamic>.from(e as Map)))
      );
    } catch (e) {
      print('ERROR fetching usage for date range: $e');
      return <AppUsage>[];
    }
  }

  Future<bool> checkPermission() async {
    try {
      return await _methodChannel.invokeMethod('checkPermission');
    } catch (e) {
      print('ERROR checking permission: $e');
      return false;
    }
  }

  Future<void> openSettings() async {
    try {
      await _methodChannel.invokeMethod('openUsageSettings');
    } catch (e) {
      print('ERROR opening settings: $e');
    }
  }
}