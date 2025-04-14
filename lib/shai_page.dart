import 'package:ambulo/manualTest/trailTest.dart';
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
              child: const Text('To to Trail Tests'),
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
