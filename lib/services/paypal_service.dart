import 'package:hotelapp_flutter/services/api_service.dart';

class PaypalService {
  final ApiService _api = ApiService();
  final String _endpoint = '/paypal';

  Future<dynamic> getPaymentHistory() async {
    final response = await _api.get('$_endpoint/payment-history');
    return response.data;
  }

  Future<dynamic> getConfig() async {
    final response = await _api.get('$_endpoint/config');
    return response.data;
  }
}
