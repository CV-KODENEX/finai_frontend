import 'dart:ui';

import 'package:finai_frontend/app/domain/entities/chat_item.dart';
import 'package:finai_frontend/core/database/chat_db.dart';
import 'package:finai_frontend/core/style/app_theme.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      return 'Greetings. I am ARTHA, your advanced financial intelligence. How may I assist you today?';
    } else if (input.contains('expense') || input.contains('spent')) {
      return 'I can analyze your expenditure patterns. Please provide the transaction details.';
    } else if (input.contains('budget')) {
      return 'Budget optimization is key. You can configure your limits in the Stats module.';
    } else if (input.contains('advice') || input.contains('tip')) {
      return 'Optimization Tip: Allocating 20% of income to savings increases long-term financial stability.';
    }
    return 'I am processing your input. Could you elaborate on your financial query?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark.withOpacity(0.8),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome,
                color: AppTheme.primaryNeon, size: 20),
            const SizedBox(width: 8),
            Text(
              'ARTHA AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textWhite,
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.accentPink),
            onPressed: () async {
              String userId = await Prefs.getCurrentUserId ?? '';
              await ChatDb.instance.clearChat(userId);
              _loadMessages();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundBlack,
                    Color(0xFF050510),
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryNeon))
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        AppTheme.primaryNeon.withOpacity(0.1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryNeon
                                            .withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline,
                                      size: 64, color: AppTheme.primaryNeon),
                                )
                                    .animate(
                                        onPlay: (c) => c.repeat(reverse: true))
                                    .scale(
                                        begin: const Offset(0.9, 0.9),
                                        end: const Offset(1.1, 1.1)),
                                const SizedBox(height: 24),
                                Text(
                                  'INITIALIZE CHAT SEQUENCE',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: AppTheme.textGrey,
                                        letterSpacing: 2,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isUser = msg.isUser == 1;
                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? AppTheme.primaryNeon.withOpacity(0.2)
                                        : AppTheme.surfaceDark,
                                    borderRadius:
                                        BorderRadius.circular(20).copyWith(
                                      bottomRight: isUser
                                          ? Radius.zero
                                          : const Radius.circular(20),
                                      bottomLeft: isUser
                                          ? const Radius.circular(20)
                                          : Radius.zero,
                                    ),
                                    border: Border.all(
                                      color: isUser
                                          ? AppTheme.primaryNeon
                                              .withOpacity(0.5)
                                          : Colors.white.withOpacity(0.1),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isUser
                                            ? AppTheme.primaryNeon
                                                .withOpacity(0.1)
                                            : Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        msg.message ?? '',
                                        style: TextStyle(
                                          color: isUser
                                              ? AppTheme.textWhite
                                              : AppTheme.textWhite
                                                  .withOpacity(0.9),
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('HH:mm').format(
                                            DateTime.parse(msg.timestamp ??
                                                DateTime.now()
                                                    .toIso8601String())),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isUser
                                              ? AppTheme.textWhite
                                                  .withOpacity(0.6)
                                              : AppTheme.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                              );
                            },
                          ),
              ),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withOpacity(0.8),
                      border: Border(
                          top:
                              BorderSide(color: Colors.white.withOpacity(0.1))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color:
                                        AppTheme.primaryNeon.withOpacity(0.3)),
                              ),
                              child: TextField(
                                controller: _messageController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter command...',
                                  hintStyle: TextStyle(
                                      color:
                                          AppTheme.textGrey.withOpacity(0.5)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryNeon,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryNeon.withOpacity(0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded,
                                  color: Colors.black),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
