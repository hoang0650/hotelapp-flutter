import 'package:hotelapp_flutter/services/api_service.dart';

class StaffService {
  final ApiService _api = ApiService();
  final String _endpoint = '/staffs';

  // Get all staff
  Future<List<dynamic>> getStaff() async {
    final response = await _api.get(_endpoint);
    return response.data as List<dynamic>;
  }

  // Get staff by hotel
  Future<List<dynamic>> getStaffByHotel(String hotelId) async {
    final response = await _api.get('$_endpoint/hotel/$hotelId');
    return response.data as List<dynamic>;
  }

  // Get staff by ID
  Future<dynamic> getStaffById(String id) async {
    final response = await _api.get('$_endpoint/$id');
    return response.data;
  }

  // Update staff
  Future<dynamic> updateStaff(String id, Map<String, dynamic> staff) async {
    final response = await _api.put('$_endpoint/$id', data: staff);
    return response.data;
  }

  // Create staff
  Future<dynamic> createStaff(Map<String, dynamic> staff) async {
    final response = await _api.post(_endpoint, data: staff);
    return response.data;
  }

  // Delete staff
  Future<void> deleteStaff(String id) async {
    await _api.delete('$_endpoint/$id');
  }

  // Calculate salary
  Future<dynamic> calculateSalary(String staffId, Map<String, dynamic> data) async {
    final response = await _api.post('$_endpoint/$staffId/calculate-salary', data: data);
    return response.data;
  }

  // Pay salary
  Future<dynamic> paySalary(String staffId, Map<String, dynamic> data) async {
    final response = await _api.post('$_endpoint/$staffId/pay-salary', data: data);
    return response.data;
  }
}
