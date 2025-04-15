import 'dart:async';

import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:ambulo/utils/gpx_ops.dart';
import 'package:ambulo/utils/navigation_record_ops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// NavigationPage displays real-time metrics during navigation
/// It shows distance traveled, elapsed time, elevation, and progress
class NavigationPage extends StatefulWidget {
  const NavigationPage({Key? key}) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // Map controller
  final MapController _mapController = MapController();

  // Navigation recording operations handler
  final NavigationRecordOps _recordOps = NavigationRecordOps();

  // Navigation metrics
  double _distance = 0.0;
  String _elapsedTime = "00:00:00";
  double _elevationGain = 0.0;
  double _progressPercentage = 0.0;
  List<LatLng> _routePoints = [];

  // Track if navigation is active
  bool _isNavigating = false;

  // Weather information
  String _weatherInfo = "Loading weather...";

  // Timer for updating UI
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  /// Fetch current weather information
  Future<void> _fetchWeather() async {
    // In a real app, use a weather API here
    setState(() {
      _weatherInfo = "24°C, Partly Cloudy";
    });
  }

  /// Start the navigation recording session
  void _startNavigation() {
    setState(() {
      _isNavigating = true;
    });

    _recordOps.startSession();

    // Set up timer to update UI every second
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = _recordOps.showElapsedTime();
        _distance = _recordOps.showNumOfKM();
        _elevationGain = _recordOps.showElevationGain();
        _progressPercentage = _recordOps.showProgressPercentage();
        _routePoints = _recordOps.getCurrentRoute();
      });
    });
  }

  /// End the navigation recording session
  void _endNavigation() {
    _uiUpdateTimer?.cancel();

    // Get final metrics before ending session
    final finalDistance = _recordOps.showNumOfKM();
    final finalTime = _recordOps.showElapsedTime();
    final finalElevation = _recordOps.showElevationGain();

    _recordOps.endSession();

    setState(() {
      _isNavigating = false;
    });

    // Show summary dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Navigation Summary', style: context.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Distance: ${finalDistance.toStringAsFixed(2)} km'),
            AppConstants.kSizedBoxSmall,
            Text('Duration: $finalTime'),
            AppConstants.kSizedBoxSmall,
            Text('Elevation Gain: ${finalElevation.toStringAsFixed(2)} m'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              GpxOps.export(context, _recordOps.getSessionData());
            },
            child: const Text('Save as GPX'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation', style: context.textTheme.titleLarge),
        actions: [
          // Weather display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(_weatherInfo, style: context.textTheme.bodyMedium),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map area (2/3 of screen)
          Expanded(
            flex: 2,
            child: _buildMapWidget(),
          ),

          // Navigation metrics area (1/3 of screen)
          Expanded(
            flex: 1,
            child: Container(
              padding: AppConstants.kPaddingMedium,
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.kRadiusLarge),
                  topRight: Radius.circular(AppConstants.kRadiusLarge),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildMetricsWidget(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isNavigating ? _endNavigation : _startNavigation,
        backgroundColor:
            _isNavigating ? Colors.red : context.colorScheme.primary,
        label: Text(_isNavigating ? 'Stop' : 'Start'),
        icon: Icon(_isNavigating ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  /// Build the map widget showing the current route
  Widget _buildMapWidget() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(31.7683, 35.2137), // Default to Jerusalem
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ambulo',
        ),
        // Show the recorded route
        PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints,
              strokeWidth: 4.0,
              color: Colors.blue,
              borderColor: Colors.white,
              borderStrokeWidth: 2.0,
            ),
          ],
        ),
        // Show current position marker if navigating
        if (_isNavigating && _routePoints.isNotEmpty)
          MarkerLayer(
            markers: [
              Marker(
                point: _routePoints.last,
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Build the metrics display widget
  Widget _buildMetricsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: _progressPercentage,
          backgroundColor: context.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            context.colorScheme.primary,
          ),
          minHeight: 8,
          borderRadius: BorderRadius.circular(AppConstants.kRadiusSmall),
        ),
        AppConstants.kSizedBoxMedium,

        // Main metrics in a row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricItem(
              icon: Icons.straighten,
              value: '${_distance.toStringAsFixed(2)} km',
              label: 'Distance',
            ),
            _buildMetricItem(
              icon: Icons.timer,
              value: _elapsedTime,
              label: 'Time',
            ),
            _buildMetricItem(
              icon: Icons.terrain,
              value: '${_elevationGain.toStringAsFixed(0)} m',
              label: 'Elevation',
            ),
          ],
        ),

        AppConstants.kSizedBoxMedium,

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.folder_open,
              label: 'Load GPX',
              onPressed: () => GpxOps.loadGpx(context, _recordOps),
            ),
            _buildActionButton(
              icon: Icons.place,
              label: 'Add POI',
              onPressed: _isNavigating ? () => GpxOps.addPOI(context) : null,
            ),
            _buildActionButton(
              icon: Icons.save,
              label: 'Export',
              onPressed: _isNavigating
                  ? () => GpxOps.export(context, _recordOps.getSessionData())
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  /// Build a single metric display item
  Widget _buildMetricItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: context.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Build an action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _recordOps.dispose();
    _mapController.dispose();
    super.dispose();
  }
}
