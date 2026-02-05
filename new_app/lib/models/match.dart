import 'dart:convert';

/// Country Model
class Country {
  final String code;
  final String name;

  Country({
    required this.code,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic>? json) {
    return Country(
      code: json?['code']?.toString() ?? '',
      name: json?['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'code': code, 'name': name};
}

/// Team in match context
class MatchTeam {
  final int id;
  final String name;
  final String? flashId;
  final String? logoUrl;
  final Country? country;

  MatchTeam({
    required this.id,
    required this.name,
    this.flashId,
    this.logoUrl,
    this.country,
  });

  factory MatchTeam.fromJson(Map<String, dynamic>? json) {
    return MatchTeam(
      id: json?['id'] ?? 0,
      name: json?['name']?.toString() ?? '',
      flashId: json?['flashId']?.toString(),
      logoUrl: json?['logoUrl']?.toString(),
      country: json?['country'] != null ? Country.fromJson(json!['country']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'flashId': flashId,
    'logoUrl': logoUrl,
    'country': country?.toJson(),
  };
}

/// Season in match context
class MatchSeason {
  final String uid;
  final int year;
  final MatchLeague? league;

  MatchSeason({
    required this.uid,
    required this.year,
    this.league,
  });

  factory MatchSeason.fromJson(Map<String, dynamic>? json) {
    return MatchSeason(
      uid: json?['uid']?.toString() ?? '',
      year: json?['year'] ?? 0,
      league: json?['league'] != null ? MatchLeague.fromJson(json!['league']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'year': year,
    'league': league?.toJson(),
  };
}

/// League in match context
class MatchLeague {
  final int id;
  final String name;
  final Country? country;
  final String? flashScoreId;

  MatchLeague({
    required this.id,
    required this.name,
    this.country,
    this.flashScoreId,
  });

  factory MatchLeague.fromJson(Map<String, dynamic>? json) {
    return MatchLeague(
      id: json?['id'] ?? 0,
      name: json?['name']?.toString() ?? '',
      country: json?['country'] != null ? Country.fromJson(json!['country']) : null,
      flashScoreId: json?['flashScoreId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country?.toJson(),
    'flashScoreId': flashScoreId,
  };
}

/// Single Odd Value
class OddValue {
  final String name;
  final double value;
  final double? openingValue;

  OddValue({
    required this.name,
    required this.value,
    this.openingValue,
  });

  factory OddValue.fromJson(Map<String, dynamic>? json) {
    return OddValue(
      name: json?['name']?.toString() ?? '',
      value: (json?['value'] ?? 0).toDouble(),
      openingValue: json?['openingValue']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'openingValue': openingValue,
  };
}

/// Odds Market
class OddsMarket {
  final int marketId;
  final String marketName;
  final List<OddValue> odds;

  OddsMarket({
    required this.marketId,
    required this.marketName,
    required this.odds,
  });

  factory OddsMarket.fromJson(Map<String, dynamic>? json) {
    return OddsMarket(
      marketId: json?['marketId'] ?? 0,
      marketName: json?['marketName']?.toString() ?? '',
      odds: (json?['odds'] as List<dynamic>?)
          ?.map((o) => OddValue.fromJson(o))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'marketId': marketId,
    'marketName': marketName,
    'odds': odds.map((o) => o.toJson()).toList(),
  };

  /// Get 1X2 odds
  double? get homeWin => odds.where((o) => o.name == '1' || o.name.toLowerCase() == 'home').firstOrNull?.value;
  double? get draw => odds.where((o) => o.name == 'X' || o.name.toLowerCase() == 'draw').firstOrNull?.value;
  double? get awayWin => odds.where((o) => o.name == '2' || o.name.toLowerCase() == 'away').firstOrNull?.value;
}

/// Match Model for SStats.net API
class Match {
  final int id;
  final String? flashId;
  final String? date;
  final String? dateUtc;
  final int? status;
  final String? statusName;
  final int? elapsed;
  final int? extraMinutes;
  final int? homeResult;
  final int? awayResult;
  final int? homeHTResult;
  final int? awayHTResult;
  final int? homeFTResult;
  final int? awayFTResult;
  final MatchTeam homeTeam;
  final MatchTeam awayTeam;
  final MatchSeason? season;
  final String? roundName;
  final List<OddsMarket> odds;

  Match({
    required this.id,
    this.flashId,
    this.date,
    this.dateUtc,
    this.status,
    this.statusName,
    this.elapsed,
    this.extraMinutes,
    this.homeResult,
    this.awayResult,
    this.homeHTResult,
    this.awayHTResult,
    this.homeFTResult,
    this.awayFTResult,
    required this.homeTeam,
    required this.awayTeam,
    this.season,
    this.roundName,
    this.odds = const [],
  });

  /// Match status helpers
  bool get isLive {
    final name = statusName?.toLowerCase();
    return name == 'live' || name == 'in play' || name == '1h' || name == '2h' || name == 'ht';
  }
  
  bool get isFinished {
    final name = statusName?.toLowerCase();
    return name == 'finished' || name == 'ft' || name == 'aet' || name == 'pen' || name == 'ended';
  }
  
  bool get isUpcoming {
    final name = statusName?.toLowerCase();
    return name == 'scheduled' || name == 'ns' || name == 'not started' || name == null || name == '';
  }
  
  bool get isPostponed => statusName?.toLowerCase() == 'postponed' || statusName?.toLowerCase() == 'pst';
  bool get isCancelled => statusName?.toLowerCase() == 'cancelled' || statusName?.toLowerCase() == 'canc';

  String get statusText => statusName ?? 'Scheduled';

  /// Get match date/time
  DateTime? get dateTime {
    // Try dateUtc first
    if (dateUtc != null && dateUtc!.isNotEmpty) {
      final parsed = _parseDate(dateUtc!);
      if (parsed != null) return parsed.toLocal();
    }
    // Try date field
    if (date != null && date!.isNotEmpty) {
      final parsed = _parseDate(date!);
      if (parsed != null) return parsed;
    }
    return null;
  }
  
  /// Parse date from various formats
  static DateTime? _parseDate(String dateStr) {
    // Try as Unix timestamp (milliseconds)
    final asInt = int.tryParse(dateStr);
    if (asInt != null) {
      // If it's a reasonable timestamp (after year 2000 and before 2100)
      // Milliseconds: 946684800000 (2000-01-01) to 4102444800000 (2100-01-01)
      if (asInt > 946684800000 && asInt < 4102444800000) {
        return DateTime.fromMillisecondsSinceEpoch(asInt);
      }
      // Try as seconds
      if (asInt > 946684800 && asInt < 4102444800) {
        return DateTime.fromMillisecondsSinceEpoch(asInt * 1000);
      }
    }
    
    // Try ISO 8601 format (2026-02-05T18:49:10.407Z)
    var parsed = DateTime.tryParse(dateStr);
    if (parsed != null && parsed.year > 1900 && parsed.year < 2200) {
      return parsed;
    }
    
    // Try common date formats
    try {
      // Format: "2024-02-05"
      if (dateStr.contains('-') && !dateStr.contains('T')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          if (year > 1900 && year < 2200) {
            return DateTime(year, int.parse(parts[1]), int.parse(parts[2]));
          }
        }
      }
      // Format: "05.02.2024"
      if (dateStr.contains('.')) {
        final parts = dateStr.split('.');
        if (parts.length == 3) {
          final year = int.parse(parts[2]);
          if (year > 1900 && year < 2200) {
            return DateTime(year, int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      }
    } catch (_) {}
    
    return null;
  }

  /// Get formatted time
  String get time {
    final dt = dateTime;
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted date
  String get formattedDate {
    final dt = dateTime;
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  /// Get league name
  String? get leagueName => season?.league?.name;

  /// Get country name
  String? get countryName => season?.league?.country?.name;

  /// Get 1X2 odds
  OddsMarket? get mainOdds {
    return odds.where((m) => 
      m.marketName.toLowerCase().contains('1x2') ||
      m.marketName.toLowerCase().contains('match winner') ||
      m.marketId == 1
    ).firstOrNull;
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] ?? 0,
      flashId: json['flashId']?.toString(),
      date: json['date']?.toString(),
      dateUtc: json['dateUtc']?.toString(),
      status: json['status'],
      statusName: json['statusName']?.toString(),
      elapsed: json['elapsed'],
      extraMinutes: json['extraMinutes'],
      homeResult: json['homeResult'],
      awayResult: json['awayResult'],
      homeHTResult: json['homeHTResult'],
      awayHTResult: json['awayHTResult'],
      homeFTResult: json['homeFTResult'],
      awayFTResult: json['awayFTResult'],
      homeTeam: MatchTeam.fromJson(json['homeTeam']),
      awayTeam: MatchTeam.fromJson(json['awayTeam']),
      season: json['season'] != null ? MatchSeason.fromJson(json['season']) : null,
      roundName: json['roundName']?.toString(),
      odds: (json['odds'] as List<dynamic>?)
          ?.map((o) => OddsMarket.fromJson(o))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'flashId': flashId,
    'date': date,
    'dateUtc': dateUtc,
    'status': status,
    'statusName': statusName,
    'elapsed': elapsed,
    'extraMinutes': extraMinutes,
    'homeResult': homeResult,
    'awayResult': awayResult,
    'homeHTResult': homeHTResult,
    'awayHTResult': awayHTResult,
    'homeFTResult': homeFTResult,
    'awayFTResult': awayFTResult,
    'homeTeam': homeTeam.toJson(),
    'awayTeam': awayTeam.toJson(),
    'season': season?.toJson(),
    'roundName': roundName,
    'odds': odds.map((o) => o.toJson()).toList(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory Match.fromJsonString(String jsonString) {
    return Match.fromJson(jsonDecode(jsonString));
  }
}
