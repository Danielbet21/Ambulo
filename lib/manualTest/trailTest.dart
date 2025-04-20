// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ambulo/models/trail.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/models/trail_keys.dart';

class TrailTestsPage extends StatefulWidget {
  const TrailTestsPage({super.key});

  @override
  State<TrailTestsPage> createState() => _TrailTestsPageState();
}

class _TrailTestsPageState extends State<TrailTestsPage> {
  String? currentTrailId;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gpxController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _estimatedTimeController =
      TextEditingController();
  final TextEditingController _startingPointController =
      TextEditingController();
  final TextEditingController _endingPointController = TextEditingController();
  final TextEditingController _nightsController = TextEditingController();

  String? selectedRegion;
  String? selectedDifficulty;
  String? selectedTrailType;
  String? selectedSeason;
  String? selectedSurface;
  bool loop = false;
  bool hasWater = false;
  bool requiresPayment = false;

  Future<String?> showInputDialog(
      BuildContext context, String title, String hintText) async {
    String? input;
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: hintText),
          onChanged: (value) => input = value,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('OK')),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final trailId = await Trail.create(
          db: dataManager,
          name: _nameController.text,
          gpx: _gpxController.text,
          additionalDetails: {
            TrailKeys.description: _descriptionController.text,
            TrailKeys.distance:
                double.tryParse(_distanceController.text) ?? 0.0,
            TrailKeys.estimatedTime:
                int.tryParse(_estimatedTimeController.text) ?? 0,
            TrailKeys.startingPoint: _startingPointController.text,
            TrailKeys.endingPoint: _endingPointController.text,
            TrailKeys.nights: int.tryParse(_nightsController.text) ?? 0,
            TrailKeys.loop: loop,
            TrailKeys.hasWaterSections: hasWater,
            TrailKeys.requiresPayment: requiresPayment,
            TrailKeys.region: selectedRegion ?? '',
            TrailKeys.difficulty: selectedDifficulty ?? '',
            TrailKeys.trailType: selectedTrailType ?? '',
            TrailKeys.recommendedSeason: selectedSeason ?? '',
            TrailKeys.surfaceType: selectedSurface ?? '',
          },
        );
        print("✅ Trail created with ID: $trailId");
        currentTrailId = trailId;
      } catch (e) {
        print("❌ Failed to create trail: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trail Tests')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Create Trail (Form)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Trail Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _gpxController,
                  decoration: const InputDecoration(labelText: 'GPX Content'),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _estimatedTimeController,
                  decoration: const InputDecoration(
                      labelText: 'Estimated Time (minutes)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _startingPointController,
                  decoration:
                      const InputDecoration(labelText: 'Starting Point'),
                ),
                TextFormField(
                  controller: _endingPointController,
                  decoration: const InputDecoration(labelText: 'Ending Point'),
                ),
                TextFormField(
                  controller: _nightsController,
                  decoration: const InputDecoration(labelText: 'Nights'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('Loop'),
                  value: loop,
                  onChanged: (val) => setState(() => loop = val),
                ),
                SwitchListTile(
                  title: const Text('Includes Water Sections'),
                  value: hasWater,
                  onChanged: (val) => setState(() => hasWater = val),
                ),
                SwitchListTile(
                  title: const Text('Requires Payment'),
                  value: requiresPayment,
                  onChanged: (val) => setState(() => requiresPayment = val),
                ),
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
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  value: selectedDifficulty,
                  onChanged: (val) => setState(() => selectedDifficulty = val),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Trail Type'),
                  items: TrailType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  value: selectedTrailType,
                  onChanged: (val) => setState(() => selectedTrailType = val),
                ),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Recommended Season'),
                  items: TrailSeason.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  value: selectedSeason,
                  onChanged: (val) => setState(() => selectedSeason = val),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Surface Type'),
                  items: TrailSurface.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  value: selectedSurface,
                  onChanged: (val) => setState(() => selectedSurface = val),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create Trail'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              try {
                if (currentTrailId == null) {
                  print('⚠️ No trail selected.');
                  return;
                }
                final key = await showInputDialog(
                    context, 'Edit Trail Key', 'Enter key (e.g. name)');
                final value = await showInputDialog(
                    context, 'Edit Trail Value', 'Enter new value');
                if (key != null && value != null) {
                  final result = await Trail.editDetails(
                      dataManager, currentTrailId!, key, value);
                  print(result
                      ? '✏️ Trail detail updated.'
                      : '❌ Failed to update detail.');
                }
              } catch (e) {
                print('❌ Error editing trail: $e');
              }
            },
            child: const Text('Edit Trail Details'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (currentTrailId == null) {
                  print('⚠️ No trail selected.');
                  return;
                }
                await Trail.editMap(dataManager, currentTrailId!);
              } catch (e) {
                print('❌ Error editing map: $e');
              }
            },
            child: const Text('Edit Trail Map'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (currentTrailId == null) {
                  print('⚠️ No trail selected.');
                  return;
                }
                final desc = await showInputDialog(
                    context, 'Trail Description', 'Enter description');
                if (desc != null && desc.isNotEmpty) {
                  final result = await Trail.writeDescription(
                      dataManager, currentTrailId!, desc);
                  print(result
                      ? '📝 Description saved.'
                      : '❌ Failed to write description.');
                }
              } catch (e) {
                print('❌ Error writing description: $e');
              }
            },
            child: const Text('Write Description'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (currentTrailId == null) {
                  print('⚠️ No trail selected.');
                  return;
                }
                final rating = await showInputDialog(
                    context, 'Rating', 'Enter rating (0-5)');
                if (rating != null) {
                  await Trail.updateRating(
                      dataManager, currentTrailId!, double.parse(rating));
                  print('⭐ Rating updated.');
                }
              } catch (e) {
                print('❌ Error updating rating: $e');
              }
            },
            child: const Text('Update Rating'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (currentTrailId == null) {
                  print('⚠️ No trail selected.');
                  return;
                }
                final mosquito = await showInputDialog(
                    context, 'Mosquito Rating', 'Enter rating (0-5)');
                if (mosquito != null) {
                  await Trail.updateMosquitoRating(
                      dataManager, currentTrailId!, double.parse(mosquito));
                  print('🦟 Mosquito rating updated.');
                }
              } catch (e) {
                print('❌ Error updating mosquito rating: $e');
              }
            },
            child: const Text('Update Mosquito Rating'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (currentTrailId == null) {
                  print('⚠️ No trail selected.');
                  return;
                }
                await Trail.delete(dataManager, currentTrailId!);
                print('🗑️ Trail deleted.');
                setState(() => currentTrailId = null);
              } catch (e) {
                print('❌ Error deleting trail: $e');
              }
            },
            child: const Text('Delete Trail'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gpxController.dispose();
    _descriptionController.dispose();
    _distanceController.dispose();
    _estimatedTimeController.dispose();
    _startingPointController.dispose();
    _endingPointController.dispose();
    _nightsController.dispose();
    super.dispose();
  }
}
