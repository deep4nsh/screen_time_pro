import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/app_usage.dart';

class MostUsedList extends StatelessWidget {
  final List<AppUsage> usages;
  const MostUsedList({Key? key, required this.usages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort by usage time (highest first) and take top 10
    final sortedUsages = List<AppUsage>.from(usages)
      ..sort((a, b) => b.timeHours.compareTo(a.timeHours));
    final list = sortedUsages.length > 10 ? sortedUsages.sublist(0, 10) : sortedUsages;

    if (list.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No usage data available'),
          ),
        ),
      );
    }

    // Get max time for progress bar calculation
    final maxTime = list.isNotEmpty && list.first.timeHours > 0
        ? list.first.timeHours
        : 1.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final app = list[index];
          Widget leading;

          if (app.iconBase64.isNotEmpty) {
            try {
              Uint8List bytes = base64Decode(app.iconBase64);
              leading = CircleAvatar(
                backgroundImage: MemoryImage(bytes),
                onBackgroundImageError: (exception, stackTrace) {
                  // Fallback handled by catch block
                },
              );
            } catch (e) {
              leading = CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
          } else {
            leading = CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          return ListTile(
            leading: leading,
            title: Text(app.appName, overflow: TextOverflow.ellipsis),
            subtitle: Text('${app.timeHours.toStringAsFixed(2)} hrs'),
            trailing: SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                value: maxTime > 0
                    ? (app.timeHours / maxTime).clamp(0.0, 1.0)
                    : 0.0,
                color: Colors.blueAccent,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }
}