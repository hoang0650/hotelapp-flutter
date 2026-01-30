import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _api = ApiService();
  bool _loading = true;
  bool _refreshing = false;
  String _activeTab = 'all'; // all | sepay | paypal | crypto
  String _searchText = '';
  List<dynamic> _sepay = [];
  List<dynamic> _paypal = [];
  List<dynamic> _crypto = [];
  final _currencyVnd = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  final _currencyUsd = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _refreshing = true;
    });
    try {
      final results = await Future.wait([
        _api.get('${AppConstants.sepayEndpoint}/payment-history'),
        _api.get('${AppConstants.paypalEndpoint}/payment-history'),
        _api.get('${AppConstants.cryptoEndpoint}/payment-history'),
      ]);
      final sepayData = results[0].data;
      final paypalData = results[1].data;
      final cryptoData = results[2].data;
      _sepay = (sepayData is List) ? sepayData : (sepayData is Map && sepayData['data'] is List) ? sepayData['data'] : [];
      _paypal = (paypalData is List) ? paypalData : (paypalData is Map && paypalData['data'] is List) ? paypalData['data'] : [];
      _crypto = (cryptoData is List) ? cryptoData : (cryptoData is Map && cryptoData['data'] is List) ? cryptoData['data'] : [];
    } catch (_) {
      _sepay = [];
      _paypal = [];
      _crypto = [];
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  String _formatCurrency(num? amount, {String? currency}) {
    if (amount == null) return currency == 'USD' ? '\$0.00' : '0 đ';
    if (currency == 'USD') return _currencyUsd.format(amount);
    return _currencyVnd.format(amount);
  }

  String _formatDate(String? value) {
    if (value == null) return 'N/A';
    final d = DateTime.tryParse(value);
    if (d == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  Color _statusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s == 'completed' || s == 'success' || s == 'paid') return Colors.green;
    if (s == 'pending') return Colors.orange;
    if (s == 'failed' || s == 'cancelled') return Colors.red;
    return Colors.grey;
  }

  Widget _statusBadge(String? status) {
    final color = _statusColor(status);
    final label = (status ?? 'N/A').toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  List<Map<String, dynamic>> _normalizeSepay(List<dynamic> src) {
    return src.map<Map<String, dynamic>>((item) {
      final map = item as Map<String, dynamic>;
      final amount = (map['amount'] ?? map['paymentGatewayResponse']?['transferAmount'] ?? 0) as num;
      return {
        'id': map['_id'] ?? map['id'] ?? UniqueKey().toString(),
        'method': 'SePay',
        'amount': amount,
        'currency': map['currency'] ?? 'VND',
        'status': map['status'] ?? map['paymentStatus'],
        'createdAt': map['createdAt'],
        'transactionId': map['transactionId'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _normalizePaypal(List<dynamic> src) {
    return src.map<Map<String, dynamic>>((item) {
      final map = item as Map<String, dynamic>;
      final amount = (map['amount'] ?? 0) as num;
      return {
        'id': map['_id'] ?? map['id'] ?? UniqueKey().toString(),
        'method': 'PayPal',
        'amount': amount,
        'currency': map['currency'] ?? 'USD',
        'status': map['status'] ?? map['paymentStatus'],
        'createdAt': map['createdAt'],
        'orderId': map['paypalOrderId'] ?? map['orderId'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _normalizeCrypto(List<dynamic> src) {
    return src.map<Map<String, dynamic>>((item) {
      final map = item as Map<String, dynamic>;
      final amount = (map['amount'] ?? 0) as num;
      return {
        'id': map['_id'] ?? map['id'] ?? UniqueKey().toString(),
        'method': 'Crypto USDT',
        'amount': amount,
        'currency': map['currency'] ?? 'VND',
        'status': map['status'] ?? map['paymentStatus'],
        'createdAt': map['createdAt'],
        'txHash': map['cryptoTransactionHash'] ?? map['txHash'],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _allPayments() {
    final sepay = _normalizeSepay(_sepay);
    final paypal = _normalizePaypal(_paypal);
    final crypto = _normalizeCrypto(_crypto);
    return [...sepay, ...paypal, ...crypto];
  }

  List<Map<String, dynamic>> _filteredPayments() {
    List<Map<String, dynamic>> data;
    if (_activeTab == 'sepay') {
      data = _normalizeSepay(_sepay);
    } else if (_activeTab == 'paypal') {
      data = _normalizePaypal(_paypal);
    } else if (_activeTab == 'crypto') {
      data = _normalizeCrypto(_crypto);
    } else {
      data = _allPayments();
    }
    if (_searchText.isEmpty) return data;
    final s = _searchText.toLowerCase();
    return data.where((e) {
      final method = (e['method'] ?? '').toString().toLowerCase();
      final tx = (e['transactionId'] ?? e['orderId'] ?? e['txHash'] ?? '').toString().toLowerCase();
      return method.contains(s) || tx.contains(s);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      {'id': 'all', 'label': 'Tất cả'},
      {'id': 'sepay', 'label': 'SePay'},
      {'id': 'paypal', 'label': 'PayPal'},
      {'id': 'crypto', 'label': 'Crypto'},
    ];
    final data = _filteredPayments();
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử thanh toán')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm theo phương thức hoặc mã giao dịch',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _searchText = v),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _loadAll,
                    child: const Text('Làm mới'),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs.map((t) {
                final active = _activeTab == t['id'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text('${t['label']}'),
                    selected: active,
                    onSelected: (_) => setState(() => _activeTab = '${t['id']}'),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? const Center(child: Text('Chưa có lịch sử thanh toán'))
                    : ListView.separated(
                        itemCount: data.length,
                        padding: const EdgeInsets.all(12),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return Card(
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['method'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  _statusBadge(item['status']?.toString()),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Số tiền: ${_formatCurrency(item['amount'] as num?, currency: item['currency']?.toString())}'),
                                  const SizedBox(height: 4),
                                  Text('Thời gian: ${_formatDate(item['createdAt']?.toString())}'),
                                  const SizedBox(height: 4),
                                  Text('Mã giao dịch: ${(item['transactionId'] ?? item['orderId'] ?? item['txHash'] ?? 'N/A').toString()}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
