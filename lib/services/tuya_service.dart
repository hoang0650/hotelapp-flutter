import 'package:dio/dio.dart';
import 'api_service.dart';

class TuyaService {
  final ApiService _api = ApiService();
  final String _endpoint = '/tuya';

  Future<List<dynamic>> getDevices({String? roomId, String? hotelId}) async {
    final Map<String, dynamic> params = {};
    if (roomId != null) params['roomId'] = roomId;
    if (hotelId != null) params['hotelId'] = hotelId;

    final response = await _api.get('$_endpoint/devices', queryParameters: params);
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  Future<dynamic> getDevice(String deviceId) async {
    final response = await _api.get('$_endpoint/devices/$deviceId');
    return response.data['data'];
  }

  Future<dynamic> turnOn(String deviceId) async {
    final response = await _api.post('$_endpoint/devices/$deviceId/turn-on');
    return response.data;
  }

  Future<dynamic> turnOff(String deviceId) async {
    final response = await _api.post('$_endpoint/devices/$deviceId/turn-off');
    return response.data;
  }

  Future<dynamic> toggle(String deviceId) async {
    final response = await _api.post('$_endpoint/devices/$deviceId/toggle');
    return response.data;
  }

  Future<dynamic> getStatus(String deviceId) async {
    final response = await _api.get('$_endpoint/devices/$deviceId/status');
    return response.data['data'];
  }

  Future<dynamic> addDevice(Map<String, dynamic> deviceData) async {
    final response = await _api.post('$_endpoint/devices', data: deviceData);
    return response.data['data'];
  }

  Future<dynamic> updateDevice(String deviceId, Map<String, dynamic> deviceData) async {
    final response = await _api.put('$_endpoint/devices/$deviceId', data: deviceData);
    return response.data['data'];
  }

  Future<void> deleteDevice(String deviceId) async {
    await _api.delete('$_endpoint/devices/$deviceId');
  }

  Future<void> autoTurnOnOnCheckIn(String roomId) async {
    await _api.post('$_endpoint/rooms/$roomId/auto-turn-on');
  }

  Future<void> autoTurnOffOnCheckOut(String roomId) async {
    await _api.post('$_endpoint/rooms/$roomId/auto-turn-off');
  }

  Future<void> turnOnByRoom(String roomId) async {
    await _api.post('$_endpoint/devices/room/$roomId/turn-on');
  }

  Future<void> turnOffByRoom(String roomId) async {
    await _api.post('$_endpoint/devices/room/$roomId/turn-off');
  }
}
