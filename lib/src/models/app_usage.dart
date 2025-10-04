class AppUsage {
  final String appName;
  final String packageName;
  final String iconBase64;
  final int usageMillis;
  final int timeInForeground; // milliseconds
  final String category;
  final DateTime date;

  AppUsage({
    required this.appName,
    required this.packageName,
    required this.usageMillis,
    required this.iconBase64,
    required this.timeInForeground,
    required this.category,
    required this.date,
  });

  factory AppUsage.fromJson(Map<String, dynamic> json) {
    return AppUsage(
      appName: json["appName"] ?? '',
      packageName: json["packageName"] ?? '',
      iconBase64: json["iconBase64"] ?? '',
      usageMillis: json["usageMillis"] ?? 0,
      timeInForeground: json["timeInForeground"] ?? 0,
      category: json["category"] ?? 'Other',
      date: json["date"] != null
          ? DateTime.parse(json["date"])
          : DateTime.now(),
    );
  }

  AppUsage copyWith({
    String? appName,
    String? packageName,
    String? iconBase64,
    int? usageMillis,
    int? timeInForeground,
    String? category,
    DateTime? date,
  }) {
    return AppUsage(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      iconBase64: iconBase64 ?? this.iconBase64,
      usageMillis: usageMillis ?? this.usageMillis,
      timeInForeground: timeInForeground ?? this.timeInForeground,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  double get timeHours => usageMillis / 3600000;
}