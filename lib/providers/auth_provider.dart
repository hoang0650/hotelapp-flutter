import 'package:flutter/foundation.dart';
import 'package:hotelapp_flutter/models/user.dart';
import 'package:hotelapp_flutter/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = true;
  
  User? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  
  Future<bool> login(String emailOrUsername, String password) async {
    try {
      _loading = true;
      notifyListeners();
      
      final response = await _authService.login(emailOrUsername, password);
      
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
        _loading = false;
        notifyListeners();
        return true;
      }
      
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
  
  void updateUser(User? updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}

