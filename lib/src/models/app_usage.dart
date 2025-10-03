class AppUsage {
  final String packageName;
  final String appName;
  final double timeHours;
  final String iconBase64;

  AppUsage({
    required this.packageName,
    required this.appName,
    required this.timeHours,
    required this.iconBase64,
  });

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      packageName: map['packageName'] ?? '',
      appName: map['appName'] ?? '',
      timeHours: (map['timeHours'] as num).toDouble(),
      iconBase64: map['icon'] ?? '',
    );
  }
}
