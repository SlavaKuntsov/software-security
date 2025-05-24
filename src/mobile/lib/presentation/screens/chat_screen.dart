import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../domain/models/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatPartnerId;
  final String chatPartnerName;

  const ChatScreen({
    super.key, 
    required this.chatPartnerId,
    required this.chatPartnerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  ChatProvider? _chatProvider;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Безопасная инициализация с задержкой для избежания ошибок построения
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initChat();
        
        // Добавляем слушатель провайдера для прокрутки при получении новых сообщений
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.addListener(_handleProviderUpdate);
      }
    });
  }
  
  // Прокрутка списка сообщений к последнему сообщению (теперь к началу списка)
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0.0, // При reverse: true последние сообщения наверху списка
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Безопасная инициализация чата
  Future<void> _initChat() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      debugPrint('ChatScreen: начало инициализации чата');
      
      // Получаем провайдер без подписки
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      // Check if provider is initialized - используем await Future.microtask
      // для избежания setState во время построения
      await Future.microtask(() {});
      
      if (!_chatProvider!.isInitialized) {
        debugPrint('ChatScreen: инициализация провайдера чата');
        await _chatProvider!.initialize();
        
        // Проверяем, была ли успешной инициализация
        if (!_chatProvider!.isInitialized) {
          throw Exception('Не удалось инициализировать чат: ${_chatProvider!.error}');
        }
        debugPrint('ChatScreen: инициализация провайдера завершена успешно');
      } else {
        debugPrint('ChatScreen: провайдер чата уже инициализирован');
      }
      
      debugPrint('ChatScreen: загрузка истории сообщений для ${widget.chatPartnerId}');
      await _chatProvider!.loadChatHistory(widget.chatPartnerId);
      debugPrint('ChatScreen: история сообщений загружена успешно');
      
      if (mounted) {
        debugPrint('ChatScreen: отмечаем сообщения как прочитанные');
        await _chatProvider!.markMessagesAsRead();
        debugPrint('ChatScreen: сообщения отмечены как прочитанные');
        
        // Прокручиваем к последнему сообщению после загрузки
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('ChatScreen: ошибка при инициализации чата - $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
      debugPrint('Error initializing chat: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Обработчик обновлений провайдера
  void _handleProviderUpdate() {
    if (mounted && _chatProvider != null && _chatProvider!.status == ChatStatus.success) {
      // Прокручиваем вниз при получении новых сообщений
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    // Удаляем слушатель перед уничтожением виджета
    if (_chatProvider != null) {
      _chatProvider!.removeListener(_handleProviderUpdate);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Первичная проверка загрузки в локальном состоянии
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.chatPartnerName),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // Обработка локальной ошибки
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.chatPartnerName),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initChat,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatPartnerName),
        backgroundColor: AppTheme.primaryColor,
      ),
      // Указываем, что контент должен адаптироваться к появлению клавиатуры
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.status == ChatStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (chatProvider.status == ChatStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ошибка: ${chatProvider.error ?? "Проблема при загрузке сообщений"}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initChat,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }
                
                final messages = chatProvider.messages;
                if (messages.isEmpty) {
                  return const Center(child: Text('Нет сообщений, напишите первым!'));
                }
                
                // Используем reverse для показа последних сообщений
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  controller: _scrollController,
                  reverse: true, // Переворачиваем список, чтобы последние сообщения были внизу
                  itemBuilder: (context, index) {
                    // При reverse: true индексы инвертированы - меняем для правильного отображения
                    final reverseIndex = messages.length - 1 - index;
                    if (reverseIndex < 0 || reverseIndex >= messages.length) {
                      return const SizedBox.shrink();
                    }
                    final message = messages[reverseIndex];
                    return _buildMessageItem(message, chatProvider.isMyMessage(message));
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, bool isMe) {
    // Защита от пустых строк и null
    final firstLetter = widget.chatPartnerName.isNotEmpty ? 
        widget.chatPartnerName[0] : '?';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Text(
                firstLetter,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.accentColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe)
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
        color: AppTheme.primaryColor,
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
              decoration: InputDecoration(
                hintText: 'Введите сообщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide(color: AppTheme.accentColor, width: 1.5),
                ),
                filled: true,
                fillColor: AppTheme.primaryColor,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(chatProvider),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider chatProvider) {
    if (_messageController.text.isEmpty) return;
    
    final messageText = _messageController.text;
    _messageController.clear(); // Очищаем ввод сразу
    
    // Скроллим вниз после отправки сообщения
    _scrollToBottom();
    
    try {
      // Асинхронно отправляем сообщение
      chatProvider.sendMessage(messageText).then((_) {
        // Успешная отправка - скроллим вниз еще раз после получения подтверждения
        _scrollToBottom();
      }).catchError((e) {
        // Ошибка отправки
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при отправке сообщения: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => _retryMessageSend(chatProvider, messageText),
            ),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при отправке сообщения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _retryMessageSend(ChatProvider chatProvider, String messageText) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Повторная отправка...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      // Скроллим вниз после отправки сообщения
      _scrollToBottom();
      
      chatProvider.sendMessage(messageText).then((_) {
        // Успешная отправка - скроллим вниз еще раз
        _scrollToBottom();
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Повторная ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при повторной отправке: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 