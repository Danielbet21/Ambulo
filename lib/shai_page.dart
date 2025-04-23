import 'package:ambulo/main.dart';
import 'package:ambulo/manualTest/TrailPageTest.dart';
import 'package:ambulo/manualTest/WeatherTest.dart';
import 'package:ambulo/manualTest/trailSuggesterTest.dart';
import 'package:ambulo/manualTest/trailTest.dart';
import 'package:ambulo/manualTest/show_all_trail_test.dart';
import 'package:ambulo/views/pages/CompletedRoutesPage.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:ambulo/views/pages/MyTrailsPage.dart';
import 'package:ambulo/views/pages/SavedRoutesPage.dart';
import 'package:ambulo/views/pages/adminCreateTrail.dart';
import 'package:ambulo/views/pages/DeleteTrailsPage.dart';
import 'package:ambulo/views/pages/login_page.dart';
import 'package:ambulo/views/pages/register_page.dart';
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
          return FutureBuilder<User?>(
            future: createAndWrapUser(
                dataManager, testEmail, testPassword, testName),
            builder: (context, retrySnapshot) {
              if (retrySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (retrySnapshot.hasError || !retrySnapshot.hasData) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Shai Page'),
                  ),
                  body: const Center(
                    child: Text('Failed to load or register user.'),
                  ),
                );
              }

              final User retryUser = retrySnapshot.data!;
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Shai Page'),
                ),
                body: Center(
                  child: Text(
                      'User registered successfully (refresh the page): ${retryUser.name}'),
                ),
              );
            },
          );
        }

        final User testUser = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Shai Page'),
          ),
          body: Center(
            child: SingleChildScrollView(
              // Added SingleChildScrollView
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserTestsPage()),
                      );
                    },
                    child: const Text('Go to User Tests'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TrailTestsPage()),
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
                      const String trailId = '1744731419543'; // yavniel
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
                  ElevatedButton(
                    onPressed: () {
                      const trailId = '1744731419543';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrailPageTest(
                            trailId: trailId,
                            testUser: testUser,
                          ),
                        ),
                      );
                    },
                    child: const Text('Go To Trail Page Test'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyTrailsPage(
                                  user: testUser,
                                )),
                      );
                    },
                    child: const Text('Go To My Trails Page---- REMOVE'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminCreateTrailPage(
                                  user: testUser,
                                )),
                      );
                    },
                    child: const Text('Go To Admin Create Trail Page'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShowAllTrailTest()),
                      );
                    },
                    child: const Text('Show All Trails'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SavedRoutesPage(
                                  user: testUser,
                                )),
                      );
                    },
                    child: const Text('Go to Saved Routes Page'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompletedRoutesPage(
                                  user: testUser,
                                )),
                      );
                    },
                    child: const Text('Go to Completed Routes Page'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteTrailsPage(
                                  user: testUser,
                                )),
                      );
                    },
                    child: const Text('Go to Delete Trails Page'),
                  ),
                  SizedBox(height: 45),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text('Go to Register User Page'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text('Go to Login User Page'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
