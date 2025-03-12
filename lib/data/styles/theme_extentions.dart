import 'package:flutter/material.dart';

/// Extension methods for BuildContext to simplify access to theme properties
extension ThemeExtension on BuildContext {
  // Get the full theme
  ThemeData get theme => Theme.of(this);

  // Get just the text theme - this allows for shorter syntax like:
  // context.textTheme.titleLarge instead of Theme.of(context).textTheme.titleLarge
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Get just the color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}