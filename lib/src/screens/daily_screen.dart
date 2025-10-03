import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usage_provider.dart';
import '../widgets/usage_bar_chart.dart';
import '../widgets/most_used_list.dart';
import '../widgets/category_summary_card.dart';

class DailyScreen extends StatelessWidget {
  const DailyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<UsageProvider>(context);

    // Permission not granted
    if (!prov.hasPermission) {
      return Center(
        child: ElevatedButton(
          onPressed: () => prov.requestPermission(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Grant Usage Access',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // Loading
    if (prov.loading) return const Center(child: CircularProgressIndicator());

    // Get total time and categorized usage
    final total = prov.totalTime(prov.daily);
    final categories = prov.categorize(prov.daily);

    return RefreshIndicator(
      onRefresh: prov.refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Daily Usage Chart
          Text(
            'Daily App Usage',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          UsageBarChart(usages: prov.daily, title: "Daily"),
          const SizedBox(height: 24),

          // Category Summary
          Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.entries
                .map(
                  (e) => CategorySummaryCard(category: e.key, hours: e.value),
            )
                .toList(),
          ),
          const SizedBox(height: 24),

          // Most Used Apps List
          Text(
            'Most Used Apps',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          MostUsedList(usages: prov.daily),
        ],
      ),
    );
  }
}
