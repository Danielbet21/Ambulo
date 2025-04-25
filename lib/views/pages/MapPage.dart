// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:ambulo/models/AlertTypes.dart';
import 'package:ambulo/utils/maps_ops.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ambulo/services/weather_api.dart';

class MapPage extends StatefulWidget {
  final List<LatLng> routePoints;
  final List<Map<String, dynamic>> waypoints;
  final bool triggerRender;
  final bool shouldAutoCenter;
  final void Function(LatLng)? onTapToAddPoint;
  final void Function(LatLng)? onAlertTapped;
  final List<LatLng> walkedPath;

  const MapPage({
    super.key,
    this.routePoints = const [],
    this.waypoints = const [],
    this.triggerRender = false,
    this.shouldAutoCenter = true,
    this.onTapToAddPoint,
    this.onAlertTapped,
    this.walkedPath = const [],
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final LatLng _defaultPosition = LatLng(31.7683, 35.2137);
  String _currentMapLayer = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  String _weatherInfo = 'Loading weather...';
  bool _hasInitiallyCentered = false;
  bool _showMapTools = false;
  LatLng? _myLocation;
  StreamSubscription<Position>? _locationStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
      _fetchWeather();
    });
    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerRender && !oldWidget.triggerRender && widget.shouldAutoCenter) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _fitToRouteBounds();
          setState(() {});
        }
      });
    }
  }

  Future<void> _initializeMap() async {
    try {
      if (widget.routePoints.length > 1 && widget.shouldAutoCenter && !_hasInitiallyCentered) {
        await Future.delayed(const Duration(milliseconds: 50));
        _fitToRouteBounds();
        _hasInitiallyCentered = true;
      } else if (widget.routePoints.isEmpty) {
        await MapsOps.centerToMyLocation(_mapController);
      }
      _mapController.mapEventStream.listen((event) {
        if (event is MapEventMove) {
          setState(() {});
        }
      });
      if (mounted) setState(() {});
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
        if (mounted && widget.triggerRender) setState(() {});
      } catch (e) {
        print('Error fitting bounds: $e');
      }
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final center = _mapController.camera.center;
      final weatherText = await WeatherService.getTodayForecastText(center.latitude, center.longitude);
      setState(() {
        _weatherInfo = weatherText ?? 'Unable to fetch weather';
      });
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error fetching weather';
      });
    }
  }

  Widget _buildSearchBar() {
    final TextEditingController _searchController = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withOpacity(0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search location',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            MapsOps.search(_mapController, value);
          }
        },
      ),
    );
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
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
              onTap: (tapPosition, latlng) {
                widget.onTapToAddPoint?.call(latlng);
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
                    Polyline(points: widget.routePoints, strokeWidth: 4, color: Colors.blue),
                  ],
                ),
              if (widget.walkedPath.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: widget.walkedPath, color: Colors.red, strokeWidth: 4.0),
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
                      final LatLng position = poi['position'];
                      final alertType = AlertTypes.all.firstWhere(
                        (item) => item['type'] == name,
                        orElse: () => {},
                      );
                      final isAlert = alertType.isNotEmpty;
                      final icon = alertType['icon'] ?? Icons.place;
                      final color = alertType['color'] ?? Colors.red;
                      return Marker(
                        point: position,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            if (isAlert) widget.onAlertTapped?.call(position);
                          },
                          child: Tooltip(
                            message: name,
                            child: Icon(icon, color: color),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.navigation, color: Colors.green, size: 36),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(top: 90, left: 16, child: _buildWeatherInfo()),
          Positioned(top: 36, left: 10, right: 16, child: _buildSearchBar()),
          Positioned(bottom: 16, left: 16, child: _buildScaleBar()),
          Positioned(
            top: 85,
            right: 16,
            child: FloatingActionButton(
              // backgroundColor: const Color.fromARGB(255, 157, 210, 158),
              backgroundColor: context.colorScheme.surface,
              mini: true,
              heroTag: 'toggle_map_tools',
              onPressed: () => setState(() => _showMapTools = !_showMapTools),
              tooltip: 'Toggle Map Tools',
              child: Icon(_showMapTools ? Icons.close : Icons.menu),
            ),
          ),
          if (_showMapTools) ...[
            Positioned(
              top: 150,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    backgroundColor: context.colorScheme.surface,
                    mini: true,
                    heroTag: 'layers_btn',
                    tooltip: 'Change Map Layer',
                    onPressed: _showMapLayersDialog,
                    child: const Icon(Icons.layers),
                  ),
                  const SizedBox(height: 12),
                FloatingActionButton(
                  mini: true,
                  heroTag: 'rotate_btn',
                  onPressed: () {
                    _mapController.rotate(0); // Reset rotation to 0 degrees
                  },
                  tooltip: 'Reset map rotation',
                  child: const Icon(Icons.explore),
                ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    backgroundColor: context.colorScheme.surface,
                    mini: true,
                    heroTag: 'legend_btn',
                    tooltip: 'Show Map Legend',
                    onPressed: () => MapsOps.showLegend(context),
                    child: const Icon(Icons.info_outline),
                  ),
                ],  
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              heroTag: 'center_btn',
              onPressed: () => MapsOps.centerToMyLocation(_mapController),
              tooltip: 'Center to my location',
              child: const Icon(Icons.my_location),
            ),
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildScaleBar() => Container(
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
        Text('1:10000', style: context.textTheme.bodyMedium),
      ],
    ),
  );

  Widget _buildWeatherInfo() => Container(
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

  void _showMapLayersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Map Layer', style: context.textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLayerOption('Standard', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
              _buildLayerOption('Hiking', 'https://israelhiking.osm.org.il/Tiles/{z}/{x}/{y}.png'),
              _buildLayerOption('Satellite', 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'),
              _buildLayerOption('Topographic', 'https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png'),
              _buildLayerOption('Outdoors', 'https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildLayerOption(String name, String url) => ListTile(
    title: Text(name),
    selected: _currentMapLayer == url,
    onTap: () {
      MapsOps.changeMapLayer(url);
      setState(() => _currentMapLayer = url);
      Navigator.pop(context);
    },
  );

  @override
  void dispose() {
    _locationStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}