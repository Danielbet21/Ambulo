import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCreateTrailPage extends StatefulWidget {
  final User user;

  const AdminCreateTrailPage({
    super.key,
    required this.user,
  });

  @override
  State<AdminCreateTrailPage> createState() => _AdminCreateTrailPageState();
}

class _AdminCreateTrailPageState extends State<AdminCreateTrailPage> {
  final _formKey = GlobalKey<FormState>();

  // Basic details
  String name = '';
  String description = '';
  double distance = 0;
  String difficulty = '';
  String region = '';
  bool loop = false;

  // Additional details
  String gpx = ''; // GPX content entered by the user
  bool hasWaterSections = false;
  int nights = 0;
  String trailType = '';
  String startingPoint = '';
  String endingPoint = '';
  bool requiresPayment = false;
  String recommendedSeason = '';
  String surfaceType = '';
  int estimatedTime = 0;
  bool isSaving = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSaving = true);

      try {
        final newTrailId = await Trail.create(
          db: widget.user.db,
          name: name,
          gpx: gpx, // Use the GPX content entered by the user
          additionalDetails: {
            TrailKeys.userUid: widget.user.userUid,
            TrailKeys.official: true,
            TrailKeys.createdAt: FieldValue.serverTimestamp(),
            TrailKeys.distance: distance,
            TrailKeys.difficulty: difficulty,
            TrailKeys.region: region,
            TrailKeys.loop: loop,
            TrailKeys.description: description,
            TrailKeys.hasWaterSections: hasWaterSections,
            TrailKeys.nights: nights,
            TrailKeys.trailType: trailType,
            TrailKeys.startingPoint: startingPoint,
            TrailKeys.endingPoint: endingPoint,
            TrailKeys.requiresPayment: requiresPayment,
            TrailKeys.recommendedSeason: recommendedSeason,
            TrailKeys.surfaceType: surfaceType,
            TrailKeys.estimatedTime: estimatedTime,
          },
        );

        await widget.user.completeTrail(newTrailId);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Trail saved successfully!")),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save trail: $e")),
        );
      } finally {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin: Create Trail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Basic Info Section
              _buildSectionHeader('Basic Information'),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Trail Name'),
                onChanged: (val) => name = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (val) => description = val,
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => distance = double.tryParse(val) ?? 0,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: TrailDifficulty.values
                    .map((diff) => DropdownMenuItem(
                          value: diff,
                          child: Text(diff),
                        ))
                    .toList(),
                onChanged: (val) => difficulty = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Region'),
                items: TrailRegion.values
                    .map((region) => DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        ))
                    .toList(),
                onChanged: (val) => region = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // GPX Field
              TextFormField(
                decoration: const InputDecoration(labelText: 'GPX Content'),
                onChanged: (val) => gpx = val,
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Trail Characteristics Section
              _buildSectionHeader('Trail Characteristics'),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Trail Type'),
                items: TrailType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (val) => trailType = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Surface Type'),
                items: TrailSurface.values
                    .map((surface) => DropdownMenuItem(
                          value: surface,
                          child: Text(surface),
                        ))
                    .toList(),
                onChanged: (val) => surfaceType = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Estimated Time (minutes)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => estimatedTime = int.tryParse(val) ?? 0,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Recommended Season'),
                items: TrailSeason.values
                    .map((season) => DropdownMenuItem(
                          value: season,
                          child: Text(season),
                        ))
                    .toList(),
                onChanged: (val) => recommendedSeason = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Location Details
              _buildSectionHeader('Location Details'),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Starting Point'),
                onChanged: (val) => startingPoint = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Ending Point'),
                onChanged: (val) => endingPoint = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Additional Options
              _buildSectionHeader('Additional Options'),

              SwitchListTile(
                value: loop,
                onChanged: (val) => setState(() => loop = val),
                title: const Text('Loop Trail'),
              ),

              SwitchListTile(
                value: hasWaterSections,
                onChanged: (val) => setState(() => hasWaterSections = val),
                title: const Text('Has Water Sections'),
              ),

              SwitchListTile(
                value: requiresPayment,
                onChanged: (val) => setState(() => requiresPayment = val),
                title: const Text('Requires Payment'),
              ),

              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Number of Nights (for multi-day trails)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => nights = int.tryParse(val) ?? 0,
              ),

              const SizedBox(height: 24),

              // Save Button
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: isSaving
                    ? const Text("Saving...")
                    : const Text("Save Trail"),
                onPressed: isSaving ? null : _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
