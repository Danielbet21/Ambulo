import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Ambulo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),

            // App Logo
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/background/my_logo.jpg'),
              ),
            ),

            const SizedBox(height: 16),

            // App Name
            const Center(
              child: Text(
                'Ambulo',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            // Short Description
            const Center(
              child: Text(
                'Explore, hike, and connect with nature like never before.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 24),

            // Key Features
            const Text(
              'Key Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const FeatureItem(text: 'Personalized trail recommendations'),
            const FeatureItem(text: 'Tricky turn alerts'),
            const FeatureItem(text: 'Group hike planning'),
            const FeatureItem(text: 'Equipment sharing list'),

            const SizedBox(height: 24),

            // Version Info
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Contact Info
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Contact us: ambulo.dev@gmail.com'),
              ),
            ),

            const SizedBox(height: 16),

            // Legal Links (optional)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Privacy Policy'),
                ),
                const Text(' | '),
                TextButton(
                  onPressed: () {},
                  child: const Text('Terms of Service'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Credits
            const Center(
              child: Text(
                'Map data by OpenStreetMap contributors.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String text;

  const FeatureItem({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
