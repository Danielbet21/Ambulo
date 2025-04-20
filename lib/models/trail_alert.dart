import 'package:latlong2/latlong.dart';
import 'package:gpx/gpx.dart';
import 'package:flutter/material.dart';

class TrailAlert {
  final String type;
  final String description;
  final LatLng location;
  final DateTime timestamp;

  TrailAlert({
    required this.type,
    required this.description,
    required this.location,
    required this.timestamp,
  });

  Wpt toWaypoint() => Wpt(
        lat: location.latitude,
        lon: location.longitude,
        name: type,
        desc: '$description\nReported at: ${timestamp.toIso8601String()}',
      );

  static TrailAlert fromWaypoint(Wpt wpt) {
    return TrailAlert(
      type: wpt.name ?? "Unknown",
      description: wpt.desc?.split('\n').first ?? "",
      location: LatLng(wpt.lat!, wpt.lon!),
      timestamp: DateTime.tryParse(
              wpt.desc?.split('\n').last.replaceFirst("Reported at: ", "") ??
                  "") ??
          DateTime.now(),
    );
  }
}

