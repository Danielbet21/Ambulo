import 'package:ambulo/views/widgets/profile_category.dart';
import 'package:flutter/material.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          children: [
            ProfileCategory(nameOfCategory: "Account Settings", 
                icon: Icons.account_circle_outlined),
            ProfileCategory(nameOfCategory: "Privacy & Security", 
                icon: Icons.security),
            ProfileCategory(nameOfCategory: "Units",
                icon: Icons.straighten),
            ProfileCategory(nameOfCategory: "Appearance", 
                icon: Icons.palette),
            ProfileCategory(nameOfCategory: "About", 
                icon: Icons.info_outline),
          ],
        ),
      )
    );
  }
}
