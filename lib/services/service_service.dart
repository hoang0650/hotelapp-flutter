import 'package:dio/dio.dart';
import 'api_service.dart';

class ServiceService {
  final ApiService _api = ApiService();
  final String _endpoint = '/services';

  // ============ QUẢN LÝ DỊCH VỤ ============

  Future<List<dynamic>> getServices({String? hotelId, String? category}) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    if (category != null) params['category'] = category;

    final response = await _api.get(_endpoint, queryParameters: params);
    return response.data as List<dynamic>;
  }

  Future<dynamic> getServiceById(String id) async {
    final response = await _api.get('$_endpoint/$id');
    return response.data;
  }

  Future<List<String>> getServiceCategories(String hotelId) async {
    final response = await _api.get('$_endpoint/categories', queryParameters: {'hotelId': hotelId});
    return (response.data as List).map((e) => e.toString()).toList();
  }

  Future<dynamic> createService(Map<String, dynamic> service) async {
    final response = await _api.post(_endpoint, data: service);
    return response.data;
  }

  Future<dynamic> updateService(String id, Map<String, dynamic> service) async {
    final response = await _api.put('$_endpoint/$id', data: service);
    return response.data;
  }

  Future<void> deleteService(String id) async {
    await _api.delete('$_endpoint/$id');
  }

  // ============ QUẢN LÝ ĐƠN HÀNG DỊCH VỤ ============

  Future<dynamic> createServiceOrder(Map<String, dynamic> order) async {
    final response = await _api.post('$_endpoint/orders', data: order);
    return response.data;
  }

  Future<dynamic> updateServiceOrderStatus(String id, String status, {String? staffId}) async {
    final response = await _api.patch(
      '$_endpoint/orders/$id/status',
      data: {'status': status, if (staffId != null) 'staffId': staffId},
    );
    return response.data;
  }

  Future<dynamic> getServiceOrderById(String id) async {
    final response = await _api.get('$_endpoint/orders/$id');
    return response.data;
  }

  Future<List<dynamic>> getServiceOrdersByRoom(String roomId) async {
    final response = await _api.get('$_endpoint/orders/room/$roomId');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getServiceOrdersByHotel(
    String hotelId, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final Map<String, dynamic> params = {
      'hotelId': hotelId,
      'page': page,
      'limit': limit,
    };
    if (status != null) params['status'] = status;

    final response = await _api.get('$_endpoint/orders/hotel', queryParameters: params);
    return response.data;
  }

  Future<List<dynamic>> getAllServiceOrdersForStatistics(
    String hotelId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<String, dynamic> params = {
      'hotelId': hotelId,
      'page': 1,
      'limit': 10000,
    };
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    final response = await _api.get('$_endpoint/orders/hotel', queryParameters: params);
    return response.data['orders'] ?? [];
  }

  Future<void> deleteServiceOrder(String id) async {
    await _api.delete('$_endpoint/orders/$id');
  }

  // ============ ASSIGN DỊCH VỤ VÀO KHÁCH SẠN ============

  Future<dynamic> assignServiceToHotel(String serviceId, String hotelId) async {
    final response = await _api.post('$_endpoint/assign', data: {
      'serviceId': serviceId,
      'hotelId': hotelId,
    });
    return response.data;
  }

  Future<dynamic> bulkAssignServicesToHotel(List<String> serviceIds, String hotelId) async {
    final response = await _api.post('$_endpoint/bulk-assign', data: {
      'serviceIds': serviceIds,
      'hotelId': hotelId,
    });
    return response.data;
  }

  // ============ DỊCH VỤ CHO MODAL CHECKIN/CHECKOUT ============

  Future<dynamic> getServicesForCheckout(String bookingId) async {
    final response = await _api.get('$_endpoint/checkout/$bookingId');
    return response.data;
  }

  Future<dynamic> calculateServiceTotal(List<Map<String, dynamic>> services) async {
    final response = await _api.post('$_endpoint/calculate-total', data: {'services': services});
    return response.data;
  }

  Future<dynamic> getAvailableServicesForModal(String hotelId) async {
    final response = await _api.get('$_endpoint/available', queryParameters: {'hotelId': hotelId});
    return response.data;
  }
}
