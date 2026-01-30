import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class DebtManagementScreen extends StatefulWidget {
  const DebtManagementScreen({super.key});

  @override
  State<DebtManagementScreen> createState() => _DebtManagementScreenState();
}

class _DebtManagementScreenState extends State<DebtManagementScreen> {
  final _api = ApiService();
  List<dynamic> _items = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  List<dynamic> _hotels = [];
  String? _selectedHotelId;
  final _searchController = TextEditingController();
  final _debtorController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _statusValue;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _loadHotels();
      final res = await _api.get(
        AppConstants.debtEndpoint,
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

  @override
  void dispose() {
    _searchController.dispose();
    _debtorController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchController.text.toLowerCase();
    _filtered = _items.where((x) {
      final m = x as Map<String, dynamic>;
      final debtor = '${m['debtorName'] ?? m['customerName'] ?? ''}'.toLowerCase();
      final status = '${m['status'] ?? ''}'.toLowerCase();
      return debtor.contains(q) || status.contains(q);
    }).toList();
    setState(() {});
  }

  Future<void> _deleteDebt(String id) async {
    try {
      await _api.delete('${AppConstants.debtEndpoint}/$id');
      await _load();
    } catch (_) {}
  }

  Future<void> _submitDebt({Map<String, dynamic>? initial}) async {
    final debtor = _debtorController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    final note = _noteController.text.trim();
    if (debtor.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên khách và số tiền')));
      return;
    }
    setState(() => _saving = true);
    try {
      final payload = {
        'debtorName': debtor,
        'amount': amount,
        if (note.isNotEmpty) 'note': note,
        if (_statusValue != null && _statusValue!.isNotEmpty) 'status': _statusValue,
        if (_selectedHotelId != null) 'hotelId': _selectedHotelId,
      };
      if (initial == null) {
        await _api.post(AppConstants.debtEndpoint, data: payload);
      } else {
        final id = initial['_id'] ?? initial['id'];
        await _api.put('${AppConstants.debtEndpoint}/$id', data: payload);
      }
      Navigator.of(context).pop();
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lưu công nợ')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openDebtForm({Map<String, dynamic>? initial}) {
    _debtorController.text = '${initial?['debtorName'] ?? initial?['customerName'] ?? ''}';
    _amountController.text = initial?['amount'] != null ? '${initial?['amount']}' : '';
    _noteController.text = '${initial?['note'] ?? ''}';
    _statusValue = '${initial?['status'] ?? ''}';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(initial == null ? 'Thêm công nợ' : 'Sửa công nợ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _debtorController,
                  decoration: const InputDecoration(labelText: 'Khách hàng *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Số tiền *'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Ghi chú'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _statusValue?.isEmpty == true ? null : _statusValue,
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Chờ xử lý')),
                    DropdownMenuItem(value: 'paid', child: Text('Đã thanh toán')),
                    DropdownMenuItem(value: 'overdue', child: Text('Quá hạn')),
                  ],
                  onChanged: (v) => setState(() => _statusValue = v ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: _saving ? null : () => _submitDebt(initial: initial),
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
      appBar: AppBar(title: const Text('Quản lý công nợ')),
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
                      hintText: 'Tìm công nợ theo khách/trạng thái',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._filtered.map((e) {
                    final m = e as Map<String, dynamic>;
                    final debtor = '${m['debtorName'] ?? m['customerName'] ?? 'Khách hàng'}';
                    final amount = m['amount'] ?? m['total'] ?? 0;
                    final status = '${m['status'] ?? 'pending'}';
                    final color = status == 'paid' ? Colors.green : status == 'overdue' ? Colors.redAccent : Colors.orange;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.money_off),
                                const SizedBox(width: 8),
                                Expanded(child: Text(debtor, style: const TextStyle(fontWeight: FontWeight.w600))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(status == 'paid' ? 'Đã thanh toán' : status == 'overdue' ? 'Quá hạn' : 'Chờ xử lý', style: TextStyle(color: color)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Số tiền: $amount'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Sửa'),
                                    onPressed: () => _openDebtForm(initial: m),
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
                                      if (id != null) _deleteDebt('$id');
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
        onPressed: () => _openDebtForm(),
        label: const Text('Thêm công nợ'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
