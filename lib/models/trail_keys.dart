/// This class defines all keys used in the `trailDetails` map for Trail creation.
///
/// Using these keys helps ensure consistency and avoids hardcoded strings.
/// Example usage:
///
/// ```dart
/// Trail.create(
///   db: db,
///   name: 'Sunset Hike',
///   gpx: gpxString,
///   additionalDetails: {
///     TrailKeys.region: TrailRegion.north,
///     TrailKeys.difficulty: TrailDifficulty.easy,
///     TrailKeys.loop: true,
///     TrailKeys.estimatedTime: 90,
///   },
/// );
/// ```

// ignore_for_file: dangling_library_doc_comments

class TrailKeys {
  // Basic info
  static const String name = 'name';
  static const String description = 'description';
  static const String distance = 'distance';
  static const String region = 'region';

  // Physical route attributes
  static const String loop = 'loop';
  static const String hasWaterSections = 'hasWaterSections';
  static const String nights = 'nights';
  static const String estimatedTime = 'estimatedTime';
  static const String surfaceType = 'surfaceType';

  // User experience
  static const String trailType = 'trailType'; // e.g., Kids Friendly
  static const String difficulty = 'difficulty'; // e.g., Moderate
  static const String recommendedSeason = 'recommendedSeason';

  // Logistics
  static const String startingPoint = 'startingPoint';
  static const String endingPoint = 'endingPoint';
  static const String requiresPayment = 'requiresPayment';

  // Metadata
  static const String official = 'official';
  static const String userUid = 'userUid';
  static const String createdAt = 'createdAt';
}

/// Predefined values for each key in TrailKeys
/// These should be used when building UI or storing data, to ensure consistency

class TrailRegion {
  static const String jerusalem = 'Jerusalem District';
  static const String north = 'Northern District';
  static const String haifa = 'Haifa District';
  static const String center = 'Central District';
  static const String telAviv = 'Tel Aviv District';
  static const String south = 'Southern District';
  static const String westBank = 'West Bank';

  static const List<String> values = [
    jerusalem,
    north,
    haifa,
    center,
    telAviv,
    south,
    westBank,
  ];
}

class TrailDifficulty {
  static const String easy = 'Easy';
  static const String moderate = 'Moderate';
  static const String advanced = 'Advanced Hikers';

  static const List<String> values = [
    easy,
    moderate,
    advanced,
  ];
}

class TrailType {
  static const String kids = 'Kids Friendly';
  static const String couples = 'Couples';
  static const String wheelChair = 'Wheel Chair Friendly';
  static const String dogs = 'Dog Friendly';

  static const List<String> values = [
    kids,
    couples,
    wheelChair,
    dogs,
  ];
}

class TrailSeason {
  static const String summer = 'Summer';
  static const String winter = 'Winter';
  static const String spring = 'Spring';
  static const String autumn = 'Autumn';

  static const List<String> values = [
    summer,
    winter,
    spring,
    autumn,
  ];
}

class TrailSurface {
  static const String offRoad = 'Off-Road';
  static const String paved = 'Paved';

  static const List<String> values = [
    offRoad,
    paved,
  ];
}
