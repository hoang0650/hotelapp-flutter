import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(AppConstants.financialSummaryEndpoint);
      final data = res.data;
      if (data is Map<String, dynamic>) {
        _summary = data;
      } else {
        _summary = null;
      }
    } catch (e) {
      _summary = null;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo tài chính')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _summary == null
                ? const Center(child: Text('Không có dữ liệu'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.attach_money),
                          title: const Text('Tổng doanh thu'),
                          trailing: Text('${_summary?['totalRevenue'] ?? 0}'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.money_off),
                          title: const Text('Tổng chi phí'),
                          trailing: Text('${_summary?['totalExpense'] ?? 0}'),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.savings),
                          title: const Text('Lợi nhuận'),
                          trailing: Text('${_summary?['profit'] ?? 0}'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

