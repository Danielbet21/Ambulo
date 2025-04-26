import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthenticationInterface {
  // Get the currently signed-in user
  User? getCurrentUser();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password);

  // Register a new user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password);

  // Sign out the current user
  Future<void> signOut();

  // Delete the current user
  Future<void> deleteUser();

  // Create an admin user
  Future<UserCredential?> createAdminUser(String email, String password);

  // Check if the current user is an admin
  bool isAdmin();

  // Reset password for a user
  Future<void> resetPassword(String email);
}
