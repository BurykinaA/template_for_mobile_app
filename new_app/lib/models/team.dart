import 'match.dart';

/// Team Model for SStats.net API
class Team {
  final int id;
  final String name;
  final String? flashId;
  final String? logoUrl;
  final Country? country;

  Team({
    required this.id,
    required this.name,
    this.flashId,
    this.logoUrl,
    this.country,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      flashId: json['flashId']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
    );
  }

  /// Get logo URL (alias for compatibility)
  String? get logo => logoUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'flashId': flashId,
    'logoUrl': logoUrl,
    'country': country?.toJson(),
  };
}

/// Team Standing in season table
class TeamStanding {
  final int teamId;
  final String teamName;
  final int rank;
  final int totalGames;
  final int wins;
  final int draws;
  final int loss;
  final int goalsScored;
  final int goalsMissed;
  final int points;
  final int scoreDiff;

  TeamStanding({
    required this.teamId,
    required this.teamName,
    required this.rank,
    required this.totalGames,
    required this.wins,
    required this.draws,
    required this.loss,
    required this.goalsScored,
    required this.goalsMissed,
    required this.points,
    required this.scoreDiff,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      teamId: json['TeamId'] ?? json['teamId'] ?? 0,
      teamName: json['TeamName']?.toString() ?? json['teamName']?.toString() ?? '',
      rank: json['Rank'] ?? json['rank'] ?? 0,
      totalGames: json['TotalGames'] ?? json['totalGames'] ?? 0,
      wins: json['Wins'] ?? json['wins'] ?? 0,
      draws: json['Draws'] ?? json['draws'] ?? 0,
      loss: json['Loss'] ?? json['loss'] ?? 0,
      goalsScored: json['GoalsScored'] ?? json['goalsScored'] ?? 0,
      goalsMissed: json['GoalsMissed'] ?? json['goalsMissed'] ?? 0,
      points: json['Points'] ?? json['points'] ?? 0,
      scoreDiff: json['ScoreDiff'] ?? json['scoreDiff'] ?? 0,
    );
  }

  /// Convert to Team for display
  Team toTeam() {
    return Team(
      id: teamId,
      name: teamName,
    );
  }
}
