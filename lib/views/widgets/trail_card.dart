// trail_card.dart

import 'package:ambulo/models/trail_keys.dart';
import 'package:flutter/material.dart';

class TrailCard extends StatelessWidget {
  final Map<String, dynamic> trailDetails;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TrailCard({
    super.key,
    required this.trailDetails,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.landscape, color: Colors.grey),
        ),
        title: Text(trailDetails[TrailKeys.name] ?? "Unnamed Trail"),
        subtitle: Text(
          "${trailDetails[TrailKeys.region] ?? 'Unknown Region'} · ${trailDetails[TrailKeys.distance]?.toStringAsFixed(1) ?? '?'} km",
        ),
        trailing: trailing,
      ),
    );
  }
}
