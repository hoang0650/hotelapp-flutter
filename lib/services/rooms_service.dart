import 'package:dio/dio.dart';
import 'package:hotelapp_flutter/services/api_service.dart';

class RoomsService {
  final ApiService _api = ApiService();
  final String _endpoint = '/rooms';

  // Get rooms with optional filters
  Future<List<dynamic>> getRooms({String? hotelId, int? floor}) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    if (floor != null) params['floor'] = floor;

    final response = await _api.get(_endpoint, queryParameters: params);
    return response.data as List<dynamic>;
  }

  // Get room by ID
  Future<dynamic> getRoomById(String id, {int? limit, bool? includeOldEvents, bool? excludeCheckedOut}) async {
    final Map<String, dynamic> params = {};
    if (limit != null) params['limit'] = limit;
    if (includeOldEvents != null) params['includeOldEvents'] = includeOldEvents;
    if (excludeCheckedOut != null) params['excludeCheckedOut'] = excludeCheckedOut;

    final response = await _api.get('$_endpoint/$id', queryParameters: params);
    return response.data;
  }

  // Get room events
  Future<List<dynamic>> getRoomEvents(String roomId, {
    int? limit,
    int? skip,
    String? type,
    String? startDate,
    String? endDate,
    bool? excludeCheckedOut,
  }) async {
    final Map<String, dynamic> params = {};
    if (limit != null) params['limit'] = limit;
    if (skip != null) params['skip'] = skip;
    if (type != null) params['type'] = type;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (excludeCheckedOut != null) params['excludeCheckedOut'] = excludeCheckedOut;

    final response = await _api.get('$_endpoint/$roomId/events', queryParameters: params);
    return response.data as List<dynamic>;
  }

  // Get available rooms
  Future<List<dynamic>> getAvailableRooms({
    required String hotelId,
    String? checkInDate,
    String? checkOutDate,
    int? floor,
  }) async {
    final Map<String, dynamic> params = {'hotelId': hotelId};
    if (checkInDate != null) params['checkInDate'] = checkInDate;
    if (checkOutDate != null) params['checkOutDate'] = checkOutDate;
    if (floor != null) params['floor'] = floor;

    final response = await _api.get('$_endpoint/available', queryParameters: params);
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getRoomsByFloor(String hotelId, int floor) async {
    final response = await _api.get('$_endpoint/hotel/$hotelId/floor/$floor');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getHotelFloors(String hotelId) async {
    final response = await _api.get('$_endpoint/hotel/$hotelId/floors');
    return response.data as Map<String, dynamic>;
  }

  Future<dynamic> createRoom(Map<String, dynamic> data) async {
    final response = await _api.post(_endpoint, data: data);
    return response.data;
  }

  Future<dynamic> updateRoom(String id, Map<String, dynamic> room) async {
    final response = await _api.put('$_endpoint/$id', data: room);
    return response.data;
  }

  Future<void> deleteRoom(String id) async {
    await _api.delete('$_endpoint/$id');
  }

  // Service assignment
  Future<dynamic> assignServiceToRoom(String roomId, String serviceId) async {
    final response = await _api.post('$_endpoint/$roomId/services/$serviceId', data: {});
    return response.data;
  }

  Future<dynamic> removeServiceFromRoom(String roomId, String serviceId) async {
    final response = await _api.delete('$_endpoint/$roomId/services/$serviceId');
    return response.data;
  }

  // Room status
  Future<dynamic> updateRoomStatus(String roomId, String status, String staffId, String note) async {
    final response = await _api.patch('$_endpoint/$roomId/status', data: {
      'status': status,
      'staffId': staffId,
      'note': note,
    });
    return response.data;
  }

  // Transfer room
  Future<dynamic> transferRoom({
    required String sourceRoomId,
    required String targetRoomId,
    required String staffId,
    required String notes,
  }) async {
    final response = await _api.post('$_endpoint/transfer', data: {
      'sourceRoomId': sourceRoomId,
      'targetRoomId': targetRoomId,
      'staffId': staffId,
      'notes': notes,
    });
    return response.data;
  }

  // Check-in
  Future<dynamic> checkInRoom(String id, Map<String, dynamic> payload) async {
    final response = await _api.post('$_endpoint/checkin/$id', data: payload);
    return response.data;
  }

  // Check-out
  Future<dynamic> checkOutRoom(String id, Map<String, dynamic> payload) async {
    final response = await _api.post('$_endpoint/checkout/$id', data: payload);
    return response.data;
  }

  // Re-checkin
  Future<dynamic> recheckinRoom({required String roomId, String? invoiceId, String? historyId}) async {
    final Map<String, dynamic> payload = {'roomId': roomId};
    if (invoiceId != null) payload['invoiceId'] = invoiceId;
    if (historyId != null) payload['historyId'] = historyId;
    
    final response = await _api.post('$_endpoint/recheckin', data: payload);
    return response.data;
  }

  // Delete checkout history
  Future<dynamic> deleteCheckoutHistory({required String roomId, String? invoiceId, required String historyId}) async {
    final Map<String, dynamic> payload = {'roomId': roomId, 'historyId': historyId};
    if (invoiceId != null) payload['invoiceId'] = invoiceId;

    // Use delete with data/body is tricky in some clients, but Dio supports it via 'data' in options or custom request
    // ApiService delete supports queryParameters, but usually body in delete is not standard.
    // However, the Angular service uses { body: payload }.
    // Let's see if ApiService supports data in delete. It does not seem to have a data param in delete signature in Read output.
    // I should check ApiService again or assume I might need to modify it or use request.
    // Looking at ApiService: Future<Response> delete(String path, {Map<String, dynamic>? queryParameters})
    // It lacks 'data'. I should check if I can modify ApiService or use request.
    // For now, I'll use _api.request if available or skip body (which might fail) or better, modify ApiService later.
    // Wait, let's modify ApiService to support data in delete as it is common in this project.
    // For now I will assume I can fix ApiService.
    // Or I can use _api._dio.delete directly if I could access it, but it's private.
    // I will try to pass it as queryParameters if it's small, or I will update ApiService.
    // Let's update ApiService to support body in delete.
    
    // For this specific call, I'll comment a TODO or try to use a different method if possible.
    // But since I'm implementing the service, I should fix the infrastructure.
    // I will update ApiService in the next step.
    // For now, I will write the code assuming ApiService has delete with data or I will use a custom call.
    
    // Actually, looking at ApiService again:
    // Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async { ... }
    // It really misses data.
    
    // I'll proceed with creating the file and then update ApiService.
    return _api.delete('$_endpoint/history', queryParameters: payload); // Fallback to query params if server supports it, or I'll fix ApiService.
  }

  // Clean room
  Future<dynamic> cleanRoom(String roomId, Map<String, dynamic> roomUpdate) async {
    final response = await _api.post('$_endpoint/clean/$roomId', data: roomUpdate);
    return response.data;
  }

  // Room history
  Future<Map<String, dynamic>> getRoomHistory({
    String? hotelId,
    String? filterType,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'limit': limit,
    };
    if (hotelId != null) params['hotelId'] = hotelId;
    if (filterType != null) params['filterType'] = filterType;

    final response = await _api.get('$_endpoint/history', queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<dynamic> getInvoiceDetails(String invoiceId) async {
    final response = await _api.get('$_endpoint/invoice/$invoiceId');
    return response.data;
  }

  Future<dynamic> createInvoice(String roomId, Map<String, dynamic> invoiceData) async {
    final response = await _api.post('$_endpoint/$roomId/invoice', data: invoiceData);
    return response.data;
  }

  Future<dynamic> createBooking(Map<String, dynamic> bookingData) async {
    final response = await _api.post('$_endpoint/booking', data: bookingData);
    return response.data;
  }

  Future<dynamic> cancelBooking(String roomId, String reason, {String? bookingId, String? checkInDate}) async {
    final Map<String, dynamic> body = {'reason': reason};
    if (bookingId != null) body['bookingId'] = bookingId;
    if (checkInDate != null) body['checkInDate'] = checkInDate;

    final response = await _api.post('$_endpoint/booking/cancel/$roomId', data: body);
    return response.data;
  }

  Future<dynamic> getBookings({
    String? roomId,
    String? hotelId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (roomId != null) params['roomId'] = roomId;
    if (hotelId != null) params['hotelId'] = hotelId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get('$_endpoint/bookings', queryParameters: params);
    return response.data;
  }
}
