import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/providers/auth_provider.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomIndex = 0;
  int _revenueTab = 1;
  int _roomSalesTab = 1;
  String? _selectedHotelId;
  String _selectedHotelName = 'Chọn khách sạn';
  final _api = ApiService();
  final _dateFmt = DateFormat('dd/MM/yyyy');
  List<Map<String, dynamic>> _hotels = [];
  int _vacant = 0;
  int _occupied = 0;
  int _booked = 0;
  int _cleaning = 0;
  List<Map<String, dynamic>> _recentBookings = [];
  List<Map<String, dynamic>> _roomEvents = [];
  List<double> _revenueData = [];
  double _totalRevenue = 0;
  double _totalExpense = 0;
  List<double> _salesData = [];
  int _totalSales = 0;

  @override
  void initState() {
    super.initState();
    _initHotelAndLoad();
  }

  Future<void> _initHotelAndLoad() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userHotelId = auth.user?.hotelId;
    try {
      final hotelsRes = await _api.get(AppConstants.hotelsEndpoint);
      final hotelsData = hotelsRes.data;
      if (hotelsData is List) {
        _hotels = hotelsData.cast<Map<String, dynamic>>();
      } else {
        _hotels = [];
      }
    } catch (_) {
      _hotels = [];
    }
    if (userHotelId != null && userHotelId.isNotEmpty) {
      _selectedHotelId = userHotelId;
      try {
        final hRes = await _api.get('${AppConstants.hotelsEndpoint}/$userHotelId');
        final hData = hRes.data;
        if (hData is Map && hData['name'] is String) {
          _selectedHotelName = hData['name'];
        }
      } catch (_) {}
    } else if (_hotels.isNotEmpty) {
      _selectedHotelId = '${_hotels.first['_id'] ?? _hotels.first['id'] ?? ''}';
      _selectedHotelName = '${_hotels.first['name'] ?? 'Khách sạn'}';
    }
    if (mounted) setState(() {});
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (_selectedHotelId == null || _selectedHotelId!.isEmpty) return;
    try {
      final roomsRes = await _api.get(AppConstants.roomsEndpoint, queryParameters: {'hotelId': _selectedHotelId});
      List rooms = [];
      if (roomsRes.data is List) {
        rooms = roomsRes.data as List;
      } else if (roomsRes.data is Map && roomsRes.data['items'] is List) {
        rooms = roomsRes.data['items'] as List;
      }
      int vacant = 0, booked = 0, cleaning = 0, occupied = 0;
      for (final r in rooms) {
        final s = '${(r as Map)['status'] ?? ''}';
        if (s == 'vacant') vacant++;
        else if (s == 'booked') booked++;
        else if (s == 'occupied') occupied++;
        else if (s == 'cleaning' || s == 'dirty') cleaning++;
      }
      _vacant = vacant;
      _booked = booked;
      _cleaning = cleaning;
      _occupied = occupied;
    } catch (_) {
      _vacant = 0;
      _booked = 0;
      _cleaning = 0;
      _occupied = 0;
    }
    try {
      final bookingsRes = await _api.get('/rooms/bookings', queryParameters: {'hotelId': _selectedHotelId});
      final bData = bookingsRes.data;
      List bookings = [];
      if (bData is Map && bData['bookings'] is List) {
        bookings = bData['bookings'] as List;
      }
      bookings.sort((a, b) {
        final da = DateTime.tryParse('${(a as Map)['checkInDate'] ?? a['checkinDate'] ?? ''}')?.millisecondsSinceEpoch ?? 0;
        final db = DateTime.tryParse('${(b as Map)['checkInDate'] ?? b['checkinDate'] ?? ''}')?.millisecondsSinceEpoch ?? 0;
        return db.compareTo(da);
      });
      final top = bookings.take(5).toList();
      _recentBookings = top.map<Map<String, dynamic>>((booking) {
        final m = booking as Map<String, dynamic>;
        return {
          '_id': m['_id'] ?? '',
          'guestName': m['guestInfo']?['name'] ?? m['guestName'] ?? 'Khách lẻ',
          'roomNumber': m['roomId']?['roomNumber'] ?? m['roomNumber'] ?? 'N/A',
          'checkInDate': m['checkInDate'] ?? m['checkinDate'],
          'checkOutDate': m['checkOutDate'] ?? m['checkoutDate'],
          'status': m['status'] ?? 'pending',
        };
      }).toList();
    } catch (_) {
      _recentBookings = [];
    }
    try {
      final types = jsonEncode(['checkin', 'checkout', 'maintenance', 'transfer']);
      final eventsRes = await _api.get('/rooms/events', queryParameters: {'hotelId': _selectedHotelId, 'limit': 5, 'types': types});
      if (eventsRes.data is List) {
        _roomEvents = (eventsRes.data as List).cast<Map<String, dynamic>>();
      } else {
        _roomEvents = [];
      }
    } catch (_) {
      _roomEvents = [];
    }
    await _loadRevenueData();
    await _loadSalesData();
    if (mounted) setState(() {});
  }

  Future<void> _loadRevenueData() async {
    if (_selectedHotelId == null || _selectedHotelId!.isEmpty) return;
    final period = _revenueTab == 0 ? 'day' : _revenueTab == 1 ? 'week' : 'month';
    try {
      final res = await _api.get('/shift-handover/revenue/period', queryParameters: {'hotelId': _selectedHotelId, 'period': period});
      final d = res.data is Map ? res.data as Map : {};
      final arr = (d['revenueData'] is List) ? (d['revenueData'] as List) : [];
      _revenueData = arr.map((e) => (e is num) ? e.toDouble() : double.tryParse('$e') ?? 0).toList();
      _totalRevenue = (d['totalRevenue'] is num) ? (d['totalRevenue'] as num).toDouble() : 0;
      _totalExpense = (d['totalExpense'] is num) ? (d['totalExpense'] as num).toDouble() : 0;
    } catch (_) {
      _revenueData = [];
      _totalRevenue = 0;
      _totalExpense = 0;
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadSalesData() async {
    if (_selectedHotelId == null || _selectedHotelId!.isEmpty) return;
    final period = _roomSalesTab == 0 ? 'day' : _roomSalesTab == 1 ? 'week' : 'month';
    try {
      final res = await _api.get('/shift-handover/checkin-count/period', queryParameters: {'hotelId': _selectedHotelId, 'period': period});
      final d = res.data is Map ? res.data as Map : {};
      final arr = (d['checkinCountData'] is List) ? (d['checkinCountData'] as List) : [];
      _salesData = arr.map((e) => (e is num) ? e.toDouble() : double.tryParse('$e') ?? 0).toList();
      _totalSales = (d['totalCheckins'] is num) ? (d['totalCheckins'] as num).toInt() : 0;
    } catch (_) {
      _salesData = [];
      _totalSales = 0;
    }
    if (mounted) setState(() {});
  }

  String _formatDate(dynamic d) {
    try {
      if (d is String) {
        return _dateFmt.format(DateTime.parse(d));
      } else if (d is DateTime) {
        return _dateFmt.format(d);
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PHHotel PMS'),
        actions: [
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
        ],
      ),
      body: authProvider.isAuthenticated ? _buildDashboard(context) : _buildGuest(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) {
          setState(() => _bottomIndex = i);
          if (i == 0) {}
          if (i == 1) context.push('/admin/rooms');
          if (i == 2) context.push('/admin/management');
          if (i == 3) context.push('/admin/financial-summary');
          if (i == 4) context.push('/profile');
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Rooms'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_applications), label: 'Management'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final role = Provider.of<AuthProvider>(context, listen: false).user?.role;
    final isAdmin = role == AppConstants.roleAdmin || role == AppConstants.roleSuperadmin;
    final isBusiness = role == AppConstants.roleBusiness;
    final isHotel = role == AppConstants.roleHotel;
    final isStaff = role == AppConstants.roleStaff;
    final quickItems = <Map<String, dynamic>>[
      {'title': 'Invoices', 'icon': Icons.receipt_long, 'route': '/admin/financial-summary'},
      {'title': 'Services', 'icon': Icons.room_service, 'route': '/admin/services'},
      {'title': 'Staff', 'icon': Icons.people, 'route': '/admin/staff'},
      {'title': 'Shift History', 'icon': Icons.history, 'route': '/admin/shift-handover-history'},
      {'title': 'Room', 'icon': Icons.bed, 'route': '/admin/rooms'},
      {'title': 'Guest', 'icon': Icons.person, 'route': '/admin/guests'},
      {'title': 'Debt', 'icon': Icons.account_balance_wallet, 'route': '/admin/debt'},
      {'title': 'Payment History', 'icon': Icons.credit_card, 'route': '/admin/financial-summary'},
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedHotelName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('PHHotel PMS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Welcome back!', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      value: _selectedHotelId,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      items: _hotels.map((h) {
                        final id = '${h['_id'] ?? h['id'] ?? ''}';
                        final name = '${h['name'] ?? 'Khách sạn'}';
                        return DropdownMenuItem(value: id, child: Text(name, style: const TextStyle(color: Colors.white)));
                      }).toList(),
                      onChanged: (v) async {
                        if (v != null) {
                          _selectedHotelId = v;
                          final found = _hotels.firstWhere((e) => '${e['_id'] ?? e['id'] ?? ''}' == v, orElse: () => {});
                          _selectedHotelName = found.isNotEmpty ? '${found['name'] ?? _selectedHotelName}' : _selectedHotelName;
                          setState(() {});
                          await _loadDashboardData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard(context, '$_vacant', 'Vacant')),
                const SizedBox(width: 8),
                Expanded(child: _statCard(context, '$_occupied', 'Occupied')),
                const SizedBox(width: 8),
                Expanded(child: _statCard(context, '$_booked', 'Booked')),
                const SizedBox(width: 8),
                Expanded(child: _statCard(context, '$_cleaning', 'Cleaning')),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              'OTA Booking Synchronization',
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _otaItem(context, Icons.check_circle, 'Booking.com', Colors.blue),
                    _otaItem(context, Icons.public, 'Agoda', Colors.purple),
                    _otaItem(context, Icons.flight, 'Traveloka', Colors.blueAccent),
                    _otaItem(context, Icons.home, 'Airbnb', Colors.redAccent),
                    _otaItem(context, Icons.luggage, 'Expedia', Colors.indigo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              'Quick Access',
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1),
                itemCount: quickItems.length,
                itemBuilder: (c, i) => _quickItem(context, quickItems[i]['title'], quickItems[i]['icon'], quickItems[i]['route']),
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              'Recent Bookings',
              Column(
                children: _recentBookings.isEmpty
                    ? [const ListTile(title: Text('Không có dữ liệu'))]
                    : _recentBookings.map((b) {
                        final tag = '${b['status'] ?? ''}';
                        final color = tag == 'checked_in'
                            ? Colors.blue
                            : tag == 'confirmed'
                                ? Colors.green
                                : tag == 'cancelled'
                                    ? Colors.redAccent
                                    : Colors.orange;
                        final subtitle = 'Phòng ${b['roomNumber']} • Ngày ${_formatDate(b['checkInDate'])} - ${_formatDate(b['checkOutDate'])}';
                        return _bookingItem('${b['guestName']}', subtitle, tag == 'pending' ? 'Sắp đến' : tag, color);
                      }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              'Sự kiện',
              Column(
                children: _roomEvents.isEmpty
                    ? [const ListTile(title: Text('Không có dữ liệu'))]
                    : _roomEvents.map((e) {
                        final type = '${e['type'] ?? ''}';
                        final roomNum = e['roomId'] is Map ? e['roomId']['roomNumber'] : e['roomNumber'];
                        final guest = e['guestInfo'] is Map ? e['guestInfo']['name'] : e['guestName'];
                        final time = e['checkinTime'] ?? e['checkoutTime'] ?? e['createdAt'];
                        final title = type == 'checkin'
                            ? 'Nhận phòng'
                            : type == 'checkout'
                                ? 'Trả phòng'
                                : type == 'maintenance'
                                    ? 'Bảo trì'
                                    : 'Chuyển phòng';
                        final tagText = title;
                        final color = type == 'checkin'
                            ? Colors.green
                            : type == 'checkout'
                                ? Colors.blue
                                : type == 'maintenance'
                                    ? Colors.grey
                                    : Colors.purple;
                        final subtitle = 'Phòng $roomNum • ${guest ?? ''} • ${_formatDate(time)}';
                        return _eventItem(title, subtitle, tagText, color);
                      }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              'Revenue Statistics',
              Column(
                children: [
                  _segmentedTabs(context, _revenueTab, (i) async {
                    setState(() => _revenueTab = i);
                    await _loadRevenueData();
                  }),
                  const SizedBox(height: 8),
                  SizedBox(height: 160, child: _barChart(_revenueData)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tổng doanh thu: ${_totalRevenue.toStringAsFixed(0)} đ'),
                      Text('Tổng chi phí: ${_totalExpense.toStringAsFixed(0)} đ'),
                      Text('Lợi nhuận: ${(_totalRevenue - _totalExpense).toStringAsFixed(0)} đ'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              'Room Sales Statistics',
              Column(
                children: [
                  _segmentedTabs(context, _roomSalesTab, (i) async {
                    setState(() => _roomSalesTab = i);
                    await _loadSalesData();
                  }),
                  const SizedBox(height: 8),
                  SizedBox(height: 160, child: _barChart(_salesData)),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: Text('Total Sales: $_totalSales lượt')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuest(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hotel, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Chào mừng đến với PHHotel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          ElevatedButton(onPressed: () => context.push('/auth/login'), child: const Text('Đăng nhập')),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: () => context.push('/auth/signup'), child: const Text('Đăng ký')),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _otaItem(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 24, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  Widget _quickItem(BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 24, backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1), child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 6),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _bookingItem(String title, String subtitle, String tag, Color color) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Chip(label: Text(tag, style: const TextStyle(color: Colors.white)), backgroundColor: color),
    );
  }

  Widget _eventItem(String title, String subtitle, String tag, Color color) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Chip(label: Text(tag, style: const TextStyle(color: Colors.white)), backgroundColor: color),
    );
  }

  Widget _segmentedTabs(BuildContext context, int index, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(child: _segTab(context, 'By Day', index == 0, () => onChanged(0))),
        const SizedBox(width: 8),
        Expanded(child: _segTab(context, 'By Week', index == 1, () => onChanged(1))),
        const SizedBox(width: 8),
        Expanded(child: _segTab(context, 'By Month', index == 2, () => onChanged(2))),
      ],
    );
  }

  Widget _segTab(BuildContext context, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _barChart(List<double> values) {
    final bars = <BarChartGroupData>[];
    for (var i = 0; i < values.length; i++) {
      bars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: values[i], color: Colors.blue, width: 16, borderRadius: BorderRadius.circular(6))]));
    }
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8), child: Text('${value.toInt() + 1}')))),
        ),
        barGroups: bars,
      ),
    );
  }
}

