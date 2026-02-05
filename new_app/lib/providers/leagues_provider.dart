import 'package:flutter/foundation.dart';
import '../models/league.dart';
import '../services/api_service.dart';

/// Leagues state provider
class LeaguesProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<League> _leagues = [];
  League? _selectedLeague;
  
  bool _isLoading = false;
  String? _error;

  LeaguesProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService();

  // Getters
  List<League> get leagues => _leagues;
  League? get selectedLeague => _selectedLeague;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all available leagues with seasons
  Future<void> loadLeagues() async {
    if (_leagues.isNotEmpty) return; // Already loaded
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leagues = await _apiService.getLeagues();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force reload leagues
  Future<void> refreshLeagues() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leagues = await _apiService.getLeagues();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a league from the list
  void selectLeague(League league) {
    _selectedLeague = league;
    notifyListeners();
  }

  /// Clear selected league
  void clearSelectedLeague() {
    _selectedLeague = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
