import 'package:ambulo/data/styles/constant.dart';
import 'package:flutter/material.dart';

class ProfileCategory extends StatelessWidget {
  final String nameOfCategory;
  final IconData? icon;
// icon color , will be default to grey[700] if not provided by the user
  final Color? iconColor;
  final Widget? pageToNavigateTo;

  ProfileCategory({
    super.key,
    required this.nameOfCategory,
    this.icon,
    this.iconColor = const Color(0xFF616161),
    this.pageToNavigateTo, // Accept a Widget for navigation
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
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            if (pageToNavigateTo != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pageToNavigateTo!),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null)
                      Icon(icon, size: 20, color: iconColor),
                    if (icon != null)
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
        const SizedBox(height: 16),
      ],
    );
  }
}