import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final _api = ApiService();
  final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  bool _loading = true;
  List<dynamic> _invoices = [];
  int _page = 1;
  final int _pageSize = 20;
  int _totalPages = 1;
  String? _hotelId;
  String? _statusFilter; // paid | pending | cancelled | failed | null

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(
        AppConstants.invoicesEndpoint,
        queryParameters: {
          if (_hotelId != null && _hotelId!.isNotEmpty) 'hotelId': _hotelId,
          if (_statusFilter != null && _statusFilter!.isNotEmpty) 'status': _statusFilter,
          'page': _page,
          'limit': _pageSize,
        },
      );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final items = data['invoices'];
        final pagination = data['pagination'];
        _invoices = (items is List) ? items : [];
        _totalPages = (pagination is Map && pagination['totalPages'] is int) ? pagination['totalPages'] : 1;
      } else if (data is List) {
        _invoices = data;
        _totalPages = 1;
      } else {
        _invoices = [];
        _totalPages = 1;
      }
    } catch (_) {
      _invoices = [];
      _totalPages = 1;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 đ';
    return _currency.format(amount);
  }

  String _formatDate(String? value) {
    if (value == null) return 'N/A';
    final d = DateTime.tryParse(value);
    if (d == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
    }

  Color _statusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s == 'paid' || s == 'completed' || s == 'success') return Colors.green;
    if (s == 'pending') return Colors.orange;
    if (s == 'cancelled' || s == 'failed') return Colors.red;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo hóa đơn')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Trạng thái',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: _statusFilter,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'paid', child: Text('Đã thanh toán')),
                      DropdownMenuItem(value: 'pending', child: Text('Chờ thanh toán')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Đã hủy')),
                      DropdownMenuItem(value: 'failed', child: Text('Thất bại')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _statusFilter = v;
                        _page = 1;
                      });
                      _loadInvoices();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: _loadInvoices,
                    child: const Text('Làm mới'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _invoices.isEmpty
                    ? const Center(child: Text('Không có hóa đơn'))
                    : ListView.separated(
                        itemCount: _invoices.length,
                        padding: const EdgeInsets.all(12),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _invoices[index] as Map<String, dynamic>;
                          final number = item['invoiceNumber'] ?? item['number'] ?? 'N/A';
                          final total = (item['totalAmount'] ?? item['amount'] ?? 0) as num;
                          final status = item['status'] ?? item['paymentStatus'];
                          final createdAt = item['createdAt'] as String?;
                          return Card(
                            child: ListTile(
                              title: Text('Hóa đơn #$number', style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Ngày tạo: ${_formatDate(createdAt)}'),
                                  const SizedBox(height: 4),
                                  Text('Tổng tiền: ${_formatCurrency(total)}'),
                                ],
                              ),
                              trailing: _statusBadge(status),
                            ),
                          );
                        },
                      ),
          ),
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trang $_page/$_totalPages'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _page > 1
                            ? () {
                                setState(() => _page--);
                                _loadInvoices();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _page < _totalPages
                            ? () {
                                setState(() => _page++);
                                _loadInvoices();
                              }
                            : null,
                      ),
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
