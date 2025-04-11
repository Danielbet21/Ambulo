import 'package:ambulo/data/database/data_manager.dart';

class ImageHelpers {
  final DataManager dataManager;

  ImageHelpers({required this.dataManager});

  /// Get current user's profile image URL
  Future<String?> getCurrentUserProfileImage() async {
    final user = dataManager.getCurrentUser();
    if (user == null) return null;
    return await dataManager.getUserProfileImage(user.uid);
  }

  Future<List<String>> getTrailPhotos(String trailId) async {
    final photos = await dataManager.loadTrailPhotos(trailId);
    return photos;
  }
}
