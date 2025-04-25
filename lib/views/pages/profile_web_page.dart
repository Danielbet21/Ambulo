import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/helpers/image_helper.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/views/pages/settings_page.dart';
import 'package:ambulo/views/widgets/analytics_card.dart';
import 'package:ambulo/views/widgets/profile_category.dart';
import 'package:ambulo/views/widgets/profile_info_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileWebPage extends StatefulWidget {
  const ProfileWebPage({super.key});

  @override
  State<ProfileWebPage> createState() => _ProfileWebPageState();
}

class _ProfileWebPageState extends State<ProfileWebPage> {
  String? profileImageUrl;
  final ImageHelpers imageHelpers = ImageHelpers(dataManager: dataManager);

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final imageUrl = await imageHelpers.getCurrentUserProfileImage();
    setState(() {
      profileImageUrl = imageUrl;
    });
  }

  Future<void> _uploadProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final user = dataManager.getCurrentUser();
        if (user != null) {
          final imageUrl =
              await dataManager.uploadUserProfileImage(user.uid, image);
          setState(() {
            profileImageUrl = imageUrl;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Settings button
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              icon: const Icon(Icons.settings, size: 30),
            ),
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
                              AnalyticsCard(
                                  title: 'Elevation',
                                  value: '2,400',
                                  mersure: 'm'),
                              AnalyticsCard(title: 'Total KM', value: '150'),
                            ],
                          ),
                          AppConstants.kSizedBoxXXL,

                          // Categories directly below analytics
                          ProfileCategory(
                            nameOfCategory: 'Saved Routes',
                          ),
                          ProfileCategory(
                            nameOfCategory: 'Completed Routes',
                          ),
                          ProfileCategory(
                            nameOfCategory: 'Saved Guides',
                          ),
                        ],
                      ),
                    ),

                    // Custom profile card with image upload functionality
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl!)
                                          as ImageProvider
                                      : AssetImage(
                                          'assets/background/my_logo.jpg'),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _uploadProfileImage,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.camera_alt, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              globalUser.name ?? 'Daniel',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Israel, Tel Aviv',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              globalUser.selfTitle ?? 'Rookie',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
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
