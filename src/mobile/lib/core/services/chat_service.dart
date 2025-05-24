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
        
        debugPrint('ChatService: получено сообщение: ID=${message.id}, контент=${message.content}, от=${message.senderId}');
        
        // Проверяем наличие дубликата с использованием нового метода
        final duplicateIndex = _findDuplicateMessageIndex(message);
        
        if (duplicateIndex >= 0) {
          // Если сообщение является дубликатом локального, заменяем его
          debugPrint('ChatService: заменяем сообщение на серверное: ${_currentMessages[duplicateIndex].id} -> ${message.id}');
          
          // Если заменяемое сообщение локальное, но имеет другой контент, 
          // то это может быть другое сообщение - добавляем новое
          if (_currentMessages[duplicateIndex].isLocalMessage && 
              _currentMessages[duplicateIndex].content != message.content) {
            debugPrint('ChatService: сообщения отличаются по содержанию, добавляем новое');
            _currentMessages.add(message);
          } else {
            // Просто заменяем локальное сообщение на серверное
            _currentMessages[duplicateIndex] = message;
          }
        } else {
          // Перед добавлением выполняем дополнительную проверку
          // Если есть очень похожее сообщение (но не определенное как дубликат),
          // то выводим предупреждение
          final similarIndex = _findSimilarMessageIndex(message);
          if (similarIndex >= 0) {
            debugPrint('ПРЕДУПРЕЖДЕНИЕ: Найдено похожее сообщение, но не определено как дубликат:');
            debugPrint('  Существующее: id=${_currentMessages[similarIndex].id}, контент=${_currentMessages[similarIndex].content}');
            debugPrint('  Новое: id=${message.id}, контент=${message.content}');
          }
          
          // Если это новое сообщение, добавляем его
          debugPrint('ChatService: добавляем новое сообщение: ${message.id}');
          _currentMessages.add(message);
        }
        
        // Убираем возможные точные дубликаты (с одинаковым ID)
        _removeDuplicatesById();
        
        // Сортируем сообщения по времени для правильного отображения
        _currentMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Отправляем обновленный список
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
      
      // Создаем уникальную временную метку для отслеживания сообщения
      final now = DateTime.now();
      final localMessageId = '${now.millisecondsSinceEpoch}_local';
      
      // Добавляем локальную версию сообщения для немедленного отображения в UI
      final tempMessage = ChatMessage(
        id: localMessageId, // уникальный временный ID
        senderId: _currentUserId ?? '',
        receiverId: receiverId,
        content: content,
        timestamp: now,
        isRead: false,
      );
      
      debugPrint('ChatService: создано локальное сообщение с ID: $localMessageId');
      
      // Проверяем, нет ли уже такого сообщения (для защиты от дублирования)
      if (_currentChatPartnerId == receiverId) {
        final duplicateIndex = _findDuplicateMessageIndex(tempMessage);
        if (duplicateIndex < 0) {
          // Добавляем сообщение только если его еще нет
          _currentMessages.add(tempMessage);
          
          // Сортируем сообщения по времени
          _currentMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          _chatMessagesController.add(_currentMessages);
        } else {
          debugPrint('ChatService: предотвращение дублирования - похожее сообщение уже существует');
        }
      }
      
      // Отправляем сообщение на сервер
      await _signalRService.sendMessage(receiverId, content);
      debugPrint('ChatService: сообщение успешно отправлено на сервер');
    } catch (e) {
      debugPrint('ChatService: ошибка при отправке сообщения - $e');
      
      // Удаляем временное сообщение, если оно было добавлено
      if (_currentChatPartnerId == receiverId) {
        // Находим сообщение по содержимому и ID
        final msgIndex = _currentMessages.indexWhere(
          (m) => m.id.contains('_local') && 
                m.senderId == _currentUserId && 
                m.receiverId == receiverId && 
                m.content == content
        );
        
        if (msgIndex >= 0) {
          _currentMessages.removeAt(msgIndex);
          _chatMessagesController.add(_currentMessages);
        }
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

  // Метод для поиска дубликатов сообщений
  int _findDuplicateMessageIndex(ChatMessage message) {
    for (int i = 0; i < _currentMessages.length; i++) {
      if (_currentMessages[i].isSameMessageAs(message)) {
        return i;
      }
    }
    return -1;
  }
  
  // Метод для поиска похожих сообщений (для диагностики)
  int _findSimilarMessageIndex(ChatMessage message) {
    for (int i = 0; i < _currentMessages.length; i++) {
      if (_currentMessages[i].senderId == message.senderId &&
          _currentMessages[i].receiverId == message.receiverId &&
          _currentMessages[i].content == message.content) {
        return i;
      }
    }
    return -1;
  }
  
  // Удаление точных дубликатов по ID
  void _removeDuplicatesById() {
    final uniqueIds = <String>{};
    _currentMessages = _currentMessages.where((message) {
      if (uniqueIds.contains(message.id)) {
        debugPrint('ChatService: Удаляем точный дубликат с ID: ${message.id}');
        return false; // Удаляем дубликат
      }
      uniqueIds.add(message.id);
      return true; // Оставляем уникальное сообщение
    }).toList();
  }
} 