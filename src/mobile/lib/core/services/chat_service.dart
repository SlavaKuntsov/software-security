import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_user.dart';
import '../constants/api_constants.dart';
import 'signalr_service.dart';

class ChatService {
  final Dio _dio;
  final SignalRService _signalRService;
  final StreamController<List<ChatMessage>> _chatMessagesController = 
      StreamController<List<ChatMessage>>.broadcast();
  
  Stream<List<ChatMessage>> get chatMessagesStream => _chatMessagesController.stream;
  Stream<ChatMessage> get newMessageStream => _signalRService.messageReceivedStream;
  Stream<String> get messagesReadStream => _signalRService.messagesReadStream;
  
  List<ChatMessage> _currentMessages = [];
  String? _currentUserId;
  String? _currentChatPartnerId;
  bool _isProcessingMessage = false;

  ChatService({
    required Dio dio,
    required SignalRService signalRService,
  }) : _dio = dio,
       _signalRService = signalRService;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    debugPrint('ChatService: initialize пользователя $userId');
    await _signalRService.startChatConnection(userId);
    
    // Listen to new messages from SignalR
    _signalRService.messageReceivedStream.listen((message) {
      if (_currentChatPartnerId != null && 
          (message.senderId == _currentChatPartnerId || message.receiverId == _currentChatPartnerId)) {
        
        if (_isProcessingMessage) {
          debugPrint('ChatService: уже идет обработка сообщения, пропускаем');
          return;
        }
        
        _isProcessingMessage = true;
        
        try {
          final duplicateIndex = _findDuplicateMessageIndex(message);
          
          if (duplicateIndex >= 0) {
            debugPrint('ChatService: заменяем локальное сообщение на серверное: ${_currentMessages[duplicateIndex].id} -> ${message.id}');
            _currentMessages[duplicateIndex] = message;
          } else {
            debugPrint('ChatService: добавляем новое сообщение: ${message.id}');
            _currentMessages.add(message);
          }
          
          _currentMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          final messagesCopy = List<ChatMessage>.from(_currentMessages);
          
          _chatMessagesController.add(messagesCopy);
          
          if (message.receiverId == _currentUserId && message.senderId == _currentChatPartnerId) {
            markMessagesAsRead(_currentChatPartnerId!);
          }
        } finally {
          _isProcessingMessage = false;
        }
      }
    });
  }

  Future<List<ChatUser>> getUsers() async {
    try {
      final response = await _dio.get(ApiConstants.chatUsers);
      final List<dynamic> data = response.data;
      return data.map((json) => ChatUser.fromMap(json)).toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      throw Exception('Failed to load users');
    }
  }

  Future<List<ChatMessage>> getChatHistory(String receiverId) async {
    try {
      _currentChatPartnerId = receiverId;
      final response = await _dio.get(
        ApiConstants.getChatHistory(receiverId),
      );
      final List<dynamic> data = response.data;
      _currentMessages = data.map((json) => ChatMessage.fromMap(json)).toList();
      _chatMessagesController.add(_currentMessages);
      return _currentMessages;
    } catch (e) {
      debugPrint('Error getting chat history: $e');
      throw Exception('Failed to load chat history');
    }
  }

  Future<void> sendMessage(String receiverId, String content) async {
    try {
      debugPrint('ChatService: отправка сообщения пользователю $receiverId');
      
      if (_currentUserId == null) {
        throw Exception('Сервис чата не инициализирован. Отсутствует ID пользователя.');
      }
      
      await _ensureConnection();
      
      final now = DateTime.now();
      final localMessageId = '${now.millisecondsSinceEpoch}_local';
      
      final tempMessage = ChatMessage(
        id: localMessageId,
        senderId: _currentUserId ?? '',
        receiverId: receiverId,
        content: content,
        timestamp: now,
        isRead: false,
      );
      
      debugPrint('ChatService: создано локальное сообщение с ID: $localMessageId');
      
      if (_currentChatPartnerId == receiverId) {
        final duplicateIndex = _findDuplicateMessageIndex(tempMessage);
        if (duplicateIndex < 0) {
          // _currentMessages.add(tempMessage);
          
          // _currentMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          // Делаем копию списка сообщений, чтобы избежать проблем с памятью
          final messagesCopy = List<ChatMessage>.from(_currentMessages);
          _chatMessagesController.add(messagesCopy);
        } else {
          debugPrint('ChatService: предотвращение дублирования - похожее сообщение уже существует');
        }
      }
      
      await _signalRService.sendMessage(receiverId, content);
      debugPrint('ChatService: сообщение успешно отправлено на сервер');
    } catch (e) {
      debugPrint('ChatService: ошибка при отправке сообщения - $e');
      
      if (_currentChatPartnerId == receiverId) {
        final msgIndex = _currentMessages.indexWhere(
          (m) => m.id.contains('_local') && 
                m.senderId == _currentUserId && 
                m.receiverId == receiverId && 
                m.content == content
        );
        
        if (msgIndex >= 0) {
          _currentMessages.removeAt(msgIndex);
          // Делаем копию списка сообщений
          final messagesCopy = List<ChatMessage>.from(_currentMessages);
          _chatMessagesController.add(messagesCopy);
        }
      }
      
      throw Exception('Не удалось отправить сообщение: $e');
    }
  }

  Future<void> _ensureConnection() async {
    try {
      if (_currentUserId == null) {
        throw Exception('Отсутствует ID пользователя');
      }
      
      if (!await _signalRService.isConnected()) {
        debugPrint('ChatService: Соединение отсутствует, пробуем переподключиться');
        await _signalRService.startChatConnection(_currentUserId!);
        
        await Future.delayed(Duration(milliseconds: 500));
        
        if (!await _signalRService.isConnected()) {
          throw Exception('Не удалось установить соединение с сервером');
        }
        debugPrint('ChatService: Соединение успешно восстановлено');
      }
    } catch (e) {
      debugPrint('ChatService: Ошибка при проверке соединения - $e');
      throw Exception('Проблема с подключением к серверу: $e');
    }
  }

  Future<void> markMessagesAsRead(String senderId) async {
    try {
      await _signalRService.markAsRead(senderId);
      await _dio.post(ApiConstants.markMessagesAsRead(senderId));
      
      _currentMessages = _currentMessages.map((message) {
        if (message.senderId == senderId && message.receiverId == _currentUserId && !message.isRead) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();
      
      // Делаем копию списка сообщений
      final messagesCopy = List<ChatMessage>.from(_currentMessages);
      _chatMessagesController.add(messagesCopy);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(ApiConstants.chatUnread);
      return response.data as int;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  void dispose() {
    _chatMessagesController.close();
    _signalRService.stopConnection();
  }

  int _findDuplicateMessageIndex(ChatMessage message) {
    for (int i = 0; i < _currentMessages.length; i++) {
      if (_currentMessages[i].isSameMessageAs(message)) {
        return i;
      }
    }
    return -1;
  }
} 