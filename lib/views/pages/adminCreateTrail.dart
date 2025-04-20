import 'package:flutter/material.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:ambulo/data/database/data_manager.dart';

class AdminCreateTrailPage extends StatefulWidget {
  final DataManager dataManager;

  const AdminCreateTrailPage({super.key, required this.dataManager});

  @override
  State<AdminCreateTrailPage> createState() => _AdminCreateTrailPageState();
}

class _AdminCreateTrailPageState extends State<AdminCreateTrailPage> {
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await widget.dataManager.createTrail(
          DateTime.now().millisecondsSinceEpoch.toString(), // Unique trail ID
          {
            TrailKeys.name: _nameController.text,
            'gpx': _gpxController.text, // Adjusted to match TrailPageTest.dart
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trail created successfully')),
        );
        _formKey.currentState!.reset();
        Navigator.pop(context); // First pop
        Navigator.pop(context); // Second pop
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create trail: $e')),
        );
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
                decoration: const InputDecoration(labelText: 'Starting Point'),
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
