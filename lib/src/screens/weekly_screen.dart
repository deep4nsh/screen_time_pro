import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usage_provider.dart';
import '../widgets/category_summary_card.dart';
import '../widgets/usage_bar_chart.dart';
import '../widgets/most_used_list.dart';
class WeeklyScreen extends StatelessWidget {
  const WeeklyScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<UsageProvider>(context);


    if (!prov.hasPermission) {
      return Center(
        child: ElevatedButton(
          onPressed: () => prov.requestPermission(),
          child: const Text('Grant Usage Access'),
        ),
      );
    }


    if (prov.loading) return const Center(child: CircularProgressIndicator());


    final total = prov.totalTime(prov.weekly);
    final categories = prov.categorize(prov.weekly);


    return RefreshIndicator(
      onRefresh: prov.refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Average', style: Theme.of(context).textTheme.titleLarge),
                  Text('${total.toStringAsFixed(1)} hrs', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
// Placeholder for percent change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [Text('+20% from last week', style: TextStyle(color: Colors.green))],
              )
            ],
          ),
          const SizedBox(height: 12),
          UsageBarChart(usages: prov.daily, title: "Daily"),
          const SizedBox(height: 16),
          Text('Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.entries.map((e) => CategorySummaryCard(category: e.key, hours: e.value)).toList(),
          ),
          const SizedBox(height: 16),
          Text('Most Used', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          MostUsedList(usages: prov.weekly),
        ],
      ),
    );
  }
}