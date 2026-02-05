import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/match.dart';
import '../models/league.dart';
import '../models/team.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// API Service for SStats.net
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Generic GET request
  Future<Map<String, dynamic>> _get(String endpoint, [Map<String, String>? params]) async {
    final url = ApiConfig.buildUrl(endpoint, params);
    
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is List) {
          return {'data': data};
        }
        throw ApiException('Unexpected response format');
      } else {
        throw ApiException('HTTP error', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // ===== LEAGUES =====

  /// Get all available leagues with their seasons
  /// Endpoint: /Leagues
  Future<List<League>> getLeagues() async {
    final response = await _get(ApiConfig.leaguesEndpoint);
    final data = response['data'] as List? ?? [];
    return data
        .map((l) => League.fromJson(l as Map<String, dynamic>))
        .toList();
  }

  // ===== MATCHES =====

  /// Get matches with filters
  /// Endpoint: /Games/list?leagueid=X&from=YYYY-MM-DD&to=YYYY-MM-DD
  Future<List<Match>> getMatches({
    int? leagueId,
    String? from,
    String? to,
    int? teamId,
    int? offset,
    int? limit,
  }) async {
    final params = <String, String>{};
    if (leagueId != null) params['leagueid'] = leagueId.toString();
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    if (teamId != null) params['teamid'] = teamId.toString();
    if (offset != null) params['offset'] = offset.toString();
    if (limit != null) params['limit'] = limit.toString();
    
    final response = await _get(ApiConfig.gamesListEndpoint, params);
    final data = response['data'] as List? ?? [];
    return data
        .map((m) => Match.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Get matches for next N days (only upcoming/scheduled matches)
  Future<List<Match>> getUpcomingMatches(int days) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = today.add(Duration(days: days + 1)); // Include the full last day
    
    final from = _formatDate(today);
    final to = _formatDate(today.add(Duration(days: days)));
    
    // Try to get matches with date filter
    final matches = await getMatches(from: from, to: to);
    
    // Debug: print how many matches we got and date range
    print('API returned ${matches.length} matches for $from to $to');
    
    // Debug: print first 3 matches raw date values
    for (var i = 0; i < matches.length && i < 3; i++) {
      final m = matches[i];
      print('Match ${m.id} raw dates: date="${m.date}", dateUtc="${m.dateUtc}"');
    }
    
    // CLIENT-SIDE FILTERING: API might ignore date params, so we filter manually
    final upcomingMatches = matches.where((m) {
      // Skip finished matches
      if (m.isFinished) return false;
      
      // Filter by date - only matches within the next N days
      final matchDate = m.dateTime;
      if (matchDate == null) {
        print('Match ${m.id} has no valid date (date=${m.date}, dateUtc=${m.dateUtc})');
        return false;
      }
      
      // Normalize match date to just the date (ignore time for comparison)
      final matchDay = DateTime(matchDate.year, matchDate.month, matchDate.day);
      
      // Match must be today or tomorrow (within the next N days)
      final isInRange = !matchDay.isBefore(today) && matchDay.isBefore(endDate);
      
      if (!isInRange) {
        print('Match ${m.id} filtered out: ${matchDate.toIso8601String()} not in range $today - $endDate');
      }
      
      return isInRange;
    }).toList();
    
    print('After filtering: ${upcomingMatches.length} matches within date range');
    
    // Sort by date/time ascending (nearest matches first)
    upcomingMatches.sort((a, b) {
      final dateA = a.dateTime ?? DateTime.now().add(const Duration(days: 365));
      final dateB = b.dateTime ?? DateTime.now().add(const Duration(days: 365));
      return dateA.compareTo(dateB);
    });
    
    return upcomingMatches;
  }

  /// Get matches by league and date range
  Future<List<Match>> getMatchesByLeague({
    required int leagueId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final from = fromDate != null ? _formatDate(fromDate) : null;
    final to = toDate != null ? _formatDate(toDate) : null;
    
    return getMatches(leagueId: leagueId, from: from, to: to);
  }

  /// Get upcoming matches for a league (from now to specified period)
  Future<List<Match>> getUpcomingLeagueMatches({
    required int leagueId,
    int? teamId,
    required int days,
  }) async {
    final now = DateTime.now();
    final from = _formatDate(now);
    final to = _formatDate(now.add(Duration(days: days)));
    
    return getMatches(leagueId: leagueId, teamId: teamId, from: from, to: to);
  }

  /// Get finished matches for a league (archive)
  Future<List<Match>> getArchivedMatches({
    required int leagueId,
    int? seasonYear,
  }) async {
    // Get matches from the past (e.g., last 6 months)
    final now = DateTime.now();
    final from = _formatDate(now.subtract(const Duration(days: 180)));
    final to = _formatDate(now.subtract(const Duration(days: 1)));
    
    final matches = await getMatches(leagueId: leagueId, from: from, to: to);
    // Filter for finished matches only
    return matches.where((m) => m.isFinished).toList();
  }

  /// Get match details with Glicko ratings
  /// Endpoint: /Games/glicko/{id}
  Future<Map<String, dynamic>> getMatchGlicko(int matchId) async {
    final response = await _get('${ApiConfig.gameGlickoEndpoint}/$matchId');
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  // ===== TEAMS =====

  /// Get teams list with filters
  /// Endpoint: /Teams/list?Name=X&Country=X
  Future<List<Team>> getTeams({
    String? name,
    String? country,
    int? offset,
    int? limit,
  }) async {
    final params = <String, String>{};
    if (name != null) params['Name'] = name;
    if (country != null) params['Country'] = country;
    if (offset != null) params['Offset'] = offset.toString();
    if (limit != null) params['Limit'] = limit.toString();
    
    final response = await _get(ApiConfig.teamsListEndpoint, params);
    final data = response['data'] as List? ?? [];
    return data
        .map((t) => Team.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get season table (standings)
  /// Endpoint: /Games/season-table?league=X&year=X
  Future<List<TeamStanding>> getSeasonTable({
    required int leagueId,
    required int year,
  }) async {
    final response = await _get(ApiConfig.seasonTableEndpoint, {
      'league': leagueId.toString(),
      'year': year.toString(),
    });
    final data = response['data'] as List? ?? [];
    return data
        .map((t) => TeamStanding.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Get teams from season standings (for league filter)
  Future<List<Team>> getTeamsByLeague(int leagueId, int year) async {
    final standings = await getSeasonTable(leagueId: leagueId, year: year);
    return standings.map((s) => s.toTeam()).toList();
  }

  // ===== HELPERS =====

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _client.close();
  }
}
