import 'package:ambulo/models/trail_keys.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/data/styles/theme_extentions.dart'; // Make sure this is the right path

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
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline),
      ),
      elevation: 2,
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
                    return Icon(Icons.broken_image, color: colorScheme.error);
                  },
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: Icon(Icons.landscape,
                      color: colorScheme.onSurfaceVariant),
                ),
        ),
        title: Text(
          details[TrailKeys.name] ?? "Unnamed Trail",
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${details[TrailKeys.region] ?? 'Unknown Region'} · ${details[TrailKeys.distance]?.toStringAsFixed(1) ?? '?'} km",
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (details[TrailKeys.difficulty] != null)
              Text(
                "Difficulty: ${details[TrailKeys.difficulty]}",
                style:
                    textTheme.bodySmall?.copyWith(color: colorScheme.primary),
              ),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
