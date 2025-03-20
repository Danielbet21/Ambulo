import 'dart:io';
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

  // Upload a file to storage
  Future<String> uploadFile(String path, String fileName, File file);

  // Delete a file from storage
  Future<void> deleteFile(String url);

  // Add item to an array
  Future<void> arrayUnion(
      String collection, String documentId, String field, dynamic value);

  // Remove item from an array
  Future<void> arrayRemove(
      String collection, String documentId, String field, dynamic value);

  // Get a document by field
  Future<DocumentSnapshot?> getDocumentByField(
      String collection, String field, dynamic value); // Add this line

  // upload picture
  Future<bool> uploadPicture(String path, String fileName, XFile file);

  Future<bool> uploadPictureManual(
    String type,
    String fileName,
  );

  // get user profile picture
  Future<String> getUserProfilePicture(String path);

  // delete user profile picture
  Future<void> deleteUserProfilePicture(String path);
}
