import 'package:ambulo/views/pages/profile_mobile_page.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.w500)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // --- Account Settings Section ---
          const SectionHeader(icon: Icons.person_outline, title: "Account Settings"),
          _buildSettingTile("Change Password", onTap: () {}),

          // --- Privacy & Security Section ---
          const SectionHeader(icon: Icons.lock_outline, title: "Privacy & Security"),
          _buildSettingTile("App Permissions", onTap: () {}),

          // --- Units Section ---
          const SectionHeader(icon: Icons.straighten, title: "Units"),
          _buildToggleTile("Use Metric Units", initialValue: true, onChanged: (value) {
            // TODO: Handle unit change
          }),

          // --- Appearance Section ---
          const SectionHeader(icon: Icons.visibility_outlined, title: "Appearance"),
          _buildSettingTile("Theme", onTap: () {}),

          // --- About Section ---
          const SectionHeader(icon: Icons.info_outline, title: "About"),
          _buildSettingTile("App Info", onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSettingTile(String title, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100], // 👈 Light gray tile background
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleTile(String title,
      {required bool initialValue, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100], // 👈 Light gray tile background
        borderRadius: BorderRadius.circular(12),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          bool value = initialValue;
          return SwitchListTile(
            title: Text(title),
            value: value,
            onChanged: (val) {
              setState(() => value = val);
              onChanged(val);
            },
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}