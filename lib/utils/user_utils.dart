// ignore_for_file: avoid_print

import '../data/database/data_manager.dart';
import '../models/user.dart'; // Custom User wrapper

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
    print("👋 User signed out successfully.");
  } catch (e) {
    print("❌ logoutUser error: $e");
  }
}
