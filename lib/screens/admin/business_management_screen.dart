import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class BusinessManagementScreen extends StatefulWidget {
  const BusinessManagementScreen({super.key});

  @override
  State<BusinessManagementScreen> createState() => _BusinessManagementScreenState();
}

class _BusinessManagementScreenState extends State<BusinessManagementScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _api.get(AppConstants.businessEndpoint);
      final data = res.data;
      if (data is List) {
        _items = data;
      } else if (data is Map && data['items'] is List) {
        _items = data['items'];
      } else {
        _items = [];
      }
      _applyFilter();
    } catch (e) {
      _items = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchController.text.toLowerCase();
    _filtered = _items.where((x) {
      final m = x as Map<String, dynamic>;
      final name = '${m['name'] ?? m['businessName'] ?? ''}'.toLowerCase();
      return name.contains(q);
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý doanh nghiệp')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm doanh nghiệp',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._filtered.map((e) {
                    final m = e as Map<String, dynamic>;
                    final title = '${m['name'] ?? m['businessName'] ?? 'Doanh nghiệp'}';
                    final code = m['code'] != null ? ' • ${m['code']}' : '';
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.business),
                        title: Text('$title$code'),
                      ),
                    );
                  }),
                  if (_filtered.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Không có dữ liệu'),
                    )),
                ],
              ),
      ),
    );
  }
}

