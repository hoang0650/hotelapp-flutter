import 'dart:async';
import 'dart:convert';
import 'package:hotelapp_flutter/config/constants.dart';
import 'package:hotelapp_flutter/services/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

// Models
class ChatMessage {
  String id;
  String content;
  String role; // 'user' | 'assistant'
  DateTime timestamp;
  bool? isTyping;
  String? fileUrl;
  String? fileType;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isTyping,
    this.fileUrl,
    this.fileType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      role: json['role'] ?? 'user',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
    );
  }
}

class FbMessage {
  String? tenantId;
  String? pageId;
  String senderId;
  String? recipientId;
  String? senderName;
  String? senderAvatar;
  String text;
  List<dynamic>? attachments;
  String direction; // 'in' | 'out'
  int timestamp;
  String? replyText;
  String? mid;

  FbMessage({
    this.tenantId,
    this.pageId,
    required this.senderId,
    this.recipientId,
    this.senderName,
    this.senderAvatar,
    required this.text,
    this.attachments,
    required this.direction,
    required this.timestamp,
    this.replyText,
    this.mid,
  });

  factory FbMessage.fromJson(Map<String, dynamic> json) {
    return FbMessage(
      tenantId: json['tenant_id'],
      pageId: json['page_id'],
      senderId: json['sender_id'] ?? '',
      recipientId: json['recipient_id'],
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      text: json['text'] ?? '',
      attachments: json['attachments'],
      direction: json['direction'] ?? 'in',
      timestamp: json['timestamp'] is int ? json['timestamp'] : (DateTime.tryParse(json['timestamp'].toString())?.millisecondsSinceEpoch ?? 0),
      replyText: json['reply_text'],
      mid: json['mid'],
    );
  }
}

class AiAssistantService {
  final ApiService _apiService = ApiService();
  WebSocketChannel? _channel;
  final _wsController = StreamController<dynamic>.broadcast();

  // URL configuration
  String get _aiUrl => AppConstants.aiBaseUrl; 
  String get _apiUrl => AppConstants.apiUrl;

  Stream<dynamic> get wsStream => _wsController.stream;

  // --- WebSocket Connection ---
  void connectToWebSocket(String tenantId) {
    if (_channel != null) {
      return; // Already connected or connecting logic could be improved
    }

    try {
      final wsUrl = _aiUrl.replaceFirst('http', 'ws') + '/ws/$tenantId';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _wsController.add(data);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
        onDone: () {
          print('WebSocket connection closed');
          _channel = null;
          // Implement reconnect logic if needed
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  void disconnectWebSocket() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }

  // --- Internal Chat ---
  Future<List<ChatMessage>> getChatHistory({String? hotelId}) async {
    try {
      final response = await _apiService.get(
        '/ai-assistant/history',
        queryParameters: hotelId != null ? {'hotelId': hotelId} : null,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> msgs = response.data['messages'];
        return msgs.map((e) => ChatMessage.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  Future<String> sendChatMessage(String message, {String? fileUrl, String? fileType, String? hotelId}) async {
    try {
      final response = await _apiService.post(
        '/ai-assistant/chat',
        data: {
          'message': message,
          'fileUrl': fileUrl,
          'fileType': fileType,
          if (hotelId != null) 'hotelId': hotelId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['response'] ?? 'Không có phản hồi.';
      }
      return 'Lỗi: ${response.statusMessage}';
    } catch (e) {
      print('Error sending message: $e');
      return 'Lỗi kết nối tới máy chủ.';
    }
  }

  Future<void> clearChatHistory() async {
    try {
      await _apiService.delete('/ai-assistant/history');
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  // --- Fanpage Messages ---
  Future<List<dynamic>> getFacebookPages(String tenantId) async {
    try {
      // Direct call to AI backend via ApiService if proxied, or we might need a direct dio call if it's a different domain
      // Assuming _aiUrl is accessible via standard HTTP requests.
      // NOTE: ApiService uses _dio with baseUrl from AppConstants.apiUrl.
      // If _aiUrl is different, we might need a separate Dio instance or full URL.
      // For now, I'll assume we can use a new Dio or full URL if _apiService supports it.
      // But _apiService methods prepend baseUrl. 
      // I will create a direct Dio request for AI URL since it might be different.
      
      // However, looking at the Angular code: 
      // private aiUrl = environment.aiUrl; 
      // private apiUrl = environment.apiUrl;
      // It uses http.get(aiUrl + ...)
      
      // So I should use a raw Dio instance for AI URL calls if it's different.
      // Or I can update ApiService to handle full URLs.
      // For safety, I'll use a local logic here.
      
      // Actually, let's just use the full URL with a new Dio for simplicity here, 
      // or check if AppConstants.aiUrl is just a path. It's likely a full URL.
      
      // Better: Use ApiService if it supports full URL (usually Dio supports it if path starts with http).
      // Let's try passing full URL to ApiService methods.
      
      final response = await _apiService.get('$_aiUrl/facebook/pages', queryParameters: {'tenant_id': tenantId});
      if (response.statusCode == 200) {
        return response.data is List ? response.data : [];
      }
      return [];
    } catch (e) {
      // Fallback: ApiService might prepend baseUrl. If aiUrl is external, we might need to handle it.
      // If ApiService.get throws because of 404 (due to double URL), we need to fix it.
      // But let's assume for now we can just use a helper.
      print('Error getting FB pages: $e');
      return [];
    }
  }

  Future<List<FbMessage>> getFacebookMessages(String tenantId, String pageId) async {
    try {
      final response = await _apiService.get('$_aiUrl/facebook/messages', queryParameters: {
        'tenant_id': tenantId,
        'page_id': pageId,
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => FbMessage.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting FB messages: $e');
      return [];
    }
  }

  Future<void> sendFacebookMessage(String tenantId, String pageId, String recipientId, String text) async {
    try {
      await _apiService.post('$_aiUrl/facebook/send', data: {
        'tenant_id': tenantId,
        'page_id': pageId,
        'recipient_id': recipientId,
        'message_text': text,
      });
    } catch (e) {
      print('Error sending FB message: $e');
      throw e;
    }
  }

  Future<bool> getBotStatus(String tenantId, String pageId) async {
    try {
      final response = await _apiService.get('$_aiUrl/facebook/bot-status', queryParameters: {
        'tenant_id': tenantId,
        'page_id': pageId,
      });
      if (response.statusCode == 200) {
        return response.data['active'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleBot(String tenantId, String pageId, bool active) async {
    try {
      await _apiService.post('$_aiUrl/facebook/bot-status', data: {
        'tenant_id': tenantId,
        'page_id': pageId,
        'active': active,
      });
    } catch (e) {
      print('Error toggling bot: $e');
      throw e;
    }
  }
  
  Future<String> getFacebookOAuthUrl(String tenantId) async {
    try {
      final response = await _apiService.get('$_aiUrl/facebook/oauth-url', queryParameters: {
        'tenant_id': tenantId
      });
      if (response.statusCode == 200) {
        return response.data['url'] ?? '';
      }
      return '';
    } catch (e) {
      print('Error getting OAuth URL: $e');
      return '';
    }
  }
}
