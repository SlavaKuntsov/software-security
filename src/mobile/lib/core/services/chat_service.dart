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
        _currentMessages.add(message);
        _chatMessagesController.add(_currentMessages);
        
        // Mark messages as read if we are the receiver
        if (message.receiverId == _currentUserId && message.senderId == _currentChatPartnerId) {
          markMessagesAsRead(_currentChatPartnerId!);
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
      
      // Проверяем, что SignalR соединение инициализировано
      if (_currentUserId == null) {
        throw Exception('Сервис чата не инициализирован. Отсутствует ID пользователя.');
      }
      
      // Проверяем соединение перед отправкой и пытаемся переподключиться если нужно
      await _ensureConnection();
      
      // Добавляем локальную версию сообщения для немедленного отображения в UI
      final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // временный ID
        senderId: _currentUserId ?? '',
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );
      
      // Добавляем сообщение в локальный список для мгновенного отображения
      if (_currentChatPartnerId == receiverId) {
        _currentMessages.add(tempMessage);
        _chatMessagesController.add(_currentMessages);
      }
      
      // Отправляем сообщение на сервер
      await _signalRService.sendMessage(receiverId, content);
      debugPrint('ChatService: сообщение успешно отправлено');
    } catch (e) {
      debugPrint('ChatService: ошибка при отправке сообщения - $e');
      
      // Удаляем временное сообщение, если оно было добавлено
      if (_currentChatPartnerId == receiverId) {
        _currentMessages = _currentMessages.where(
          (m) => !(m.senderId == _currentUserId && 
                  m.receiverId == receiverId && 
                  m.content == content &&
                  m.timestamp.difference(DateTime.now()).inSeconds.abs() < 5)
        ).toList();
        _chatMessagesController.add(_currentMessages);
      }
      
      throw Exception('Не удалось отправить сообщение: $e');
    }
  }

  // Добавляем метод для проверки соединения
  Future<void> _ensureConnection() async {
    try {
      if (_currentUserId == null) {
        throw Exception('Отсутствует ID пользователя');
      }
      
      // Проверяем текущее состояние соединения в SignalRService
      // и пытаемся переподключиться, если соединение отсутствует
      if (!await _signalRService.isConnected()) {
        debugPrint('ChatService: Соединение отсутствует, пробуем переподключиться');
        await _signalRService.startChatConnection(_currentUserId!);
        
        // Дополнительная задержка для стабильности
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
      
      // Update the local messages
      _currentMessages = _currentMessages.map((message) {
        if (message.senderId == senderId && message.receiverId == _currentUserId && !message.isRead) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();
      
      _chatMessagesController.add(_currentMessages);
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
} 