import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  int currentIndex = 2;
  final Function(int) onTap;

  BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.stop_circle), label: 'Record'),
        BottomNavigationBarItem(icon: Icon(Icons.account_tree_outlined), label: 'Community'),
        BottomNavigationBarItem(icon: Icon(Icons.landscape_rounded), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Shop'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_sharp), label: 'Profile'),
      ],
    );
  }
}
