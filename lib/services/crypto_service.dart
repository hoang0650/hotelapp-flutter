import 'package:hotelapp_flutter/services/api_service.dart';

class CryptoService {
  final ApiService _api = ApiService();
  final String _endpoint = '/crypto';

  Future<dynamic> getPaymentHistory() async {
    final response = await _api.get('$_endpoint/payment-history');
    return response.data;
  }
}
