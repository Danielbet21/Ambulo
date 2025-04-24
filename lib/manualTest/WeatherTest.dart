// ignore_for_file: avoid_print

import 'package:ambulo/services/weather_api.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class WeatherTestsPage extends StatefulWidget {
  const WeatherTestsPage({super.key});

  @override
  State<WeatherTestsPage> createState() => _WeatherTestsPageState();
}

// this is a test page for the weather API
class _WeatherTestsPageState extends State<WeatherTestsPage> {
  double? lat;
  double? lon;
  String? forecastText;

  final presetCities = {
    "Tel Aviv": [32.0853, 34.7818],
    "London": [51.5074, -0.1278],
    "New York": [40.7128, -74.0060],
    "Tokyo": [35.6762, 139.6503],
    "Sydney": [-33.8688, 151.2093],
  };

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        lat = pos.latitude;
        lon = pos.longitude;
      });
      print("📍 Current location: lat=$lat, lon=$lon");
    } catch (e) {
      print("❌ Location error: $e");
    }
  }

  void _setPreset(double latVal, double lonVal) {
    setState(() {
      lat = latVal;
      lon = lonVal;
    });
    print("📍 Preset selected: lat=$lat, lon=$lon");
  }

  Future<void> _fetchForecastText() async {
    if (lat == null || lon == null) return;
    final text = await WeatherService.getTodayForecastText(lat!, lon!);
    setState(() => forecastText = text);
    print("📝 Forecast text: $text");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather Tests")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("🌍 Choose Location:", style: TextStyle(fontSize: 16)),
          Wrap(
            spacing: 8,
            children: presetCities.entries.map((e) {
              return ElevatedButton(
                onPressed: () => _setPreset(e.value[0], e.value[1]),
                child: Text(e.key),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text("📍 Use Current Location"),
          ),
          const Divider(height: 30),
          if (lat != null && lon != null) ...[
            const Text("🌦️ Current Weather", style: TextStyle(fontSize: 18)),
            WeatherService.currentWidget(lat: lat!, lon: lon!),
            const SizedBox(height: 20),
            const Text("📅 Weekly Forecast", style: TextStyle(fontSize: 18)),
            WeatherService.forecastWidget(lat: lat!, lon: lon!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchForecastText,
              child: const Text("Get Forecast Summary Text"),
            ),
            if (forecastText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("📋 $forecastText"),
              ),
          ] else
            const Text("⚠️ Please select or detect a location first."),
        ],
      ),
    );
  }
}
