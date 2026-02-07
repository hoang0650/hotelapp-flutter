import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/services/auth_service.dart'; // Assuming AuthService exists

class BusinessService {
  final ApiService _api = ApiService();
  final String _endpoint = '/businesses';
  final AuthService _authService = AuthService(); // Or inject it

  // Get all businesses
  Future<List<dynamic>> getBusinesses() async {
    final response = await _api.get(_endpoint);
    return response.data as List<dynamic>;
  }

  // Get business by ID
  Future<dynamic> getBusinessById(String id) async {
    final response = await _api.get('$_endpoint/$id');
    return response.data;
  }

  // Get business info of current user
  Future<dynamic> getBusinessInfoOfCurrentUser() async {
    // We need to implement getCurrentUser in AuthService or get it from storage
    // For now, let's assume AuthService has a method to get userId or user object
    final user = await _authService.getCurrentUser();
    if (user != null && user['_id'] != null) {
      final response = await _api.get('$_endpoint/owner/${user['_id']}');
      return response.data;
    }
    throw Exception('User not logged in or user ID not available.');
  }

  // Create business
  Future<dynamic> createBusiness(Map<String, dynamic> business) async {
    final response = await _api.post(_endpoint, data: business);
    return response.data;
  }

  // Update business
  Future<dynamic> updateBusiness(String id, Map<String, dynamic> business) async {
    final response = await _api.put('$_endpoint/$id', data: business);
    return response.data;
  }

  // Update business status
  Future<dynamic> updateBusinessStatus(String id, String status) async {
    final response = await _api.patch('$_endpoint/$id/status', data: {'status': status});
    return response.data['business'];
  }

  // Delete business
  Future<void> deleteBusiness(String id) async {
    await _api.delete('$_endpoint/$id');
  }

  // Update subscription
  Future<dynamic> updateSubscription(String businessId, String plan, int contractYears, bool autoRenew) async {
    final response = await _api.patch('$_endpoint/$businessId/subscription', data: {
      'plan': plan,
      'contractYears': contractYears,
      'autoRenew': autoRenew,
    });
    return response.data;
  }
}
