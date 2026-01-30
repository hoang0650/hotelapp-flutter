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
  List<dynamic> _hotels = [];
  String? _selectedHotelId;
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _roleValue;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _loadHotels();
      final path = _selectedHotelId != null && _selectedHotelId!.isNotEmpty
          ? '${AppConstants.staffsEndpoint}/hotel/${_selectedHotelId}'
          : AppConstants.staffsEndpoint;
      final res = await _api.get(path);
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
      final name = '${m['fullName'] ?? m['username'] ?? ''}'.toLowerCase();
      final role = '${m['role'] ?? ''}'.toLowerCase();
      return name.contains(q) || role.contains(q);
    }).toList();
    setState(() {});
  }

  Future<void> _deleteStaff(String id) async {
    try {
      await _api.delete('${AppConstants.staffsEndpoint}/$id');
      await _load();
    } catch (_) {}
  }

  Future<void> _submitStaff({Map<String, dynamic>? initial}) async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (fullName.isEmpty && username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên/username')));
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = {
        if (fullName.isNotEmpty) 'fullName': fullName,
        if (username.isNotEmpty) 'username': username,
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone': phone,
        if (_roleValue != null && _roleValue!.isNotEmpty) 'role': _roleValue,
        if (_selectedHotelId != null) 'hotelId': _selectedHotelId,
      };
      if (initial == null) {
        await _api.post(AppConstants.staffsEndpoint, data: payload);
      } else {
        final id = initial['_id'] ?? initial['id'];
        await _api.put('${AppConstants.staffsEndpoint}/$id', data: payload);
      }
      Navigator.of(context).pop();
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lưu nhân viên')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openStaffForm({Map<String, dynamic>? initial}) {
    _fullNameController.text = '${initial?['fullName'] ?? ''}';
    _usernameController.text = '${initial?['username'] ?? ''}';
    _emailController.text = '${initial?['email'] ?? ''}';
    _phoneController.text = '${initial?['phone'] ?? ''}';
    _roleValue = '${initial?['role'] ?? ''}';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(initial == null ? 'Thêm nhân viên' : 'Sửa nhân viên'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ tên'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'SĐT'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _roleValue?.isEmpty == true ? null : _roleValue,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'business', child: Text('Business')),
                    DropdownMenuItem(value: 'hotel', child: Text('Hotel Manager')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  ],
                  onChanged: (v) => setState(() => _roleValue = v ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: _saving ? null : () => _submitStaff(initial: initial),
              child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _calculateSalary(Map<String, dynamic> staff) async {
    final id = staff['_id'] ?? staff['id'];
    if (id == null) return;
    try {
      final res = await _api.post('${AppConstants.staffsEndpoint}/$id/calculate-salary');
      final data = res.data is Map ? res.data as Map<String, dynamic> : {};
      final total = data['total'] ?? data['amount'] ?? 0;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tính lương'),
          content: Text('Tổng lương: $total'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Đóng')),
            ElevatedButton(
              onPressed: () async {
                await _api.post('${AppConstants.staffsEndpoint}/$id/pay-salary');
                Navigator.of(ctx).pop();
              },
              child: const Text('Thanh toán'),
            ),
          ],
        ),
      );
    } catch (_) {}
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
                      hintText: 'Tìm nhân viên',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._filtered.map((e) {
                    final m = e as Map<String, dynamic>;
                    final title = '${m['fullName'] ?? m['username'] ?? 'Nhân viên'}';
                    final role = m['role'] != null ? ' • ${m['role']}' : '';
                    final status = '${m['status'] ?? m['employmentStatus'] ?? ''}';
                    final working = status == 'active' || status == 'working';
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people),
                                const SizedBox(width: 8),
                                Expanded(child: Text('$title$role', style: const TextStyle(fontWeight: FontWeight.w600))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: (working ? Colors.green : Colors.grey).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(working ? 'Đang làm việc' : 'Tạm nghỉ', style: TextStyle(color: working ? Colors.green : Colors.grey)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(m['email'] ?? ''),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Sửa'),
                                    onPressed: () => _openStaffForm(initial: m),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.attach_money, size: 18),
                                    label: const Text('Tính lương'),
                                    onPressed: () => _calculateSalary(m),
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
                                      if (id != null) _deleteStaff('$id');
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
        onPressed: () => _openStaffForm(),
        label: const Text('Thêm nhân viên'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
