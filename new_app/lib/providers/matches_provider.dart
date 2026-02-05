import 'package:flutter/foundation.dart';
import '../models/match.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

/// Matches state provider
class MatchesProvider extends ChangeNotifier {
  final ApiService _apiService;
  final CacheService _cacheService;

  List<Match> _upcomingMatches = [];
  List<Match> _searchResults = [];
  List<Match> _archivedMatches = [];
  Match? _selectedMatch;
  Map<String, dynamic>? _matchGlicko;
  
  bool _isLoading = false;
  bool _isFromCache = false;
  String? _error;

  MatchesProvider({
    ApiService? apiService,
    CacheService? cacheService,
  })  : _apiService = apiService ?? ApiService(),
        _cacheService = cacheService ?? CacheService();

  // Getters
  List<Match> get upcomingMatches => _upcomingMatches;
  List<Match> get searchResults => _searchResults;
  List<Match> get archivedMatches => _archivedMatches;
  Match? get selectedMatch => _selectedMatch;
  Map<String, dynamic>? get matchGlicko => _matchGlicko;
  bool get isLoading => _isLoading;
  bool get isFromCache => _isFromCache;
  String? get error => _error;

  /// Load upcoming matches for next 2 days
  Future<void> loadUpcomingMatches() async {
    _isLoading = true;
    _error = null;
    _isFromCache = false;
    notifyListeners();

    try {
      _upcomingMatches = await _apiService.getUpcomingMatches(2);
      
      // Cache matches
      if (_upcomingMatches.isNotEmpty) {
        await _cacheService.cacheMatches(_upcomingMatches);
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      
      // Try to load from cache
      final cached = await _cacheService.getCachedMatches();
      if (cached.isNotEmpty) {
        _upcomingMatches = cached;
        _isFromCache = true;
        _error = 'Показаны данные из кэша';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search matches by league with filters
  Future<void> searchMatches({
    required int leagueId,
    DateTime? fromDate,
    DateTime? toDate,
    int? teamId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate days for period
      final now = DateTime.now();
      final from = fromDate ?? now;
      final to = toDate ?? now.add(const Duration(days: 30));
      final days = to.difference(from).inDays;

      var matches = await _apiService.getUpcomingLeagueMatches(
        leagueId: leagueId,
        teamId: teamId,
        days: days,
      );

      _searchResults = matches;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load archived (finished) matches
  Future<void> loadArchivedMatches(int leagueId, {int? seasonYear}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _archivedMatches = await _apiService.getArchivedMatches(
        leagueId: leagueId,
        seasonYear: seasonYear,
      );
      // Sort by date descending (most recent first)
      _archivedMatches.sort((a, b) {
        final dateA = a.dateTime ?? DateTime.now();
        final dateB = b.dateTime ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
      _error = null;
    } catch (e) {
      _error = e.toString();
      _archivedMatches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get match details with Glicko ratings
  Future<void> loadMatchDetails(int matchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getMatchGlicko(matchId);
      if (result['fixture'] != null) {
        _selectedMatch = Match.fromJson(result['fixture']);
      }
      _matchGlicko = result['glicko'];
      _error = null;
    } catch (e) {
      _error = e.toString();
      _selectedMatch = null;
      _matchGlicko = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// Clear archived matches
  void clearArchivedMatches() {
    _archivedMatches = [];
    notifyListeners();
  }

  /// Clear selected match
  void clearSelectedMatch() {
    _selectedMatch = null;
    _matchGlicko = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
