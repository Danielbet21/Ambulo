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

  // ----------- User Part -----------

  // Create a new user profile in Firestore
  Future<void> createUserProfile(
      String userId, String name, String email) async {
    await databaseService.setData('users', userId, {
      'name': name,
      'email': email,
      'userPhoto': '',
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
    final trailData = await databaseService.getDocument('trails', trailId);
    if (trailData != null) {
      await databaseService.arrayUnion('users', uid, 'hikingHistory', {
        'trailId': trailId,
        'date': DateTime.now().millisecondsSinceEpoch,
        'trailDetails': trailData['trailDetails'] ?? {},
      });
    } else {
      throw Exception("Trail not found");
    }
  }

  // Get a user's hiking history
  Future<List<Map<String, dynamic>>> showHikingHistory(String userId) async {
    final doc = await databaseService.getDocument('users', userId);
    if (doc != null && doc['hikingHistory'] != null) {
      return List<Map<String, dynamic>>.from(doc['hikingHistory']);
    }
    return [];
  }

  // Remove a hike from the user's history
  Future<void> deleteHikeFromHistory(
      String userId, Map<String, dynamic> hike) async {
    await databaseService.arrayRemove('users', userId, 'hikingHistory', hike);
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
    if (!isAdmin()) throw Exception("Only an admin can delete accounts");
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
      'trackId': trailData['trackId'],
      'trailDetails': trailData['trailDetails'] ?? {},
      'photos': [],
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

  // Add photo to a trail
  Future<bool> addPhotoToTrail(String trailId, XFile photo) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String path = "Images/Trails/$trailId";

    bool success = await databaseService.uploadPicture(path, fileName, photo);

    if (success) {
      // Get the URL of the uploaded photo
      String photoUrl =
          await databaseService.getUserProfilePicture("$path/$fileName");

      // Add the URL to the trail's photos array
      await databaseService.arrayUnion('trails', trailId, 'photos', photoUrl);
      return true;
    }
    return false;
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
    // This method would typically open a map editor interface
    // or process GPX file updates
    print("Opening map editor for trail $trailId");
  }

  // Write description to trail
  Future<bool> writeDescription(String trailId, String description) async {
    try {
      await databaseService.updateDocument('trails', trailId, {
        'trailDetails.description': description,
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
    // Get current rating data
    final trailData = await databaseService.getDocument('trails', trailId);
    int currentRatings = trailData?['ratingCount'] ?? 0;
    double currentRating = trailData?['Rating'] ?? 0.0;

    // Calculate new average rating
    double newRating =
        ((currentRating * currentRatings) + rating) / (currentRatings + 1);

    // Update rating data
    await databaseService.updateDocument('trails', trailId, {
      'rating': newRating,
      'ratingCount': currentRatings + 1,
    });
  }

  // Update mosquito rating
  Future<void> updateMosquitoRating(String trailId, double rating) async {
    // Similar to trail rating, but for mosquito presence
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
    await databaseService.deleteDocument('trails', trailId);
  }

  // ----------- Images Part -----------
  // Upload a picture to storage
  Future<bool> uploadPicture(
      String path, String objectId, String fileName, XFile file) async {
    return await databaseService.uploadPicture(path, fileName, file);
  }

  // Upload a picture to storage manually
  Future<bool> uploadPictureManual(
    Enum type,
    String objectId,
  ) async {
    String filePath = "Images";
    String typePath = "";
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    if (type == UploadType.userPhoto) {
      typePath = "Users";
      fileName = "profilePicture";
    } else if (type == UploadType.trailPhoto) {
      typePath = "Trails";
    }
    filePath = "$filePath/$typePath/$objectId";
    print("filePath: $filePath");
    return await databaseService.uploadPictureManual(filePath, fileName);
  }

  // Upload Finished Trails Picture
  Future<bool> uploadFinishedTrailsPictureManual(
      String userID, String trailID) async {
    String filePath = "Images/Users/$userID/FinishedTrails/$trailID";
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    return await databaseService.uploadPictureManual(filePath, fileName);
  }

  // Get a user's profile picture
  Future<String> getUserProfilePicture(String userId) async {
    String path = "Images/Users/$userId/profilePicture";
    path = "${path}.jpg";
    print(path);

    return await databaseService.getUserProfilePicture(path);
  }

  // Delete a user's profile picture
  Future<void> deleteUserProfilePicture(String userId) async {
    String path = "Images/Users/$userId/profilePicture";
    await databaseService.deleteUserProfilePicture(path);
  }
}
