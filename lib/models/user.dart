import '../data/database/data_manager.dart';

class User {
  final DataManager db;
  final String uid;

  // Cached user fields
  String? _name;
  String? _email;
  String? _selfTitle;
  Map<String, dynamic>? _preferences;
  double _totalKm = 0.0;
  double _totalElevation = 0.0;
  int _completedHikes = 0;

  User(this.db) : uid = db.getCurrentUser()?.uid ?? '' {
    if (uid.isEmpty) throw Exception('No signed-in user.');
  }

  /// Load all user data from Firestore and cache locally
  Future<void> load() async {
    final doc = await db.databaseService.getDocument('users', uid);
    _name = doc?['name'];
    _email = doc?['email'];
    _selfTitle = doc?['selfTitle'];
    _totalKm = (doc?['totalKm'] ?? 0.0).toDouble();
    _totalElevation = (doc?['totalElevation'] ?? 0.0).toDouble();
    _completedHikes = (doc?['completedHikes'] ?? 0).toInt();
    _preferences = doc?['userPreference'] ?? await db.getUserPreferences(uid);
  }

  /// Unique user ID from Firebase
  String get userUid => uid;

  // ===== Basic cached info =====
  String? get name => _name;
  String? get email => _email;
  String? get selfTitle => _selfTitle;
  Map<String, dynamic>? get preferences => _preferences;
  double get totalKm => _totalKm;
  double get totalElevation => _totalElevation;
  int get completedHikes => _completedHikes;

  // ===== Preferences shortcuts =====
  bool get isNotificationsEnabled => _preferences?['notifications'] ?? true;
  bool get isLightTheme => (_preferences?['theme'] ?? 'light') == 'light';

  /// Toggle notification preference and update cache
  Future<void> setNotifications(bool enabled) async {
    await setPreference('notifications', enabled);
    _preferences ??= {};
    _preferences!['notifications'] = enabled;
  }

  /// Toggle theme preference and update cache
  Future<void> setLightTheme(bool light) async {
    final theme = light ? 'light' : 'dark';
    await setPreference('theme', theme);
    _preferences ??= {};
    _preferences!['theme'] = theme;
  }

  // ===== Basic setters =====

  /// Set display name and sync with Firestore
  Future<void> setName(String name) async {
    await db.changeName(uid, name);
    _name = name;
  }

  /// Set self title ("Explorer", etc)
  Future<void> setSelfTitle(String title) async {
    await db.databaseService.updateDocument('users', uid, {'selfTitle': title});
    _selfTitle = title;
  }

  /// Set any user preference key-value
  Future<void> setPreference(String key, dynamic value) async {
    await db.updatePreferences(uid, key, value);
    _preferences ??= {};
    _preferences![key] = value;
  }

  // ================================
  // ==== TRAIL-SPECIFIC BINDINGS ===
  // ================================

  /// Add trailId to user's hiking history
  /// Firestore structure: hikingHistory: [trailId1, trailId2, ...]
  Future<void> completeTrail(String trailId) async {
    await db.addTrailToHistory(uid, trailId);
  }

  /// Remove trailId from user's hiking history
  Future<void> deleteCompletedTrail(String trailId) async {
    await db.deleteHikeFromHistory(uid, trailId);
  }

  /// Get list of trail IDs the user completed
  Future<List<String>> getHikingHistory() async {
    final doc = await db.databaseService.getDocument('users', uid);
    final list = List<dynamic>.from(doc?['hikingHistory'] ?? []);
    return list.map((e) => e.toString()).toList();
  }

  /// Save trail to user's savedHikes with metadata
  /// Firestore structure: savedHikes: [{ id, name, addedAt }]
  Future<void> saveTrail(String trailId, {String name = 'Unnamed'}) async {
    final entry = {
      'id': trailId,
      'name': name,
      'addedAt': DateTime.now().toIso8601String(),
    };
    await db.addToSaves(uid, entry);
  }

  /// Remove trail from user's saved list
  Future<void> unsaveTrail(String trailId) async {
    final saved = await db.databaseService.getDocument('users', uid);
    final savedList =
        List<Map<String, dynamic>>.from(saved?['savedHikes'] ?? []);
    final toRemove = savedList.firstWhere(
      (t) => t['id'] == trailId,
      orElse: () => {},
    );
    if (toRemove.isNotEmpty) {
      await db.removeTrailSaves(uid, toRemove);
    }
  }

  /// Get all saved trail IDs
  Future<List<String>> getSavedTrailIds() async {
    final doc = await db.databaseService.getDocument('users', uid);
    final saved = List<Map<String, dynamic>>.from(doc?['savedHikes'] ?? []);
    return saved.map((t) => t['id'].toString()).toList();
  }

  /// Add kilometers to the user's total and sync with Firestore
  Future<void> addUserKM(double km) async {
    _totalKm += km;
    await db.databaseService
        .updateDocument('users', uid, {'totalKm': _totalKm});
  }

  /// Add elevation to the user's total and sync with Firestore
  Future<void> addUserElevation(double elevation) async {
    _totalElevation += elevation;
    await db.databaseService
        .updateDocument('users', uid, {'totalElevation': _totalElevation});
  }
}
