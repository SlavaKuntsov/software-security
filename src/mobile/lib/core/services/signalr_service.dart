// lib/core/services/signalr_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../constants/api_constants.dart';
import '../../domain/models/chat_message.dart';

class SignalRService {
  HubConnection? _hubConnection;
  bool _isConnected = false;
  String? _accessToken;
  String? _userId;
  bool _isDisposed = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  SharedPreferences? _prefs;

  final StreamController<ChatMessage> _messageReceivedController =
      StreamController<ChatMessage>.broadcast();

  final StreamController<String> _messagesReadController =
      StreamController<String>.broadcast();

  Stream<ChatMessage> get messageReceivedStream =>
      _messageReceivedController.stream;

  Stream<String> get messagesReadStream =>
      _messagesReadController.stream;

  SignalRService({String? accessToken}) {
    _accessToken = accessToken;
    _initPrefs();
  }
  
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Retrieve the latest access token
  Future<String> _getAccessToken() async {
    if (_prefs == null) {
      await _initPrefs();
    }
    
    // Try to get the token from shared preferences first
    final token = _prefs?.getString('access_token') ?? '';
    
    // Update the stored token
    _accessToken = token;
    
    return token;
  }

  Future<void> startChatConnection(String userId) async {
    // Защита от повторного подключения
    if (_isConnected) return;

    // Проверка на dispose
    if (_isDisposed) {
      debugPrint('Попытка использовать SignalRService после dispose');
      return;
    }
    
    _userId = userId;
    _reconnectAttempts = 0;

    try {
      // Ensure we have the latest token
      await _getAccessToken();
      
      _hubConnection = HubConnectionBuilder()
            .withUrl(
            ApiConstants.chatHub,
              options: HttpConnectionOptions(
                accessTokenFactory: () async => await _getAccessToken(),
                skipNegotiation: true,
                transport: HttpTransportType.WebSockets,
              ),
            )
          .withAutomaticReconnect(
            // Настройка стратегии переподключения
            retryDelays: [2000, 5000, 10000, 15000, 30000],
          )
            .build();

      // Настраиваем обработчики событий
      _setupEventHandlers();

      // Запускаем подключение
      await _hubConnection?.start();
      _isConnected = true;
      await _hubConnection?.invoke('JoinChat', args: [userId]);
      
      // Обнуляем счетчик попыток, так как подключение успешно
      _reconnectAttempts = 0;
    } catch (e) {
      _isConnected = false;
      _reconnectAttempts++;
      
      debugPrint('SignalR connection error: $e');
      
      // Пробуем переподключиться, если не превысили лимит попыток
      if (_reconnectAttempts < _maxReconnectAttempts) {
        debugPrint('Attempt to reconnect: $_reconnectAttempts');
        await Future.delayed(Duration(seconds: 2 * _reconnectAttempts));
        return startChatConnection(userId);
      }
      
      rethrow;
    }
  }

  void _setupEventHandlers() {
    // Безопасно устанавливаем обработчики событий
    _hubConnection?.on('ReceiveMessage', _handleReceiveMessage);
    _hubConnection?.on('MessagesRead', _handleMessagesRead);
    
    // Обработчики состояния соединения
    _hubConnection?.onreconnecting(({error}) {
      debugPrint('SignalR reconnecting: $error');
      _isConnected = false;
    });
    
    _hubConnection?.onreconnected(({connectionId}) {
      debugPrint('SignalR reconnected with ID: $connectionId');
      _isConnected = true;
      // Переприсоединяемся к чату после переподключения
      if (_userId != null) {
        _hubConnection?.invoke('JoinChat', args: [_userId!])
          .catchError((e) => debugPrint('Error rejoining chat: $e'));
      }
    });
    
    _hubConnection?.onclose(({error}) {
      debugPrint('SignalR connection closed: $error');
      _isConnected = false;
    });
  }
  
  void _handleReceiveMessage(List<Object?>? arguments) {
    if (_isDisposed) return;
    
    try {
      if (arguments != null && arguments.isNotEmpty && arguments[0] is Map<String, dynamic>) {
        final message = ChatMessage.fromMap(arguments[0] as Map<String, dynamic>);
        _messageReceivedController.add(message);
      }
    } catch (e) {
      debugPrint('Error processing received message: $e');
    }
  }
  
  void _handleMessagesRead(List<Object?>? arguments) {
    if (_isDisposed) return;
    
    try {
      if (arguments != null && arguments.isNotEmpty && arguments[0] is String) {
        final senderId = arguments[0] as String;
        _messagesReadController.add(senderId);
      }
    } catch (e) {
      debugPrint('Error processing messages read: $e');
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    if (_isDisposed) {
      debugPrint('Попытка отправить сообщение через закрытый SignalRService');
      throw Exception('Сервис сообщений недоступен');
    }
    
    if (!_isConnected || _hubConnection == null) {
      debugPrint('Соединение не установлено. Попытка переподключения...');
      try {
        await _reconnectIfNeeded();
        if (!_isConnected) {
          throw Exception('Не удалось установить соединение с сервером');
        }
      } catch (e) {
        debugPrint('Ошибка при попытке переподключения: $e');
        throw Exception('Не удалось подключиться к серверу сообщений');
      }
    }

    try {
      debugPrint('Отправка сообщения получателю: $receiverId');
      await _hubConnection?.invoke('SendMessage', args: [receiverId, message]);
      debugPrint('Сообщение успешно отправлено');
    } catch (e) {
      debugPrint('Ошибка отправки сообщения: $e');
      // Попытка переподключения при ошибке
      try {
        await _reconnectIfNeeded();
        // Повторная попытка отправки после переподключения
        await _hubConnection?.invoke('SendMessage', args: [receiverId, message]);
        debugPrint('Сообщение успешно отправлено после переподключения');
      } catch (retryError) {
        debugPrint('Повторная ошибка отправки сообщения: $retryError');
        throw Exception('Не удалось отправить сообщение. Проверьте подключение к интернету.');
      }
    }
  }

  Future<void> _reconnectIfNeeded() async {
    if (_isDisposed) return;
    
    if (!_isConnected && _userId != null) {
      debugPrint('Attempting to reconnect to SignalR...');
      await startChatConnection(_userId!);
    }
  }

  Future<void> markAsRead(String senderId) async {
    if (_isDisposed) return;
    
    if (!_isConnected || _hubConnection == null) {
      await _reconnectIfNeeded();
    }

    try {
      await _hubConnection?.invoke('MarkAsRead', args: [senderId]);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> stopConnection() async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection?.stop();
      _isConnected = false;
    } catch (e) {
      debugPrint('Error stopping SignalR connection: $e');
    }
  }

  void dispose() {
    _isDisposed = true;
    stopConnection();
    _messageReceivedController.close();
    _messagesReadController.close();
  }
}
