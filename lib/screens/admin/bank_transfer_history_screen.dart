import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class BankTransferHistoryScreen extends StatefulWidget {
  const BankTransferHistoryScreen({super.key});

  @override
  State<BankTransferHistoryScreen> createState() => _BankTransferHistoryScreenState();
}

class _BankTransferHistoryScreenState extends State<BankTransferHistoryScreen> {
  final _api = ApiService();
  bool _loading = true;
  bool _refreshing = false;
  List<dynamic> _transactions = [];
  String _searchText = '';
  final _currencyVnd = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _refreshing = true;
    });
    try {
      final res = await _api.get('${AppConstants.sepayEndpoint}/transactions');
      final data = res.data;
      _transactions = (data is List) ? data : (data is Map && data['transactions'] is List) ? data['transactions'] : [];
    } catch (_) {
      _transactions = [];
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 đ';
    return _currencyVnd.format(amount);
  }

  String _formatDate(String? value) {
    if (value == null) return 'N/A';
    final d = DateTime.tryParse(value);
    if (d == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  List<dynamic> _filtered() {
    if (_searchText.isEmpty) return _transactions;
    final s = _searchText.toLowerCase();
    return _transactions.where((t) {
      final m = t as Map<String, dynamic>;
      final brand = (m['bank_brand_name'] ?? '').toString().toLowerCase();
      final acc = (m['account_number'] ?? '').toString().toLowerCase();
      final content = (m['content'] ?? '').toString().toLowerCase();
      final ref = (m['reference_code'] ?? '').toString().toLowerCase();
      return brand.contains(s) || acc.contains(s) || content.contains(s) || ref.contains(s);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _filtered();
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử giao dịch SePay')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm theo nội dung hoặc mã tham chiếu',
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
                    onPressed: _loadTransactions,
                    child: const Text('Làm mới'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : data.isEmpty
                    ? const Center(child: Text('Chưa có giao dịch'))
                    : ListView.separated(
                        itemCount: data.length,
                        padding: const EdgeInsets.all(12),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = data[index] as Map<String, dynamic>;
                          final inAmount = num.tryParse('${item['amount_in'] ?? '0'}') ?? 0;
                          final outAmount = num.tryParse('${item['amount_out'] ?? '0'}') ?? 0;
                          final isIn = inAmount > 0;
                          final amount = isIn ? inAmount : outAmount;
                          return Card(
                            child: ListTile(
                              title: Text(
                                '${item['bank_brand_name'] ?? 'N/A'} - ${item['account_number'] ?? 'N/A'}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Thời gian: ${_formatDate(item['transaction_date']?.toString())}'),
                                  const SizedBox(height: 4),
                                  Text('Nội dung: ${(item['content'] ?? 'N/A').toString()}'),
                                  const SizedBox(height: 4),
                                  Text('Mã tham chiếu: ${(item['reference_code'] ?? 'N/A').toString()}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    (isIn ? '+ ' : '- ') + _formatCurrency(amount),
                                    style: TextStyle(
                                      color: isIn ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(isIn ? 'Tiền vào' : 'Tiền ra', style: const TextStyle(fontSize: 12)),
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
