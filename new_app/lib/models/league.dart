import 'match.dart';

/// League Model for SStats.net API
class League {
  final int id;
  final String name;
  final Country? country;
  final String? flashScoreId;
  final List<Season> seasons;

  League({
    required this.id,
    required this.name,
    this.country,
    this.flashScoreId,
    this.seasons = const [],
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      flashScoreId: json['flashScoreId']?.toString(),
      seasons: (json['seasons'] as List<dynamic>?)
          ?.map((s) => Season.fromJson(s))
          .toList() ?? [],
    );
  }

  /// Get display name
  String get displayName => name;

  /// Get country name
  String? get countryName => country?.name;

  /// Get the latest/current season
  Season? get currentSeason {
    if (seasons.isEmpty) return null;
    // Sort by year descending and get the first one
    final sorted = [...seasons]..sort((a, b) => b.year.compareTo(a.year));
    return sorted.first;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country?.toJson(),
    'flashScoreId': flashScoreId,
    'seasons': seasons.map((s) => s.toJson()).toList(),
  };
}

/// Season Model for SStats.net API
class Season {
  final String uid;
  final int year;
  final League? league;
  final String? dateStart;
  final String? dateEnd;
  final String? flashScoreId;

  Season({
    required this.uid,
    required this.year,
    this.league,
    this.dateStart,
    this.dateEnd,
    this.flashScoreId,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      uid: json['uid']?.toString() ?? '',
      year: json['year'] ?? 0,
      league: json['league'] != null ? League.fromJson(json['league']) : null,
      dateStart: json['dateStart']?.toString(),
      dateEnd: json['dateEnd']?.toString(),
      flashScoreId: json['flashScoreId']?.toString(),
    );
  }

  /// Get season name for display
  String get name => year.toString();

  /// Get season ID (uid)
  String get id => uid;

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'year': year,
    'league': league?.toJson(),
    'dateStart': dateStart,
    'dateEnd': dateEnd,
    'flashScoreId': flashScoreId,
  };
}
