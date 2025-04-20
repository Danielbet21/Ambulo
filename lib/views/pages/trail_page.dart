// trail_page.dart

import 'package:ambulo/services/weather_api.dart';
import 'package:ambulo/views/pages/EditTrailPage.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:ambulo/views/pages/NavigationPage.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ambulo/models/trail.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:ambulo/helpers/image_helper.dart';

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
  List<String> trailPhotos = [];
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

      final imageHelper = ImageHelpers(dataManager: widget.user.db);
      final photos = await imageHelper.getTrailPhotos(widget.trailId);

      setState(() {
        trailDetails = details;
        trailPhotos = photos;
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
      appBar: AppBar(
        title: Text(trailDetails![TrailKeys.name] ?? 'Trail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Edit Trail',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTrailPage(
                    trailId: widget.trailId,
                    user: widget.user,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (trailPhotos.isNotEmpty)
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trailPhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.network(
                        trailPhotos[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text("No images available"),
            ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            child: routePoints.isEmpty
                ? const Center(child: Text("No route map available"))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Create a key to force rebuild of MapPage when constraints are available
                        final mapKey = GlobalKey();
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: 300,
                          key: mapKey,
                          child: MapPage(
                            routePoints: routePoints,
                            waypoints: const [],
                            // Add triggerRender parameter to force map to render immediately
                            triggerRender: true,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            trailDetails![TrailKeys.description] ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text("5-Day Weather Forecast",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (routePoints.isNotEmpty)
            WeatherService.forecastWidget(
              lat: routePoints.first.latitude,
              lon: routePoints.first.longitude,
            )
          else
            Text("⚠️ Weather forecast unavailable for this trail.",
                style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3,
            children: [
              _infoCard(Icons.map, "Region", trailDetails![TrailKeys.region]),
              _infoCard(Icons.straighten, "Distance",
                  "${trailDetails![TrailKeys.distance]} km"),
              _infoCard(Icons.timer, "Time",
                  "${trailDetails![TrailKeys.estimatedTime]} min"),
              _infoCard(Icons.loop, "Loop",
                  trailDetails![TrailKeys.loop] ? "Yes" : "No"),
              _infoCard(Icons.trending_up, "Difficulty",
                  trailDetails![TrailKeys.difficulty]),
              _infoCard(Icons.group, "Trail Type",
                  trailDetails![TrailKeys.trailType]),
              _infoCard(Icons.terrain, "Surface",
                  trailDetails![TrailKeys.surfaceType]),
              _infoCard(Icons.wb_sunny, "Season",
                  trailDetails![TrailKeys.recommendedSeason]),
              _infoCard(Icons.water, "Water",
                  trailDetails![TrailKeys.hasWaterSections] ? "Yes" : "No"),
              _infoCard(
                  Icons.attach_money,
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

  Widget _infoCard(IconData icon, String label, String? value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(value ?? "-",
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
