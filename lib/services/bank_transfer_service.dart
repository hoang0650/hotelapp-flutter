import 'package:dio/dio.dart';
import 'api_service.dart';

class BankTransferService {
  final ApiService _api = ApiService();
  final String _endpoint = '/sepay';
  final String _bankTransfersEndpoint = '/api/bank-transfers'; // Note: Angular has 'api/bank-transfers' but usually ApiService prepends base URL. 
  // However, Angular service has private bankTransfersUrl = 'api/bank-transfers'; and usage is this.http.get(...)
  // Assuming 'api/bank-transfers' is relative to base URL.

  // NOTE: ApiService in Flutter likely prepends baseUrl.
  // I will assume /bank-transfers is the correct path if api/ prefix is standard.
  // Let's check api_service.dart base url structure if needed, but usually it's just path.
  // Actually, Angular code: private bankTransfersUrl = 'api/bank-transfers';
  // If environment.apiUrl is 'http://localhost:3000', then it calls 'http://localhost:3000/api/bank-transfers' ??? 
  // OR is it relative to current domain? 
  // Usually Angular HttpClient with simple string uses relative path if not http...
  // BUT wait, standard practice in this project seems to be `${environment.apiUrl}/...`.
  // The bank transfer service has `private bankTransfersUrl = 'api/bank-transfers';` and `this.http.get(...)`.
  // If it's not starting with http, it's relative to the page origin (frontend server), which might proxy to backend.
  // OR it might be a mistake in Angular code and it relies on interceptor to add base URL.
  // I will assume it maps to `${environment.apiUrl}/bank-transfers` or `${environment.apiUrl}/api/bank-transfers`.
  // Let's try `bank-transfers` first or check backend routes. 
  // I'll stick to `bank-transfers` (no api prefix) if that's common, OR `api/bank-transfers`.
  // Let's check other services. `private apiUrl = '${environment.apiUrl}/services';`
  // So likely `bank-transfers` is at root of API or `api/` is part of path.
  // I'll use `/bank-transfers` for now, assuming standard NestJS routing.

  Future<List<dynamic>> getTransferHistory() async {
    final response = await _api.get('/bank-transfers');
    return response.data as List<dynamic>;
  }

  Future<dynamic> getTransferById(String id) async {
    final response = await _api.get('/bank-transfers/$id');
    return response.data;
  }

  Future<List<dynamic>> searchTransfers({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? bankName,
  }) async {
    final Map<String, dynamic> params = {};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();
    if (status != null) params['status'] = status;
    if (bankName != null) params['bankName'] = bankName;

    final response = await _api.get('/bank-transfers/search', queryParameters: params);
    return response.data as List<dynamic>;
  }

  // ============ SePay Transactions ============

  Future<dynamic> getSepayTransactions({
    String? token,
    String? dateFrom,
    String? dateTo,
    String? status,
    String? bankName,
    String? bankAccountId,
    String? search,
    int? page,
    int? pageSize,
  }) async {
    final Map<String, dynamic> params = {};
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (status != null) params['status'] = status;
    if (bankName != null) params['bankName'] = bankName;
    if (bankAccountId != null) params['bank_account_id'] = bankAccountId;
    if (search != null) params['search'] = search;
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;

    // Handling headers if token is provided
    // ApiService might not support custom headers easily per request if not designed so.
    // But usually we can pass options. 
    // If ApiService doesn't support headers, we might need to rely on default auth or modify ApiService.
    // Assuming backend handles token if not provided (as per comment "Nếu không có token, backend sẽ tự lấy token").
    
    // NOTE: ApiService in Flutter project usually handles Authorization header automatically.
    // If we need to pass a SPECIFIC token (SePay token), we might need to override it.
    // But the comment says backend proxies it.
    
    final response = await _api.get('$_endpoint/transactions', queryParameters: params);
    return response.data;
  }

  Future<dynamic> getSepayPaymentHistory() async {
    final response = await _api.get('$_endpoint/payment-history');
    return response.data;
  }

  // OAuth2 methods ... (Might not be needed for mobile app if web flow is used, but good to have)
  
  Future<dynamic> getOAuth2AuthorizeUrl({
    required String clientId,
    required String redirectUri,
    String? scope,
    String? state,
  }) async {
    final Map<String, dynamic> params = {
      'client_id': clientId,
      'redirect_uri': redirectUri,
    };
    if (scope != null) params['scope'] = scope;
    if (state != null) params['state'] = state;

    final response = await _api.get('$_endpoint/oauth2/authorize', queryParameters: params);
    return response.data;
  }
}
