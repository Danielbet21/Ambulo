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

// ----------- IMAGE UPLOAD ------------------

  Future<String> uploadProfilePictureManual(String userID) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return "";
    }

    final imageUrl = await uploadUserProfileImage(userID, file);
    if (imageUrl != null) {
      return imageUrl;
    }
    return "";
  }

  // Upload user profile image to Firebase Storage
  @override
  Future<String?> uploadUserProfileImage(String userId, XFile image) async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference userProfileDir = referenceRoot.child("UserProfileImages");

    // Get just the file name from the path
    String fileExtention = image.name; // TODO check if work on android
    // connect the userID with the fileName extension
    fileExtention = fileExtention.split('.').last;
    String fileName = "${userId}.$fileExtention";
    print("File name: $fileName");

    Reference referenceImageToUpload = userProfileDir.child(fileName);

    try {
      if (kIsWeb) {
        Uint8List imageBytes = await image.readAsBytes();
        await referenceImageToUpload.putData(imageBytes);
      } else {
        await referenceImageToUpload.putFile(File(image.path));
      }

      String downloadURL = await referenceImageToUpload.getDownloadURL();
      print("URL: $downloadURL");
      return downloadURL;
    } catch (error) {
      print("Error: $error");
      return "";
    }
  }

  @override
  Future<bool> deleteUserProfileImage(String imageUrl) async {
    try {
      // Delete the file from Firebase Storage
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting user profile image: $e');
      return false;
    }
  }

// ----------- TRAIL IMAGE UPLOAD ------------------
  @override
  Future<String?> uploadTrailImageManual(String trailID) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return "";
    }

    final imageUrl = await uploadTrailImage(trailID, file);
    if (imageUrl != null) {
      return imageUrl;
    }
    return "";
  }

  @override
  Future<String?> uploadTrailImage(String trailId, XFile image) async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference trailDir = referenceRoot.child("trail");
    Reference trailImagesDir = trailDir.child(trailId);

    // Get just the file name from the path
    String fileExtention = image.name; // TODO check if work on android
    // connect the userID with the fileName extension
    fileExtention = fileExtention.split('.').last;
    // get timestamp to make the file name unique
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    // create a unique file name using the trailId and timestamp
    String fileName = "${trailId}_$timeStamp.$fileExtention";
    print("File name: $fileName");

    Reference referenceImageToUpload = trailImagesDir.child(fileName);

    try {
      if (kIsWeb) {
        Uint8List imageBytes = await image.readAsBytes();
        await referenceImageToUpload.putData(imageBytes);
      } else {
        await referenceImageToUpload.putFile(File(image.path));
      }

      String downloadURL = await referenceImageToUpload.getDownloadURL();
      print("URL: $downloadURL");
      return downloadURL;
    } catch (error) {
      print("Error: $error");
      return "";
    }
  }

  @override
  Future<bool> deleteTrailImage(String imageUrl) async {
    try {
      // Delete the file from Firebase Storage
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting user profile image: $e');
      return false;
    }
  }
}
