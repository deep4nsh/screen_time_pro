import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/app_usage.dart';

class UsageBarChart extends StatelessWidget {
  final List<AppUsage> usages;
  final String title; // "Daily" or "Weekly"

  const UsageBarChart({Key? key, required this.usages, this.title = "Daily"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (usages.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No data")),
      );
    }

    // Sort descending by usage time and take top 10
    final sorted = List<AppUsage>.from(usages)
      ..sort((a, b) => b.timeHours.compareTo(a.timeHours));
    final topList = sorted.length > 10 ? sorted.sublist(0, 10) : sorted;
    final maxTime = topList.first.timeHours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title App Usage',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxTime + 0.5,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final app = topList[groupIndex];
                    return BarTooltipItem(
                      '${app.appName}\n${app.timeHours.toStringAsFixed(2)} hrs',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < topList.length) {
                        return RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            topList[index].appName,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (maxTime / 5).ceilToDouble(),
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: topList
                  .asMap()
                  .map(
                    (i, app) => MapEntry(
                  i,
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: app.timeHours,
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlueAccent],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        width: 18,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxTime + 0.5,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .values
                  .toList(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 600),
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }
}
