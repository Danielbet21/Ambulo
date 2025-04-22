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
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
        actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
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
                        backgroundImage: AssetImage('assets/background/my_logo.jpg'),
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
                  SizedBox(width: 24), // a horozontal space between the avatar and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ambulo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('The title', style: TextStyle(color: Colors.grey[600])),
                      SizedBox(height: 8),
                      
                    ],
                  ),
                ],
              ),
            ),
        
            Divider(),
            // Options List 
            const ProfileCategory(nameOfCategory: 'Completed Routes', icon: Icons.check_circle_outline, iconColor: Colors.green),
            const ProfileCategory(nameOfCategory: 'Saved Routes', icon: Icons.save_alt),
            const ProfileCategory(nameOfCategory: 'Saved Guides', icon: Icons.bookmark),
            const ProfileCategory(nameOfCategory: 'Subscription', icon: Icons.star, iconColor: Colors.amber),
            const ProfileCategory(nameOfCategory: 'Settings', icon: Icons.settings),
            const ProfileCategory(nameOfCategory: 'Help', icon: Icons.help),  
            const ProfileCategory(nameOfCategory: 'About', icon: Icons.info),
            const ProfileCategory(nameOfCategory: 'Log Out', icon: Icons.logout, iconColor: Colors.red),
            // Bottom Navigation
          ],
        ),
      ),
    bottomNavigationBar:  BottomNavigationBar(
              currentIndex: 2,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
              ],
            )
    );
  }
}