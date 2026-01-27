import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({super.key});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(AppConstants.debtEndpoint);
      final data = res.data;
      if (data is List) {
        _items = data;
      } else if (data is Map && data['items'] is List) {
        _items = data['items'];
      } else {
        _items = [];
      }
    } catch (e) {
      _items = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý công nợ')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final m = _items[index] as Map<String, dynamic>;
                  final debtor = '${m['debtorName'] ?? m['customerName'] ?? 'Khách hàng'}';
                  final amount = m['amount'] ?? m['total'] ?? 0;
                  final status = m['status'] ?? 'pending';
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.money_off),
                      title: Text(debtor),
                      subtitle: Text('Số tiền: $amount • Trạng thái: $status'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

