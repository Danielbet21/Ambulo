import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ====================================================================
// YOUR API KEY HERE
const String _apiKey = '38fd749a09e0266464c859addd4b37fe';
// ====================================================================

/// Core data structure to hold parsed weather info
class WeatherData {
  final double temp;
  final String description;
  final String iconUrl;
  final String time;

  WeatherData({
    required this.temp,
    required this.description,
    required this.iconUrl,
    required this.time,
  });
}

class WeatherService {
  // ========== API ==========

  static Future<Map<String, dynamic>?> _fetch(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Weather fetch error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception while fetching weather: $e");
    }
    return null;
  }

  /// Get current weather raw map
  static Future<Map<String, dynamic>?> getCurrentRaw(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=en';
    return await _fetch(url);
  }

  /// Get daily forecast (5 days ahead)
  static Future<List<Map<String, dynamic>>> getForecastRaw(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=en';
    final data = await _fetch(url);
    final List<dynamic> all = data?['list'] ?? [];
    final List<Map<String, dynamic>> daily = [];
    for (int i = 0; i < all.length; i += 8) {
      daily.add(Map<String, dynamic>.from(all[i]));
    }
    return daily;
  }

  // ========== PARSERS ==========

  /// Convert raw forecast map to WeatherData
  static WeatherData fromForecast(Map<String, dynamic> item) {
    return WeatherData(
      temp: item['main']['temp'].toDouble(),
      description: item['weather'][0]['description'],
      iconUrl:
          'https://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png',
      time: item['dt_txt'],
    );
  }

  /// Convert raw current weather map to WeatherData
  static WeatherData fromCurrent(Map<String, dynamic> item) {
    return WeatherData(
      temp: item['main']['temp'].toDouble(),
      description: item['weather'][0]['description'],
      iconUrl:
          'https://openweathermap.org/img/wn/${item['weather'][0]['icon']}@2x.png',
      time: '',
    );
  }

  // ========== SHORTCUTS ==========

  /// Get current temperature only
  static Future<double?> getTemperatureOnly(double lat, double lon) async {
    final raw = await getCurrentRaw(lat, lon);
    return raw?['main']?['temp']?.toDouble();
  }

  /// Get today’s forecast as string (e.g. "Sunny, 23°C")
  static Future<String?> getTodayForecastText(double lat, double lon) async {
    final daily = await getForecastRaw(lat, lon);
    if (daily.isEmpty) return null;
    final first = fromForecast(daily.first);
    return '${first.description}, ${first.temp.toStringAsFixed(1)}°C';
  }

  // ========== WIDGETS ==========

  /// Widget to show current weather (icon + description + temp)
  static Widget currentWidget({required double lat, required double lon}) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getCurrentRaw(lat, lon),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final data = fromCurrent(snapshot.data!);
        return Row(
          children: [
            Image.network(data.iconUrl, width: 40),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.description, style: const TextStyle(fontSize: 16)),
                Text('🌡️ ${data.temp.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Widget to show 5-day forecast as a vertical list
  static Widget forecastWidget({required double lat, required double lon}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getForecastRaw(lat, lon),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final items = snapshot.data!.map(fromForecast).toList();
        return Column(
          children: items.map((day) {
            return ListTile(
              leading: Image.network(day.iconUrl),
              title: Text(day.description),
              subtitle:
                  Text('🌡️ ${day.temp.toStringAsFixed(1)}°C • ${day.time}'),
            );
          }).toList(),
        );
      },
    );
  }
}
