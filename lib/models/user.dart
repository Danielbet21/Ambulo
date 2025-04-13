import '../data/database/data_manager.dart';

class User {
  final DataManager db;
  final String uid;

  // Constructor: wraps DataManager and gets the current signed-in user ID
  User(this.db) : uid = db.getCurrentUser()?.uid ?? '' {
    if (uid.isEmpty) throw Exception('No signed-in user.');
  }

  /// Returns the user's UID
  String get userUid => uid;

  /// Helper to fetch the full user document from Firestore
  Future<Map<String, dynamic>?> _getUserDoc() async {
    return await db.databaseService.getDocument('users', uid);
  }

  /// Gets the user's display name
  Future<String?> getName() async {
    final doc = await _getUserDoc();
    return doc?['name'];
  }

  /// Updates the user's display name
  Future<void> setName(String name) async {
    await db.changeName(uid, name);
  }

  /// Gets the user's email address
  Future<String?> getEmail() async {
    final doc = await _getUserDoc();
    return doc?['email'];
  }

  /// Gets the user's preferences (theme, language, etc.)
  Future<Map<String, dynamic>?> getPreferences() async {
    return await db.getUserPreferences(uid);
  }

  /// Updates a single preference key (e.g., theme, language)
  Future<void> setPreference(String key, dynamic value) async {
    await db.updatePreferences(uid, key, value);
  }

  /// Gets the user's self-defined title
  Future<String?> getSelfTitle() async {
    final doc = await _getUserDoc();
    return doc?['selfTitle'];
  }

  /// Gets the total kilometers hiked
  Future<double> getTotalKm() async {
    final doc = await _getUserDoc();
    return (doc?['totalKm'] ?? 0.0).toDouble();
  }

  /// Gets the total elevation gained
  Future<double> getTotalElevation() async {
    final doc = await _getUserDoc();
    return (doc?['totalElevation'] ?? 0.0).toDouble();
  }

  /// Gets the number of completed hikes
  Future<int> getCompletedHikes() async {
    final doc = await _getUserDoc();
    return (doc?['completedHikes'] ?? 0) as int;
  }

  /// Gets the user's hiking history (list of completed trails)
  Future<List<Map<String, dynamic>>> getHikingHistory() async {
    return await db.showHikingHistory(uid);
  }

  /// Removes a specific hike from the user's history
  Future<void> deleteHike(Map<String, dynamic> hike) async {
    await db.deleteHikeFromHistory(uid, hike);
  }

  /// Adds a trail to the user's saved hikes
  Future<void> addToSaved(Map<String, dynamic> trail) async {
    await db.addToSaves(uid, trail);
  }

  /// Removes a trail from the user's saved hikes
  Future<void> removeFromSaved(Map<String, dynamic> trail) async {
    await db.removeTrailSaves(uid, trail);
  }
}
