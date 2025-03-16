import 'package:flutter/material.dart';

class DanielPage extends StatelessWidget {
  const DanielPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daniel Page'),
      ),
      body: const Center(
        child: Text('This is Daniel\'s development page.'),
      ),
    );
  }
}

