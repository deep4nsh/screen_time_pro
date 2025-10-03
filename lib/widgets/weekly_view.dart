import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/usage_service.dart';


class WeeklyView extends StatelessWidget {
  const WeeklyView({super.key});


  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UsageService>(context);
    if (!svc.initialized) return const Center(child: CircularProgressIndicator());


// For demo, show 7-day bars by aggregating dailyBuckets per day
    final days = svc.dailyBuckets; // simplification: production should use properly aggregated 7-day data


    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Week Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barGroups: days.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.byApp.values.fold<double>(0, (p, d) => p + d.inMilliseconds / 1000.0))])).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Daily average & % change', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
// Implement list of per-day averages and % change
        ...List.generate(7, (i) => ListTile(title: Text('Day ${i + 1}'), subtitle: Text('Avg: 1.2 hrs, Δ: +5%'))),
      ],
    );
  }
}