import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
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
      final res = await _api.get(AppConstants.staffsEndpoint);
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
      final name = '${m['fullName'] ?? m['username'] ?? ''}'.toLowerCase();
      final role = '${m['role'] ?? ''}'.toLowerCase();
      return name.contains(q) || role.contains(q);
    }).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý nhân viên')),
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
                      hintText: 'Tìm nhân viên',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._filtered.map((e) {
                    final m = e as Map<String, dynamic>;
                    final title = '${m['fullName'] ?? m['username'] ?? 'Nhân viên'}';
                    final role = m['role'] != null ? ' • ${m['role']}' : '';
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.people),
                        title: Text('$title$role'),
                        subtitle: Text(m['email'] ?? ''),
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

