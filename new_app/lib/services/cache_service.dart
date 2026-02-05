import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match.dart';

/// Cache Service for storing matches locally
class CacheService {
  static const String _matchesCacheKey = 'cached_matches';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const int _maxCachedMatches = 10;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save matches to cache (keeps last 10)
  Future<void> cacheMatches(List<Match> matches) async {
    final p = await prefs;
    
    // Take only the last 10 matches
    final matchesToCache = matches.take(_maxCachedMatches).toList();
    
    final jsonList = matchesToCache.map((m) => m.toJson()).toList();
    await p.setString(_matchesCacheKey, jsonEncode(jsonList));
    await p.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached matches
  Future<List<Match>> getCachedMatches() async {
    final p = await prefs;
    
    final jsonString = p.getString(_matchesCacheKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => Match.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Check if cache exists
  Future<bool> hasCachedMatches() async {
    final p = await prefs;
    return p.containsKey(_matchesCacheKey);
  }

  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    final p = await prefs;
    final timestamp = p.getInt(_cacheTimestampKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if cache is stale (older than specified duration)
  Future<bool> isCacheStale({Duration maxAge = const Duration(hours: 1)}) async {
    final timestamp = await getCacheTimestamp();
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > maxAge;
  }

  /// Clear matches cache
  Future<void> clearMatchesCache() async {
    final p = await prefs;
    await p.remove(_matchesCacheKey);
    await p.remove(_cacheTimestampKey);
  }

  /// Add new matches to existing cache (maintains max limit)
  Future<void> appendToCache(List<Match> newMatches) async {
    final existing = await getCachedMatches();
    
    // Combine and remove duplicates by match ID
    final combined = <int, Match>{};
    for (final m in [...newMatches, ...existing]) {
      combined[m.id] = m;
    }
    
    // Take only the latest matches up to max limit
    final sorted = combined.values.toList()
      ..sort((a, b) {
        final dateA = a.dateTime ?? DateTime.now();
        final dateB = b.dateTime ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
    
    await cacheMatches(sorted.take(_maxCachedMatches).toList());
  }
}
