import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/app_usage.dart';

class MostUsedList extends StatelessWidget {
  final List<AppUsage> usages;
  const MostUsedList({Key? key, required this.usages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (usages.isEmpty) return const SizedBox();

    // Sort descending by usage time and take top 10
    final list = List<AppUsage>.from(usages)
      ..sort((a, b) => b.timeHours.compareTo(a.timeHours));
    final topList = list.length > 10 ? list.sublist(0, 10) : list;

    final maxTime = topList.first.timeHours;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: topList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final a = topList[index];

          // Decode icon from Base64 if available
          Widget leadingWidget;
          if (a.iconBase64.isNotEmpty) {
            leadingWidget = CircleAvatar(
              backgroundImage: MemoryImage(base64Decode(a.iconBase64)),
            );
          } else {
            leadingWidget = CircleAvatar(child: Text('${index + 1}'));
          }

          return ListTile(
            leading: leadingWidget,
            title: Text(a.appName), // Show real app name
            subtitle: Text('${a.timeHours.toStringAsFixed(2)} hrs'),
            trailing: SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                value: (a.timeHours / maxTime).clamp(0.0, 1.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
