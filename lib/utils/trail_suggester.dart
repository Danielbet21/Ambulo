// trail_suggester.dart

import 'package:ambulo/data/database/data_manager.dart';
import 'package:ambulo/models/trail_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Holds explicit user preferences for trail recommendation.
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
  const TrailPreferences({
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

/// Suggests trails that strictly match all stated categorical preferences,
/// then ranks them with a weighted-score model.
class TrailSuggester {
  final DataManager db;
  const TrailSuggester({required this.db});

  Future<List<QueryDocumentSnapshot>> suggestTrails(
    TrailPreferences prefs, {
    int maxResults = 5,
  }) async {
    // -------------- 1. Fetch all trails ----------------
    final snapshot = await db.getAllTrails().first;
    final trails = snapshot.docs;

    // -------------- 2. Score only the trails that pass hard filters ----------
    final List<MapEntry<QueryDocumentSnapshot, double>> scored = [];

    for (final doc in trails) {
      final details = (doc.data() as Map<String, dynamic>?)?['trailDetails'];
      if (details == null || details is! Map) continue;

      // ---------- 2a. HARD FILTERS (strict match) ----------
      if (prefs.region != null && details[TrailKeys.region] != prefs.region)
        continue;
      if (prefs.difficulty != null &&
          details[TrailKeys.difficulty] != prefs.difficulty) continue;
      if (prefs.loop != null && details[TrailKeys.loop] != prefs.loop) continue;
      if (prefs.requiresPayment != null &&
          details[TrailKeys.requiresPayment] != prefs.requiresPayment) continue;
      if (prefs.trailType != null &&
          details[TrailKeys.trailType] != prefs.trailType) continue;
      if (prefs.season != null &&
          details[TrailKeys.recommendedSeason] != prefs.season) continue;
      if (prefs.surfaceType != null &&
          details[TrailKeys.surfaceType] != prefs.surfaceType) continue;
      if (prefs.maxDistance != null &&
          (details[TrailKeys.distance] ?? double.infinity) > prefs.maxDistance!)
        continue;
      if (prefs.maxEstimatedTime != null &&
          (details[TrailKeys.estimatedTime] ?? double.infinity) >
              prefs.maxEstimatedTime!) continue;

      // ---------- 2b. SOFT SCORING (weight-based ranking) ----------
      double score = 0;
      double totalWeight = 0;

      const wRegion = 1.5,
          wDifficulty = 1.5,
          wLoop = 1.0,
          wPayment = 1.0,
          wTrailType = 1.2,
          wSeason = 1.0,
          wSurface = 1.0,
          wDistance = 1.3,
          wTime = 1.3;

      void addBoolMatch(bool condition, double weight) {
        totalWeight += weight;
        if (condition) score += weight;
      }

      addBoolMatch(prefs.region != null, wRegion); // already ensured match
      addBoolMatch(prefs.difficulty != null, wDifficulty);
      addBoolMatch(prefs.loop != null, wLoop);
      addBoolMatch(prefs.requiresPayment != null, wPayment);
      addBoolMatch(prefs.trailType != null, wTrailType);
      addBoolMatch(prefs.season != null, wSeason);
      addBoolMatch(prefs.surfaceType != null, wSurface);

      // Distance closeness (lower = better)
      if (prefs.maxDistance != null) {
        totalWeight += wDistance;
        final d = (details[TrailKeys.distance] ?? 0).toDouble();
        score += wDistance * (1 - (d / prefs.maxDistance!).clamp(0.0, 1.0));
      }

      // Time closeness (lower = better)
      if (prefs.maxEstimatedTime != null) {
        totalWeight += wTime;
        final t = (details[TrailKeys.estimatedTime] ?? 0).toDouble();
        score += wTime * (1 - (t / prefs.maxEstimatedTime!).clamp(0.0, 1.0));
      }

      final normalized = totalWeight > 0 ? score / totalWeight : 0;
      scored.add(MapEntry(doc, normalized.toDouble()));
    }

    // -------------- 3. Rank & return top N ----------------
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(maxResults).map((e) => e.key).toList();
  }
}
