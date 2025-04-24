import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/data/styles/themes.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/utils/user_utils.dart';
import 'package:ambulo/views/pages/CompletedRoutesPage.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:ambulo/views/pages/SavedRoutesPage.dart';
import 'package:ambulo/views/pages/register_page.dart';
import 'package:ambulo/views/pages/settings_page.dart';
import 'package:ambulo/views/widgets/profile_category.dart';
import 'package:flutter/material.dart';

class ProfileMobilePage extends StatefulWidget {
  const ProfileMobilePage({Key? key}) : super(key: key);

  @override
  State<ProfileMobilePage> createState() => _ProfileMobilePageState();
}

class _ProfileMobilePageState extends State<ProfileMobilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:
              Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              }),
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
                          backgroundImage:
                              AssetImage('assets/background/my_logo.jpg'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt, size: 14),
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

              //TODO  DELETE THIS PART ------------------------------
              // logout button
              ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  bool confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Log Out'),
                            content:
                                const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Log Out',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      ) ??
                      false;

                  if (confirm) {
                    // Log out using the utility function
                    await logoutUser(globalUser.db);

                    // Navigate to the login/register page
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  }
                },
                child: const Text('Log Out'),
              ),
              // is admin
              Text('Is Admin: ${isAdmin}',
                  style: TextStyle(color: Colors.grey[600])),
              //button only admin see
              if (isAdmin)
                Text("only admin can see this",
                    style: TextStyle(color: Colors.red[600])),
              //TODO  DELETE THIS PART ^^^^^^^^^^^^^^^^^^^^^^^
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ));
  }
}
