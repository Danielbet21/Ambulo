// trail_suggester.dart

import 'package:ambulo/data/database/data_manager.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrailPreferences {
  final String? region;
  final String? difficulty;
  final bool? loop;
  final bool? requiresPayment;
  final String? trailType;
  final String? season;
  final String? surfaceType;
  final double? maxDistance;
  final int? maxEstimatedTime;

  TrailPreferences({
    this.region,
    this.difficulty,
    this.loop,
    this.requiresPayment,
    this.trailType,
    this.season,
    this.surfaceType,
    this.maxDistance,
    this.maxEstimatedTime,
  });
}

class TrailSuggester {
  final DataManager db;

  TrailSuggester({required this.db});

  Future<List<QueryDocumentSnapshot>> suggestTrails(
    TrailPreferences preferences, {
    int maxResults = 5,
  }) async {
    {
      final snapshot = await db.getAllTrails().first;
      final trails = snapshot.docs;

      List<MapEntry<QueryDocumentSnapshot, double>> scored = [];

      for (final doc in trails) {
        final details = (doc.data() as Map<String, dynamic>?)?['trailDetails'];
        if (details == null || details is! Map) continue;

        double score = 0;

        if (preferences.region != null &&
            details[TrailKeys.region] == preferences.region) score += 1;

        if (preferences.difficulty != null &&
            details[TrailKeys.difficulty] == preferences.difficulty) score += 1;

        if (preferences.loop != null &&
            details[TrailKeys.loop] == preferences.loop) score += 1;

        if (preferences.requiresPayment != null &&
            details[TrailKeys.requiresPayment] == preferences.requiresPayment)
          score += 1;

        if (preferences.trailType != null &&
            details[TrailKeys.trailType] == preferences.trailType) score += 1;

        if (preferences.season != null &&
            details[TrailKeys.recommendedSeason] == preferences.season)
          score += 1;

        if (preferences.surfaceType != null &&
            details[TrailKeys.surfaceType] == preferences.surfaceType)
          score += 1;

        if (preferences.maxDistance != null &&
            (details[TrailKeys.distance] ?? double.infinity) <=
                preferences.maxDistance!) score += 1;

        if (preferences.maxEstimatedTime != null &&
            (details[TrailKeys.estimatedTime] ?? double.infinity) <=
                preferences.maxEstimatedTime!) score += 1;

        scored.add(MapEntry(doc, score));
      }

      scored.sort((a, b) => b.value.compareTo(a.value));
      return scored.take(maxResults).map((e) => e.key).toList();
    }
  }
}
