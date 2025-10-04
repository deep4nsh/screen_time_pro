import 'package:flutter/material.dart';

class CategorySummaryCard extends StatelessWidget {
  final String category;
  final double hours;
  const CategorySummaryCard({Key? key, required this.category, required this.hours}) : super(key: key);

  Color _categoryColor() {
    switch (category) {
      case 'Entertainment':
        return Colors.redAccent;
      case 'Games':
        return Colors.orangeAccent;
      case 'Communication':
        return Colors.blueAccent;
      case 'Learning':
        return Colors.greenAccent;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon() {
    switch (category) {
      case 'Entertainment':
        return Icons.movie;
      case 'Games':
        return Icons.videogame_asset;
      case 'Communication':
        return Icons.chat_bubble;
      case 'Learning':
        return Icons.school;
      case 'Other':
        return Icons.apps;
      default:
        return Icons.apps;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();
    return Card(
      color: color.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(_categoryIcon(), color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hours.toStringAsFixed(2)} hrs',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: (hours / 10).clamp(0.0, 1.0),
                color: color,
                backgroundColor: color.withOpacity(0.25),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          ],
        ),
      ),
    );
  }
}