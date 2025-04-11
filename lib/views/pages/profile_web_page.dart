import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/views/pages/settings_page.dart';
import 'package:ambulo/views/widgets/analytics_card.dart';
import 'package:ambulo/views/widgets/profile_category.dart';
import 'package:ambulo/views/widgets/profile_info_card.dart';
import 'package:flutter/material.dart';

class ProfileWebPage extends StatelessWidget {
  const ProfileWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Settings button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppConstants.kSizedBoxMedium,
          
                // Main content row
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    // Left section: Analytics cards and categories
                    SizedBox(
                      width: 650,
                      child: Column(
                        children: [
                          // Analytics cards
                          Row(
                            spacing: 5,
                            children: const [
                              AnalyticsCard(title: 'Trips', value: '12'),
                              AnalyticsCard(title: 'Elevation', value: '2,400'),
                              AnalyticsCard(title: 'Total KM', value: '150'),
                            ],
                          ),
                          AppConstants.kSizedBoxXXL,
                          
                          // Categories directly below analytics
                          const ProfileCategory(
                            nameOfCategory: 'Saved Routes',
                          ),
                          const ProfileCategory(
                            nameOfCategory: 'Completed Routes',
                          ),
                          const ProfileCategory(
                            nameOfCategory: 'Saved Guides',
                          ),
                        ],
                      ),
                    ),
                    
                    // Right section: Profile info card
                    const ProfileInfoCard(
                      name: 'Daniel',
                      location: 'Israel, Tel Aviv',
                      title: 'Rookie',
                      imagePath: 'assets/background/my_logo.jpg',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}