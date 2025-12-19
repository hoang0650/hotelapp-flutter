import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:hotelapp_flutter/config/constants.dart';
import 'package:hotelapp_flutter/models/user.dart';
import 'package:hotelapp_flutter/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    final isEmail = emailOrUsername.contains('@');
    final payload = {
      'password': password,
      if (isEmail) 'email': emailOrUsername else 'username': emailOrUsername,
    };
    
    try {
      final response = await _apiService.post(
        AppConstants.loginEndpoint,
        data: payload,
      );
      
      if (response.data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, response.data['token']);
        if (response.data['user'] != null) {
          // Store user as JSON string
          final userJson = response.data['user'];
          if (userJson is Map) {
            // Convert Map to JSON string
            await prefs.setString(
              AppConstants.userKey,
              userJson.toString(),
            );
          }
        }
      }
      
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.hotelIdKey);
    await prefs.remove(AppConstants.businessIdKey);
  }
  
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(AppConstants.userKey);
      
      if (userStr != null && userStr.isNotEmpty) {
        try {
          // Try to parse as JSON - you may need to adjust based on storage format
          // For now, fallback to token decoding
        } catch (e) {
          // If parsing fails, continue to token decoding
        }
      }
      
      final token = prefs.getString(AppConstants.tokenKey);
      if (token != null && !JwtDecoder.isExpired(token)) {
        final decoded = JwtDecoder.decode(token);
        return User.fromJson(decoded);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
  
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      if (JwtDecoder.isExpired(token)) {
        await logout();
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        AppConstants.forgotPasswordEndpoint,
        data: {'email': email},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    try {
      final response = await _apiService.post(
        AppConstants.resetPasswordEndpoint,
        data: {'token': token, 'password': password},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        AppConstants.userProfileEndpoint,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

