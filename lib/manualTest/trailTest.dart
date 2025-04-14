// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ambulo/models/trail.dart';
import 'package:ambulo/main.dart';

class TrailTestsPage extends StatefulWidget {
  const TrailTestsPage({super.key});

  @override
  State<TrailTestsPage> createState() => _TrailTestsPageState();
}

class _TrailTestsPageState extends State<TrailTestsPage> {
  String? currentTrailId;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trail Tests')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ElevatedButton(
              onPressed: () async {
                print("---- Trail Tests ----");
                print("Test 0: Create Trail");

                final trailName = await showInputDialog(
                    context, "Trail Name", "Enter trail name");
                if (trailName == null || trailName.isEmpty) {
                  print("❌ Trail name is required.");
                  return;
                }

                final gpxContent = await showInputDialog(
                    context, "GPX Content", "Paste GPX XML here");
                if (gpxContent == null || gpxContent.isEmpty) {
                  print("❌ GPX content is required.");
                  return;
                }

                try {
                  final id = await Trail.create(
                    db: dataManager,
                    name: trailName,
                    gpx: gpxContent,
                    additionalDetails: {
                      'difficulty': 'medium',
                      'season': 'spring',
                    },
                  );
                  currentTrailId = id;
                  print("✅ Trail created with ID: $id");
                } catch (e) {
                  print("❌ Failed to create trail: $e");
                }
              },
              child: const Text("Test 0: Create Trail"),
            ),
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
      ),
    );
  }
}
