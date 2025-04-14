// ignore_for_file: avoid_print

import '../data/database/data_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Trail {
  
  static Future<String> create({
    required DataManager db,
    required String name,
    required String gpx,
    Map<String, dynamic> additionalDetails = const {},
  }) async {
    final trailId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final trailDetails = {'name': name, ...additionalDetails};
      final data = {
        'trailDetails': trailDetails,
        'gpx': gpx,
      };
      await db.createTrail(trailId, data);
      return trailId;
    } catch (e) {
      throw Exception('Failed to create trail: $e');
    }
  }

  static Future<bool> editDetails(
      DataManager db, String trailId, String key, dynamic value) async {
    try {
      return await db.editTrailDetails(trailId, key, value);
    } catch (e) {
      print('Error editing trail details: $e');
      return false;
    }
  }

  static Future<void> editMap(DataManager db, String trailId) async {
    try {
      await db.editTrailMap(trailId);
    } catch (e) {
      print('Error editing trail map: $e');
    }
  }

  static Future<bool> writeDescription(
      DataManager db, String trailId, String description) async {
    try {
      return await db.writeDescription(trailId, description);
    } catch (e) {
      print('Error writing trail description: $e');
      return false;
    }
  }

  static Stream<DocumentSnapshot> stream(DataManager db, String trailId) {
    return db.getTrail(trailId);
  }

  static Future<void> updateRating(
      DataManager db, String trailId, double rating) async {
    try {
      if (rating < 0 || rating > 5)
        throw Exception('Rating must be between 0 and 5');
      await db.updateTrailRating(trailId, rating);
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  static Future<void> updateMosquitoRating(
      DataManager db, String trailId, double rating) async {
    try {
      if (rating < 0 || rating > 5) {
        throw Exception('Rating must be between 0 and 5');
      }
      await db.updateMosquitoRating(trailId, rating);
    } catch (e) {
      print('Error updating mosquito rating: $e');
    }
  }

  static Future<void> delete(DataManager db, String trailId) async {
    try {
      await db.deleteTrail(trailId);
    } catch (e) {
      print('Error deleting trail: $e');
    }
  }
}
