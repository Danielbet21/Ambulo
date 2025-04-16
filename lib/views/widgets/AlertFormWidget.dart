import 'package:ambulo/models/AlertTypes.dart';
import 'package:ambulo/models/trail_alert.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AlertFormWidget extends StatelessWidget {
  final LatLng currentLocation;

  const AlertFormWidget({super.key, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of columns based on screen width
        int crossAxisCount = (constraints.maxWidth / 150).floor().clamp(2, 4);

        return Container(
          color: Colors
              .white, // Set a background color to avoid transparency issues
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: AlertTypes.all.map((alert) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: alert['color'],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    TrailAlert(
                      type: alert['type'],
                      description: '',
                      location: currentLocation,
                      timestamp: DateTime.now(),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(alert['icon'], size: 32, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      alert['type'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
