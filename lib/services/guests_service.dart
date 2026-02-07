import 'package:hotelapp_flutter/services/api_service.dart';

class GuestsService {
  final ApiService _api = ApiService();
  final String _endpoint = '/guests';

  Future<Map<String, dynamic>> getGuests({
    String? hotelId,
    int? page,
    int? limit,
    String? search,
    String? guestType,
  }) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (search != null) params['search'] = search;
    if (guestType != null) params['guestType'] = guestType;

    final response = await _api.get(_endpoint, queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<dynamic> getGuestById(String id) async {
    final response = await _api.get('$_endpoint/$id');
    return response.data;
  }

  Future<Map<String, dynamic>> createGuest(Map<String, dynamic> guest) async {
    final response = await _api.post(_endpoint, data: guest);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateGuest(String id, Map<String, dynamic> guest) async {
    final response = await _api.patch('$_endpoint/$id', data: guest);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteGuest(String id) async {
    final response = await _api.delete('$_endpoint/$id');
    return response.data as Map<String, dynamic>;
  }

  // Create booking for guest
  Future<dynamic> createBookingForGuest(String guestId, Map<String, dynamic> request) async {
    final response = await _api.post('$_endpoint/$guestId/create-booking', data: request);
    return response.data;
  }

  // Assign guest to room
  Future<dynamic> assignGuestToRoom(String guestId, Map<String, dynamic> request) async {
    final response = await _api.post('$_endpoint/$guestId/assign-room', data: request);
    return response.data;
  }

  // Find guest by ID number
  Future<List<dynamic>> findGuestByIdNumber(String idNumber, String hotelId) async {
    final response = await _api.get('$_endpoint/find', queryParameters: {
      'idNumber': idNumber,
      'hotelId': hotelId,
    });
    return response.data as List<dynamic>;
  }

  // Get guests by room
  Future<List<dynamic>> getGuestsByRoom(String roomId) async {
    final response = await _api.get('$_endpoint/room/$roomId');
    return response.data as List<dynamic>;
  }

  // Merge guests
  Future<dynamic> mergeGuests(String primaryId, String secondaryId) async {
    final response = await _api.post('$_endpoint/merge', data: {
      'primaryId': primaryId,
      'secondaryId': secondaryId,
    });
    return response.data;
  }
}
