import 'package:flutter/services.dart';
import '../models/app_usage.dart';

class UsageService {
  static const MethodChannel _channel = MethodChannel('screen_time_pro/usage');

  Future<bool> checkPermission() async {
    return await _channel.invokeMethod('hasUsagePermission');
  }

  Future<void> openSettings() async {
    await _channel.invokeMethod('openUsageSettings');
  }

  Future<List<AppUsage>> fetchUsage({String interval = 'daily'}) async {
    final List<dynamic> result =
    await _channel.invokeMethod('fetchUsage', {'interval': interval});

    // Convert each map to AppUsage
    return result.map((e) => AppUsage.fromMap(Map<String, dynamic>.from(e))).toList();
  }
}
