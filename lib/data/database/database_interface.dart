import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

abstract class DatabaseInterface {
  // Create or update a document
  Future<void> setData(
      String collection, String documentId, Map<String, dynamic> data);

  // Get a document by ID
  Future<Map<String, dynamic>?> getDocument(
      String collection, String documentId);

  // Stream a specific document
  Stream<DocumentSnapshot> streamDocument(String collection, String documentId);

  // Stream a collection with optional query
  Stream<QuerySnapshot> streamCollection(String collection,
      {String? field, dynamic isEqualTo});

  // Update a document
  Future<void> updateDocument(
      String collection, String documentId, Map<String, dynamic> data);

  // Delete a document
  Future<void> deleteDocument(String collection, String documentId);

  // Add item to an array
  Future<void> arrayUnion(
      String collection, String documentId, String field, dynamic value);

  // Remove item from an array
  Future<void> arrayRemove(
      String collection, String documentId, String field, dynamic value);

  // Get a document by field
  Future<DocumentSnapshot?> getDocumentByField(
      String collection, String field, dynamic value); // Add this line

  // Upload a user profile image
  Future<String> uploadProfilePictureManual(String userID);

  Future<String?> uploadUserProfileImage(String userId, XFile image);

  Future<bool> deleteUserProfileImage(String imageUrl);

  // trail upload images
  Future<String?> uploadTrailImageManual(String trailID);

  Future<String?> uploadTrailImage(String trailId, XFile image);

  Future<bool> deleteTrailImage(String imageUrl);
}
