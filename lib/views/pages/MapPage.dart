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

  const MapPage({
    super.key,
    this.routePoints = const [],
    this.waypoints = const [],
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final LatLng _currentPosition = LatLng(31.7683, 35.2137);
  String _currentMapLayer = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  String _weatherInfo = 'Loading weather...';
  bool _isWeatherVisible = true;
  String _currentScale = '1:10000';

  @override
  void initState() {
    super.initState();
    _initializeMap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeather();
    });
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routePoints.length > 1) {
      final bounds = LatLngBounds.fromPoints(widget.routePoints);
      _mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ));
    }
  }

  Future<void> _initializeMap() async {
    try {
      await MapsOps.centerToMyLocation(_mapController);
      _mapController.mapEventStream.listen((event) {
        if (event is MapEventMove) {
          _updateScale();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to access location: $e')),
      );
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
      appBar: AppBar(
        title: Text('Map', style: context.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.wb_sunny),
            onPressed: () {
              setState(() {
                _isWeatherVisible = !_isWeatherVisible;
              });
            },
            tooltip: 'Toggle weather information',
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => _showMapLayersDialog(),
            tooltip: 'Change map layer',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => MapsOps.showLegend(context),
            tooltip: 'Show map legend',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Search location',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 13.0,
              maxZoom: 18.0,
              minZoom: 3.0,
              interactionOptions:
                  InteractionOptions(flags: InteractiveFlag.all),
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
              if (widget.waypoints.isNotEmpty)
                MarkerLayer(
                  markers: widget.waypoints.map((poi) {
                    return Marker(
                      point: poi['position'],
                      width: 40,
                      height: 40,
                      child: Tooltip(
                        message: poi['name'] ?? '',
                        child: const Icon(Icons.place, color: Colors.red),
                      ),
                    );
                  }).toList(),
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
          if (_isWeatherVisible)
            Positioned(
              top: 16,
              right: 16,
              child: _buildWeatherInfo(),
            ),
        ],
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
