import 'package:finai_frontend/app/domain/entities/chat_item.dart';
import 'package:finai_frontend/core/database/chat_db.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  List<ChatItem> _messages = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    String userId = await Prefs.getCurrentUserId ?? '';
    var list = await ChatDb.instance.getAll(userId);
    setState(() {
      _messages = list;
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
    if (_messageController.text.trim().isEmpty) return;

    String text = _messageController.text.trim();
    _messageController.clear();
    String userId = await Prefs.getCurrentUserId ?? '';

    // Save User Message
    ChatItem userMsg = ChatItem(
      message: text,
      isUser: 1,
      timestamp: DateTime.now().toIso8601String(),
      userId: userId,
    );
    await ChatDb.instance.insert(userMsg);

    setState(() {
      _messages.add(userMsg);
    });
    _scrollToBottom();

    // Simulate Bot Response
    await Future.delayed(const Duration(seconds: 1));

    String botText = _getBotResponse(text);
    ChatItem botMsg = ChatItem(
      message: botText,
      isUser: 0,
      timestamp: DateTime.now().toIso8601String(),
      userId: userId,
    );
    await ChatDb.instance.insert(botMsg);

    setState(() {
      _messages.add(botMsg);
    });
    _scrollToBottom();
  }

  String _getBotResponse(String input) {
    input = input.toLowerCase();
    if (input.contains('hello') || input.contains('hi')) {
      return 'Hello! I am Artha, your financial assistant. How can I help you today?';
    } else if (input.contains('expense') || input.contains('spent')) {
      return 'I can help you track your expenses. Just tell me what you bought and how much it cost.';
    } else if (input.contains('budget')) {
      return 'You can set your budget in the Stats page. Do you want me to show you your current budget status?';
    } else if (input.contains('advice') || input.contains('tip')) {
      return 'My tip for today: Try to save at least 20% of your income for future goals.';
    }
    return 'I see. Tell me more about your financial goals or transactions.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artha Bot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              String userId = await Prefs.getCurrentUserId ?? '';
              await ChatDb.instance.clearChat(userId);
              _loadMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Start chatting with Artha Bot!',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg.isUser == 1;
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    isUser ? Colors.blue : Colors.grey.shade200,
                                borderRadius:
                                    BorderRadius.circular(20).copyWith(
                                  bottomRight: isUser
                                      ? Radius.zero
                                      : const Radius.circular(20),
                                  bottomLeft: isUser
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                ),
                              ),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.message ?? '',
                                    style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:mm').format(DateTime.parse(
                                        msg.timestamp ??
                                            DateTime.now().toIso8601String())),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isUser
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
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
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
