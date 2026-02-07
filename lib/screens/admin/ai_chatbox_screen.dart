import 'package:flutter/material.dart';
import 'package:hotelapp_flutter/services/ai_assistant_service.dart';
import 'package:hotelapp_flutter/config/theme.dart'; // Assuming theme exists
import 'package:go_router/go_router.dart';

class AiChatboxScreen extends StatefulWidget {
  const AiChatboxScreen({Key? key}) : super(key: key);

  @override
  _AiChatboxScreenState createState() => _AiChatboxScreenState();
}

class _AiChatboxScreenState extends State<AiChatboxScreen> {
  final AiAssistantService _aiService = AiAssistantService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final msgs = await _aiService.getChatHistory();
    setState(() {
      _messages = msgs;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    
    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      content: text,
      role: 'user',
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    final hp = Provider.of<HotelProvider>(context, listen: false);
    final response = await _aiService.sendChatMessage(text, hotelId: hp.selectedHotelId);
    
    final aiMsg = ChatMessage(
      id: DateTime.now().toString(),
      content: response,
      role: 'assistant',
      timestamp: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(aiMsg);
      });
      _scrollToBottom();
    }
  }

  Future<void> _clearHistory() async {
    await _aiService.clearChatHistory();
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.facebook),
            onPressed: () {
              context.push('/admin/fanpage');
            },
            tooltip: 'Fanpage Messages',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('Chưa có tin nhắn nào. Hãy bắt đầu trò chuyện!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return const Padding(
                              padding: EdgeInsets.only(left: 8, bottom: 8),
                              child: Text('AI đang soạn tin...', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                            );
                          }
                          final msg = _messages[index];
                          final isUser = msg.role == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(msg.content),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
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
                    controller: _textController,
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
