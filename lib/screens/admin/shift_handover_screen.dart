import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/shift_handover_service.dart';
import 'package:hotelapp_flutter/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ShiftHandoverScreen extends StatefulWidget {
  const ShiftHandoverScreen({super.key});

  @override
  State<ShiftHandoverScreen> createState() => _ShiftHandoverScreenState();
}

class _ShiftHandoverScreenState extends State<ShiftHandoverScreen> {
  final _shiftHandoverService = ShiftHandoverService();
  final _authService = AuthService();
  final _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  final _cashController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _loading = false;
  double? _systemRevenue;
  String? _hotelId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _cashController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() => _loading = true);
    try {
      final user = await _authService.getCurrentUser();
      _hotelId = user?.hotelId ?? user?.businessId;
      
      if (_hotelId != null) {
        // Calculate revenue for today/current shift
        // Assuming backend handles "current shift" or we default to today
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day).toIso8601String();
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
        
        final revenueData = await _shiftHandoverService.calculateRevenue(
          hotelId: _hotelId!,
          startDate: start,
          endDate: end,
        );
        
        if (revenueData is Map && revenueData['totalRevenue'] != null) {
          _systemRevenue = (revenueData['totalRevenue'] as num).toDouble();
        } else if (revenueData is num) {
          _systemRevenue = revenueData.toDouble();
        }
      }
    } catch (_) {
      // Ignore errors, system revenue might not be available
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitHandover() async {
    final hp = Provider.of<HotelProvider>(context, listen: false);
    _hotelId = hp.selectedHotelId;

    if (_hotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy thông tin khách sạn')));
      return;
    }

    final cashStr = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cash = double.tryParse(cashStr);

    if (cash == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tổng tiền mặt')));
      return;
    }

    setState(() => _loading = true);
    try {
      await _shiftHandoverService.createShiftHandover({
        'hotelId': _hotelId,
        'totalCash': cash,
        'note': _noteController.text.trim(),
        'systemRevenue': _systemRevenue, // Send for record keeping
        'date': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giao ca thành công')));
        _cashController.clear();
        _noteController.clear();
        context.push('/admin/shift-handover-history');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
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
            tooltip: 'Lịch sử giao ca',
            onPressed: () => context.push('/admin/shift-handover-history'),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.calculate, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Doanh thu hệ thống (Hôm nay)',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    _loading && _systemRevenue == null
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            _systemRevenue != null ? _currency.format(_systemRevenue) : '---',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Thông tin giao ca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _cashController,
              decoration: const InputDecoration(
                labelText: 'Tổng tiền mặt thực tế *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
                hintText: 'Nhập số tiền...',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Ghi chú thêm (nếu có)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _submitHandover,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              icon: _loading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle),
              label: const Text('XÁC NHẬN GIAO CA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
