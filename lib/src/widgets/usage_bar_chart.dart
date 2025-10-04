import 'dart:convert';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/app_usage.dart';

class UsageBarChart extends StatelessWidget {
  final List<AppUsage> usages;

  const UsageBarChart({Key? key, required this.usages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (usages.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("No data")),
      );
    }

    final sorted = List<AppUsage>.from(usages)
      ..sort((a, b) => b.timeInForeground.compareTo(a.timeInForeground));
    final topApps = sorted.length > 10 ? sorted.sublist(0, 10) : sorted;
    final maxTime = topApps.first.timeInForeground / 3600000; // hours

    // Ensure maxY is at least 0.5 to show some scale
    final maxY = maxTime > 0 ? maxTime + 0.5 : 1.0;
    final interval = maxY > 0 ? (maxY / 5).clamp(0.1, double.infinity) : 0.2;

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: topApps.asMap().entries.map((entry) {
            int index = entry.key;
            final app = entry.value;
            final hours = app.timeInForeground / 3600000;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: hours,
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.blueAccent,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < topApps.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          topApps[index].appName,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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
                interval: interval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final app = topApps[groupIndex];
                return BarTooltipItem(
                  '${app.appName}\n${(app.timeInForeground / 3600000).toStringAsFixed(2)} hrs',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}