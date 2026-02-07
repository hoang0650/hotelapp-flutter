import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotelapp_flutter/services/ai_assistant_service.dart';
import 'package:hotelapp_flutter/services/auth_service.dart';
import 'package:hotelapp_flutter/providers/hotel_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotelapp_flutter/config/constants.dart';
import 'dart:async';

class FanpageMessagesScreen extends StatefulWidget {
  const FanpageMessagesScreen({Key? key}) : super(key: key);

  @override
  _FanpageMessagesScreenState createState() => _FanpageMessagesScreenState();
}

class _FanpageMessagesScreenState extends State<FanpageMessagesScreen> {
  final AiAssistantService _aiService = AiAssistantService();
  final AuthService _authService = AuthService();
  
  List<dynamic> _pages = [];
  String? _selectedPageId;
  
  List<FbMessage> _messages = []; // All messages for current page
  List<Map<String, dynamic>> _conversations = []; // Grouped conversations
  
  String? _selectedSenderId;
  List<FbMessage> _displayedMessages = [];
  
  bool _isLoading = false;
  bool _isSending = false;
  bool _isBotActive = false;
  
  final TextEditingController _replyController = TextEditingController();
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _aiService.disconnectWebSocket();
    _replyController.dispose();
    super.dispose();
  }

  Future<String> _getTenantId() async {
    try {
      final hp = Provider.of<HotelProvider>(context, listen: false);
      if (hp.selectedHotelId != null) {
        return hp.selectedHotelId!;
      }
      final user = await _authService.getCurrentUser();
      if (user != null) {
        return user.hotelId ?? user.businessId ?? 'default';
      }
      return 'default';
    } catch (_) {
      return 'default';
    }
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      final tenantId = await _getTenantId();
      
      // Connect WS
      _aiService.connectToWebSocket(tenantId);
      _wsSubscription = _aiService.wsStream.listen(_handleRealtimeMessage);

      await _refreshPages(tenantId);
      
    } catch (e) {
      print('Error init: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _handleRealtimeMessage(dynamic msg) {
    if (msg == null) return;
    
    // 1. Deduplicate by mid
    final mid = msg['mid'];
    if (mid != null && _messages.any((m) => m.mid == mid)) {
      return;
    }

    // 2. Check page
    if (msg['page_id'] != _selectedPageId) return;

    final newMsg = FbMessage.fromJson(msg);
    
    setState(() {
      _messages.add(newMsg);
      _buildConversations();
      
      // Update displayed if current conversation
      if (_selectedSenderId != null) {
        final partnerId = newMsg.direction == 'in' ? newMsg.senderId : newMsg.recipientId;
        if (partnerId == _selectedSenderId) {
          _filterDisplayedMessages();
        }
      }
    });
  }

  Future<void> _refreshPages(String tenantId) async {
    final pages = await _aiService.getFacebookPages(tenantId);
    setState(() {
      _pages = pages;
      if (_pages.isNotEmpty && _selectedPageId == null) {
        _selectedPageId = _pages[0]['id'];
      }
    });
    
    if (_selectedPageId != null) {
      await _loadMessages(tenantId);
      await _loadBotStatus(tenantId);
    }
  }
  
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      // Re-fetch everything
      final prefs = await SharedPreferences.getInstance();
      // ... get tenantId ...
      String tenantId = 'default'; // simplified
      
      await _refreshPages(tenantId);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages(String tenantId) async {
    if (_selectedPageId == null) return;
    final msgs = await _aiService.getFacebookMessages(tenantId, _selectedPageId!);
    setState(() {
      _messages = msgs;
      _buildConversations();
    });
  }
  
  Future<void> _loadBotStatus(String tenantId) async {
    if (_selectedPageId == null) return;
    final status = await _aiService.getBotStatus(tenantId, _selectedPageId!);
    setState(() {
      _isBotActive = status;
    });
  }
  
  Future<void> _toggleBot(bool value) async {
     if (_selectedPageId == null) return;
     // ... get tenantId
     String tenantId = 'default';
     
     setState(() => _isBotActive = value); // Optimistic update
     try {
       await _aiService.toggleBot(tenantId, _selectedPageId!, value);
     } catch (e) {
       setState(() => _isBotActive = !value); // Revert
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
     }
  }

  void _buildConversations() {
    final Map<String, Map<String, dynamic>> convMap = {};
    // Sort messages by timestamp desc
    final sorted = List<FbMessage>.from(_messages)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    for (var m in sorted) {
      final partnerId = m.direction == 'in' ? m.senderId : (m.recipientId ?? 'Unknown');
      if (!convMap.containsKey(partnerId)) {
        convMap[partnerId] = {
          'sender_id': partnerId,
          'sender_name': m.senderName ?? partnerId,
          'sender_avatar': m.senderAvatar,
          'lastText': m.text.isNotEmpty ? m.text : (m.attachments != null && m.attachments!.isNotEmpty ? '[Đính kèm]' : ''),
          'lastTime': m.timestamp,
        };
      } else {
        // Update name/avatar if missing
        if ((convMap[partnerId]!['sender_name'] == null || convMap[partnerId]!['sender_name'] == partnerId) && m.senderName != null) {
          convMap[partnerId]!['sender_name'] = m.senderName;
          convMap[partnerId]!['sender_avatar'] = m.senderAvatar;
        }
      }
    }
    
    _conversations = convMap.values.toList();
  }

  void _selectConversation(String senderId) {
    setState(() {
      _selectedSenderId = senderId;
      _filterDisplayedMessages();
    });
  }

  void _filterDisplayedMessages() {
    if (_selectedSenderId == null) return;
    _displayedMessages = _messages.where((m) => 
      (m.direction == 'in' && m.senderId == _selectedSenderId) ||
      (m.direction == 'out' && m.recipientId == _selectedSenderId)
    ).toList();
    _displayedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  Future<void> _sendMessage() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _selectedPageId == null || _selectedSenderId == null) return;
    
    setState(() => _isSending = true);
    try {
      // ... get tenantId
      String tenantId = 'default';
      await _aiService.sendFacebookMessage(tenantId, _selectedPageId!, _selectedSenderId!, text);
      _replyController.clear();
      // WebSocket should handle the rest (adding to list)
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gửi lỗi: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If a conversation is selected, show the thread (Detail View)
    // Otherwise show the list of conversations (List View)
    // Back button in Detail View goes back to List View
    
    if (_selectedSenderId != null) {
      return _buildThreadView();
    }
    return _buildListView();
  }
  
  Widget _buildListView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn Fanpage'),
        actions: [
           IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          Switch(
            value: _isBotActive,
            onChanged: _toggleBot,
            activeColor: Colors.green,
          ),
        ],
      ),
      body: Column(
        children: [
          // Page Selector
          if (_pages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPageId,
                items: _pages.map((p) => DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(p['name'] ?? 'Unnamed Page'),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPageId = val;
                    _selectedSenderId = null;
                  });
                  _loadMessages('default'); // reload
                },
              ),
            ),
            
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _conversations.isEmpty 
                ? const Center(child: Text('Chưa có tin nhắn'))
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final c = _conversations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: c['sender_avatar'] != null ? NetworkImage(c['sender_avatar']) : null,
                          child: c['sender_avatar'] == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(c['sender_name'] ?? 'Unknown'),
                        subtitle: Text(
                          c['lastText'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          DateTime.fromMillisecondsSinceEpoch(c['lastTime']).toString().substring(11, 16),
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () => _selectConversation(c['sender_id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildThreadView() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedSenderId = null;
            });
          },
        ),
        title: Text(_conversations.firstWhere((c) => c['sender_id'] == _selectedSenderId, orElse: () => {'sender_name': 'Chat'})['sender_name']),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadMessages('default'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _displayedMessages.length,
              itemBuilder: (context, index) {
                final m = _displayedMessages[index];
                final isOut = m.direction == 'out';
                return Align(
                  alignment: isOut ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isOut ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.text),
                        if (m.attachments != null && m.attachments!.isNotEmpty)
                           ...m.attachments!.map((a) {
                             if (a['type'] == 'image') {
                               return Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Image.network(a['payload']['url'], height: 150),
                               );
                             }
                             return const Text('[Attachment]');
                           }),
                        const SizedBox(height: 4),
                        Text(
                          DateTime.fromMillisecondsSinceEpoch(m.timestamp).toString().substring(11, 16),
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
