import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:hotelapp_flutter/config/constants.dart';

class HotelProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<Map<String, dynamic>> _hotels = [];
  String? _selectedHotelId;
  String _selectedHotelName = 'Chọn khách sạn';
  bool _loading = false;
  
  List<Map<String, dynamic>> get hotels => _hotels;
  String? get selectedHotelId => _selectedHotelId;
  String get selectedHotelName => _selectedHotelName;
  bool get loading => _loading;
  
  // Call this when app starts or user logs in
  Future<void> loadHotels({String? userHotelId}) async {
    _loading = true;
    notifyListeners();
    
    try {
      final res = await _api.get(AppConstants.hotelsEndpoint);
      final data = res.data;
      if (data is List) {
        _hotels = data.cast<Map<String, dynamic>>();
      } else {
        _hotels = [];
      }
      
      // Set initial selection
      if (userHotelId != null && userHotelId.isNotEmpty) {
        // Try to find the user's assigned hotel
        final found = _hotels.firstWhere(
          (h) => '${h['_id'] ?? h['id']}' == userHotelId,
          orElse: () => {},
        );
        
        if (found.isNotEmpty) {
          _selectedHotelId = userHotelId;
          _selectedHotelName = found['name'] ?? 'Khách sạn';
        } else {
          // If not in list (maybe restricted list?), try to use it anyway or fallback
           _selectedHotelId = userHotelId;
           // Optionally fetch specific hotel name if needed, but for now fallback
        }
      } 
      
      // If no selection yet and we have hotels, select the first one
      if ((_selectedHotelId == null || _selectedHotelId!.isEmpty) && _hotels.isNotEmpty) {
        final first = _hotels.first;
        _selectedHotelId = '${first['_id'] ?? first['id']}';
        _selectedHotelName = first['name'] ?? 'Khách sạn';
      }
      
    } catch (e) {
      print('Error loading hotels: $e');
      _hotels = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectHotel(String hotelId) {
    if (_selectedHotelId == hotelId) return;
    
    final found = _hotels.firstWhere(
      (h) => '${h['_id'] ?? h['id']}' == hotelId,
      orElse: () => {},
    );
    
    if (found.isNotEmpty) {
      _selectedHotelId = hotelId;
      _selectedHotelName = found['name'] ?? 'Khách sạn';
      notifyListeners();
    }
  }
  
  // Helper to clear selection (e.g. on logout)
  void clear() {
    _hotels = [];
    _selectedHotelId = null;
    _selectedHotelName = 'Chọn khách sạn';
    notifyListeners();
  }
}
