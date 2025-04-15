// trail_card.dart

import 'package:ambulo/models/trail_keys.dart';
import 'package:flutter/material.dart';

class TrailCard extends StatelessWidget {
  final Map<String, dynamic> fullTrailData;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TrailCard({
    super.key,
    required this.fullTrailData,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final details = fullTrailData['trailDetails'] ?? {};
    final List<String> images =
        List<String>.from(fullTrailData['photosURL'] ?? []);
    final hasImage = images.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: hasImage
              ? Image.network(
                  images.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image);
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.landscape, color: Colors.grey),
                ),
        ),
        title: Text(details[TrailKeys.name] ?? "Unnamed Trail"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${details[TrailKeys.region] ?? 'Unknown Region'} · ${details[TrailKeys.distance]?.toStringAsFixed(1) ?? '?'} km"),
            if (details[TrailKeys.difficulty] != null)
              Text("Difficulty: ${details[TrailKeys.difficulty]}",
                  style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
