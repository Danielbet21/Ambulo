// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:ambulo/utils/maps_ops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ambulo/services/weather_api.dart';

class MapPage extends StatefulWidget {
  final List<LatLng> routePoints;
  final List<Map<String, dynamic>> waypoints;
  final bool triggerRender;
  final bool shouldAutoCenter; // Add this parameter
  final void Function(LatLng)? onTapToAddPoint;

  const MapPage({
    super.key,
    this.routePoints = const [],
    this.waypoints = const [],
    this.triggerRender = false,
    this.shouldAutoCenter = true, // Default to true for backward compatibility
    this.onTapToAddPoint,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final LatLng _defaultPosition = LatLng(31.7683, 35.2137);
  String _currentMapLayer = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  String _weatherInfo = 'Loading weather...';
  bool _isWeatherVisible = true;
  String _currentScale = '1:10000';
  bool _hasInitiallyCentered = false; // Track if we've centered initially

  @override
  void initState() {
    super.initState();
    // Use a shorter delay to initialize the map quickly after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
      _fetchWeather();
    });
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only auto-center if explicitly requested via triggerRender
    if (widget.triggerRender &&
        !oldWidget.triggerRender &&
        widget.shouldAutoCenter) {
      // Add small delay to ensure controller is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _fitToRouteBounds();
          // Force redraw of the map
          setState(() {});
        }
      });
    }
  }

  Future<void> _initializeMap() async {
    try {
      if (widget.routePoints.length > 1 &&
          widget.shouldAutoCenter &&
          !_hasInitiallyCentered) {
        // Add small delay to ensure controller is ready
        await Future.delayed(const Duration(milliseconds: 50));
        _fitToRouteBounds();
        _hasInitiallyCentered =
            true; // Mark that we've done the initial centering
      } else if (widget.routePoints.isEmpty) {
        await MapsOps.centerToMyLocation(_mapController);
      }

      _mapController.mapEventStream.listen((event) {
        if (event is MapEventMove) {
          _updateScale();
        }
      });

      // Force a rebuild after map is initialized
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to access location: $e')),
        );
      }
    }
  }

  void _fitToRouteBounds() {
    if (widget.routePoints.length > 1) {
      try {
        final bounds = LatLngBounds.fromPoints(widget.routePoints);
        _mapController.fitCamera(CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ));

        // Force a rebuild after fitting bounds
        if (mounted && widget.triggerRender) {
          setState(() {});
        }
      } catch (e) {
        // Handle any potential errors during fitting bounds
        print('Error fitting bounds: $e');
      }
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final center = _mapController.camera.center;
      final weatherText = await WeatherService.getTodayForecastText(
        center.latitude,
        center.longitude,
      );
      setState(() {
        _weatherInfo = weatherText ?? 'Unable to fetch weather';
      });
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error fetching weather';
      });
    }
  }

  void _updateScale() {
    setState(() {
      // _currentScale = '1:${scale.round()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultPosition,
              initialZoom: 13.0,
              maxZoom: 18.0,
              minZoom: 3.0,
              interactionOptions:
                  InteractionOptions(flags: InteractiveFlag.all),
              onTap: (tapPosition, latlng) {
                if (widget.onTapToAddPoint != null) {
                  widget.onTapToAddPoint!(latlng);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _currentMapLayer,
                userAgentPackageName: 'com.example.ambulo',
              ),
              if (widget.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.routePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
              if (widget.routePoints.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.routePoints.first,
                      width: 40,
                      height: 40,
                      child: const Tooltip(
                        message: 'Start',
                        child: Icon(Icons.flag, color: Colors.green),
                      ),
                    ),
                    Marker(
                      point: widget.routePoints.last,
                      width: 40,
                      height: 40,
                      child: const Tooltip(
                        message: 'End',
                        child: Icon(Icons.flag, color: Colors.red),
                      ),
                    ),
                    ...widget.waypoints.map((poi) {
                      final String name = poi['name'] ?? '';
                      final isAlert = [
                        'Blocked Trail',
                        'Flooded Path',
                        'Stray Dog',
                        'Scenic View',
                        'Stream',
                        'Spring'
                      ].contains(name);
                      return Marker(
                        point: poi['position'],
                        width: 40,
                        height: 40,
                        child: Tooltip(
                          message: name,
                          child: Icon(
                            isAlert ? Icons.warning_amber : Icons.place,
                            color: isAlert ? Colors.orange : Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'center_btn',
              onPressed: () => MapsOps.centerToMyLocation(_mapController),
              tooltip: 'Center to my location',
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: _buildScaleBar(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _buildWeatherInfo(),
                const SizedBox(width: 8),
                _buildFAB(Icons.layers, _showMapLayersDialog, 'layers_btn',
                    'Change map layer'),
                _buildFAB(Icons.info_outline, () => MapsOps.showLegend(context),
                    'legend_btn', 'Show map legend'),
                _buildFAB(Icons.search, _showSearchDialog, 'search_btn',
                    'Search location'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(
      IconData icon, VoidCallback onTap, String tag, String tooltip) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton(
        mini: true,
        heroTag: tag,
        onPressed: onTap,
        tooltip: tooltip,
        child: Icon(icon),
      ),
    );
  }

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
          Text(_currentScale, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

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
          Text(_weatherInfo, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }

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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final query = _searchController.text;
              if (query.isNotEmpty) {
                MapsOps.search(_mapController, query);
                Navigator.pop(context);
              }
            },
            child: const Text('Search'),
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
