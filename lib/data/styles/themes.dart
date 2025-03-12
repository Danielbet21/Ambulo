// ignore_for_file: prefer_const_constructors

import 'package:ambulo/data/styles/conatant.dart';
import 'package:flutter/material.dart';


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
      // Title text will be yellow in light mode as requested
      titleLarge: TextStyle(
        color: Colors.yellow,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      // Subtitle style
      titleMedium: TextStyle(
        color: Colors.orange,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      // Body text style
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
        borderRadius: BorderRadius.circular(AppConstants.kRadiusMedium),
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
      seedColor: Colors.deepPurple,
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
      color: Colors.grey[850],
      elevation: AppConstants.kDefaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.kRadiusMedium),
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
}