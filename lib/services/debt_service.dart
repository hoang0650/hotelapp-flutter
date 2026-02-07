import 'package:dio/dio.dart';
import 'api_service.dart';

class DebtService {
  final ApiService _api = ApiService();
  final String _endpoint = '/debt';

  Future<dynamic> createDebt(String invoiceId, {String? notes, String? dueDate}) async {
    final Map<String, dynamic> data = {'invoiceId': invoiceId};
    if (notes != null) data['notes'] = notes;
    if (dueDate != null) data['dueDate'] = dueDate;

    final response = await _api.post(_endpoint, data: data);
    return response.data;
  }

  Future<dynamic> createManualDebt(Map<String, dynamic> payload) async {
    final response = await _api.post(_endpoint, data: payload);
    return response.data;
  }

  Future<dynamic> updateDebt(String id, Map<String, dynamic> payload) async {
    final response = await _api.put('$_endpoint/$id', data: payload);
    return response.data;
  }

  Future<dynamic> getDebts({
    int? page,
    int? pageSize,
    String? hotelId,
    String? status,
    String? customerId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (page != null) params['page'] = page;
    if (pageSize != null) params['limit'] = pageSize;
    if (hotelId != null) params['hotelId'] = hotelId;
    if (status != null) params['status'] = status;
    if (customerId != null) params['customerId'] = customerId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get(_endpoint, queryParameters: params);
    return response.data;
  }

  Future<dynamic> getDebtById(String id) async {
    final response = await _api.get('$_endpoint/$id');
    return response.data;
  }

  Future<dynamic> settleDebt(String id, Map<String, dynamic> request) async {
    final response = await _api.post('$_endpoint/$id/settle', data: request);
    return response.data;
  }

  Future<void> deleteDebt(String id) async {
    await _api.delete('$_endpoint/$id');
  }

  Future<dynamic> updateDebtLabels(String id, List<dynamic> labels) async {
    final response = await _api.patch('$_endpoint/$id/labels', data: {'labels': labels});
    return response.data;
  }
}
