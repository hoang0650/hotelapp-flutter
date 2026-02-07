import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotelapp_flutter/services/service_service.dart';
import 'package:hotelapp_flutter/providers/hotel_provider.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final _serviceService = ServiceService();
  List<dynamic> _items = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();
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
      final hp = Provider.of<HotelProvider>(context, listen: false);
      final hotelId = hp.selectedHotelId;
      final data = await _serviceService.getServices(hotelId: hotelId);
      _items = data;
      _applyFilter();
    } catch (e) {
      _items = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Removed _loadHotels

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
      await _serviceService.deleteService(id);
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
      final hp = Provider.of<HotelProvider>(context, listen: false);
      final hotelId = hp.selectedHotelId;
      if (initial == null) {
        final created = await _serviceService.createService({
          'name': name,
          if (price != null) 'price': price,
          if (_categoryValue != null && _categoryValue!.isNotEmpty) 'category': _categoryValue,
          'active': _activeValue,
        });
        
        final createdMap = created is Map ? created as Map<String, dynamic> : null;
        final createdId = createdMap?['_id'] ?? createdMap?['id'];
        
        if (hotelId != null && createdId != null) {
          await _serviceService.assignServiceToHotel(createdId, hotelId);
        }
      } else {
        final id = initial['_id'] ?? initial['id'];
        await _serviceService.updateService(id, {
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
