// trail_suggester_test.dart

import 'package:ambulo/utils/trail_suggester.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/models/trail_keys.dart';

class TrailSuggesterTestPage extends StatefulWidget {
  const TrailSuggesterTestPage({super.key});

  @override
  State<TrailSuggesterTestPage> createState() => _TrailSuggesterTestPageState();
}

class _TrailSuggesterTestPageState extends State<TrailSuggesterTestPage> {
  String? selectedRegion;
  String? selectedDifficulty;
  String? selectedTrailType;
  String? selectedSeason;
  String? selectedSurface;
  bool loop = false;
  bool requiresPayment = false;
  double? maxDistance;
  int? maxEstimatedTime;

  List<String> trailNames = [];

  void _runSuggestion() async {
    final prefs = TrailPreferences(
      region: selectedRegion,
      difficulty: selectedDifficulty,
      trailType: selectedTrailType,
      season: selectedSeason,
      surfaceType: selectedSurface,
      loop: loop,
      requiresPayment: requiresPayment,
      maxDistance: maxDistance,
      maxEstimatedTime: maxEstimatedTime,
    );

    final suggester = TrailSuggester(db: dataManager);
    final results = await suggester.suggestTrails(prefs);

    setState(() {
      trailNames = results
          .map((doc) {
            final details = Map<String, dynamic>.from(doc['trailDetails']);
            return details[TrailKeys.name] ?? 'Unnamed Trail';
          })
          .toList()
          .cast<String>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trail Suggester Test")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Region'),
              items: TrailRegion.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              value: selectedRegion,
              onChanged: (val) => setState(() => selectedRegion = val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: TrailDifficulty.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              value: selectedDifficulty,
              onChanged: (val) => setState(() => selectedDifficulty = val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Trail Type'),
              items: TrailType.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              value: selectedTrailType,
              onChanged: (val) => setState(() => selectedTrailType = val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Season'),
              items: TrailSeason.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              value: selectedSeason,
              onChanged: (val) => setState(() => selectedSeason = val),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Surface'),
              items: TrailSurface.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              value: selectedSurface,
              onChanged: (val) => setState(() => selectedSurface = val),
            ),
            SwitchListTile(
              title: const Text("Loop"),
              value: loop,
              onChanged: (val) => setState(() => loop = val),
            ),
            SwitchListTile(
              title: const Text("Requires Payment"),
              value: requiresPayment,
              onChanged: (val) => setState(() => requiresPayment = val),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Max Distance (km)"),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => maxDistance = double.tryParse(val)),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  labelText: "Max Estimated Time (minutes)"),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => maxEstimatedTime = int.tryParse(val)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runSuggestion,
              child: const Text("Suggest Trails"),
            ),
            const SizedBox(height: 20),
            const Text("Suggested Trails:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...trailNames.map((name) => ListTile(title: Text(name))).toList(),
          ],
        ),
      ),
    );
  }
}
