import 'package:ambulo/data/styles/theme_extentions.dart';
import 'package:ambulo/data/styles/constant.dart';
import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String name;
  final String title;
  final String location;
  final String imagePath;

  const ProfileInfoCard({
    super.key,
    required this.name,
    required this.title,
    required this.location,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          padding: const EdgeInsets.all(16),
          width: 300,
          height: 400,
          child: Column(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(imagePath),
              ),
              AppConstants.kSizedBoxMedium,              
              // Name
              Text(
                name,
                style: context.textTheme.titleLarge,
              ),
              Text(
                location,
                style: context.textTheme.bodyMedium,
              ),
              // Title
              Text(
                title,
                style: context.textTheme.titleMedium,
              ),
            ],
          ),
        ),
    );
  }
}