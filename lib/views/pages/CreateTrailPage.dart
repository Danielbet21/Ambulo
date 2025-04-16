import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/models/trail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateTrailPage extends StatefulWidget {
  final String gpxString;
  final List<dynamic> routePoints;
  final List<dynamic> waypoints;
  final User user;

  const CreateTrailPage({
    super.key,
    required this.gpxString,
    required this.routePoints,
    required this.waypoints,
    required this.user,
  });

  @override
  State<CreateTrailPage> createState() => _CreateTrailPageState();
}

class _CreateTrailPageState extends State<CreateTrailPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  double distance = 0;
  String difficulty = '';
  String region = '';
  bool loop = false;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Trail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Trail Name'),
                onChanged: (val) => name = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
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
                items: ['Easy', 'Moderate', 'Hard']
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Region'),
                onChanged: (val) => region = val,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: loop,
                onChanged: (val) => setState(() => loop = val),
                title: const Text('Loop Trail'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: isSaving
                    ? const Text("Saving...")
                    : const Text("Save Trail"),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isSaving = true);

                          final newTrailId = await Trail.create(
                            db: widget.user.db,
                            name: name,
                            gpx: widget.gpxString,
                            additionalDetails: {
                              'userUid': widget.user.userUid,
                              'official': false,
                              'createdAt': FieldValue.serverTimestamp(),
                              'distance': distance,
                              'difficulty': difficulty,
                              'region': region,
                              'loop': loop,
                            },
                          );

                          await widget.user.completeTrail(newTrailId);

                          if (!mounted) return;

                          // ✅ Go back to main page (2 pages back)
                          Navigator.pop(context); // close CreateTrailPage
                          Navigator.pop(context); // close NavigationPage

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Trail saved successfully!"),
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
