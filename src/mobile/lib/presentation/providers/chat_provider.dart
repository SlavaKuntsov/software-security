import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../core/services/chat_service.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_user.dart';
import 'auth_provider.dart';

enum ChatStatus { initial, loading, success, error }

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;
  final AuthProvider _authProvider;

  List<ChatUser> _users = [];
  List<ChatMessage> _messages = [];
  ChatStatus _status = ChatStatus.initial;
  String? _error;
  String? _currentChatPartnerId;
  int _unreadCount = 0;
  bool _isInitialized = false;
  bool _isInitializing = false;

  ChatProvider({
    required ChatService chatService,
    required AuthProvider authProvider,
  })  : _chatService = chatService,
        _authProvider = authProvider;

  List<ChatUser> get users => _users;
  List<ChatMessage> get messages => _messages;
  ChatStatus get status => _status;
  String? get error => _error;
  String? get currentChatPartnerId => _currentChatPartnerId;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;

  // This method should be called explicitly after provider is created
  Future<void> initialize() async {
    // Prevent multiple initialization attempts
    if (_isInitialized || _isInitializing) {
      debugPrint('ChatProvider: уже инициализирован или инициализируется');
      return;
    }
    
    debugPrint('ChatProvider: начало инициализации');
    _isInitializing = true;
    _status = ChatStatus.loading;
    
    // Используем scheduleMicrotask для безопасного вызова notifyListeners
    Future.microtask(() => notifyListeners());
    
    try {
      // Проверяем состояние и получаем пользователя в AuthProvider
      debugPrint('ChatProvider AuthStatus: ${_authProvider.authStatus}');
      
      // Проверяем, аутентифицирован ли пользователь
      // if (_authProvider.authStatus != AuthStatus.authenticated) {
      //   debugPrint('ChatProvider: пользователь не аутентифицирован');
      //   _error = 'Пользователь не аутентифицирован';
      //   _status = ChatStatus.error;
      //   return;
      // }
      
      // Получаем пользователя через новый метод
      final currentUser = await _authProvider.getCurrentUser();
      debugPrint('ChatProvider: получен пользователь из AuthProvider: $currentUser');
      
      // Если пользователь всё еще null после попытки получить его
      if (currentUser == null) {
        debugPrint('ChatProvider: не удалось получить пользователя после запроса');
        _error = 'Не удалось получить данные пользователя';
        _status = ChatStatus.error;
        return;
      }
      
      // Теперь у нас точно есть currentUser
      final userId = currentUser.id;
      debugPrint('ChatProvider: инициализация для пользователя $userId');
      
      try {
        await _chatService.initialize(userId);
        debugPrint('ChatProvider: инициализация чат-сервиса успешна');
        
        // Безопасно настраиваем слушателей
        _setupListeners();
        
        // Update unread count
        await refreshUnreadCount();
        
        _isInitialized = true;
        _status = ChatStatus.success;
        debugPrint('ChatProvider: инициализация завершена успешно');
      } catch (e) {
        debugPrint('ChatProvider: ошибка инициализации чат-сервиса: $e');
        _error = 'Ошибка подключения к серверу: $e';
        _status = ChatStatus.error;
      }
    } catch (e) {
      debugPrint('ChatProvider: ошибка инициализации: $e');
      _error = e.toString();
      _status = ChatStatus.error;
    } finally {
      _isInitializing = false;
      // Используем scheduleMicrotask для безопасного вызова notifyListeners
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> loadUsers() async {
    try {
      _status = ChatStatus.loading;
      // Безопасный вызов notifyListeners
      Future.microtask(() => notifyListeners());
      
      _users = await _chatService.getUsers();
      
      _status = ChatStatus.success;
    } catch (e) {
      _status = ChatStatus.error;
      _error = e.toString();
      debugPrint('Error loading users: $e');
    } finally {
      // Безопасный вызов notifyListeners
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> loadChatHistory(String userId) async {
    try {
      _currentChatPartnerId = userId;
      _status = ChatStatus.loading;
      // Безопасный вызов notifyListeners
      Future.microtask(() => notifyListeners());
      
      await _chatService.getChatHistory(userId);
      
      _status = ChatStatus.success;
    } catch (e) {
      _status = ChatStatus.error;
      _error = e.toString();
      debugPrint('Error loading chat history: $e');
    } finally {
      // Безопасный вызов notifyListeners
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentChatPartnerId == null) {
      debugPrint('ChatProvider: нельзя отправить сообщение - не выбран получатель');
      return;
    }
    
    try {
      // Проверка инициализации и повторная попытка если нужно
      if (!_isInitialized) {
        debugPrint('ChatProvider: попытка инициализации перед отправкой сообщения');
        await initialize();
        
        // Проверяем результат инициализации
        if (!_isInitialized) {
          throw Exception('Не удалось инициализировать чат');
        }
      }
      
      debugPrint('ChatProvider: отправка сообщения...');
      await _chatService.sendMessage(_currentChatPartnerId!, content);
      debugPrint('ChatProvider: сообщение отправлено успешно');
    } catch (e) {
      debugPrint('ChatProvider: ошибка при отправке сообщения: $e');
      _error = e.toString();
      _status = ChatStatus.error;
      // Безопасный вызов notifyListeners
      Future.microtask(() => notifyListeners());
      throw Exception('Ошибка при отправке сообщения: $e');
    }
  }

  Future<void> markMessagesAsRead() async {
    if (_currentChatPartnerId == null) return;
    
    try {
      await _chatService.markMessagesAsRead(_currentChatPartnerId!);
      await refreshUnreadCount();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _chatService.getUnreadCount();
      // Безопасный вызов notifyListeners
      Future.microtask(() => notifyListeners());
    } catch (e) {
      debugPrint('Error refreshing unread count: $e');
    }
  }

  ChatUser? getUserById(String userId) {
    return _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => ChatUser(
        id: userId,
        email: 'Unknown',
        firstName: 'Unknown',
        lastName: 'User',
      ),
    );
  }

  bool isMyMessage(ChatMessage message) {
    final currentUserId = _authProvider.currentUser?.id;
    if (currentUserId == null) return false;
    return message.senderId == currentUserId;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _chatService.dispose();
    }
    super.dispose();
  }

  // Выносим настройку слушателей в отдельный метод
  void _setupListeners() {
    // Listen to new messages - используем безопасное обновление
    _chatService.chatMessagesStream.listen((messages) {
      _messages = messages;
      // Безопасно обновляем UI
      Future.microtask(() => notifyListeners());
    });
    
    // Setup read markers listener - используем безопасное обновление
    _chatService.messagesReadStream.listen((_) {
      // Just trigger refresh when messages are read
      Future.microtask(() => notifyListeners());
    });
  }
} 