import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  List<dynamic> _hotels = [];
  String? _selectedHotelId;
  bool _saving = false;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _categoryValue;
  bool _activeValue = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _loadHotels();
      final res = await _api.get(
        AppConstants.servicesEndpoint,
        queryParameters: _selectedHotelId != null ? {'hotelId': _selectedHotelId} : null,
      );
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

  Future<void> _loadHotels() async {
    try {
      final res = await _api.get(AppConstants.hotelsEndpoint);
      final data = res.data;
      _hotels = (data is List)
          ? data
          : (data is Map && data['items'] is List)
              ? data['items']
              : [];
      if (_hotels.isNotEmpty && _selectedHotelId == null) {
        _selectedHotelId = (_hotels.first as Map)['_id'];
      }
    } catch (_) {
      _hotels = [];
    }
  }

  void _applyFilter() {
    final q = _searchController.text.toLowerCase();
    _filtered = _items.where((x) {
      final m = x as Map<String, dynamic>;
      final name = '${m['name'] ?? ''}'.toLowerCase();
      return name.contains(q);
    }).toList();
    setState(() {});
  }

  Future<void> _deleteService(String id) async {
    try {
      await _api.delete('${AppConstants.servicesEndpoint}/$id');
      await _load();
    } catch (_) {}
  }

  Future<void> _submitService({Map<String, dynamic>? initial}) async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên dịch vụ')));
      return;
    }
    setState(() => _saving = true);
    try {
      if (initial == null) {
        final res = await _api.post(AppConstants.servicesEndpoint, data: {
          'name': name,
          if (price != null) 'price': price,
          if (_categoryValue != null && _categoryValue!.isNotEmpty) 'category': _categoryValue,
          'active': _activeValue,
        });
        final created = res.data is Map ? res.data as Map<String, dynamic> : null;
        final createdId = created?['_id'] ?? created?['id'];
        if (_selectedHotelId != null && createdId != null) {
          await _api.post('${AppConstants.servicesEndpoint}/assign', data: {
            'serviceId': createdId,
            'hotelId': _selectedHotelId,
          });
        }
      } else {
        final id = initial['_id'] ?? initial['id'];
        await _api.put('${AppConstants.servicesEndpoint}/$id', data: {
          'name': name,
          if (price != null) 'price': price,
          if (_categoryValue != null && _categoryValue!.isNotEmpty) 'category': _categoryValue,
          'active': _activeValue,
        });
      }
      Navigator.of(context).pop();
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lưu dịch vụ')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openServiceForm({Map<String, dynamic>? initial}) {
    _nameController.text = '${initial?['name'] ?? ''}';
    _priceController.text = initial?['price'] != null ? '${initial?['price']}' : '';
    _categoryValue = '${initial?['category'] ?? ''}';
    _activeValue = (initial?['active'] == true) || (initial?['status'] == 'active');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(initial == null ? 'Thêm dịch vụ' : 'Sửa dịch vụ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên dịch vụ *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _categoryValue?.isEmpty == true ? null : _categoryValue,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: const [
                    DropdownMenuItem(value: 'food', child: Text('Đồ uống')),
                    DropdownMenuItem(value: 'service', child: Text('Dịch vụ')),
                    DropdownMenuItem(value: 'other', child: Text('Khác')),
                  ],
                  onChanged: (v) => setState(() => _categoryValue = v ?? ''),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _activeValue,
                  onChanged: (v) => setState(() => _activeValue = v),
                  title: const Text('Hoạt động'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: _saving ? null : () => _submitService(initial: initial),
              child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý dịch vụ')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedHotelId,
                    decoration: const InputDecoration(labelText: 'Khách sạn'),
                    items: _hotels
                        .map((h) => DropdownMenuItem<String>(
                              value: (h as Map)['_id'],
                              child: Text('${(h as Map)['name'] ?? 'N/A'}'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedHotelId = v);
                      _load();
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm dịch vụ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._filtered.map((e) {
                    final m = e as Map<String, dynamic>;
                    final title = '${m['name'] ?? 'Dịch vụ'}';
                    final price = m['price'] != null ? ' - ${m['price']}₫' : '';
                    final active = (m['active'] == true) || (m['status'] == 'active');
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.room_service),
                                const SizedBox(width: 8),
                                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (active ? Colors.green : Colors.grey).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(active ? 'Hoạt động' : 'Tạm dừng', style: TextStyle(color: active ? Colors.green : Colors.grey)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Giá$price'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Sửa'),
                                    onPressed: () => _openServiceForm(initial: m),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Xóa'),
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                    onPressed: () {
                                      final id = m['_id'] ?? m['id'];
                                      if (id != null) _deleteService('$id');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openServiceForm(),
        label: const Text('Thêm dịch vụ'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
