import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'authentication_interface.dart';
import 'database_interface.dart';

class FirebaseFirestoreServices
    implements AuthenticationInterface, DatabaseInterface {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // AuthenticationInterface implementation
  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      debugPrint('Error signing in: $e');
      return null;
    }
  }

  @override
  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // DatabaseInterface implementation
  @override
  Future<void> setData(
      String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).set(data);
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
      String collection, String documentId) async {
    DocumentSnapshot doc =
        await _firestore.collection(collection).doc(documentId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Stream<DocumentSnapshot> streamDocument(
      String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  @override
  Stream<QuerySnapshot> streamCollection(String collection,
      {String? field, dynamic isEqualTo}) {
    Query query = _firestore.collection(collection);

    if (field != null && isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }

    return query.snapshots();
  }

  @override
  Future<void> updateDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  @override
  Future<String> uploadFile(String path, String fileName, File file) async {
    final reference = _storage.ref().child(path).child(fileName);
    final downloadUrl = await reference.getDownloadURL();
    return downloadUrl;
  }

  @override
  Future<void> deleteFile(String url) async {
    try {
      final reference = _storage.refFromURL(url);
      await reference.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      rethrow;
    }
  }

  @override
  Future<void> arrayUnion(
      String collection, String documentId, String field, dynamic value) async {
    await _firestore.collection(collection).doc(documentId).update({
      field: FieldValue.arrayUnion([value])
    });
  }

  @override
  Future<void> arrayRemove(
      String collection, String documentId, String field, dynamic value) async {
    await _firestore.collection(collection).doc(documentId).update({
      field: FieldValue.arrayRemove([value])
    });
  }

  @override
  Future<UserCredential?> createAdminUser(String email, String password) async {
    try {
      // For now, this can be the same as creating a regular user
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      debugPrint('Error creating admin user: $e');
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  @override
  Future<DocumentSnapshot<Object?>?> getDocumentByField(
      String collection, String field, dynamic value) async {
    try {
      final query = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return query.docs.first;
    } catch (e) {
      debugPrint('Error getting document by field: $e');
      return null;
    }
  }

  @override
  bool isAdmin() {
    // Temporarily return false or implement real logic
    return false;
  }

// firebase cloud storage
  @override
  Future<bool> uploadPicture(
      String pathToSave, String fileName, XFile file) async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirType = referenceRoot.child(pathToSave);
    Reference referenceImageToUpload = referenceDirType.child(fileName);

    // Store the file
    try {
      if (kIsWeb) {
        // For web platform - use bytes
        Uint8List imageBytes = await file.readAsBytes();
        await referenceImageToUpload.putData(imageBytes);
      } else {
        // For mobile platforms - use file
        await referenceImageToUpload.putFile(File(file.path));
      }

      // Get download URL and return it
      String downloadURL = await referenceImageToUpload.getDownloadURL();
      print("URL: $downloadURL");
      return true;
    } catch (error) {
      {
        print("Error: $error");
        return false;
      }
    }
  }

  @override
  Future<bool> uploadPictureManual(
    String type,
    String fileName,
  ) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return false;
    }

    if (await uploadPicture(type, fileName, file)) {
      return true;
    }
    return false;
  }

  @override
  Future<void> deleteUserProfilePicture(String path) async {
    try {
      final reference = _storage.ref().child(path);
      await reference.delete();
      debugPrint('Profile picture deleted successfully');
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
      rethrow;
    }
  }

  @override
  Future<String> getUserProfilePicture(String path) async {
    try {
      final reference = _storage.ref().child(path);
      final downloadUrl = await reference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error getting profile picture URL: $e');
      rethrow;
    }
  }
}
