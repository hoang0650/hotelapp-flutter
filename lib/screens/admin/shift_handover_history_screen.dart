import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class ShiftHandoverHistoryScreen extends StatefulWidget {
  const ShiftHandoverHistoryScreen({super.key});

  @override
  State<ShiftHandoverHistoryScreen> createState() => _ShiftHandoverHistoryScreenState();
}

class _ShiftHandoverHistoryScreenState extends State<ShiftHandoverHistoryScreen> {
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
      final res = await _api.get(AppConstants.shiftHandoverEndpoint);
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
      appBar: AppBar(title: const Text('Lịch sử giao ca')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final m = _items[index] as Map<String, dynamic>;
                  final date = '${m['createdAt'] ?? m['date'] ?? ''}';
                  final totalCash = m['totalCash'] ?? m['cash'] ?? 0;
                  final note = m['note'] ?? '';
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('Ngày: $date'),
                      subtitle: Text('Tiền mặt: $totalCash • $note'),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

