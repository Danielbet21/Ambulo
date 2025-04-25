// ignore_for_file: avoid_print

import '../data/database/data_manager.dart';
import '../models/user.dart'; // Custom User wrapper
import 'package:shared_preferences/shared_preferences.dart';

/// Registers a new user, creates their Firestore profile,
/// signs them in, and returns a wrapped User object.
///
/// Returns null if registration or any step fails.
Future<User?> createAndWrapUser(
    DataManager db, String email, String password, String name) async {
  try {
    final cred = await db.register(email, password);
    if (cred == null) return null;

    final uid = cred.user?.uid;
    if (uid == null) return null;

    await db.createUserProfile(uid, name, email);
    await db.signIn(email, password);
    print("👤 User registered and signed in successfully.");
    print("👤 User ID: $uid");
    print("👤 User email: $email");
    print("👤 User name: $name");

    // Save login state
    await saveLoginState(email, password);

    return User(db);
  } catch (e) {
    print('❌ createAndWrapUser error: $e');
    return null;
  }
}

/// Signs in an existing user and returns a wrapped User object.
///
/// Returns null if login fails.
Future<User?> loginAndWrapUser(
    DataManager db, String email, String password) async {
  try {
    final cred = await db.signIn(email, password);
    if (cred == null) return null;

    print("👤 User signed in successfully.");
    print("👤 User ID: ${cred.user?.uid}");
    print("👤 User email: $email");

    // Save login state
    await saveLoginState(email, password);

    return User(db);
  } catch (e) {
    print('❌ loginAndWrapUser error: $e');
    return null;
  }
}

/// Signs out the currently logged-in user
Future<void> logoutUser(DataManager db) async {
  try {
    await db.signOut();
    await clearLoginState();
    print("👋 User signed out successfully.");
  } catch (e) {
    print("❌ logoutUser error: $e");
  }
}

/// Check if a user is currently logged in with Firebase
/// This doesn't rely on shared preferences
bool isUserLoggedIn(DataManager db) {
  return db.getCurrentUser() != null;
}

/// Save login state to shared preferences with better error handling
Future<void> saveLoginState(String email, String password) async {
  try {
    try {
      print("Attempting to save login state...");
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool('isLoggedIn', true),
        prefs.setString('userEmail', email),
        prefs.setString('userPassword', password),
      ]);
      print("💾 Login state saved successfully");
    } catch (e) {
      print("⚠️ Shared preferences not available: $e");
      // Continue even if shared preferences fails
    }
  } catch (e) {
    print("❌ Error saving login state: $e");
  }
}

/// Clear login state from shared preferences
Future<void> clearLoginState() async {
  try {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userEmail');
      await prefs.remove('userPassword');
      print("🧹 Login state cleared");
    } catch (e) {
      print("⚠️ Shared preferences not available: $e");
      // Continue even if shared preferences fails
    }
  } catch (e) {
    print("❌ Error clearing login state: $e");
  }
}

/// Save theme preference
Future<void> saveThemePreference(String themeMode) async {
  try {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', themeMode);
      print("💾 Theme preference saved: $themeMode");
    } catch (e) {
      print("⚠️ Shared preferences not available: $e");
      // Continue even if shared preferences fails
    }
  } catch (e) {
    print("❌ Error saving theme preference: $e");
  }
}
