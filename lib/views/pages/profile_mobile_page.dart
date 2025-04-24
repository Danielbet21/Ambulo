import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/helpers/image_helper.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/views/pages/CompletedRoutesPage.dart';
import 'package:ambulo/views/pages/SavedRoutesPage.dart';
import 'package:ambulo/views/pages/settings_page.dart';
import 'package:ambulo/views/widgets/profile_category.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileMobilePage extends StatefulWidget {
  const ProfileMobilePage({Key? key}) : super(key: key);

  @override
  State<ProfileMobilePage> createState() => _ProfileMobilePageState();
}

class _ProfileMobilePageState extends State<ProfileMobilePage> {
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
        title:
            Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!) as ImageProvider
                            : AssetImage('assets/background/my_logo.jpg'),
                        child: profileImageUrl != null
                            ? null
                            : Container(), // Empty container when image is loaded
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploadProfileImage,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      width:
                          24), // a horozontal space between the avatar and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //TODO: fix the title?
                      AppConstants.kSizedBoxLarge,
                      Text(globalUser.name ?? 'Guest',
                          style: TextStyle(
                              fontSize: AppConstants.kFontSizeLarge,
                              fontWeight: FontWeight.bold)),
                      Text(globalUser.selfTitle ?? 'Newbie',
                          style: TextStyle(color: Colors.grey[600])),
                      SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),

            Divider(),
            // Options List
            ProfileCategory(
                nameOfCategory: 'Completed Routes',
                pageToNavigateTo: CompletedRoutesPage(user: globalUser),
                icon: Icons.check_circle_outline,
                iconColor: Colors.green),
            ProfileCategory(
                nameOfCategory: 'Saved Routes',
                pageToNavigateTo: SavedRoutesPage(user: globalUser),
                icon: Icons.save_alt),
            ProfileCategory(
                nameOfCategory: 'Saved Guides', icon: Icons.bookmark),
            ProfileCategory(
                nameOfCategory: 'Subscription',
                icon: Icons.star,
                iconColor: Colors.amber),
            ProfileCategory(
                nameOfCategory: 'Settings',
                pageToNavigateTo: SettingsPage(),
                icon: Icons.settings),
            ProfileCategory(nameOfCategory: 'Help', icon: Icons.help),
            ProfileCategory(nameOfCategory: 'About', icon: Icons.info),
            ProfileCategory(
                nameOfCategory: 'Log Out',
                icon: Icons.logout,
                iconColor: Colors.red),
            // Bottom Navigation
          ],
        ),
      ),
    );
  }
}
