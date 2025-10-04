import 'dart:convert';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyUsageBarChart extends StatelessWidget {
  final Map<String, List<double>> categoryData; // category -> 7 days
  final List<String> days; // last 7 days labels
  final List<Map<String, dynamic>> topApps; // top 10 apps with iconBase64, appName, timeInForeground

  const WeeklyUsageBarChart({
    Key? key,
    required this.categoryData,
    required this.days,
    required this.topApps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define colors for categories
    final categoryColors = {
      'Entertainment': Colors.redAccent,
      'Games': Colors.orangeAccent,
      'Learning': Colors.greenAccent,
      'Communication': Colors.blueAccent,
      'Other': Colors.grey,
    };

    // Calculate total usage per day (stacked)
    final barGroups = List.generate(days.length, (dayIndex) {
      double stackedY = 0;
      final rods = <BarChartRodStackItem>[];

      // Create stacked segments for each category
      for (var entry in categoryData.entries) {
        final val = entry.value[dayIndex];
        if (val > 0) {
          rods.add(BarChartRodStackItem(
            stackedY,
            stackedY + val,
            categoryColors[entry.key] ?? Colors.grey,
          ));
          stackedY += val;
        }
      }

      return BarChartGroupData(
        x: dayIndex,
        barRods: [
          BarChartRodData(
            toY: stackedY,
            width: 40,
            borderRadius: BorderRadius.circular(6),
            rodStackItems: rods,
          ),
        ],
      );
    });

    // Calculate max Y for chart
    double maxY = 0;
    for (int i = 0; i < days.length; i++) {
      double dayTotal = 0;
      for (var entry in categoryData.entries) {
        dayTotal += entry.value[i];
      }
      if (dayTotal > maxY) maxY = dayTotal;
    }

    maxY = maxY > 0 ? maxY + 1 : 2.0; // Add padding and minimum scale
    final interval = (maxY / 5).clamp(0.2, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly App Usage by Category',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              alignment: BarChartAlignment.spaceAround,
              barGroups: barGroups,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
              ),
              borderData: FlBorderData(show: false),
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
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            days[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final dayLabel = days[groupIndex];
                    final tooltipText = StringBuffer('$dayLabel\n');

                    // Show breakdown by category
                    for (var entry in categoryData.entries) {
                      final val = entry.value[groupIndex];
                      if (val > 0) {
                        tooltipText.writeln('${entry.key}: ${val.toStringAsFixed(2)}h');
                      }
                    }

                    return BarTooltipItem(
                      tooltipText.toString(),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
            swapAnimationDuration: const Duration(milliseconds: 500),
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
        const SizedBox(height: 16),
        // Category legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: categoryData.keys.map((cat) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: categoryColors[cat] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(cat, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Top 10 Apps This Week',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topApps.length,
          itemBuilder: (context, index) {
            final app = topApps[index];
            Widget leadingWidget = const CircleAvatar(
              child: Icon(Icons.apps),
            );

            // Decode base64 icon if available
            if (app['iconBase64'] != null && app['iconBase64'].toString().isNotEmpty) {
              try {
                final bytes = base64Decode(app['iconBase64']);
                leadingWidget = CircleAvatar(
                  backgroundImage: MemoryImage(bytes),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Error handled by catch block
                  },
                );
              } catch (e) {
                // Keep default icon
              }
            }

            final hours = (app['timeInForeground'] as int) / 3600000;

            return ListTile(
              leading: leadingWidget,
              title: Text(
                app['appName'] ?? 'Unknown',
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${hours.toStringAsFixed(1)}h',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text('${hours.toStringAsFixed(2)} hours total'),
            );
          },
        ),
      ],
    );
  }
}