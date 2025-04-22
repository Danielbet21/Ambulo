// ignore_for_file: avoid_print

import 'package:ambulo/models/trail_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'authentication_interface.dart';
import 'database_interface.dart';

enum UploadType { userPhoto, trailPhoto, finishedTrails }

class DataManager {
  final AuthenticationInterface authService;
  final DatabaseInterface databaseService;

  DataManager({required this.authService, required this.databaseService});

  // List of admin emails
  final List<String> adminEmails = [
    "adminautotest@example.com",
    "admin2@example.com",
    "admin3@example.com"
  ];

  // ----------- Auth Part -----------

  // Get the currently authenticated user
  User? getCurrentUser() {
    return authService.getCurrentUser();
  }

  // Register a new user with email and password
  Future<UserCredential?> register(String email, String password) async {
    return await authService.createUserWithEmailAndPassword(email, password);
  }

  // Sign in an existing user with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    return await authService.signInWithEmailAndPassword(email, password);
  }

  // Sign out the current user
  Future<void> signOut() async {
    await authService.signOut();
  }

  // Delete the currently authenticated user
  Future<void> deleteUser() async {
    await authService.deleteUser();
  }

  Future<void> deleteUserFromDB(String userId) async {
    // delete user profile image if exists
    final userDoc = await databaseService.getDocument('users', userId);
    if (userDoc != null && userDoc['userPhotoPath'] != null) {
      final imageUrl = userDoc['userPhotoPath'];
      await databaseService.deleteUserProfileImage(imageUrl);
    }
    // delete user document from Firestore
    await databaseService.deleteDocument("users", userId);
    // delete user authentication account
    await deleteUser();
  }

  // ----------- User Part -----------

  // Create a new user profile in Firestore
  Future<void> createUserProfile(
      String userId, String name, String email) async {
    await databaseService.setData('users', userId, {
      'name': name,
      'email': email,
      'userPhotoPath': '',
      'userPreference': {
        'theme': 'light',
        'notifications': true,
        'language': 'en',
      },
      'hikingHistory': [],
      'savedHikes': [],
      'totalKm': 0.0,
      'totalElevation': 0.0,
      'completedHikes': 0,
      'selfTitle': '',
    });
  }

  // Get a user's profile as a stream
  Stream<DocumentSnapshot> getUserProfile(String userId) {
    return databaseService.streamDocument('users', userId);
  }

  // Update a user's preferences
  Future<void> updatePreferences(
      String userId, String key, dynamic value) async {
    await databaseService.updateDocument('users', userId, {
      'userPreference.$key': value,
    });
  }

  // Get a user's preferences
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    final doc = await databaseService.getDocument('users', userId);
    if (doc != null && doc['userPreference'] != null) {
      return Map<String, dynamic>.from(doc['userPreference']);
    }
    return null;
  }

  // Change the user's name
  Future<void> changeName(String userId, String name) async {
    await databaseService.updateDocument('users', userId, {'name': name});
  }

  // Add a trail to the user's hiking history
  Future<void> addTrailToHistory(String uid, String trailId) async {
    await databaseService.arrayUnion('users', uid, 'hikingHistory', trailId);
  }

  // Remove a hike from the user's history
  Future<void> deleteHikeFromHistory(String uid, String trailId) async {
    await databaseService.arrayRemove('users', uid, 'hikingHistory', trailId);
  }

  // Get the count of trails in a user's hiking history
  Future<int> getHikingHistoryCount(String userId) async {
    final doc = await databaseService.getDocument('users', userId);
    if (doc != null && doc['hikingHistory'] != null) {
      return List.from(doc['hikingHistory']).length;
    }
    return 0;
  }

  // Get the user's hiking history
  Future<List<Map<String, dynamic>>> showHikingHistory(String userId) async {
    final doc = await databaseService.getDocument('users', userId);
    if (doc != null && doc['hikingHistory'] != null) {
      return List<Map<String, dynamic>>.from(doc['hikingHistory']);
    }
    return [];
  }

  // Get trails from the user's hiking history
  Future<List<Map<String, dynamic>>> getTrailsFromHikingHistory(
      String userId) async {
    final userDoc = await databaseService.getDocument('users', userId);
    if (userDoc == null || userDoc['hikingHistory'] == null) {
      return [];
    }

    final hikingHistory = List<String>.from(userDoc['hikingHistory']);
    final trails = await Future.wait(hikingHistory.map((trailId) async {
      final trailDoc = await databaseService.getDocument('trails', trailId);
      if (trailDoc != null) {
        return {'id': trailId, ...trailDoc};
      }
      return null;
    }));

    return trails.whereType<Map<String, dynamic>>().toList();
  }

  // Add a trail to the user's saved hikes
  Future<void> addToSaves(String userId, Map<String, dynamic> trail) async {
    await databaseService.arrayUnion('users', userId, 'savedHikes', trail);
  }

  // Remove a trail from the user's saved hikes
  Future<void> removeTrailSaves(
      String userId, Map<String, dynamic> trail) async {
    await databaseService.arrayRemove('users', userId, 'savedHikes', trail);
  }

  // Remove a trail from the user's saved hikes by ID
  Future<void> removeTrailFromSavedHikes(String userId, String trailId) async {
    final userDoc = await databaseService.getDocument('users', userId);
    if (userDoc == null || userDoc['savedHikes'] == null) {
      return;
    }

    final savedHikes = List<Map<String, dynamic>>.from(userDoc['savedHikes']);
    final updatedSavedHikes =
        savedHikes.where((hike) => hike['id'] != trailId).toList();

    await databaseService.updateDocument('users', userId, {
      'savedHikes': updatedSavedHikes,
    });
  }

  // Get trails from the user's saved hikes
  Future<List<Map<String, dynamic>>> getTrailsFromSavedHikes(
      String userId) async {
    final userDoc = await databaseService.getDocument('users', userId);
    if (userDoc == null || userDoc['savedHikes'] == null) {
      return [];
    }

    final savedHikes = List<Map<String, dynamic>>.from(userDoc['savedHikes']);
    final trails = await Future.wait(savedHikes.map((savedHike) async {
      final trailId = savedHike['id'];
      final trailDoc = await databaseService.getDocument('trails', trailId);
      if (trailDoc != null) {
        return {'id': trailId, ...trailDoc};
      }
      return null;
    }));

    return trails.whereType<Map<String, dynamic>>().toList();
  }

  // Upload a user profile image manually
  Future<String> uploadProfilePictureManual(String userID) async {
    final imagePath = await databaseService.uploadProfilePictureManual(userID);
    if (imagePath.isNotEmpty) {
      await databaseService.updateDocument('users', userID, {
        'userPhotoPath': imagePath,
      });
      return imagePath;
    } else {
      throw Exception("Failed to upload image");
    }
  }

  // Upload a user profile image
  Future<String?> uploadUserProfileImage(String userId, XFile image) async {
    final imagePath =
        await databaseService.uploadUserProfileImage(userId, image);

    if (imagePath != null) {
      await databaseService.updateDocument('users', userId, {
        'userPhotoPath': imagePath,
      });
      return imagePath;
    } else {
      throw Exception("Failed to upload image");
    }
  }

  // Delete a user profile image
  Future<bool> deleteUserProfileImage(String imageUrl) async {
    final imagePath = await databaseService.deleteUserProfileImage(imageUrl);
    if (imagePath) {
      await databaseService.updateDocument('users', getCurrentUser()!.uid, {
        'userPhotoPath': '',
      });
      return true;
    } else {
      throw Exception("Failed to delete image");
    }
  }

  // Get user profile image by user ID
  Future<String?> getUserProfileImage(String userId) async {
    final doc = await databaseService.getDocument('users', userId);
    if (doc != null && doc['userPhotoPath'] != null) {
      return doc['userPhotoPath'];
    }
    return null;
  }

  Future<String?> loadUserProfileImageForCurrentUser() async {
    final user = getCurrentUser();
    if (user != null) {
      return await getUserProfileImage(user.uid);
    }
    return null;
  }

  // ----------- Admin Part -----------

  // Check if the current user is an admin
  bool isAdmin() {
    final user = getCurrentUser();
    if (user == null) return false;
    return adminEmails.contains(user.email);
  }

  Future<void> createAdminUser(String email, String password) async {
    if (!isAdmin()) throw Exception("Only an admin can create new admin users");
    adminEmails.add(email);
    await authService.createUserWithEmailAndPassword(email, password);
  }

  Future<void> disableUserAccount(String email) async {
    if (!isAdmin()) throw Exception("Only an admin can disable accounts");
    final docSnap =
        await databaseService.getDocumentByField("users", "email", email);
    if (docSnap == null) throw Exception("User not found");
    await databaseService
        .updateDocument("users", docSnap.id, {"disabled": true});
  }

  Future<void> deleteUserAccount(String email) async {
    final docSnap =
        await databaseService.getDocumentByField("users", "email", email);
    if (docSnap == null) throw Exception("User not found");
    await databaseService.deleteDocument("users", docSnap.id);
  }

  // ----------- Trail Part -----------

  // Create a new trail with required attributes
  Future<void> createTrail(
      String trailId, Map<String, dynamic> trailData) async {
    await databaseService.setData('trails', trailId, {
      'official': trailData['trailDetails']?[TrailKeys.official] ?? false,
      'trailDetails': trailData['trailDetails'] ?? {},
      'photosURL': [],
      'gpx': trailData['gpx'] ?? '',
      'uploadDate': DateTime.now().millisecondsSinceEpoch,
      'uploadBy': getCurrentUser()?.uid,
      'rating': 0.0,
      'likes': 0,
      'comment': 0,
      'mosquitoRate': 0.0,
    });
  }

  // Stream trail data
  Stream<DocumentSnapshot> getTrail(String trailId) {
    return databaseService.streamDocument('trails', trailId);
  }

  // Edit trail details
  Future<bool> editTrailDetails(
      String trailId, String key, dynamic value) async {
    try {
      await databaseService.updateDocument('trails', trailId, {
        'trailDetails.$key': value,
      });
      return true;
    } catch (e) {
      print("Error updating trail details: $e");
      return false;
    }
  }

  // Edit trail map - placeholder function that would be implemented
  // with actual map editing functionality in the UI
  Future<void> editTrailMap(String trailId) async {
    print("Opening map editor for trail $trailId");
  }

  // Write description to trail
  Future<bool> writeDescription(String trailId, String description) async {
    try {
      await databaseService.updateDocument('trails', trailId, {
        'trailDetails.${TrailKeys.description}': description,
      });
      return true;
    } catch (e) {
      print("Error updating trail description: $e");
      return false;
    }
  }

  // Get all trails
  Stream<QuerySnapshot> getAllTrails() {
    return databaseService.streamCollection('trails');
  }

  // Update trail rating
  Future<void> updateTrailRating(String trailId, double rating) async {
    final trailData = await databaseService.getDocument('trails', trailId);
    int currentRatings = trailData?['ratingCount'] ?? 0;
    double currentRating = trailData?['rating'] ?? 0.0;

    double newRating =
        ((currentRating * currentRatings) + rating) / (currentRatings + 1);

    await databaseService.updateDocument('trails', trailId, {
      'rating': newRating,
      'ratingCount': currentRatings + 1,
    });
  }

  // Update mosquito rating
  Future<void> updateMosquitoRating(String trailId, double rating) async {
    if (rating < 0 || rating > 5) {
      throw Exception("Rating must be between 0 and 5");
    }
    final trailData = await databaseService.getDocument('trails', trailId);
    int currentRatings = trailData?['mosquitoRatings'] ?? 0;
    double currentRate = trailData?['mosquitoRate'] ?? 0.0;

    double newRate =
        ((currentRate * currentRatings) + rating) / (currentRatings + 1);

    await databaseService.updateDocument('trails', trailId, {
      'mosquitoRate': newRate,
      'mosquitoRatings': currentRatings + 1,
    });
  }

  // Delete a trail
  Future<void> deleteTrail(String trailId) async {
    try {
      // 1. Remove trail images
      final trailDoc = await databaseService.getDocument('trails', trailId);
      if (trailDoc != null && trailDoc['photosURL'] != null) {
        final photos = List<String>.from(trailDoc['photosURL']);
        for (final photo in photos) {
          await deleteTrailImage(trailId, photo);
        }
      }

      // 2. Remove trail references from all users
      final usersQuerySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      for (final userDoc in usersQuerySnapshot.docs) {
        final userId = userDoc.id;

        // Remove from savedHikes
        await removeTrailFromSavedHikes(userId, trailId);

        // Remove from hikingHistory
        await deleteHikeFromHistory(userId, trailId);
      }

      // 3. Delete the trail document
      await databaseService.deleteDocument('trails', trailId);
      print("Trail $trailId successfully deleted with all references.");
    } catch (e) {
      print("Error deleting trail: $e");
      throw Exception("Failed to delete trail: $e");
    }
  }

  // Upload a trail image manually
  Future<String?> uploadTrailImageManual(String trailID) async {
    final imagePath = await databaseService.uploadTrailImageManual(trailID);
    if (imagePath != null) {
      await databaseService.updateDocument('trails', trailID, {
        'photosURL': FieldValue.arrayUnion([imagePath]),
      });
      return imagePath;
    } else {
      throw Exception("Failed to upload image");
    }
  }

  // Upload a trail image
  Future<String?> uploadTrailImage(String trailId, XFile image) async {
    final imagePath = await databaseService.uploadTrailImage(trailId, image);
    if (imagePath != null) {
      await databaseService.updateDocument('trails', trailId, {
        'photosURL': FieldValue.arrayUnion([imagePath]),
      });
      return imagePath;
    } else {
      throw Exception("Failed to upload image");
    }
  }

  // Delete a trail image
  Future<bool> deleteTrailImage(String trailID, String imageUrl) async {
    final imagePath = await databaseService.deleteTrailImage(imageUrl);
    if (imagePath) {
      await databaseService.updateDocument('trails', trailID, {
        'photosURL': FieldValue.arrayRemove([imageUrl]),
      });
      return true;
    } else {
      throw Exception("Failed to delete image");
    }
  }

  Future<List<String>> loadTrailPhotos(String trailId) async {
    final doc = await databaseService.getDocument('trails', trailId);
    if (doc != null && doc['photosURL'] != null) {
      return List<String>.from(doc['photosURL']);
    }
    return [];
  }
}
