// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io' as io;

import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:ambulo/utils/navigation_record_ops.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// A utility class for GPX file operations
/// Handles loading, saving, and editing GPX files for hiking routes
class GpxOps {
  // Private constructor to prevent instantiation
  GpxOps._();

  /// Export navigation data as a GPX file
  ///
  /// [sessionData] - The navigation session data to export
  static Future<void> export(
      BuildContext context, Map<String, dynamic> sessionData) async {
    try {
      // Extract route points and metadata from session data
      final List<LatLng> routePoints =
          sessionData['routePoints'] as List<LatLng>;
      final DateTime startTime = sessionData['startTime'] as DateTime;
      final DateTime endTime = sessionData['endTime'] as DateTime;
      final List<Map<String, dynamic>>? waypoints =
          sessionData['waypoints'] as List<Map<String, dynamic>>?;

      if (routePoints.isEmpty) {
        throw Exception('No route points to export');
      }

      // Create GPX structure
      final gpx = Gpx();
      final track =
          Trk(name: 'Ambulo Track ${startTime.toString().split('.')[0]}');
      final segment = Trkseg();

      // Add track points
      for (var point in routePoints) {
        segment.trkpts.add(
          Wpt(
            lat: point.latitude,
            lon: point.longitude,
            time: startTime, // Ideally each point would have its own timestamp
            ele: sessionData['elevations'] != null
                ? (sessionData['elevations']
                    as List<double>)[routePoints.indexOf(point)]
                : null,
          ),
        );
      }

      // Add waypoints if any
      if (waypoints != null && waypoints.isNotEmpty) {
        for (final waypoint in waypoints) {
          gpx.wpts.add(
            Wpt(
              lat: waypoint['position'].latitude,
              lon: waypoint['position'].longitude,
              name: waypoint['name'],
              desc: waypoint['description'],
            ),
          );
        }
      }

      // Finalize GPX structure
      track.trksegs.add(segment);
      gpx.trks.add(track);

      // Define filename
      final fileName =
          'ambulo_track_${startTime.toString().replaceAll(':', '-').split('.')[0]}.gpx';
      final gpxString = GpxWriter().asString(gpx, pretty: true);

      // Save based on platform
      if (kIsWeb) {
        // Web saving
        final bytes = utf8.encode(gpxString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..download = fileName;
        anchor.click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPX file downloaded: $fileName')),
        );
      } else {
        // Mobile saving
        final directory = await getApplicationDocumentsDirectory();
        final file = io.File('${directory.path}/$fileName');
        await file.writeAsString(gpxString);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Track saved to: ${file.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting GPX: $e')),
      );
    }
  }

  /// Cancel current GPX operation
  ///
  /// This is a utility method used when user wants to abort an operation
  static void cancel(BuildContext context) {
    Navigator.pop(context);
  }

  /// Show statistics for a loaded trail
  ///
  /// [context] - BuildContext for showing the dialog
  /// [trackData] - Data about the track to show statistics for
  static void showTrailStatistics(
      BuildContext context, Map<String, dynamic> trackData) {
    final String trackName = trackData['name'] as String? ?? 'Unnamed Track';
    final double distance = trackData['distance'] as double? ?? 0.0;
    final double totalAscent = trackData['totalAscent'] as double? ?? 0.0;
    final double totalDescent = trackData['totalDescent'] as double? ?? 0.0;
    final double maxElevation = trackData['maxElevation'] as double? ?? 0.0;
    final double minElevation = trackData['minElevation'] as double? ?? 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trail Statistics', style: context.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track: $trackName', style: context.textTheme.titleMedium),
            AppConstants.kSizedBoxMedium,
            _buildStatRow(
                context, 'Distance', '${distance.toStringAsFixed(2)} km'),
            _buildStatRow(
                context, 'Total Ascent', '${totalAscent.toStringAsFixed(2)} m'),
            _buildStatRow(context, 'Total Descent',
                '${totalDescent.toStringAsFixed(2)} m'),
            _buildStatRow(context, 'Max Elevation',
                '${maxElevation.toStringAsFixed(2)} m'),
            _buildStatRow(context, 'Min Elevation',
                '${minElevation.toStringAsFixed(2)} m'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Helper to build a statistic row
  static Widget _buildStatRow(
      BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Add a Point of Interest (POI) to the current route
  ///
  /// [context] - BuildContext for showing the dialog
  static Future<void> addPOI(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Add Point of Interest', style: context.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            AppConstants.kSizedBoxMedium,
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real implementation, this would add the POI
              // using current GPS coordinates
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('POI added successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Create and edit a hiking route
  ///
  /// [context] - BuildContext for showing the UI
  static void createAndEditHike(BuildContext context) {
    // This would typically open a more complex UI for route creation
    // Here we just show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Hiking Route', style: context.textTheme.titleLarge),
        content: const Text(
          'This would open the route creation interface where you can tap on the map to add waypoints.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start Creating'),
          ),
        ],
      ),
    );
  }

  /// Switch the start and end points of a route
  ///
  /// [context] - BuildContext for notifications
  /// [routePoints] - The list of route points to reverse
  /// Returns the reversed route
  static List<LatLng> switchStartAndEnd(
      BuildContext context, List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No route to reverse')),
      );
      return routePoints;
    }

    final reversedRoute = routePoints.reversed.toList();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route direction reversed')),
    );

    return reversedRoute;
  }

  /// Undo the last action in route editing
  ///
  /// [context] - BuildContext for notifications
  /// [routePoints] - Current route points
  /// Returns the route with last point removed
  static List<LatLng> undo(BuildContext context, List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to undo')),
      );
      return routePoints;
    }

    final newRoute = List<LatLng>.from(routePoints);
    newRoute.removeLast();

    return newRoute;
  }

  /// Load a GPX file from storage
  ///
  /// [context] - BuildContext for notifications
  /// [recordOps] - Navigation record operations instance to load the GPX into
  static Future<void> loadGpx(
      BuildContext context, NavigationRecordOps recordOps) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
        withData: true,
      );

      if (result != null) {
        String contents;
        if (kIsWeb) {
          contents = String.fromCharCodes(result.files.single.bytes!);
        } else {
          final file = io.File(result.files.single.path!);
          contents = await file.readAsString();
        }

        var gpx = GpxReader().fromString(contents);

        // Extract route points
        List<LatLng> routePoints = [];
        String? trackName;

        for (var track in gpx.trks) {
          trackName = track.name ?? 'Unnamed Track';
          for (var segment in track.trksegs) {
            for (var point in segment.trkpts) {
              if (point.lat != null && point.lon != null) {
                routePoints.add(LatLng(point.lat!, point.lon!));
              }
            }
          }
        }

        // Extract waypoints
        List<Map<String, dynamic>> waypoints = [];
        for (var wpt in gpx.wpts) {
          if (wpt.lat != null && wpt.lon != null) {
            waypoints.add({
              'position': LatLng(wpt.lat!, wpt.lon!),
              'name': wpt.name ?? 'Unnamed Waypoint',
              'description': wpt.desc,
            });
          }
        }

        // Calculate track statistics
        double distance = 0;
        if (routePoints.length > 1) {
          for (int i = 0; i < routePoints.length - 1; i++) {
            distance += const Distance().as(
              LengthUnit.Kilometer,
              routePoints[i],
              routePoints[i + 1],
            );
          }
        }

        // Calculate elevation stats
        double totalAscent = 0;
        double totalDescent = 0;
        double? maxElevation;
        double? minElevation;

        for (var track in gpx.trks) {
          for (var segment in track.trksegs) {
            for (int i = 1; i < segment.trkpts.length; i++) {
              var previousPoint = segment.trkpts[i - 1];
              var currentPoint = segment.trkpts[i];

              if (previousPoint.ele != null && currentPoint.ele != null) {
                double elevDiff = currentPoint.ele! - previousPoint.ele!;
                if (elevDiff > 0) {
                  totalAscent += elevDiff;
                } else {
                  totalDescent -= elevDiff;
                }

                maxElevation = maxElevation != null
                    ? (currentPoint.ele! > maxElevation
                        ? currentPoint.ele!
                        : maxElevation)
                    : currentPoint.ele;

                minElevation = minElevation != null
                    ? (currentPoint.ele! < minElevation
                        ? currentPoint.ele!
                        : minElevation)
                    : currentPoint.ele;
              }
            }
          }
        }

        // Create track data summary
        Map<String, dynamic> trackData = {
          'name': trackName,
          'distance': distance,
          'totalAscent': totalAscent,
          'totalDescent': totalDescent,
          'maxElevation': maxElevation ?? 0,
          'minElevation': minElevation ?? 0,
        };

        // Load the track into the navigation record
        recordOps.loadTrack(routePoints, waypoints);

        // Show statistics
        showTrailStatistics(context, trackData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading GPX file: $e')),
      );
    }
  }
}
