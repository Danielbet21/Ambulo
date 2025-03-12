import 'package:flutter/material.dart';

/// App-wide constants for consistent styling
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Spacing values
  static const double kSpacingXS = 4.0;
  static const double kSpacingSmall = 8.0;
  static const double kSpacingMedium = 16.0;
  static const double kSpacingLarge = 24.0;
  static const double kSpacingXL = 32.0;
  static const double kSpacingXXL = 48.0;

  // Widget sizes
  static const double kButtonHeight = 48.0;
  static const double kSmallButtonHeight = 36.0;
  static const double kIconSize = 24.0;
  static const double kLargeIconSize = 32.0;
  static const double kCardWidth = 300.0;

  // Border radius values
  static const double kRadiusSmall = 4.0;
  static const double kRadiusMedium = 8.0;
  static const double kRadiusLarge = 12.0;
  static const double kRadiusCircular = 999.0;

  // Animation durations
  static const Duration kDurationFast = Duration(milliseconds: 200);
  static const Duration kDurationMedium = Duration(milliseconds: 300);
  static const Duration kDurationSlow = Duration(milliseconds: 500);

  // Default card elevation
  static const double kDefaultElevation = 2.0;

  // Default paddings
  static const EdgeInsets kPaddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets kPaddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets kPaddingLarge = EdgeInsets.all(24.0);
}