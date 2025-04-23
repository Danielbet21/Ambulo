import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTrailPage extends StatefulWidget {
  final String gpxString;
  final List<dynamic> routePoints;
  final List<dynamic> waypoints;
  final User user;
  final String elapsedTime; // Add elapsed time
  final double distance; // Add distance

  const CreateTrailPage({
    super.key,
    required this.gpxString,
    required this.routePoints,
    required this.waypoints,
    required this.user,
    required this.elapsedTime, // Initialize elapsed time
    required this.distance, // Initialize distance
  });

  @override
  State<CreateTrailPage> createState() => _CreateTrailPageState();
}

class _CreateTrailPageState extends State<CreateTrailPage> {
  final _formKey = GlobalKey<FormState>();

  // Basic details
  String name = '';
  String description = '';
  String difficulty = '';
  String region = '';
  bool loop = false;

  // Additional details
  bool hasWaterSections = false;
  int nights = 0;
  String trailType = '';
  String startingPoint = '';
  String endingPoint = '';
  bool requiresPayment = false;
  String recommendedSeason = '';
  String surfaceType = '';
  bool isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _startingPointController;
  late TextEditingController _endingPointController;
  late TextEditingController _nightsController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _startingPointController = TextEditingController();
    _endingPointController = TextEditingController();
    _nightsController = TextEditingController(text: '0');
    // distance and estimatedTime are pre-filled and hidden from the user
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _startingPointController.dispose();
    _endingPointController.dispose();
    _nightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New Trail'),
          automaticallyImplyLeading: false, // Remove the back arrow
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Navigate to the first page without saving
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                // Basic Info Section
                _buildSectionHeader('Basic Information'),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Trail Name'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: difficulty.isEmpty ? null : difficulty,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: TrailDifficulty.values
                      .map((diff) => DropdownMenuItem(
                            value: diff,
                            child: Text(diff),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => difficulty = val ?? ''),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: region.isEmpty ? null : region,
                  decoration: const InputDecoration(labelText: 'Region'),
                  items: TrailRegion.values
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => region = val ?? ''),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Trail Characteristics Section
                _buildSectionHeader('Trail Characteristics'),

                DropdownButtonFormField<String>(
                  value: trailType.isEmpty ? null : trailType,
                  decoration: const InputDecoration(labelText: 'Trail Type'),
                  items: TrailType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => trailType = val ?? ''),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: surfaceType.isEmpty ? null : surfaceType,
                  decoration: const InputDecoration(labelText: 'Surface Type'),
                  items: TrailSurface.values
                      .map((surface) => DropdownMenuItem(
                            value: surface,
                            child: Text(surface),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => surfaceType = val ?? ''),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: recommendedSeason.isEmpty ? null : recommendedSeason,
                  decoration:
                      const InputDecoration(labelText: 'Recommended Season'),
                  items: TrailSeason.values
                      .map((season) => DropdownMenuItem(
                            value: season,
                            child: Text(season),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => recommendedSeason = val ?? ''),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Location Details
                _buildSectionHeader('Location Details'),

                TextFormField(
                  controller: _startingPointController,
                  decoration:
                      const InputDecoration(labelText: 'Starting Point'),
                  onChanged: (val) => startingPoint = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _endingPointController,
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
                  controller: _nightsController,
                  decoration:
                      const InputDecoration(labelText: 'Number of Nights'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => nights = int.tryParse(val) ?? 0,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 24),

                // Save Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: isSaving
                      ? const Text("Saving...")
                      : const Text("Save Trail"),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return; // If validation failed, do not proceed
                          }

                          // Double-check critical fields
                          if (difficulty.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please select a Difficulty.")),
                            );
                            return;
                          }

                          if (_nameController.text.isEmpty ||
                              _descriptionController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Name and Description are required.")),
                            );
                            return;
                          }

                          setState(() => isSaving = true);

                          final name = _nameController.text;
                          final description = _descriptionController.text;
                          final startingPoint = _startingPointController.text;
                          final endingPoint = _endingPointController.text;
                          final nights =
                              int.tryParse(_nightsController.text) ?? 0;

                          final newTrailId = await Trail.create(
                            db: widget.user.db,
                            name: name,
                            gpx: widget.gpxString,
                            additionalDetails: {
                              TrailKeys.userUid: widget.user.userUid,
                              TrailKeys.official: false,
                              TrailKeys.createdAt: FieldValue.serverTimestamp(),
                              TrailKeys.distance:
                                  widget.distance, // Use pre-filled distance
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
                              TrailKeys.estimatedTime: _convertTimeToMinutes(
                                  widget.elapsedTime), // Use pre-filled time
                            },
                          );

                          await widget.user.completeTrail(newTrailId);

                          // Update user stats
                          await widget.user.addUserKM(widget.distance);
                          await widget.user.addUserElevation(
                              _calculateTotalElevation(widget.routePoints));

                          if (!mounted) return;

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Trail saved successfully!"),
                            ),
                          );

                          // Navigate to the first page
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _convertTimeToMinutes(String elapsedTime) {
    final parts = elapsedTime.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return (hours * 60) + minutes;
  }

  double _calculateTotalElevation(List<dynamic> routePoints) {
    double totalElevation = 0.0;
    for (int i = 1; i < routePoints.length; i++) {
      final elevationDiff =
          routePoints[i]['elevation'] - routePoints[i - 1]['elevation'];
      if (elevationDiff > 0) {
        totalElevation += elevationDiff;
      }
    }
    return totalElevation;
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
