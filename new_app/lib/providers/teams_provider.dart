import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/api_service.dart';

/// Teams state provider
class TeamsProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Team> _teams = [];
  List<TeamStanding> _standings = [];
  Team? _selectedTeam;
  
  bool _isLoading = false;
  String? _error;

  TeamsProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Getters
  List<Team> get teams => _teams;
  List<TeamStanding> get standings => _standings;
  Team? get selectedTeam => _selectedTeam;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load teams list with optional filters
  Future<void> loadTeams({String? name, String? country}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teams = await _apiService.getTeams(name: name, country: country, limit: 100);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _teams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load teams for a league (from season table)
  Future<void> loadTeamsByLeague(int leagueId, int year) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _standings = await _apiService.getSeasonTable(leagueId: leagueId, year: year);
      _teams = _standings.map((s) => s.toTeam()).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _teams = [];
      _standings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a team
  void selectTeam(Team team) {
    _selectedTeam = team;
    notifyListeners();
  }

  /// Clear selected team
  void clearSelectedTeam() {
    _selectedTeam = null;
    notifyListeners();
  }

  /// Clear teams
  void clearTeams() {
    _teams = [];
    _standings = [];
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
