import 'package:flutter/material.dart';

class CategorySummaryCard extends StatelessWidget {
  final String category;
  final double hours;
  const CategorySummaryCard({Key? key, required this.category, required this.hours}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(category);
    final icon = _categoryIcon(category);

    return Card(
      color: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${hours.toStringAsFixed(2)} hrs', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LinearProgressIndicator(
                value: (hours / 10).clamp(0.0, 1.0), // assuming max 10 hrs for scale
                color: color,
                backgroundColor: color.withOpacity(0.3),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Entertainment': return Colors.purple;
      case 'Learning': return Colors.green;
      case 'Communication': return Colors.blue;
      case 'Games': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Entertainment': return Icons.movie;
      case 'Learning': return Icons.school;
      case 'Communication': return Icons.chat;
      case 'Games': return Icons.videogame_asset;
      default: return Icons.apps;
    }
  }
}
