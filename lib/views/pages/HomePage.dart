// import 'package:ambulo/main.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/views/pages/MapPage.dart';
import 'package:ambulo/views/pages/NavigationPage.dart';
import 'package:ambulo/views/pages/profile_mobile_page.dart';
import 'package:ambulo/views/pages/profile_web_page.dart';
import 'package:ambulo/views/widgets/all_trails_widget.dart';
import 'package:flutter/material.dart';
import 'package:ambulo/views/widgets/BottomNavBar.dart';
import 'package:ambulo/views/pages/ShopPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // default is Explore

  final List<Widget> _pages = [
    NavigationPage(
      user: globalUser,
    ),
    AllTrailsWidget(),
    MapPage(),
    ShopPage(),
    ProfileMobilePage(),
    ProfileWebPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
