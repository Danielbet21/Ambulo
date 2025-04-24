import 'package:ambulo/data/styles/themes.dart';
import 'package:ambulo/main.dart';
import 'package:ambulo/shai_page.dart';
import 'package:ambulo/utils/user_utils.dart';
import 'package:ambulo/views/pages/HomePage.dart';
import 'package:ambulo/views/pages/login_page.dart';
import 'package:ambulo/views/pages/profile_mobile_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Try to get shared preferences
      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
      } catch (e) {
        print("Shared preferences plugin error: $e");
        // If shared preferences fails, redirect to login
        _navigateToLogin();
        return;
      }

      // Check if user is logged in
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final email = prefs.getString('userEmail');
      final password = prefs.getString('userPassword');
      final themeMode = prefs.getString('themeMode') ?? 'light';

      // Update app theme
      appTheme = themeMode == 'dark' ? AppTheme.darkTheme : AppTheme.lightTheme;

      if (isLoggedIn && email != null && password != null) {
        // Try to log in with stored credentials
        final user = await loginAndWrapUser(dataManager, email, password);

        if (user != null) {
          // Login successful, initialize global user
          await user.load();
          globalUser = user;

          // Check if admin
          isAdmin = await dataManager.isAdmin();

          // Navigate to home page (using ShaiPage for now)
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
          return;
        }
      }

      // If we reach here, user is not logged in or credentials are invalid
      _navigateToLogin();
    } catch (e) {
      print('Error in loading page: $e');
      // On error, redirect to login page
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/background/roads/road_to_the_mountains_register.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or name
              const Text(
                'Ambulo',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 20),
              // Loading text
              const Text(
                'Loading your adventures...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black54,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
