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

class AlertFormWidget extends StatefulWidget {
  final LatLng currentLocation;
  const AlertFormWidget({super.key, required this.currentLocation});

  @override
  State<AlertFormWidget> createState() => _AlertFormWidgetState();
}

class _AlertFormWidgetState extends State<AlertFormWidget> {
  String _selectedType = "Blocked Trail";
  final TextEditingController _desc = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButton<String>(
          value: _selectedType,
          items: [
            "Blocked Trail",
            "Flooded Path",
            "Stray Dog",
            "Scenic View",
            "Stream",
            "Spring"
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _selectedType = v!),
        ),
        TextField(
          controller: _desc,
          decoration: const InputDecoration(labelText: "Optional Description"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              TrailAlert(
                type: _selectedType,
                description: _desc.text,
                location: widget.currentLocation,
                timestamp: DateTime.now(),
              ),
            );
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
