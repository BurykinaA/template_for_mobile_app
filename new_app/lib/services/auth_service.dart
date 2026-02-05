import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Authentication Service (Local - always successful)
class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final p = await prefs;
    return p.getBool(_isLoggedInKey) ?? false;
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    final p = await prefs;
    final userJson = p.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Login (always successful)
  Future<User> login(String email, String password) async {
    // Always successful login - create/get user
    final p = await prefs;
    
    // Check if user exists
    User? existingUser = await getCurrentUser();
    
    if (existingUser != null && existingUser.email == email) {
      // Return existing user
      await p.setBool(_isLoggedInKey, true);
      return existingUser;
    }
    
    // Create new user
    final user = User.create(email: email);
    await p.setString(_userKey, jsonEncode(user.toJson()));
    await p.setBool(_isLoggedInKey, true);
    
    return user;
  }

  /// Register (always successful)
  Future<User> register(String email, String password, {String? name}) async {
    final p = await prefs;
    
    // Create new user
    final user = User.create(email: email, name: name);
    await p.setString(_userKey, jsonEncode(user.toJson()));
    await p.setBool(_isLoggedInKey, true);
    
    return user;
  }

  /// Logout
  Future<void> logout() async {
    final p = await prefs;
    await p.setBool(_isLoggedInKey, false);
  }

  /// Update user profile
  Future<User> updateProfile({String? name, String? email}) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    final updatedUser = User(
      id: currentUser.id,
      email: email ?? currentUser.email,
      name: name ?? currentUser.name,
      createdAt: currentUser.createdAt,
    );

    final p = await prefs;
    await p.setString(_userKey, jsonEncode(updatedUser.toJson()));
    
    return updatedUser;
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    final p = await prefs;
    await p.remove(_userKey);
    await p.remove(_isLoggedInKey);
  }
}
