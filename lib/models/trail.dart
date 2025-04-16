// ignore_for_file: avoid_print

import 'package:ambulo/models/trail_alert.dart';
import 'package:gpx/gpx.dart';

import '../data/database/data_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trail_keys.dart';

class Trail {
  static Future<String> create({
    required DataManager db,
    required String name,
    required String gpx,
    Map<String, dynamic> additionalDetails = const {},
  }) async {
    final trailId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final trailDetails = {
        TrailKeys.name: name,
        TrailKeys.description: additionalDetails[TrailKeys.description] ?? '',
        TrailKeys.distance: additionalDetails[TrailKeys.distance] ?? 0.0,
        TrailKeys.region: additionalDetails[TrailKeys.region] ?? '',
        TrailKeys.loop: additionalDetails[TrailKeys.loop] ?? false,
        TrailKeys.hasWaterSections:
            additionalDetails[TrailKeys.hasWaterSections] ?? false,
        TrailKeys.nights: additionalDetails[TrailKeys.nights] ?? 0,
        TrailKeys.trailType: additionalDetails[TrailKeys.trailType] ?? '',
        TrailKeys.difficulty: additionalDetails[TrailKeys.difficulty] ?? '',
        TrailKeys.startingPoint:
            additionalDetails[TrailKeys.startingPoint] ?? '',
        TrailKeys.endingPoint: additionalDetails[TrailKeys.endingPoint] ?? '',
        TrailKeys.requiresPayment:
            additionalDetails[TrailKeys.requiresPayment] ?? false,
        TrailKeys.recommendedSeason:
            additionalDetails[TrailKeys.recommendedSeason] ?? '',
        TrailKeys.surfaceType: additionalDetails[TrailKeys.surfaceType] ?? '',
        TrailKeys.estimatedTime:
            additionalDetails[TrailKeys.estimatedTime] ?? 0,
        TrailKeys.official: additionalDetails[TrailKeys.official] ?? false,
        TrailKeys.userUid: additionalDetails[TrailKeys.userUid] ?? '',
        TrailKeys.createdAt: additionalDetails[TrailKeys.createdAt] ??
            FieldValue.serverTimestamp(),
      };

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

  static Future<void> appendWaypoint(
    DataManager db,
    String trailId,
    TrailAlert alert,
  ) async {
    try {
      final snapshot = await db.databaseService.getDocument('trails', trailId);
      final gpxRaw = snapshot?['gpx'] as String?;

      if (gpxRaw == null) return;

      final gpx = GpxReader().fromString(gpxRaw);
      gpx.wpts.add(alert.toWaypoint());

      final updatedGpx = GpxWriter().asString(gpx, pretty: true);

      await db.databaseService.updateDocument('trails', trailId, {
        'gpx': updatedGpx,
      });

      print("✅ GPX updated successfully with new alert.");
    } catch (e) {
      print("❌ Failed to append waypoint to trail: $e");
    }
  }
}
