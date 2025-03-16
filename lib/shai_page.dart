import 'package:flutter/material.dart';

class ShaiPage extends StatelessWidget {
  const ShaiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shai Page'),
      ),
      body: const Center(
        child: Text('This is Shai\'s development page.'),
      ),
    );
  }
}

