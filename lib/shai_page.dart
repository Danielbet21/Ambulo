import 'package:ambulo/manualTest/WeatherTest.dart';
import 'package:ambulo/manualTest/trailTest.dart';
import 'package:ambulo/views/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'manualTest/usertTests.dart'; // Import the userTests page

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
                // Add navigation logic for another page here
              },
              child: const Text('Button 3'),
            ),
            // Add more buttons as needed
          ],
        ),
      ),
    );
  }
}
