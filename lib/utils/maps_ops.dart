import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// A utility class that provides static methods for map operations
/// This class cannot be instantiated and serves as an interface
class MapsOps {
  // Private constructor to prevent instantiation
  MapsOps._();

  /// Change the active map layer to the specified URL
  ///
  /// The [layerUrl] parameter is the URL template for the tile layer
  static void changeMapLayer(String layerUrl) {
    // Implementation note: This method is minimal since the actual
    // layer change is handled by the MapPage when it updates its state
  }

  /// Center the map to the user's current location
  ///
  /// [mapController] - The controller for the map to be centered
  static Future<void> centerToMyLocation(MapController mapController) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Check if we have permission to access location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Move map to current position
      mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0, // Zoom level
      );
    } catch (e) {
      throw Exception('Error getting current location: $e');
    }
  }

  /// Show the map legend explaining symbols and colors
  ///
  /// [context] - The BuildContext required to show the dialog
  static void showLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Map Legend', style: context.textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(
                  context, Icons.route, Colors.blue, 'Walking Trail'),
              _buildLegendItem(
                  context, Icons.route, Colors.red, 'Difficult Trail'),
              _buildLegendItem(context, Icons.park, Colors.green, 'Park'),
              _buildLegendItem(
                  context, Icons.water, Colors.blue, 'Water Source'),
              _buildLegendItem(
                  context, Icons.landscape, Colors.brown, 'Viewpoint'),
              _buildLegendItem(
                  context, Icons.home_work, Colors.grey, 'Shelter'),
              _buildLegendItem(
                  context, Icons.local_parking, Colors.blueGrey, 'Parking'),
              _buildLegendItem(
                  context, Icons.restaurant, Colors.orange, 'Food'),
              AppConstants.kSizedBoxMedium,
              Text(
                'Map data © OpenStreetMap contributors',
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Helper method to build a legend item
  static Widget _buildLegendItem(
      BuildContext context, IconData icon, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(label, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

  /// Search for a location and center the map on it
  ///
  /// [mapController] - The controller for the map to be centered
  /// [query] - The search query string (location name)
  static Future<void> search(MapController mapController, String query) async {
    if (query.isEmpty) return;

    try {
      // Use Nominatim search API (respecting usage policy)
      final searchQuery = Uri.encodeComponent(query);
      final url =
          'https://nominatim.openstreetmap.org/search?q=$searchQuery&format=json&limit=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Ambulo/1.0'},
      );

      if (response.statusCode == 200) {
        final results = jsonDecode(response.body) as List;
        if (results.isNotEmpty) {
          final location = results.first;
          final lat = double.parse(location['lat']);
          final lon = double.parse(location['lon']);

          mapController.move(LatLng(lat, lon), 14.0);
        } else {
          throw Exception('No results found');
        }
      } else {
        throw Exception('Search failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }
}
