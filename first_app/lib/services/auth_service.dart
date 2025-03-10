import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AuthService extends ChangeNotifier {
  String? _currentUserId;
  String? _currentUsername;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String? get currentUserId => _currentUserId;
  String? get currentUsername => _currentUsername;
  bool get isAuthenticated => _currentUserId != null;

  Future<bool> signUp(String username, String password) async {
    try {
      final userId = await _dbHelper.createUser(username, password);
      _currentUserId = userId;
      _currentUsername = username;
      await _saveUserSession(userId, username);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn(String username, String password) async {
    try {
      final user = await _dbHelper.getUser(username, password);
      if (user != null) {
        _currentUserId = user['id'];
        _currentUsername = user['username'];
        await _saveUserSession(user['id'], user['username']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUserId = null;
    _currentUsername = null;
    await _clearUserSession();
    notifyListeners();
  }

  Future<void> _saveUserSession(String userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');

    if (userId != null && username != null) {
      _currentUserId = userId;
      _currentUsername = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    if (_currentUserId == null || _currentUsername == null) return false;

    try {
      final user = await _dbHelper.getUser(_currentUsername!, currentPassword);
      if (user == null) return false;

      await _dbHelper.updateUserPassword(_currentUserId!, newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }
}
