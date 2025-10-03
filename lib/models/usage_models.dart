class AppUsageEntry {
  final String packageName;
  final String appName;
  final Duration totalTime;
  final String category; // e.g., 'Entertainment', 'Learning'


  AppUsageEntry({required this.packageName, required this.appName, required this.totalTime, required this.category});
}


class DailyBucket {
  final DateTime start;
  final DateTime end;
  final Map<String, Duration> byCategory; // category -> time
  final Map<String, Duration> byApp; // package -> time


  DailyBucket({required this.start, required this.end, required this.byCategory, required this.byApp});
}