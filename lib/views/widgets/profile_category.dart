import 'package:ambulo/data/styles/constant.dart';
import 'package:flutter/material.dart';

class ProfileCategory extends StatelessWidget {
  final String nameOfCategory;
  final IconData? icon;
// icon color , will be default to grey[700] if not provided by the user
  final Color? iconColor;

  const ProfileCategory({
    super.key,
    required this.nameOfCategory,
    this.icon,
    this.iconColor = const Color(0xFF616161),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            side: const BorderSide(
              color: Color.fromARGB(255, 214, 211, 211),
              width: 1,
            ),
            padding: EdgeInsets.zero, // Remove default padding to control it with Container
          ),
          onPressed: () {
            // Handle button press
            // Consider using actual route names if they differ from nameOfCategory
            Navigator.pushNamed(context, '/$nameOfCategory');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Apply padding here
            width: MediaQuery.of(context).size.width * 0.8, // Set width to 80% of screen width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( // Group icon and text together
                  mainAxisSize: MainAxisSize.min, // Take minimum space needed
                  children: [
                    if (icon != null) // Conditionally display icon
                      Icon(icon, size: 20, color: iconColor),
                    if (icon != null) // Add spacing only if icon exists
                      const SizedBox(width: 12),
                    Text(
                      nameOfCategory,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 111, 111, 111),
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
        AppConstants.kSizedBoxMedium,
      ],
    );
  }
}