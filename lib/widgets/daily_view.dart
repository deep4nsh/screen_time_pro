import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/usage_service.dart';


class DailyView extends StatelessWidget {
  const DailyView({super.key});


  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UsageService>(context);


    if (!svc.initialized) {
      return const Center(child: CircularProgressIndicator());
    }


// build bar groups from svc.dailyBuckets
    return RefreshIndicator(
      onRefresh: () => svc.fetchUsage(updateOnly: true),
      child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          const Text('Today - Time slots', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            barGroups: svc.dailyBuckets.asMap().entries.map((entry) {
              final idx = entry.key;
              final bucket = entry.value;
// stacked bars per category -> build stack with sums
              final totalMs = bucket.byCategory.values.fold<int>(0, (p, e) => p + e.inMilliseconds);
              double totalSec = totalMs / 1000.0;
// For demo, make single bar height = totalSec
              return BarChartGroupData(x: idx, barRods: [BarChartRodData(toY: totalSec)]);
            }).toList(),
          ),
        ),
      ),


      const SizedBox(height: 20),


      const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
            ...svc.categoryTotals.entries.map((e) => _CategoryCard(title: e.key, duration: e.value)).toList(),


            const SizedBox(height: 20),
            const Text('Most Used', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...svc.mostUsed.map((m) => _MostUsedRow(entry: m)).toList(),
          ],
      ),
    );
  }
}


class _CategoryCard extends StatelessWidget {
  final String title;
  final Duration duration;
  const _CategoryCard({required this.title, required this.duration});


  @override
  Widget build(BuildContext context) {
    final totalHours = duration.inMinutes / 60.0;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text('${totalHours.toStringAsFixed(2)} hours'),
        trailing: SizedBox(
          width: 120,
          child: LinearProgressIndicator(value: (totalHours / 12).clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}


class _MostUsedRow extends StatelessWidget {
  final dynamic entry;
  const _MostUsedRow({required this.entry});


  @override
  Widget build(BuildContext context) {
    final dur = (entry.totalTime as Duration);
    final mins = dur.inMinutes;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(entry.appName ?? entry.packageName),
      subtitle: Text('${(mins / 60).toStringAsFixed(2)} hrs'),
      trailing: Text(entry.category),
    );
  }
}