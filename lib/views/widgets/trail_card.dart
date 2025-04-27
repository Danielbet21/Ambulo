import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';

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

    return Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Card(
                margin: EdgeInsets.zero, // No margin inside card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                clipBehavior: Clip.antiAlias,
                elevation: 0, // Remove shadow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- IMAGE ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasImage
                            ? Image.network(
                                images.first,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 160,
                                    alignment: Alignment.center,
                                    color: colorScheme.surfaceVariant,
                                    child: Icon(Icons.broken_image,
                                        color: colorScheme.error, size: 40),
                                  );
                                },
                              )
                            : Container(
                                height: 190,
                                alignment: Alignment.center,
                                color: colorScheme.surfaceVariant,
                                child: Icon(Icons.landscape,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 40),
                              ),
                      ),
                    ),
                    // --- INFO AREA ---
                    Container(
                      width: double.maxFinite,
                      color: colorScheme.surface, // White or light background
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details[TrailKeys.name] ?? "Unnamed Trail",
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _iconWithText(
                                  Icons.place,
                                  details[TrailKeys.region] ?? 'Unknown Region',
                                  context),
                              _iconWithText(
                                  Icons.route,
                                  "${details[TrailKeys.distance]?.toStringAsFixed(1) ?? '?'} km",
                                  context),
                              _iconWithText(
                                  Icons.show_chart_rounded,
                                  "${details[TrailKeys.difficulty] ?? '?'}",
                                  context),
                              _iconWithText(
                                  Icons.accessibility_new_outlined,
                                  "${details[TrailKeys.trailType] ?? '?'}",
                                  context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- TRAILING WIDGET (e.g., Trash Icon) ---
            if (trailing != null)
              Positioned(
                top: 8,
                right: 8,
                child: trailing!,
              ),
          ],
        ),
        const Divider(height: 1, thickness: 1), // HR LINE between cards
      ],
    );
  }

  Widget _iconWithText(IconData icon, String text, BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
