import 'package:flutter/foundation.dart';
import '../models/app_usage.dart';
import '../services/usage_service.dart';


class UsageProvider extends ChangeNotifier {
  final UsageService _service = UsageService();
  List<AppUsage> daily = [];
  List<AppUsage> weekly = [];
  bool hasPermission = false;
  bool loading = false;


  UsageProvider() {
    init();
  }


  Future<void> init() async {
    hasPermission = await _service.checkPermission();
    if (hasPermission) await refreshAll();
    notifyListeners();
  }


  Future<void> requestPermission() async {
    await _service.openSettings();
  }


  Future<void> refreshAll() async {
    loading = true;
    notifyListeners();
    try {
      daily = await _service.fetchUsage(interval: 'daily');
      weekly = await _service.fetchUsage(interval: 'weekly');
    } catch (e) {
// handle
    }
    loading = false;
    notifyListeners();
  }


  double totalTime(List<AppUsage> list) => list.fold(0.0, (p, e) => p + e.timeHours);


  Map<String, double> categorize(List<AppUsage> list) {
// Basic categorization by package name heuristics. You should provide a better mapping.
    final Map<String, double> map = {};
    for (var a in list) {
      final cat = _guessCategory(a.packageName);
      map[cat] = (map[cat] ?? 0) + a.timeHours;
    }
    return map;
  }


  String _guessCategory(String pkg) {
    final p = pkg.toLowerCase();
    if (p.contains('youtube') || p.contains('netflix') || p.contains('prime')) return 'Entertainment';
    if (p.contains('edu') || p.contains('khan') || p.contains('coursera') || p.contains('udemy') || p.contains('google.classroom')) return 'Learning';
    if (p.contains('whatsapp') || p.contains('messag') || p.contains('telegram') || p.contains('signal')) return 'Communication';
    if (p.contains('game') || p.contains('puzzle')) return 'Games';
    return 'Other';
  }
}