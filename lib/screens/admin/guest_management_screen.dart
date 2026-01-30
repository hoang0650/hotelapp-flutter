import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class GuestManagementScreen extends StatefulWidget {
  const GuestManagementScreen({super.key});

  @override
  State<GuestManagementScreen> createState() => _GuestManagementScreenState();
}

class _GuestManagementScreenState extends State<GuestManagementScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  List<dynamic> _hotels = [];
  String? _selectedHotelId;
  String? _selectedGuestType; // regular | frequent | group | null (tất cả)
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _guestTypeValue;
  String? _statusValue;
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
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _loadHotels();
      final res = await _api.get(
        AppConstants.guestsEndpoint,
        queryParameters: {
          if (_selectedHotelId != null) 'hotelId': _selectedHotelId,
          if (_selectedGuestType != null && _selectedGuestType!.isNotEmpty) 'guestType': _selectedGuestType,
        },
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
      final name = '${m['fullName'] ?? m['name'] ?? ''}'.toLowerCase();
      final email = '${m['email'] ?? ''}'.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
    setState(() {});
  }

  Future<void> _deleteGuest(String id) async {
    try {
      await _api.delete('${AppConstants.guestsEndpoint}/$id');
      await _load();
    } catch (_) {}
  }

  Future<void> _submitGuest({Map<String, dynamic>? initial}) async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ tên')));
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = {
        'fullName': fullName,
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone': phone,
        if (_guestTypeValue != null && _guestTypeValue!.isNotEmpty) 'guestType': _guestTypeValue,
        if (_statusValue != null && _statusValue!.isNotEmpty) 'status': _statusValue,
        if (_selectedHotelId != null) 'hotelId': _selectedHotelId,
      };
      if (initial == null) {
        await _api.post(AppConstants.guestsEndpoint, data: payload);
      } else {
        final id = initial['_id'] ?? initial['id'];
        await _api.put('${AppConstants.guestsEndpoint}/$id', data: payload);
      }
      Navigator.of(context).pop();
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lưu khách hàng')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openGuestForm({Map<String, dynamic>? initial}) {
    _fullNameController.text = '${initial?['fullName'] ?? initial?['name'] ?? ''}';
    _emailController.text = '${initial?['email'] ?? ''}';
    _phoneController.text = '${initial?['phone'] ?? ''}';
    _guestTypeValue = '${initial?['guestType'] ?? ''}';
    _statusValue = '${initial?['status'] ?? ''}';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(initial == null ? 'Thêm khách hàng' : 'Sửa khách hàng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Họ tên *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'SĐT'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _guestTypeValue?.isEmpty == true ? null : _guestTypeValue,
                  decoration: const InputDecoration(labelText: 'Loại khách'),
                  items: const [
                    DropdownMenuItem(value: 'regular', child: Text('Khách lưu')),
                    DropdownMenuItem(value: 'frequent', child: Text('Khách quen')),
                    DropdownMenuItem(value: 'group', child: Text('Khách đoàn')),
                  ],
                  onChanged: (v) => setState(() => _guestTypeValue = v ?? ''),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _statusValue?.isEmpty == true ? null : _statusValue,
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Hoạt động')),
                    DropdownMenuItem(value: 'inactive', child: Text('Tạm dừng')),
                  ],
                  onChanged: (v) => setState(() => _statusValue = v ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: _saving ? null : () => _submitGuest(initial: initial),
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
      appBar: AppBar(title: const Text('Quản lý khách hàng')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGuestType,
                          decoration: const InputDecoration(labelText: 'Loại khách'),
                          items: const [
                          DropdownMenuItem<String>(value: '', child: Text('Tất cả')),
                            DropdownMenuItem<String>(value: 'regular', child: Text('Khách lưu')),
                            DropdownMenuItem<String>(value: 'frequent', child: Text('Khách quen')),
                            DropdownMenuItem<String>(value: 'group', child: Text('Khách đoàn')),
                          ],
                          onChanged: (v) {
                            setState(() => _selectedGuestType = (v == '' ? null : v));
                            _load();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm khách hàng',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._filtered.map((e) {
                    final m = e as Map<String, dynamic>;
                    final title = '${m['fullName'] ?? m['name'] ?? 'Khách hàng'}';
                    final phone = m['phone'] != null ? ' • ${m['phone']}' : '';
                    final status = '${m['status'] ?? ''}';
                    final active = status == 'active';
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 8),
                                Expanded(child: Text('$title$phone', style: const TextStyle(fontWeight: FontWeight.w600))),
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
                            Text(m['email'] ?? ''),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Sửa'),
                                    onPressed: () => _openGuestForm(initial: m),
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
                                      if (id != null) _deleteGuest('$id');
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
        onPressed: () => _openGuestForm(),
        label: const Text('Thêm khách hàng'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
