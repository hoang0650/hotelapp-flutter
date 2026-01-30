import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  bool _gridView = true;
  String _statusFilter = 'all'; // all | vacant | occupied | cleaning | maintenance
  String? _floorFilter; // null = all floors
  final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  List<dynamic> _hotels = [];
  String? _selectedHotelId;
  final _roomNumberController = TextEditingController();
  final _typeController = TextEditingController();
  final _floorController = TextEditingController();
  final _priceController = TextEditingController();
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
    _roomNumberController.dispose();
    _typeController.dispose();
    _floorController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _loadHotels();
      final res = await _api.get(
        AppConstants.roomsEndpoint,
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
    Iterable<dynamic> coll = _items;
    // Status filter
    if (_statusFilter != 'all') {
      coll = coll.where((x) {
        final m = x as Map<String, dynamic>;
        final s = '${m['status'] ?? ''}';
        switch (_statusFilter) {
          case 'vacant':
            return s == 'vacant';
          case 'occupied':
            return s == 'occupied';
          case 'cleaning':
            return s == 'cleaning' || s == 'dirty';
          case 'maintenance':
            return s == 'maintenance';
          default:
            return true;
        }
      });
    }
    // Floor filter
    if (_floorFilter != null && _floorFilter!.isNotEmpty) {
      coll = coll.where((x) {
        final m = x as Map<String, dynamic>;
        final f = '${m['floor'] ?? ''}';
        return f == _floorFilter;
      });
    }
    // Keyword filter
    _filtered = coll.where((x) {
      final m = x as Map<String, dynamic>;
      final name = '${m['name'] ?? m['roomName'] ?? ''}'.toLowerCase();
      final number = '${m['roomNumber'] ?? ''}'.toLowerCase();
      return name.contains(q) || number.contains(q);
    }).toList();
    setState(() {});
  }

  Map<String, int> _counts() {
    final total = _items.length;
    int vacant = 0, occupied = 0, cleaning = 0, maintenance = 0;
    for (final x in _items) {
      final s = '${(x as Map<String, dynamic>)['status'] ?? ''}';
      if (s == 'vacant') vacant++;
      else if (s == 'occupied') occupied++;
      else if (s == 'cleaning' || s == 'dirty') cleaning++;
      else if (s == 'maintenance') maintenance++;
    }
    return {'total': total, 'vacant': vacant, 'occupied': occupied, 'cleaning': cleaning, 'maintenance': maintenance};
  }

  List<String> _floors() {
    final set = <String>{};
    for (final x in _items) {
      final f = '${(x as Map<String, dynamic>)['floor'] ?? ''}';
      if (f.isNotEmpty) set.add(f);
    }
    final list = set.toList()..sort((a, b) => int.tryParse(a)?.compareTo(int.tryParse(b) ?? 0) ?? a.compareTo(b));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phòng'),
        actions: [
          IconButton(
            tooltip: _gridView ? 'Chuyển sang dạng danh sách' : 'Chuyển sang dạng lưới',
            icon: Icon(_gridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _gridView = !_gridView),
          ),
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
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
                  // Counters
                  _buildCounters(context),
                  const SizedBox(height: 12),
                  // Filters row
                  _filtersRow(context),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm phòng theo tên/số',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _gridView ? _gridRooms(context) : _listRooms(context),
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

  Widget _buildCounters(BuildContext context) {
    final c = _counts();
    Widget chip(String label, int value, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(child: chip('Tổng', c['total']!, Colors.black87)),
        const SizedBox(width: 8),
        Expanded(child: chip('Trống', c['vacant']!, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: chip('Đã thuê', c['occupied']!, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: chip('Đang dọn', c['cleaning']!, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: chip('Bảo trì', c['maintenance']!, Colors.redAccent)),
      ],
    );
  }

  Widget _filtersRow(BuildContext context) {
    final floors = _floors();
    Widget statusBtn(String label, String key) {
      final active = _statusFilter == key;
      return ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) {
          setState(() {
            _statusFilter = key;
            _applyFilter();
          });
        },
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        statusBtn('Tất cả', 'all'),
        statusBtn('Trống', 'vacant'),
        statusBtn('Đã thuê', 'occupied'),
        statusBtn('Đang dọn', 'cleaning'),
        statusBtn('Bảo trì', 'maintenance'),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _floorFilter,
          hint: const Text('Tất cả tầng'),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('Tất cả tầng')),
            ...floors.map((f) => DropdownMenuItem<String>(value: f, child: Text('Tầng $f'))),
          ],
          onChanged: (v) {
            setState(() {
              _floorFilter = v;
              _applyFilter();
            });
          },
        ),
      ],
    );
  }

  Widget _gridRooms(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => _roomCard(context, _filtered[i] as Map<String, dynamic>),
    );
  }

  Widget _listRooms(BuildContext context) {
    return Column(
      children: _filtered.map((e) => _roomCard(context, e as Map<String, dynamic>)).toList(),
    );
  }

  Widget _roomCard(BuildContext context, Map<String, dynamic> m) {
    final title = '${m['name'] ?? m['roomName'] ?? 'Phòng'}';
    final number = m['roomNumber'] != null ? '${m['roomNumber']}' : '';
    final status = '${m['status'] ?? ''}';
    final floor = m['floor'] != null ? 'Tầng ${m['floor']}' : '';
    final amenities = '${m['amenities'] ?? m['description'] ?? ''}';
    final roomType = '${m['type'] ?? m['roomType'] ?? ''}';
    final priceNum = (m['price'] is num) ? (m['price'] as num).toDouble() : double.tryParse('${m['price'] ?? ''}') ?? 0;
    final priceText = priceNum > 0 ? _currency.format(priceNum) : '—';
    final statusColor = status == 'vacant'
        ? Colors.green
        : status == 'occupied'
            ? Colors.blue
            : status == 'cleaning' || status == 'dirty'
                ? Colors.orange
                : Colors.redAccent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    number.isNotEmpty ? 'Phòng $number' : title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  label: Text(
                    status == 'vacant'
                        ? 'Trống'
                        : status == 'occupied'
                            ? 'Đã thuê'
                            : status == 'cleaning' || status == 'dirty'
                                ? 'Đang dọn'
                                : 'Bảo trì',
                  ),
                  backgroundColor: statusColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: statusColor),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (roomType.isNotEmpty || amenities.isNotEmpty) ...[
              const SizedBox(height: 6),
              if (roomType.isNotEmpty)
                Text('Hạng phòng: $roomType', maxLines: 1, overflow: TextOverflow.ellipsis),
              if (amenities.isNotEmpty)
                Text(amenities, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Text('Giá: $priceText/đêm')),
                if (floor.isNotEmpty) Text(floor),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (status == 'vacant')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.vpn_key, size: 18),
                    label: const Text('Nhận phòng'),
                    onPressed: () => _openCheckInDialog(m),
                  ),
                if (status == 'occupied')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Trả phòng'),
                    onPressed: () => _openCheckoutDialog(m),
                  ),
                if (status == 'occupied')
                  OutlinedButton.icon(
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Đổi phòng'),
                    onPressed: () => _openTransferDialog(m),
                  ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Cập nhật'),
                  onPressed: () => _openRoomForm(initial: m),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    final id = m['_id'] ?? m['id'];
                    if (id != null) _deleteRoom('$id');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openRoomForm({Map<String, dynamic>? initial}) {
    _roomNumberController.text = '${initial?['roomNumber'] ?? ''}';
    _typeController.text = '${initial?['type'] ?? ''}';
    _floorController.text = initial?['floor'] != null ? '${initial?['floor']}' : '';
    _priceController.text = initial?['price'] != null ? '${initial?['price']}' : '';
    _statusValue = '${initial?['status'] ?? ''}';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(initial == null ? 'Thêm phòng' : 'Sửa phòng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _roomNumberController,
                  decoration: const InputDecoration(labelText: 'Số phòng *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(labelText: 'Loại phòng'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _floorController,
                  decoration: const InputDecoration(labelText: 'Tầng'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Giá/đêm'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _statusValue?.isEmpty == true ? null : _statusValue,
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  items: const [
                    DropdownMenuItem(value: 'vacant', child: Text('Trống')),
                    DropdownMenuItem(value: 'occupied', child: Text('Đã thuê')),
                    DropdownMenuItem(value: 'cleaning', child: Text('Đang dọn')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Bảo trì')),
                  ],
                  onChanged: (v) => setState(() => _statusValue = v ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: _saving ? null : () => _submitRoom(initial: initial),
              child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _openCheckInDialog(Map<String, dynamic> room) {
    final guestNameController = TextEditingController();
    final advanceController = TextEditingController();
    String rateType = 'hourly'; // hourly | daily | nightly
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Nhận phòng ${room['roomNumber'] ?? ''}'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: guestNameController,
                      decoration: const InputDecoration(labelText: 'Tên khách'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: rateType,
                      decoration: const InputDecoration(labelText: 'Loại giá'),
                      items: const [
                        DropdownMenuItem(value: 'hourly', child: Text('Theo giờ')),
                        DropdownMenuItem(value: 'daily', child: Text('Ngày đêm')),
                        DropdownMenuItem(value: 'nightly', child: Text('Qua đêm')),
                      ],
                      onChanged: (v) => setStateDialog(() => rateType = v ?? 'hourly'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: advanceController,
                      decoration: const InputDecoration(labelText: 'Tiền đặt trước'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final id = room['_id'] ?? room['id'];
                if (id == null) return;
                try {
                  final payload = {
                    'status': 'occupied',
                    'events': [
                      {
                        'type': 'checkin',
                        'checkinTime': DateTime.now().toIso8601String(),
                        'guestInfo': {
                          'name': guestNameController.text.trim().isEmpty ? 'Khách lẻ' : guestNameController.text.trim(),
                        },
                        'rateType': rateType,
                        'advancePayment': double.tryParse(advanceController.text.trim()) ?? 0,
                      }
                    ],
                  };
                  await _api.post('${AppConstants.roomsEndpoint}/checkin/$id', data: payload);
                  if (context.mounted) Navigator.of(ctx).pop();
                  await _load();
                  _showSnack('Nhận phòng thành công');
                } catch (e) {
                  _showSnack('Không thể nhận phòng');
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _openCheckoutDialog(Map<String, dynamic> room) {
    final additionalController = TextEditingController();
    final discountController = TextEditingController();
    String paymentMethod = 'cash'; // cash | transfer | card
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Trả phòng ${room['roomNumber'] ?? ''}'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: const InputDecoration(labelText: 'Phương thức thanh toán'),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                        DropdownMenuItem(value: 'transfer', child: Text('Chuyển khoản')),
                        DropdownMenuItem(value: 'card', child: Text('Thẻ')),
                      ],
                      onChanged: (v) => setStateDialog(() => paymentMethod = v ?? 'cash'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: additionalController,
                      decoration: const InputDecoration(labelText: 'Phụ thu'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(labelText: 'Giảm trừ'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final id = room['_id'] ?? room['id'];
                if (id == null) return;
                try {
                  final payload = {
                    'paymentMethod': paymentMethod,
                    'additionalCharges': double.tryParse(additionalController.text.trim()) ?? 0,
                    'discount': double.tryParse(discountController.text.trim()) ?? 0,
                    'checkoutTime': DateTime.now().toIso8601String(),
                  };
                  await _api.post('${AppConstants.roomsEndpoint}/checkout/$id', data: payload);
                  if (context.mounted) Navigator.of(ctx).pop();
                  await _load();
                  _showSnack('Trả phòng thành công');
                } catch (e) {
                  _showSnack('Không thể trả phòng');
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _openTransferDialog(Map<String, dynamic> sourceRoom) {
    String? selectedTargetRoomId;
    String notes = '';
    List<dynamic> availableRooms = [];
    Future<void> loadAvailable() async {
      try {
        final res = await _api.get('${AppConstants.roomsEndpoint}/available', queryParameters: {
          if (_selectedHotelId != null) 'hotelId': _selectedHotelId!,
        });
        final data = res.data;
        if (data is List) {
          availableRooms = data.where((r) {
            final m = r as Map;
            final id = m['_id'] ?? m['id'];
            final status = '${m['status'] ?? ''}';
            return id != sourceRoom['_id'] && status == 'vacant';
          }).toList();
        }
      } catch (_) {
        availableRooms = [];
      }
    }
    loadAvailable();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Chuyển phòng'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedTargetRoomId,
                      decoration: const InputDecoration(labelText: 'Phòng đích'),
                      items: availableRooms.map((r) {
                        final m = r as Map;
                        return DropdownMenuItem<String>(
                          value: '${m['_id'] ?? m['id']}',
                          child: Text('Phòng ${m['roomNumber'] ?? ''} • ${m['type'] ?? 'N/A'} • Tầng ${m['floor'] ?? 'N/A'}'),
                        );
                      }).toList(),
                      onChanged: (v) => setStateDialog(() => selectedTargetRoomId = v),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Ghi chú'),
                      onChanged: (v) => notes = v,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final sourceId = sourceRoom['_id'] ?? sourceRoom['id'];
                if (sourceId == null || selectedTargetRoomId == null) return;
                try {
                  await _api.post('${AppConstants.roomsEndpoint}/transfer', data: {
                    'sourceRoomId': '$sourceId',
                    'targetRoomId': selectedTargetRoomId,
                    'notes': notes,
                  });
                  if (context.mounted) Navigator.of(ctx).pop();
                  await _load();
                  _showSnack('Chuyển phòng thành công');
                } catch (e) {
                  _showSnack('Không thể chuyển phòng');
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRoom({Map<String, dynamic>? initial}) async {
    final roomNumber = _roomNumberController.text.trim();
    final type = _typeController.text.trim();
    final floor = int.tryParse(_floorController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    if (roomNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số phòng')));
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = {
        'roomNumber': roomNumber,
        if (_selectedHotelId != null) 'hotelId': _selectedHotelId,
        if (type.isNotEmpty) 'type': type,
        if (floor != null) 'floor': floor,
        if (price != null) 'price': price,
        if (_statusValue != null && _statusValue!.isNotEmpty) 'status': _statusValue,
      };
      if (initial == null) {
        await _api.post(AppConstants.roomsEndpoint, data: payload);
      } else {
        final id = initial['_id'] ?? initial['id'];
        await _api.put('${AppConstants.roomsEndpoint}/$id', data: payload);
      }
      Navigator.of(context).pop();
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lưu phòng')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteRoom(String id) async {
    try {
      await _api.delete('${AppConstants.roomsEndpoint}/$id');
      await _load();
    } catch (_) {}
  }
}
