import 'package:dio/dio.dart';
import 'api_service.dart';

class ShiftHandoverService {
  final ApiService _api = ApiService();
  final String _endpoint = '/shift-handover';

  // ============ GIAO CA ============

  Future<dynamic> getShiftHandovers() async {
    final response = await _api.get(_endpoint);
    return response.data;
  }

  Future<dynamic> createShiftHandover(Map<String, dynamic> handoverData) async {
    final response = await _api.post(_endpoint, data: handoverData);
    // Note: Angular service handles login/token update here.
    // In Flutter, we might need to handle this in the UI or Provider calling this service.
    return response.data;
  }

  // ============ GIAO TIỀN QUẢN LÝ ============

  Future<dynamic> createManagerHandover(Map<String, dynamic> data) async {
    final response = await _api.post('$_endpoint/manager', data: data);
    return response.data;
  }

  // ============ LỊCH SỬ GIAO CA ============

  Future<dynamic> getShiftHandoverHistory({
    String? hotelId,
    String? staffId,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    if (staffId != null) params['staffId'] = staffId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    final response = await _api.get('$_endpoint/history', queryParameters: params);
    return response.data;
  }

  Future<dynamic> getShiftHandoverById(String id) async {
    final response = await _api.get('$_endpoint/history/$id');
    return response.data;
  }

  // ============ THỐNG KÊ GIAO CA ============

  Future<dynamic> getShiftHandoverStats({
    String? hotelId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get('$_endpoint/stats', queryParameters: params);
    return response.data;
  }

  // ============ TÍNH TOÁN DOANH THU ============

  Future<dynamic> calculateRevenue({
    required String hotelId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {'hotelId': hotelId};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get('$_endpoint/revenue', queryParameters: params);
    return response.data;
  }

  Future<dynamic> getRevenueByPeriod({
    required String hotelId,
    String? period, // 'day' | 'week' | 'month'
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {'hotelId': hotelId};
    if (period != null) params['period'] = period;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get('$_endpoint/revenue/period', queryParameters: params);
    return response.data;
  }

  // ============ LẤY SỐ TIỀN CA TRƯỚC ============

  Future<dynamic> getPreviousShiftAmount(String hotelId, {String? staffId}) async {
    final Map<String, dynamic> params = {'hotelId': hotelId};
    if (staffId != null) params['staffId'] = staffId;

    final response = await _api.get('$_endpoint/previous-amount', queryParameters: params);
    return response.data;
  }
}
