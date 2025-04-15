import 'dart:math';

import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:ambulo/utils/maps_ops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// The main map screen of the application
/// Displays an interactive map with various controls and overlays
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Controller for the map
  final MapController _mapController = MapController();

  // Default map position (can be set to user's last known position)
  final LatLng _currentPosition =
      LatLng(31.7683, 35.2137); // Default to Jerusalem

  // Current map layer URL
  String _currentMapLayer = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Weather information
  String _weatherInfo = 'Loading weather...';
  bool _isWeatherVisible = true;

  // Map scale information
  String _currentScale = '1:10000';

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _fetchWeather();
  }

  /// Initialize the map and request location permissions
  Future<void> _initializeMap() async {
    try {
      // Request location permission and center map to user's location
      await MapsOps.centerToMyLocation(_mapController);
      // Update scale when zoom changes
      _mapController.mapEventStream.listen((event) {
        if (event is MapEventMove) {
          _updateScale();
        }
      });
    } catch (e) {
      // If permission denied or location unavailable, use default position
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to access location: $e')),
      );
    }
  }

  /// Fetch weather data for the current map position
  Future<void> _fetchWeather() async {
    // In a real app, use a weather API here
    setState(() {
      _weatherInfo = '24°C, Partly Cloudy';
    });
  }

  /// Update the scale bar based on current zoom level
  void _updateScale() {
    // TODO FIXME: Calculate scale based on zoom level
    print("Fixme: _updateScale() called");
    // Calculate approximate scale based on zoom level
    // double zoom = _mapController.center.zoom; // Use center.zoom to get the current zoom level
    // final scale = 591657550.5 / pow(2, zoom);
    setState(() {
      // _currentScale = '1:${scale.round()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map', style: context.textTheme.titleLarge),
        actions: [
          // Weather display toggle
          IconButton(
            icon: const Icon(Icons.wb_sunny),
            onPressed: () {
              setState(() {
                _isWeatherVisible = !_isWeatherVisible;
              });
            },
            tooltip: 'Toggle weather information',
          ),
          // Map layers button
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => _showMapLayersDialog(),
            tooltip: 'Change map layer',
          ),
          // Map legend button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => MapsOps.showLegend(context),
            tooltip: 'Show map legend',
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Search location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main map widget
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentPosition, // Changed from 'center' to 'initialCenter'
              initialZoom: 13.0,
              maxZoom: 18.0,
              minZoom: 3.0,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Base map tile layer
              TileLayer(
                urlTemplate: _currentMapLayer,
                userAgentPackageName: 'com.example.ambulo',
              ),
              // Additional map elements would go here
              // (markers, polylines, etc.)
            ],
          ),

          // Scale bar overlay
          Positioned(
            bottom: 16,
            left: 16,
            child: _buildScaleBar(),
          ),

          // Weather information overlay
          if (_isWeatherVisible)
            Positioned(
              top: 16,
              right: 16,
              child: _buildWeatherInfo(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => MapsOps.centerToMyLocation(_mapController),
        tooltip: 'Center to my location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  /// Build the scale bar widget
  Widget _buildScaleBar() {
    return Container(
      padding: AppConstants.kPaddingSmall,
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusMedium),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.straighten, size: 18),
          const SizedBox(width: 4),
          Text(
            _currentScale,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build the weather information widget
  Widget _buildWeatherInfo() {
    return Container(
      padding: AppConstants.kPaddingSmall,
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppConstants.kRadiusMedium),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_sunny, size: 18),
          const SizedBox(width: 4),
          Text(
            _weatherInfo,
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Show dialog to change map layer
  void _showMapLayersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Map Layer', style: context.textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLayerOption(
                  'Standard', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              _buildLayerOption('Hiking',
                  'https://israelhiking.osm.org.il/Tiles/{z}/{x}/{y}.png'),
              _buildLayerOption('Satellite',
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'),
              _buildLayerOption('Topographic',
                  'https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png'),
              _buildLayerOption('Outdoors',
                  'https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png'),
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

  /// Build a single layer option for the layer selection dialog
  Widget _buildLayerOption(String name, String url) {
    return ListTile(
      title: Text(name),
      selected: _currentMapLayer == url,
      onTap: () {
        MapsOps.changeMapLayer(url);
        setState(() {
          _currentMapLayer = url;
        });
        Navigator.pop(context);
      },
    );
  }

  /// Show search dialog to find locations
  void _showSearchDialog() {
    final TextEditingController _searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Location', style: context.textTheme.titleLarge),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter location name',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.kRadiusSmall),
            ),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              MapsOps.search(_mapController, value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final query = _searchController.text;
              if (query.isNotEmpty) {
                MapsOps.search(_mapController, query);
                Navigator.pop(context);
              }
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
