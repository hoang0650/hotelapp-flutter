import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/financial_summary_service.dart';
import 'package:provider/provider.dart';
import 'package:hotelapp_flutter/providers/hotel_provider.dart';

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  final _financialSummaryService = FinancialSummaryService();
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
      final hp = Provider.of<HotelProvider>(context, listen: false);
      final data = await _financialSummaryService.getFinancialSummary(hotelId: hp.selectedHotelId);
      if (data is Map<String, dynamic>) {
        // Data might be wrapped in a message/data structure or direct
        _summary = data['data'] ?? data;
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

