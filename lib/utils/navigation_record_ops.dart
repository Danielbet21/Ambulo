import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// NavigationRecordOps handles the recording of navigation sessions
/// It tracks metrics like distance, time, and elevation
class NavigationRecordOps {
  // Session timing
  DateTime? _startTime;
  DateTime? _endTime;

  // Route tracking
  List<LatLng> _routePoints = [];
  List<double> _elevations = [];
  List<Map<String, dynamic>> _waypoints = [];

  // Metrics tracking
  double _totalDistance = 0.0;
  double _elevationGain = 0.0;

  // Target metrics (for progress calculation)
  double? _targetDistance;

  // Recording timer
  Timer? _recordingTimer;

  /// Optional callback for notifying UI on metric updates
  VoidCallback? onMetricsUpdated;

  /// Constructor
  NavigationRecordOps();

  /// Start a new recording session
  void startSession() {
    _startTime = DateTime.now();
    _endTime = null;
    _routePoints = [];
    _elevations = [];
    _totalDistance = 0.0;
    _elevationGain = 0.0;

    // Start recording location at regular intervals
    _startLocationTracking();
  }

  /// End the current recording session
  void endSession() {
    _endTime = DateTime.now();
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// Start tracking location at regular intervals
  void _startLocationTracking() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final newPoint = LatLng(position.latitude, position.longitude);

        if (_routePoints.isNotEmpty) {
          final lastPoint = _routePoints.last;
          final segmentDistance = const Distance().as(
            LengthUnit.Kilometer,
            lastPoint,
            newPoint,
          );
          _totalDistance += segmentDistance;
        }

        _routePoints.add(newPoint);
        _elevations.add(position.altitude);

        if (_elevations.length > 1) {
          final elevDiff =
              _elevations.last - _elevations[_elevations.length - 2];
          if (elevDiff > 0) {
            _elevationGain += elevDiff;
          }
        }

        onMetricsUpdated?.call();
      } catch (e) {
        print('Error recording position: $e');
      }
    });
  }

  /// Load an existing track for navigation
  void loadTrack(List<LatLng> routePoints,
      [List<Map<String, dynamic>>? waypoints]) {
    _routePoints = routePoints;

    if (routePoints.length > 1) {
      _targetDistance = 0;
      for (int i = 0; i < routePoints.length - 1; i++) {
        _targetDistance = (_targetDistance ?? 0) +
            const Distance().as(
              LengthUnit.Kilometer,
              routePoints[i],
              routePoints[i + 1],
            );
      }
    }

    if (waypoints != null) {
      _waypoints = waypoints;
    }

    onMetricsUpdated?.call();
  }

  /// Show elapsed time in HH:MM:SS format
  String showElapsedTime() {
    if (_startTime == null) return "00:00:00";

    final now = _endTime ?? DateTime.now();
    final diff = now.difference(_startTime!);

    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return "$h:$m:$s";
  }

  /// Show distance in kilometers
  double showNumOfKM() => _totalDistance;

  /// Show total elevation gain
  double showElevationGain() => _elevationGain;

  /// Show progress percentage
  double showProgressPercentage() {
    if (_targetDistance != null && _targetDistance! > 0) {
      return min(1.0, _totalDistance / _targetDistance!);
    }
    return 0.0;
  }

  /// Get the current route points
  List<LatLng> getCurrentRoute() => _routePoints;

  /// ✅ NEW: Get waypoints
  List<Map<String, dynamic>> getWaypoints() => _waypoints;

  /// Get session data
  Map<String, dynamic> getSessionData() {
    return {
      'startTime': _startTime ?? DateTime.now(),
      'endTime': _endTime ?? DateTime.now(),
      'routePoints': _routePoints,
      'elevations': _elevations,
      'totalDistance': _totalDistance,
      'elevationGain': _elevationGain,
      'waypoints': _waypoints,
    };
  }

  /// Clean up resources
  void dispose() {
    _recordingTimer?.cancel();
  }
}
