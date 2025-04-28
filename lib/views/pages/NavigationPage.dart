// NavigationPage with styled save/discard dialog
// ignore_for_file: use_build_context_synchronously

import 'package:ambulo/views/pages/CreateTrailPage.dart';
import 'package:ambulo/views/pages/HomePage.dart';
import 'package:ambulo/views/widgets/AlertFormWidget.dart';
import 'package:ambulo/models/trail_alert.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:ambulo/utils/navigation_record_ops.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail.dart';
import 'package:gpx/gpx.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

bool _isSelectingAlertLocation = false;

class NavigationPage extends StatefulWidget {
  final String? trailId;
  final User user;

  const NavigationPage({super.key, this.trailId, required this.user});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final NavigationRecordOps _recordOps = NavigationRecordOps();
  bool _isNavigating = false;
  bool _isGpxBasedTrail =
      false; // Flag to track if we're using a GPX-based trail
  double _distance = 0;
  String _elapsedTime = "00:00:00";
  double _elevationGain = 0;
  double _progress = 0;
  Timer? _timer;

  List<LatLng> _routePoints = [];
  List<LatLng> _walkedPath = []; // Track the actual path walked
  List<Map<String, dynamic>> _waypoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _recordOps.onMetricsUpdated = () {
      setState(() {
        _distance = _recordOps.showNumOfKM();
        _elevationGain = _recordOps.showElevationGain();
        _progress = _recordOps.showProgressPercentage();
        _walkedPath = _recordOps.getCurrentRoute(); // Update walked path
      });
    };

    if (widget.trailId != null) {
      _loadTrailFromFirebase(widget.trailId!);
    } else {
      _isLoading = false; // Do not start navigation automatically
    }
  }

  Future<void> _loadTrailFromFirebase(String trailId) async {
    try {
      final snapshot = await Trail.stream(widget.user.db, trailId).first;
      final data = snapshot.data() as Map<String, dynamic>?;
      final gpxRaw = data?['gpx'] as String?;
      if (gpxRaw == null) throw Exception("Missing GPX data");

      final gpx = GpxReader().fromString(gpxRaw);
      final points = <LatLng>[];
      final pois = <Map<String, dynamic>>[];

      for (var track in gpx.trks) {
        for (var segment in track.trksegs) {
          for (var point in segment.trkpts) {
            if (point.lat != null && point.lon != null) {
              points.add(LatLng(point.lat!, point.lon!));
            }
          }
        }
      }

      for (var poi in gpx.wpts) {
        if (poi.lat != null && poi.lon != null) {
          pois.add({
            'position': LatLng(poi.lat!, poi.lon!),
            'name': poi.name ?? 'POI',
            'description': poi.desc,
          });
        }
      }

      _recordOps.loadTrack(points, pois);

      setState(() {
        _routePoints = points;
        _waypoints = pois;
        _isLoading = false;
        _isGpxBasedTrail = true; // Set to true since we loaded from GPX
      });

      // Do not start navigation automatically
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trail: $e')),
      );
    }
  }

  void _reportAlert() {
    setState(() {
      _isSelectingAlertLocation = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap the map to select alert location'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _handleAlertLocationSelected(LatLng selectedLocation) async {
    setState(() {
      _isSelectingAlertLocation = false;
    });

    final alert = await showDialog<TrailAlert>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Report an Alert"),
        content: SizedBox(
          width: 400, // Set a fixed width
          child: AlertFormWidget(currentLocation: selectedLocation),
        ),
      ),
    );

    if (alert != null) {
      // Add to local display
      setState(() {
        _waypoints.add({
          'position': alert.location,
          'name': alert.type,
          'description': alert.description,
        });
      });

      // Update the original trail in Firebase if we're navigating an existing trail
      if (widget.trailId != null) {
        await Trail.appendWaypoint(widget.user.db, widget.trailId!, alert);
      }
    }
  }

  void _confirmDeleteAlert(LatLng pos) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Alert"),
        content: const Text("Do you want to delete this alert for all users?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _waypoints.removeWhere((w) => w['position'] == pos);
    });

    if (widget.trailId != null) {
      await Trail.removeWaypoint(widget.user.db, widget.trailId!, pos);
    }
  }

  void _startNavigation() {
    setState(() => _isNavigating = true);
    _recordOps.startSession();

    // Start a timer that updates the time display every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isNavigating) {
        setState(() {
          _elapsedTime = _recordOps.showElapsedTime();
        });
      }
    });
  }

  void _stopNavigation() async {
    // Pause the timer without ending the session completely
    _timer?.cancel();
    setState(() => _isNavigating = false);

    final dialogResult = await showDialog<String>(
          context: context,
          barrierDismissible: true, // Allow tapping outside to dismiss
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.hiking, color: Colors.green),
                SizedBox(width: 8),
                Text("Save Hike")
              ],
            ),
            content:
                const Text("Do you want to save this hike to your trails?"),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            actions: [
              Builder(
                builder: (context) {
                  final isAndroid =
                      Theme.of(context).platform == TargetPlatform.android;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isAndroid)
                        IconButton(
                          onPressed: () => Navigator.pop(context, 'discard'),
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          tooltip: "Discard",
                        )
                      else
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context, 'discard'),
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.red),
                          label: const Text("Discard"),
                        ),
                      if (isAndroid)
                        IconButton(
                          onPressed: () => Navigator.pop(context, 'resume'),
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.blue),
                          tooltip: "Resume",
                        )
                      else
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context, 'resume'),
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.blue),
                          label: const Text("Resume"),
                        ),
                      if (isAndroid)
                        IconButton(
                          onPressed: () => Navigator.pop(context, 'save'),
                          icon: const Icon(Icons.save_alt, color: Colors.green),
                          tooltip: "Save",
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context, 'save'),
                          icon: const Icon(Icons.save_alt),
                          label: const Text("Save"),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ) ??
        'resume'; // Default to 'resume' if dismissed by tapping outside

    if (dialogResult == 'resume') {
      // Just restart the timer without resetting the session
      setState(() => _isNavigating = true);
      // Restart timer to continue updating elapsed time
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isNavigating) {
          setState(() {
            _elapsedTime = _recordOps.showElapsedTime();
          });
        }
      });
      return;
    }

    // Only end the session if not resuming
    _recordOps.endSession();

    if (dialogResult != 'save') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false, // Remove all previous routes
      );
      return;
    }

    final session = _recordOps.getSessionData();
    final gpx = Gpx();
    final trk = Trk(name: 'Recorded Hike');
    final trkseg = Trkseg();

    for (final p in session['routePoints'] as List<LatLng>) {
      trkseg.trkpts.add(Wpt(lat: p.latitude, lon: p.longitude));
    }
    trk.trksegs.add(trkseg);
    gpx.trks.add(trk);

    for (final w in session['waypoints'] as List<Map<String, dynamic>>) {
      gpx.wpts.add(Wpt(
        lat: w['position'].latitude,
        lon: w['position'].longitude,
        name: w['name'],
        desc: w['description'],
      ));
    }

    final gpxString = GpxWriter().asString(gpx, pretty: true);

    if (widget.trailId != null) {
      try {
        final snapshot =
            await Trail.stream(widget.user.db, widget.trailId!).first;
        final data = snapshot.data() as Map<String, dynamic>?;
        final gpxRaw = data?['gpx'] as String?;

        if (gpxRaw != null) {
          final originalGpx = GpxReader().fromString(gpxRaw);

          for (final w in session['waypoints'] as List<Map<String, dynamic>>) {
            final alert = TrailAlert(
              type: w['name'],
              description: w['description'],
              location: w['position'],
              timestamp: DateTime.now(),
            );
            originalGpx.wpts.add(alert.toWaypoint());
          }

          final updatedGpx = GpxWriter().asString(originalGpx, pretty: true);
          await Trail.editDetails(
              widget.user.db, widget.trailId!, 'gpx', updatedGpx);
          print("✅ Original trail updated with alerts.");
        }
      } catch (e) {
        print("❌ Failed to update original trail with alerts: $e");
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTrailPage(
          gpxString: gpxString,
          routePoints: session['routePoints'],
          waypoints: session['waypoints'],
          user: widget.user,
          elapsedTime: _elapsedTime, // Pass elapsed time
          distance: _distance, // Pass distance
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3, // MapPage takes 3/4 of the screen
            child: Stack(
              children: [
                MapPage(
                  routePoints: _routePoints,
                  waypoints: _waypoints,
                  shouldAutoCenter: true,
                  triggerRender: true,
                  onTapToAddPoint: _isSelectingAlertLocation
                      ? _handleAlertLocationSelected
                      : null,
                  onAlertTapped: _confirmDeleteAlert,
                  walkedPath: _walkedPath, // Pass the walked path to MapPage
                ),
                if (_isGpxBasedTrail)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: 'report_alert',
                      tooltip: "Report an issue",
                      onPressed: _reportAlert,
                      child: const Icon(Icons.report_problem),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1, // Navigation controls take 1/4 of the screen
            child: Container(
              padding: AppConstants.kPaddingMedium,
              decoration: BoxDecoration(
                color: context.colorScheme.surface.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.kRadiusLarge),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate appropriate sizes based on available height
                  final availableHeight = constraints.maxHeight;
                  // Use smaller spacing for smaller screens
                  final verticalSpacing = availableHeight * 0.03;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: _progress,
                        minHeight: 5, // Slightly larger height
                        backgroundColor: context.colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(
                          context.colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      SizedBox(height: verticalSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMetric(
                              "Distance",
                              "${_distance.toStringAsFixed(2)} km",
                              Icons.straighten),
                          _buildMetric("Time", _elapsedTime, Icons.timer),
                          _buildMetric(
                              "Elevation",
                              "${_elevationGain.toStringAsFixed(0)} m",
                              Icons.terrain),
                        ],
                      ),
                      SizedBox(height: verticalSpacing),
                      AppConstants.kSizedBoxMedium,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAction(
                            _isNavigating
                                ? Icons.stop_circle
                                : Icons.play_arrow,
                            _isNavigating ? "Stop" : "Start",
                            _isNavigating ? _stopNavigation : _startNavigation,
                            availableHeight,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = screenHeight * 0.018; // Larger font size for metric values

    return Column(
      children: [
        Icon(icon, color: context.colorScheme.primary, size: fontSize * 2.0),
        SizedBox(height: fontSize * 0.3),
        Text(value,
            style: context.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: fontSize)),
        Text(label,
            style: context.textTheme.bodySmall
                ?.copyWith(fontSize: fontSize * 0.85)),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback? onPressed,
      double availableHeight) {
    // Scale button based on available height rather than screen height
    final buttonSize =
        availableHeight * 0.25; // Larger button relative to container
    final iconSize = buttonSize * 0.1; // Larger icon
    final fontSize = buttonSize * 0.3; // Larger text

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: buttonSize * 0.5,
          vertical: buttonSize * 0.035,
        ),
        minimumSize:
            Size(buttonSize * 1.2, buttonSize * 0.9), // Control minimum size
        backgroundColor:
            onPressed != null ? context.colorScheme.primary : Colors.grey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize),
          Center(
            child: Text(label, style: TextStyle(fontSize: fontSize)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordOps.dispose();
    super.dispose();
  }
}
