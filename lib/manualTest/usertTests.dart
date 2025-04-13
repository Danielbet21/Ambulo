// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ambulo/models/user.dart';
import 'package:ambulo/utils/user_utils.dart';
import 'package:ambulo/main.dart';

User? currentUser;
String testEmail = "userAutoTest@gmail.com";
String testPassword = "userAutoTestPassword";
String testName = "userAutoTestName";

class UserTestsPage extends StatelessWidget {
  const UserTestsPage({super.key});

  // Show an input dialog and return the entered string
  Future<String?> showInputDialog(
      BuildContext context, String title, String hintText) async {
    String? input;
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: hintText),
            onChanged: (value) => input = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Tests'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 0: Login.");
                final user = await loginAndWrapUser(
                  dataManager,
                  testEmail,
                  testPassword,
                );
                if (user != null) {
                  currentUser = user;
                  print("✅ Test 0 Passed: User logged in.");
                } else {
                  print("❌ Test 0 Failed: Login failed.");
                }
              },
              child: const Text('Test 0: Login'),
            ),
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 1: Init user.");

                final user = await createAndWrapUser(
                  dataManager,
                  testEmail,
                  testPassword,
                  testName,
                );

                if (user != null) {
                  currentUser = user;
                  print("✅ Test 1 Passed: User initialized.");
                } else {
                  print("❌ Test 1 Failed: Init failed.");
                }
              },
              child: const Text('Test 1: Init User'),
            ),
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 2: Get Name");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final name = await currentUser!.getName();
                print("👤 Name: $name");
              },
              child: const Text('Test 2: Get Name'),
            ),
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 3: Set Name");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final newName = await showInputDialog(
                    context, "Set Name", "Enter new name");
                if (newName == null || newName.isEmpty) return;

                await currentUser!.setName(newName);
                final name = await currentUser!.getName();
                print("✏️ New Name: $name");
              },
              child: const Text('Test 3: Set Name'),
            ),
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 4: Set/Get Preferences");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final key = await showInputDialog(
                    context, "Set Preference", "Enter preference key");
                if (key == null || key.isEmpty) return;

                final value = await showInputDialog(
                    context, "Set Preference", "Enter value for '$key'");
                if (value == null || value.isEmpty) return;

                await currentUser!.setPreference(key, value);
                final prefs = await currentUser!.getPreferences();
                print("⚙️ Preferences: $prefs");
              },
              child: const Text('Test 4: Preferences'),
            ),
            // Test 5: Get Email
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 5: Get Email");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final email = await currentUser!.getEmail();
                print("📧 Email: $email");
              },
              child: const Text('Test 5: Get Email'),
            ),

// Test 6: Get Total KM
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 6: Get Total KM");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final km = await currentUser!.getTotalKm();
                print("🚶‍♂️ Total KM: $km");
              },
              child: const Text('Test 6: Get Total KM'),
            ),

// Test 7: Get Completed Hikes
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 7: Get Completed Hikes");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final hikes = await currentUser!.getCompletedHikes();
                print("✅ Completed Hikes: $hikes");
              },
              child: const Text('Test 7: Get Completed Hikes'),
            ),

// Test 8: Get Self Title
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 8: Get Self Title");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final title = await currentUser!.getSelfTitle();
                print("🧑 Self Title: $title");
              },
              child: const Text('Test 8: Get Self Title'),
            ),

// Test 9: Get Hiking History
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 9: Get Hiking History");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final history = await currentUser!.getHikingHistory();
                print("🗺️ Hiking History (${history.length}): $history");
              },
              child: const Text('Test 9: Get Hiking History'),
            ),

// Test 10: Add to Saved Hikes
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 10: Add to Saved Hikes");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final trail = {
                  'id': 'trail_test_001',
                  'name': 'Test Trail',
                  'addedAt': DateTime.now().toIso8601String()
                };

                await currentUser!.addToSaved(trail);
                print("➕ Trail added to saved.");
              },
              child: const Text('Test 10: Add to Saved Hike'),
            ),

// Test 11: Remove from Saved Hikes
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 11: Remove from Saved Hikes");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final trail = {
                  'id': 'trail_test_001',
                  'name': 'Test Trail',
                  'addedAt': DateTime.now().toIso8601String()
                };

                await currentUser!.removeFromSaved(trail);
                print("➖ Trail removed from saved.");
              },
              child: const Text('Test 11: Remove from Saved Hike'),
            ),

// Test 12: Delete Hike from History
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 12: Delete Hike from History");

                if (currentUser == null) {
                  print("⚠️ User not initialized.");
                  return;
                }

                final history = await currentUser!.getHikingHistory();
                if (history.isEmpty) {
                  print("⚠️ No hikes to delete.");
                  return;
                }

                final hike = history.first;
                await currentUser!.deleteHike(hike);
                print("🗑️ Deleted hike: $hike");
              },
              child: const Text('Test 12: Delete Hike from History'),
            ),
            ElevatedButton(
              onPressed: () async {
                print("---- User Tests ----");
                print("Test 13: Logout User");

                await logoutUser(dataManager);
                currentUser = null;
                print("✅ User signed out.");
              },
              child: const Text('Test 13: Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
