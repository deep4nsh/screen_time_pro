import 'dart:convert';
import 'package:flutter/services.dart';

class UsageStatsHelper {
  static const platform = MethodChannel("screen_time_pro/usage");

  static Future<void> requestUsagePermission() async {
    await platform.invokeMethod("openUsageSettings");
  }

  static Future<List<Map<String, dynamic>>> getUsageStats() async {
    final String json = await platform.invokeMethod("getUsageStats");
    final List decoded = jsonDecode(json);
    return decoded.cast<Map<String, dynamic>>();
  }
}
