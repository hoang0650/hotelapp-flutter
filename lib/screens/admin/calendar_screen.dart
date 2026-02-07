import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hotelapp_flutter/services/guests_service.dart';
import 'package:hotelapp_flutter/services/hotel_service.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _guestsService = GuestsService();
  final _hotelService = HotelService();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  List<dynamic> _allGuests = [];
  List<dynamic> _selectedDayGuests = [];
  List<dynamic> _hotels = [];
  String? _selectedHotelId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _loadHotels();
      if (_selectedHotelId != null) {
        // Fetch guests - increasing limit to get a good range
        final res = await _guestsService.getGuests(hotelId: _selectedHotelId, limit: 100);
        if (res['items'] is List) {
          _allGuests = res['items'];
        }
      }
      _updateSelectedDayGuests();
    } catch (_) {
      // Ignore errors
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadHotels() async {
    try {
      final data = await _hotelService.getHotels();
      _hotels = (data is List) ? data : (data is Map && data['items'] is List ? data['items'] : []);
      if (_hotels.isNotEmpty && _selectedHotelId == null) {
        _selectedHotelId = (_hotels.first as Map)['_id'];
      }
    } catch (_) {
      _hotels = [];
    }
  }

  void _updateSelectedDayGuests() {
    if (_selectedDay == null) return;
    
    _selectedDayGuests = _allGuests.where((g) {
      final checkInStr = g['checkInDate'];
      if (checkInStr == null) return false;
      
      final checkIn = DateTime.tryParse(checkInStr);
      if (checkIn == null) return false;
      
      final checkOutStr = g['checkOutDate'];
      final checkOut = checkOutStr != null ? DateTime.tryParse(checkOutStr) : null;
      
      // Normalize dates to remove time
      final day = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      final start = DateTime(checkIn.year, checkIn.month, checkIn.day);
      final end = checkOut != null 
          ? DateTime(checkOut.year, checkOut.month, checkOut.day)
          : DateTime.now().add(const Duration(days: 365)); // If no checkout, assume active
          
      // Check if day is within range [start, end]
      return !day.isBefore(start) && !day.isAfter(end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch đặt phòng')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _updateSelectedDayGuests();
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            ),
            eventLoader: (day) {
              // Simple event marker logic
              return _allGuests.where((g) {
                final checkInStr = g['checkInDate'];
                if (checkInStr == null) return false;
                final checkIn = DateTime.tryParse(checkInStr);
                if (checkIn == null) return false;
                
                final start = DateTime(checkIn.year, checkIn.month, checkIn.day);
                final target = DateTime(day.year, day.month, day.day);
                return isSameDay(start, target);
              }).toList();
            },
          ),
          const Divider(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _selectedDayGuests.isEmpty
                    ? const Center(child: Text('Không có khách trong ngày này'))
                    : ListView.builder(
                        itemCount: _selectedDayGuests.length,
                        itemBuilder: (context, index) {
                          final guest = _selectedDayGuests[index] as Map<String, dynamic>;
                          final name = guest['fullName'] ?? 'Khách';
                          final room = guest['roomNumber'] ?? guest['roomName'] ?? 'Chưa xếp phòng';
                          final checkIn = guest['checkInDate'] != null 
                              ? DateFormat('dd/MM HH:mm').format(DateTime.parse(guest['checkInDate']))
                              : '';
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(name),
                            subtitle: Text('Phòng: $room • Vào: $checkIn'),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

