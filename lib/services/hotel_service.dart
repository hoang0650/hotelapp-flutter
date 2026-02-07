import 'package:hotelapp_flutter/services/api_service.dart';

class HotelService {
  final ApiService _api = ApiService();
  final String _endpoint = '/hotels';

  // Get hotels with optional filters
  Future<List<dynamic>> getHotels({String? businessId, String? status}) async {
    final Map<String, dynamic> params = {};
    if (businessId != null) params['businessId'] = businessId;
    if (status != null) params['status'] = status;

    final response = await _api.get(_endpoint, queryParameters: params);
    return response.data as List<dynamic>;
  }

  // Get hotel by ID
  Future<dynamic> getHotelById(String id) async {
    final response = await _api.get('$_endpoint/$id');
    return response.data;
  }

  // Create hotel
  Future<dynamic> createHotel(Map<String, dynamic> hotel) async {
    final response = await _api.post(_endpoint, data: hotel);
    return response.data;
  }

  // Update hotel
  Future<dynamic> updateHotel(String id, Map<String, dynamic> hotelUpdates) async {
    final response = await _api.put('$_endpoint/$id', data: hotelUpdates);
    return response.data;
  }

  // Delete hotel
  Future<void> deleteHotel(String id) async {
    await _api.delete('$_endpoint/$id');
  }

  // Update hotel status
  Future<dynamic> updateHotelStatus(String id, String status) async {
    final response = await _api.patch('$_endpoint/$id/status', data: {'status': status});
    // Angular returns response.hotel
    return response.data['hotel'];
  }

  // Upload hotel images
  Future<Map<String, dynamic>> uploadHotelImages(String id, List<String> images) async {
    final response = await _api.post('$_endpoint/$id/images', data: {'images': images});
    return response.data as Map<String, dynamic>;
  }

  // Delete hotel image
  Future<Map<String, dynamic>> deleteHotelImage(String id, int imageIndex) async {
    final response = await _api.delete('$_endpoint/$id/images/$imageIndex');
    return response.data as Map<String, dynamic>;
  }

  // Update hotel settings
  Future<Map<String, dynamic>> updateHotelSettings(String id, Map<String, dynamic> settingsUpdate) async {
    final response = await _api.patch('$_endpoint/$id/settings', data: {'settings': settingsUpdate});
    return response.data as Map<String, dynamic>;
  }

  // Get hotel revenue
  Future<dynamic> getHotelRevenue(String hotelId, {String period = 'day'}) async {
    final params = {'period': period};
    final response = await _api.get('$_endpoint/$hotelId/revenue', queryParameters: params);
    return response.data;
  }

  // Get hotel revenue by period (Shift Handover API)
  Future<dynamic> getHotelRevenueByPeriod(String hotelId, {String period = 'day'}) async {
    // Note: Angular service calls environment.apiUrl + '/shift-handover/revenue/period'
    // We should replicate that path. ApiService base URL is likely just the base API URL.
    // If ApiService baseUrl includes /api, we can just use /shift-handover...
    // Assuming ApiService baseUrl is correct.
    
    final params = {'hotelId': hotelId, 'period': period};
    final response = await _api.get('/shift-handover/revenue/period', queryParameters: params);
    return response.data;
  }
}
