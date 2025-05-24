// lib/core/services/signalr_service.dart
import 'dart:async';
import 'dart:io';
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

  // Добавляем метод для проверки состояния подключения
  Future<bool> isConnected() async {
    return _isConnected && _hubConnection != null;
  }

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
    
    debugPrint('Using access token: ${token.isEmpty ? "<empty>" : "${token.substring(0, 10)}..."}');
    return token;
  }

  Future<void> startChatConnection(String userId) async {
    // Защита от повторного подключения
    if (_isConnected) {
      debugPrint('SignalRService: соединение уже установлено');
      return;
    }

    // Проверка на dispose
    if (_isDisposed) {
      debugPrint('Попытка использовать SignalRService после dispose');
      throw Exception('Сервис уже уничтожен');
    }
    
    _userId = userId;
    _reconnectAttempts = 0;

    try {
      // Ensure we have the latest token
      final token = await _getAccessToken();
      debugPrint('SignalRService: полученный токен: ${token.isEmpty ? "<пусто>" : "успешно получен"}');
      
      // Настройка для игнорирования ошибок сертификата (только для разработки)
      HttpOverrides.global = new DevHttpOverrides();
      
      final hubUrl = ApiConstants.chatHub;
      debugPrint('SignalRService: попытка подключения к хабу: $hubUrl');
      
      _hubConnection = HubConnectionBuilder()
            .withUrl(
            hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () async {
                  final token = await _getAccessToken();
                  debugPrint('Отправка токена при подключении: ${token.isEmpty ? "<empty>" : "${token.substring(0, 5)}..."}');
                  return token;
                },
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
      debugPrint('SignalRService: запуск подключения...');
      if (_hubConnection == null) {
        throw Exception('HubConnection не был инициализирован');
      }
      
      // Используем Future.timeout вместо метода timeout
      try {
        await Future.value(_hubConnection!.start())
            .timeout(const Duration(seconds: 15));
        debugPrint('SignalRService: подключение к SignalR успешно установлено!');
        _isConnected = true;
        
        debugPrint('SignalRService: вызов JoinChat с userId: $userId');
        await Future.value(_hubConnection!.invoke('JoinChat', args: [userId]))
            .timeout(const Duration(seconds: 10));
        debugPrint('SignalRService: JoinChat успешно вызван');
      } on TimeoutException {
        debugPrint('SignalRService: превышено время операции');
        _isConnected = false;
        throw Exception('Превышено время ожидания операции');
      } on Exception catch (e) {
        debugPrint('SignalRService: ошибка при выполнении start или JoinChat: $e');
        _isConnected = false;
        rethrow;
      }
      
      // Обнуляем счетчик попыток, так как подключение успешно
      _reconnectAttempts = 0;
    } on TimeoutException {
      _isConnected = false;
      _reconnectAttempts++;
      
      debugPrint('SignalRService: превышено время ожидания при подключении');
      
      // Пробуем переподключиться, если не превысили лимит попыток
      if (_reconnectAttempts < _maxReconnectAttempts) {
        debugPrint('SignalRService: повторная попытка подключения: $_reconnectAttempts');
        await Future.delayed(Duration(seconds: 2 * _reconnectAttempts));
        return startChatConnection(userId);
      }
      
      throw Exception('Превышено время ожидания подключения к серверу');
    } catch (e, stackTrace) {
      _isConnected = false;
      _reconnectAttempts++;
      
      debugPrint('SignalRService: ошибка подключения: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Пробуем переподключиться, если не превысили лимит попыток
      if (_reconnectAttempts < _maxReconnectAttempts) {
        debugPrint('SignalRService: повторная попытка подключения: $_reconnectAttempts');
        await Future.delayed(Duration(seconds: 2 * _reconnectAttempts));
        return startChatConnection(userId);
      }
      
      throw Exception('Не удалось подключиться к серверу: $e');
    }
  }

  void _setupEventHandlers() {
    // Безопасно устанавливаем обработчики событий
    debugPrint('Настройка обработчиков событий SignalR');
    _hubConnection?.on('ReceiveMessage', _handleReceiveMessage);
    _hubConnection?.on('MessagesRead', _handleMessagesRead);
    _hubConnection?.on('Connected', (arguments) {
      debugPrint('Получено событие Connected: $arguments');
    });
    
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
      debugPrint('Получено сообщение: $arguments');
      if (arguments != null && arguments.isNotEmpty && arguments[0] is Map<String, dynamic>) {
        final message = ChatMessage.fromMap(arguments[0] as Map<String, dynamic>);
        debugPrint('Обработано сообщение: ${message.content}');
        _messageReceivedController.add(message);
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing received message: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }
  
  void _handleMessagesRead(List<Object?>? arguments) {
    if (_isDisposed) return;
    
    try {
      debugPrint('Получено уведомление о прочтении: $arguments');
      if (arguments != null && arguments.isNotEmpty && arguments[0] is String) {
        final senderId = arguments[0] as String;
        _messagesReadController.add(senderId);
      }
    } catch (e, stackTrace) {
      debugPrint('Error processing messages read: $e');
      debugPrint('Stack trace: $stackTrace');
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
      } catch (e, stackTrace) {
        debugPrint('Ошибка при попытке переподключения: $e');
        debugPrint('Stack trace: $stackTrace');
        throw Exception('Не удалось подключиться к серверу сообщений');
      }
    }

    try {
      debugPrint('Отправка сообщения получателю: $receiverId, содержание: $message');
      await _hubConnection?.invoke('SendMessage', args: [receiverId, message]);
      debugPrint('Сообщение успешно отправлено');
    } catch (e, stackTrace) {
      debugPrint('Ошибка отправки сообщения: $e');
      debugPrint('Stack trace: $stackTrace');
      // Попытка переподключения при ошибке
      try {
        await _reconnectIfNeeded();
        // Повторная попытка отправки после переподключения
        debugPrint('Повторная попытка отправки сообщения после переподключения');
        await _hubConnection?.invoke('SendMessage', args: [receiverId, message]);
        debugPrint('Сообщение успешно отправлено после переподключения');
      } catch (retryError, retryStackTrace) {
        debugPrint('Повторная ошибка отправки сообщения: $retryError');
        debugPrint('Stack trace: $retryStackTrace');
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
      debugPrint('Отмечаем сообщения как прочитанные от: $senderId');
      await _hubConnection?.invoke('MarkAsRead', args: [senderId]);
      debugPrint('Сообщения успешно отмечены как прочитанные');
    } catch (e, stackTrace) {
      debugPrint('Error marking messages as read: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> stopConnection() async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      debugPrint('Остановка SignalR соединения');
      await _hubConnection?.stop();
      _isConnected = false;
      debugPrint('SignalR соединение успешно остановлено');
    } catch (e, stackTrace) {
      debugPrint('Error stopping SignalR connection: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void dispose() {
    debugPrint('Уничтожение SignalRService');
    _isDisposed = true;
    stopConnection();
    _messageReceivedController.close();
    _messagesReadController.close();
    debugPrint('SignalRService успешно уничтожен');
  }
}

// Класс для игнорирования ошибок сертификата (только для разработки)
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
