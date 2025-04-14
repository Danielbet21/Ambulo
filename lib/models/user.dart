import '../data/database/data_manager.dart';

class User {
  final DataManager db;
  final String uid;

  // Local cached fields
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

  /// Loads user data from Firestore into local cache
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

  /// UID getter
  String get userUid => uid;

  /// Local getters (synchronous)
  String? get name => _name;
  String? get email => _email;
  String? get selfTitle => _selfTitle;
  Map<String, dynamic>? get preferences => _preferences;
  double get totalKm => _totalKm;
  double get totalElevation => _totalElevation;
  int get completedHikes => _completedHikes;

  /// Preference shortcuts
  bool get isNotificationsEnabled => _preferences?['notifications'] ?? true;
  bool get isLightTheme => (_preferences?['theme'] ?? 'light') == 'light';

  Future<void> setNotifications(bool enabled) async {
    await setPreference('notifications', enabled);
    _preferences ??= {};
    _preferences!['notifications'] = enabled;
  }

  Future<void> setLightTheme(bool light) async {
    final theme = light ? 'light' : 'dark';
    await setPreference('theme', theme);
    _preferences ??= {};
    _preferences!['theme'] = theme;
  }

  /// Setters update both Firebase and local cache
  Future<void> setName(String name) async {
    await db.changeName(uid, name);
    _name = name;
  }

  Future<void> setSelfTitle(String title) async {
    await db.databaseService.updateDocument('users', uid, {'selfTitle': title});
    _selfTitle = title;
  }

  Future<void> setPreference(String key, dynamic value) async {
    await db.updatePreferences(uid, key, value);
    _preferences ??= {};
    _preferences![key] = value;
  }

  /// Get user's hiking history (live from DB)
  Future<List<Map<String, dynamic>>> getHikingHistory() async {
    return await db.showHikingHistory(uid);
  }

  /// Remove specific hike from history
  Future<void> deleteHike(Map<String, dynamic> hike) async {
    await db.deleteHikeFromHistory(uid, hike);
  }

  /// Add trail to saved hikes
  Future<void> addToSaved(Map<String, dynamic> trail) async {
    await db.addToSaves(uid, trail);
  }

  /// Remove trail from saved hikes
  Future<void> removeFromSaved(Map<String, dynamic> trail) async {
    await db.removeTrailSaves(uid, trail);
  }
}
