import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  final DatabaseService _dbService = DatabaseService();

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _dbService.loginUser(email, password);
    _currentUser = user;

    _isLoading = false;
    notifyListeners();
    return user != null;
  }

  Future<bool> register(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _dbService.registerUser(user);
      _currentUser = User(
        id: id,
        name: user.name,
        email: user.email,
        role: user.role,
        bio: user.bio,
        skills: user.skills,
        education: user.education,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
