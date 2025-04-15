import 'package:ambulo/main.dart';
import 'package:ambulo/manualTest/WeatherTest.dart';
import 'package:ambulo/manualTest/trailSuggesterTest.dart';
import 'package:ambulo/manualTest/trailTest.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manualTest/usertTests.dart';
import 'views/pages/NavigationPage.dart';
import 'package:ambulo/models/user.dart';

import 'package:ambulo/utils/user_utils.dart'; // Import the utility file

class ShaiPage extends StatelessWidget {
  const ShaiPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Load the user with the specified ID
    final Future<User?> futureUser =
        loginAndWrapUser(dataManager, testEmail, testPassword);

    return FutureBuilder<User?>(
      future: futureUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Shai Page'),
            ),
            body: const Center(
              child: Text('Failed to load user.'),
            ),
          );
        }

        final User testUser = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shai Page'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserTestsPage()),
                    );
                  },
                  child: const Text('Go to User Tests'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TrailTestsPage()),
                    );
                  },
                  child: const Text('Go to Trail Tests'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WeatherTestsPage()),
                    );
                  },
                  child: const Text('Go To Weather Test'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapPage()),
                    );
                  },
                  child: const Text('Go To Map Page'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(user: testUser),
                      ),
                    );
                  },
                  child: const Text('Start Free Navigation'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // const String trailId =
                    //     '1744711733881'; // Holon
                    const String trailId = '1744711992952'; // yavniel
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NavigationPage(
                          user: testUser,
                          trailId: trailId,
                        ),
                      ),
                    );
                  },
                  child: const Text('Start Navigation from Trail'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TrailSuggesterTestPage()),
                    );
                  },
                  child: const Text('Go To Trail Suggester Test'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
