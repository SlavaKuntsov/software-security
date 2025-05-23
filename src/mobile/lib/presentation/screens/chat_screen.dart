import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: 'Пользователь 1',
      text: 'Привет, как дела?',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    _ChatMessage(
      sender: 'Я',
      text: 'Отлично! Как у тебя?',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    _ChatMessage(
      sender: 'Пользователь 1',
      text: 'Всё хорошо, спасибо!',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(_ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe)
            CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Text(
                message.sender[0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isMe ? AppTheme.accentColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isMe)
                    Text(
                      message.sender,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isMe)
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Text(
                'Я',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Введите сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFF2F2F2),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.accentColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          sender: 'Я',
          text: _messageController.text,
          isMe: true,
          time: DateTime.now(),
        ),
      );
      _messageController.clear();
    });
  }
}

class _ChatMessage {
  final String sender;
  final String text;
  final bool isMe;
  final DateTime time;

  _ChatMessage({
    required this.sender,
    required this.text,
    required this.isMe,
    required this.time,
  });
} 