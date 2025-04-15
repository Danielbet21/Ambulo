// trail_page.dart

import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:ambulo/views/pages/NavigationPage.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ambulo/models/trail.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';

class TrailPage extends StatefulWidget {
  final String trailId;
  final User user;

  const TrailPage({super.key, required this.trailId, required this.user});

  @override
  State<TrailPage> createState() => _TrailPageState();
}

class _TrailPageState extends State<TrailPage> {
  Map<String, dynamic>? trailDetails;
  List<LatLng> routePoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrailData();
  }

  Future<void> _loadTrailData() async {
    try {
      final snapshot = await Trail.stream(widget.user.db, widget.trailId).first;
      final data = snapshot.data() as Map<String, dynamic>?;

      if (data == null) throw Exception("Trail not found");

      final details = Map<String, dynamic>.from(data['trailDetails'] ?? {});
      final gpxRaw = data['gpx'] as String?;

      if (gpxRaw != null) {
        final gpx = GpxReader().fromString(gpxRaw);
        for (final trk in gpx.trks) {
          for (final seg in trk.trksegs) {
            for (final pt in seg.trkpts) {
              if (pt.lat != null && pt.lon != null) {
                routePoints.add(LatLng(pt.lat!, pt.lon!));
              }
            }
          }
        }
      }

      setState(() {
        trailDetails = details;
        isLoading = false;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load trail.")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(trailDetails![TrailKeys.name] ?? 'Trail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 400,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: routePoints.isEmpty
                ? const Text("No route map available")
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 400,
                      child: MapPage(
                        routePoints: routePoints,
                        waypoints: const [],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            trailDetails![TrailKeys.description] ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _infoRow("Region", trailDetails![TrailKeys.region]),
              _infoRow("Distance (km)",
                  trailDetails![TrailKeys.distance]?.toString()),
              _infoRow("Estimated Time",
                  "${trailDetails![TrailKeys.estimatedTime]} min"),
              _infoRow("Loop", trailDetails![TrailKeys.loop] ? "Yes" : "No"),
              _infoRow("Difficulty", trailDetails![TrailKeys.difficulty]),
              _infoRow("Trail Type", trailDetails![TrailKeys.trailType]),
              _infoRow("Surface", trailDetails![TrailKeys.surfaceType]),
              _infoRow("Season", trailDetails![TrailKeys.recommendedSeason]),
              _infoRow("Water Sections",
                  trailDetails![TrailKeys.hasWaterSections] ? "Yes" : "No"),
              _infoRow(
                  "Payment",
                  trailDetails![TrailKeys.requiresPayment]
                      ? "Required"
                      : "Free"),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationPage(
                  trailId: widget.trailId,
                  user: widget.user,
                ),
              ),
            ),
            icon: const Icon(Icons.directions_walk),
            label: const Text("Start Hike"),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await widget.user.saveTrail(widget.trailId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Trail saved to favorites")),
              );
            },
            icon: const Icon(Icons.bookmark_add),
            label: const Text("Save Trail"),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value ?? "-")),
      ],
    );
  }
}
