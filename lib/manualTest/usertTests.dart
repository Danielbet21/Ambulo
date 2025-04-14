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
      appBar: AppBar(title: const Text('User Tests')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ElevatedButton(
              onPressed: () async {
                final user = await loginAndWrapUser(
                    dataManager, testEmail, testPassword);
                if (user != null) {
                  await user.load();
                  currentUser = user;
                  print("✅ Login successful");
                } else {
                  print("❌ Login failed");
                }
              },
              child: const Text("Login and Load"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await createAndWrapUser(
                    dataManager, testEmail, testPassword, testName);
                if (user != null) {
                  await user.load();
                  currentUser = user;
                  print("✅ User created and loaded");
                } else {
                  print("❌ Failed to create user");
                }
              },
              child: const Text("Create and Load"),
            ),
            ElevatedButton(
              onPressed: () => print("👤 Name: ${currentUser?.name}"),
              child: const Text("Get Name"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name =
                    await showInputDialog(context, "Set Name", "Enter name");
                if (name != null && name.isNotEmpty) {
                  await currentUser?.setName(name);
                  print("✏️ New name: ${currentUser?.name}");
                }
              },
              child: const Text("Set Name"),
            ),
            ElevatedButton(
              onPressed: () async {
                print("Current self title: ${currentUser?.selfTitle}");
              },
              child: const Text("Get Self Title"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = await showInputDialog(
                    context, "Set Title", "Enter self title");
                if (title != null && title.isNotEmpty) {
                  await currentUser?.setSelfTitle(title);
                  print("🏷️ Self title: ${currentUser?.selfTitle}");
                }
              },
              child: const Text("Set Self Title"),
            ),
            ElevatedButton(
              onPressed: () => print("📧 Email: ${currentUser?.email}"),
              child: const Text("Get Email"),
            ),
            ElevatedButton(
              onPressed: () => print("🚶 KM: ${currentUser?.totalKm}"),
              child: const Text("Get Total KM"),
            ),
            ElevatedButton(
              onPressed: () =>
                  print("⛰️ Elevation: ${currentUser?.totalElevation}"),
              child: const Text("Get Elevation"),
            ),
            ElevatedButton(
              onPressed: () =>
                  print("🥾 Hikes: ${currentUser?.completedHikes}"),
              child: const Text("Get Completed Hikes"),
            ),
            ElevatedButton(
              onPressed: () =>
                  print("🌓 Theme is Light: ${currentUser?.isLightTheme}"),
              child: const Text("Check Light Theme"),
            ),
            ElevatedButton(
              onPressed: () => print(
                  "🔔 Notifications: ${currentUser?.isNotificationsEnabled}"),
              child: const Text("Check Notifications"),
            ),
            ElevatedButton(
              onPressed: () => currentUser
                  ?.setLightTheme(!(currentUser?.isLightTheme ?? true)),
              child: const Text("Toggle Theme"),
            ),
            ElevatedButton(
              onPressed: () => currentUser?.setNotifications(
                  !(currentUser?.isNotificationsEnabled ?? true)),
              child: const Text("Toggle Notifications"),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = currentUser?.preferences;
                print("⚙️ Preferences: $prefs");
              },
              child: const Text("Show Preferences"),
            ),
            ElevatedButton(
              onPressed: () async {
                final history = await currentUser?.getHikingHistory();
                print("📜 History: ${history?.length}");
              },
              child: const Text("Get Hiking History"),
            ),
            ElevatedButton(
              onPressed: () async {
                await logoutUser(dataManager);
                currentUser = null;
                print("👋 Logged out");
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
