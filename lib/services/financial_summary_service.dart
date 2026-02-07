import 'package:dio/dio.dart';
import 'api_service.dart';

class FinancialSummaryService {
  final ApiService _api = ApiService();
  final String _endpoint = '/financial-summary';

  Future<Map<String, dynamic>> getFinancialSummary({
    String? hotelId,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get(_endpoint, queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<dynamic> updateInitialInvestment(String hotelId, double initialInvestment) async {
    final response = await _api.patch(
      '$_endpoint/initial-investment/$hotelId',
      data: {'initialInvestment': initialInvestment},
    );
    return response.data;
  }

  Future<dynamic> updateFinancialConfig(String hotelId, Map<String, dynamic> financialConfig) async {
    final response = await _api.patch(
      '$_endpoint/financial-config/$hotelId',
      data: {'financialConfig': financialConfig},
    );
    return response.data;
  }
}
