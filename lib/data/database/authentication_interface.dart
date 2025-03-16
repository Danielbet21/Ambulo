// import 'package:ambulo/user.dart';

abstract class AuthenticationInterface {
  // Basic Email Authentication
  Future<void> signInWithEmail(String email, String password);
  Future<void> createUserWithEmail(String email, String password);
  
  // Social Authentication
  Future<void> signInWithGoogle();
  Future<void> signInWithFacebook();
  Future<void> signInWithTwitter();
  Future<void> signInWithApple();

  // Password and Verification Methods
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> updatePassword(String newPassword);

  // Sign Out and User State
  Future<void> signOut();
  // Future<User?> getCurrentUser(); // Assuming a User model is defined in your project.
  // Stream<User?> get onAuthStateChanged;
}
