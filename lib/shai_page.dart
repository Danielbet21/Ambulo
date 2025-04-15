import 'package:ambulo/manualTest/WeatherTest.dart';
import 'package:ambulo/manualTest/trailTest.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:flutter/material.dart';
import 'manualTest/usertTests.dart'; // Import the userTests page
import 'views/pages/NavigationPage.dart'; // Import the new NavigationPage

class ShaiPage extends StatelessWidget {
  const ShaiPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  MaterialPageRoute(builder: (context) => WeatherTestsPage()),
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
                  MaterialPageRoute(builder: (context) => NavigationPage()),
                );
              },
              child: const Text('Go To Navigation'),
            ),
            // Add more buttons as needed
          ],
        ),
      ),
    );
  }
}
