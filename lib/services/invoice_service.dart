import 'package:dio/dio.dart';
import 'api_service.dart';

class InvoiceService {
  final ApiService _api = ApiService();
  final String _endpoint = '/invoices'; // Base endpoint might vary, checking Angular code...
  // Angular uses environment.apiUrl + '/invoice' for single items and '/invoices' for lists.
  // It's a bit mixed. I will follow the Angular service paths exactly.

  // Lấy thông tin hóa đơn theo ID
  Future<dynamic> getInvoiceById(String id) async {
    final response = await _api.get('/invoice/$id');
    return response.data;
  }

  // Lấy hóa đơn theo phòng
  Future<dynamic> getInvoiceByRoom(String roomId, {String? hotelId}) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    
    final response = await _api.get('/invoice/room/$roomId', queryParameters: params);
    return response.data['invoice'];
  }

  // Gửi email hóa đơn
  Future<void> sendInvoiceEmail(String invoiceId, String email) async {
    await _api.post('$_endpoint/$invoiceId/email', data: {'email': email});
  }

  // Xóa hóa đơn
  Future<void> deleteInvoice(String invoiceId) async {
    await _api.delete('$_endpoint/$invoiceId');
  }

  // Tạo hóa đơn mới
  Future<dynamic> createInvoice(Map<String, dynamic> invoiceData) async {
    final response = await _api.post(_endpoint, data: invoiceData);
    return response.data;
  }

  // Lấy danh sách hóa đơn
  Future<dynamic> getInvoices({
    String? hotelId,
    String? roomId,
    String? customerId,
    String? startDate,
    String? endDate,
    String? status,
    String? paymentStatus,
    int? page,
    int? limit,
  }) async {
    final Map<String, dynamic> params = {};
    if (hotelId != null) params['hotelId'] = hotelId;
    if (roomId != null) params['roomId'] = roomId;
    if (customerId != null) params['customerId'] = customerId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (status != null) params['status'] = status;
    if (paymentStatus != null) params['paymentStatus'] = paymentStatus;
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;

    final response = await _api.get(_endpoint, queryParameters: params);
    return response.data;
  }

  // Lấy thống kê hóa đơn
  Future<dynamic> getInvoiceStats({
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

  // Cập nhật hóa đơn
  Future<dynamic> updateInvoice(String id, Map<String, dynamic> invoiceData) async {
    final response = await _api.put('/invoice/$id', data: invoiceData);
    return response.data;
  }

  // Cập nhật trạng thái hóa đơn
  Future<dynamic> updateInvoiceStatus(String id, String status) async {
    final response = await _api.patch('/invoice/$id/status', data: {'status': status});
    return response.data;
  }

  // Lấy danh sách hóa đơn theo khách sạn
  Future<dynamic> getInvoicesByHotel(String hotelId, {String? status}) async {
    final Map<String, dynamic> params = {};
    if (status != null) params['status'] = status;
    
    final response = await _api.get('/invoice/hotel/$hotelId', queryParameters: params);
    return response.data;
  }

  // Lấy thống kê hóa đơn (Legacy/Alternative)
  Future<dynamic> getInvoiceStatistics(String hotelId, String period) async {
    final params = {'period': period};
    final response = await _api.get('/invoice/statistics/$hotelId', queryParameters: params);
    return response.data;
  }

  // ============ SEPAY EINVOICE API ============
  
  // Đăng nhập Sepay eInvoice
  Future<dynamic> loginEInvoice(String username, String password) async {
    final response = await _api.post('$_endpoint/e-invoice/login', data: {
      'username': username,
      'password': password,
    });
    return response.data;
  }

  // Đăng xuất Sepay eInvoice
  Future<void> logoutEInvoice() async {
    await _api.post('$_endpoint/e-invoice/logout');
  }

  // Lấy danh sách tài khoản nhà cung cấp
  Future<dynamic> getEInvoiceProviderAccounts() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final response = await _api.get('$_endpoint/e-invoice/provider-accounts', queryParameters: {'_t': timestamp});
    return response.data;
  }

  // Lấy chi tiết tài khoản nhà cung cấp
  Future<dynamic> getEInvoiceProviderAccountDetails(String accountId) async {
    final response = await _api.get('$_endpoint/e-invoice/provider-accounts/$accountId');
    return response.data;
  }

  // Tạo hóa đơn điện tử
  Future<dynamic> createEInvoice(Map<String, dynamic> invoiceData) async {
    final response = await _api.post('$_endpoint/e-invoice/create', data: invoiceData);
    return response.data;
  }

  // Kiểm tra trạng thái tạo hóa đơn
  Future<dynamic> checkEInvoiceCreateStatus(String trackingCode) async {
    final response = await _api.get('$_endpoint/e-invoice/create/check/$trackingCode');
    return response.data;
  }

  // Phát hành hóa đơn điện tử
  Future<dynamic> issueEInvoice(Map<String, dynamic> issueData) async {
    final response = await _api.post('$_endpoint/e-invoice/issue', data: issueData);
    return response.data;
  }

  // Kiểm tra trạng thái phát hành hóa đơn
  Future<dynamic> checkEInvoiceIssueStatus(String trackingCode) async {
    final response = await _api.get('$_endpoint/e-invoice/issue/check/$trackingCode');
    return response.data;
  }

  // Lấy chi tiết hóa đơn điện tử
  Future<dynamic> getEInvoiceDetails(String referenceCode) async {
    final response = await _api.get('$_endpoint/e-invoice/$referenceCode');
    return response.data;
  }

  // Kiểm tra hạn ngạch
  Future<dynamic> getEInvoiceUsage() async {
    final response = await _api.get('$_endpoint/e-invoice/usage');
    return response.data;
  }

  // Phân chia quota cho hotel
  Future<dynamic> allocateQuota(Map<String, dynamic> data) async {
    final response = await _api.post('$_endpoint/e-invoice/quota/allocate', data: data);
    return response.data;
  }

  // Lấy danh sách quota của các hotel
  Future<dynamic> getHotelQuotas() async {
    final response = await _api.get('$_endpoint/e-invoice/quota/hotels');
    return response.data;
  }

  // Danh sách hóa đơn điện tử
  Future<dynamic> listEInvoices({
    int? page,
    int? limit,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> params = {};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (status != null) params['status'] = status;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get('$_endpoint/e-invoice', queryParameters: params);
    return response.data;
  }
}
