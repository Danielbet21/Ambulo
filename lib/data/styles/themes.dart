// ignore_for_file: prefer_const_constructors

import 'package:ambulo/data/styles/constant.dart';
import 'package:ambulo/main.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppTheme manages all theme-related styling for the application
/// It provides both light and dark theme variants
class AppTheme {
  // Light theme definition
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    // Base colors for the light theme
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    // Text styles for light theme
    textTheme: const TextTheme(
      //------------------------- Title text
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),

      //------------------------ Subtitle style
      titleMedium: TextStyle(
        color: Colors.grey,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),

      //------------------------- Body text style
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.black54,
        fontSize: 14,
      ),
    ),
    // Card theme
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: AppConstants.kDefaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color.fromARGB(255, 137, 134, 134),
          width: 1,
        ),
      ),
    ),

    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        padding: AppConstants.kPaddingMedium,
        minimumSize:
            Size(AppConstants.kButtonHeight, AppConstants.kButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.kRadiusSmall),
        ),
      ),
    ),
  );

  // Dark theme definition
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    // Base colors for the dark theme
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.lightGreen,
      brightness: Brightness.dark,
    ),
    // Text styles for dark theme
    textTheme: const TextTheme(
      // Title text will be green in dark mode as requested
      titleLarge: TextStyle(
        color: Colors.green,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      // Subtitle style
      titleMedium: TextStyle(
        color: Colors.lightGreen,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      // Body text style
      bodyLarge: TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.white60,
        fontSize: 14,
      ),
    ),
    // Card theme
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: AppConstants.kDefaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        // side: const BorderSide(
        //   color: Color.fromARGB(255, 214, 211, 211),
        //   width: 5,
        // ),
      ),
    ),
    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple[700],
        padding: AppConstants.kPaddingMedium,
        minimumSize:
            Size(AppConstants.kButtonHeight, AppConstants.kButtonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.kRadiusSmall),
        ),
      ),
    ),
  );

  /// Helper method to toggle between light and dark themes
  /// Takes the current theme and returns the opposite
  static ThemeData toggleTheme(ThemeData currentTheme) {
    return currentTheme.brightness == Brightness.light ? darkTheme : lightTheme;
  }

  /// Get theme from boolean value
  /// true = light theme, false = dark theme
  static ThemeData getTheme(bool isLight) {
    return isLight ? lightTheme : darkTheme;
  }

  /// Centralized method to toggle theme across the app
  /// Updates global appTheme and persists user preference
  static Future<void> toggleAppTheme(BuildContext context) async {
    try {
      // Toggle theme preference in user object
      final newThemeValue = !globalUser.isLightTheme;

      // Update global app theme immediately
      appTheme = getTheme(newThemeValue);

      // Save user preference to database
      await globalUser.setLightTheme(newThemeValue);

      // Save theme mode to SharedPreferences for persistence across app restarts
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', newThemeValue ? 'light' : 'dark');
      print(
          "Theme saved to SharedPreferences: ${newThemeValue ? 'light' : 'dark'}");

      // Rebuild app with new theme
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      }
    } catch (e) {
      print("Error changing theme: $e");
    }
  }
}
