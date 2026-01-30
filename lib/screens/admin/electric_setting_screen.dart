import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class ElectricSettingScreen extends StatefulWidget {
  const ElectricSettingScreen({super.key});

  @override
  State<ElectricSettingScreen> createState() => _ElectricSettingScreenState();
}

class _ElectricSettingScreenState extends State<ElectricSettingScreen> {
  final _api = ApiService();
  bool _loading = true;
  bool _refreshing = false;
  List<dynamic> _devices = [];
  List<dynamic> _hotels = [];
  List<dynamic> _rooms = [];
  String? _selectedHotelId;
  String? _selectedRoomId;
  bool _saving = false;
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      await Future.wait([_loadHotels(), _loadDevices()]);
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
        _selectedHotelId = (_hotels.first as Map)['-_id'] ?? (_hotels.first as Map)['_id'];
      }
      await _loadRoomsByHotel();
    } catch (_) {}
  }

  Future<void> _loadRoomsByHotel() async {
    if (_selectedHotelId == null || _selectedHotelId!.isEmpty) {
      setState(() {
        _rooms = [];
        _selectedRoomId = null;
      });
      return;
    }
    try {
      final res = await _api.get(AppConstants.roomsEndpoint, queryParameters: {'hotelId': _selectedHotelId});
      final data = res.data;
      _rooms = (data is List)
          ? data
          : (data is Map && data['items'] is List)
              ? data['items']
              : [];
    } catch (_) {
      _rooms = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadDevices() async {
    try {
      final res = await _api.get('/tuya/devices');
      final data = res.data;
      _devices = (data is List)
          ? data
          : (data is Map && data['data'] is List)
              ? data['data']
              : [];
    } catch (_) {
      _devices = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    try {
      await _loadDevices();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _toggleDevice(String deviceId) async {
    try {
      await _api.post('/tuya/devices/$deviceId/toggle');
      await _loadDevices();
    } catch (_) {}
  }

  Future<void> _submitAddDevice() async {
    final deviceId = _deviceIdController.text.trim();
    final name = _deviceNameController.text.trim();
    if (deviceId.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã thiết bị và tên')));
      return;
    }
    setState(() => _saving = true);
    try {
      final room = _rooms.firstWhere(
        (r) => (r as Map)['_id'] == _selectedRoomId,
        orElse: () => {},
      ) as Map<String, dynamic>?;
      await _api.post('/tuya/devices', data: {
        'deviceId': deviceId,
        'name': name,
        'hotelId': _selectedHotelId,
        'roomId': _selectedRoomId,
        'roomNumber': room?['roomNumber'],
      });
      if (mounted) Navigator.pop(context);
      await _loadDevices();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể thêm thiết bị')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && !_refreshing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cài đặt điện')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt điện')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
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
                      setState(() {
                        _selectedHotelId = v;
                        _selectedRoomId = null;
                      });
                      _loadRoomsByHotel();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRoomId,
                    decoration: const InputDecoration(labelText: 'Phòng (tuỳ chọn)'),
                    items: _rooms
                        .map((r) => DropdownMenuItem<String>(
                              value: (r as Map)['_id'],
                              child: Text('Phòng ${(r as Map)['roomNumber'] ?? 'N/A'}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRoomId = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_devices.isEmpty)
              Column(
                children: const [
                  SizedBox(height: 24),
                  Text('⚡', style: TextStyle(fontSize: 36, color: Color(0xFF1890ff))),
                  SizedBox(height: 8),
                  Text('Chưa có thiết bị Tuya', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ..._devices.map((d) {
              final m = d as Map<String, dynamic>;
              final online = m['online'] == true;
              final isOn = m['state'] == true;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('${m['name'] ?? 'Thiết bị'}', style: const TextStyle(fontWeight: FontWeight.w600))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: (isOn ? Colors.green : Colors.grey).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(isOn ? 'Bật' : 'Tắt', style: TextStyle(color: isOn ? Colors.green : Colors.grey)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Phòng: ${m['roomNumber'] ?? 'N/A'}'),
                          const SizedBox(width: 12),
                          Text(online ? 'Online' : 'Offline', style: TextStyle(color: online ? Colors.green : Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _toggleDevice('${m['id'] ?? m['deviceId']}'),
                            child: Text(isOn ? 'Tắt' : 'Bật'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDeviceModal(context),
        label: const Text('Thêm thiết bị'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _openAddDeviceModal(BuildContext context) {
    _deviceIdController.clear();
    _deviceNameController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thêm thiết bị Tuya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deviceIdController,
                    decoration: const InputDecoration(labelText: 'Mã thiết bị *'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _deviceNameController,
                    decoration: const InputDecoration(labelText: 'Tên thiết bị *'),
                  ),
                  const SizedBox(height: 8),
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
                      setState(() {
                        _selectedHotelId = v;
                        _selectedRoomId = null;
                      });
                      _loadRoomsByHotel();
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRoomId,
                    decoration: const InputDecoration(labelText: 'Phòng (tuỳ chọn)'),
                    items: _rooms
                        .map((r) => DropdownMenuItem<String>(
                              value: (r as Map)['_id'],
                              child: Text('Phòng ${(r as Map)['roomNumber'] ?? 'N/A'}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRoomId = v),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saving ? null : _submitAddDevice,
                        child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

