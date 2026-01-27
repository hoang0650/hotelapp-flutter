import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';
import 'package:go_router/go_router.dart';

class ShiftHandoverScreen extends StatefulWidget {
  const ShiftHandoverScreen({super.key});

  @override
  State<ShiftHandoverScreen> createState() => _ShiftHandoverScreenState();
}

class _ShiftHandoverScreenState extends State<ShiftHandoverScreen> {
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
      appBar: AppBar(
        title: const Text('Giao ca'),
        actions: [
          IconButton(
            onPressed: () => context.push('/admin/shift-handover-history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
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
                      leading: const Icon(Icons.swap_horiz),
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

