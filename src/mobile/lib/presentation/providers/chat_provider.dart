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
    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    
    try {
      if (_authProvider.authStatus == AuthStatus.authenticated && _authProvider.currentUser != null) {
        final userId = _authProvider.currentUser!.id;
        await _chatService.initialize(userId);
        
        // Listen to new messages
        _chatService.chatMessagesStream.listen((messages) {
          _messages = messages;
          notifyListeners();
        });
        
        // Setup read markers listener
        _chatService.messagesReadStream.listen((_) {
          // Just trigger refresh when messages are read
          notifyListeners();
        });
        
        // Update unread count
        await refreshUnreadCount();
        
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error during chat initialization: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> loadUsers() async {
    try {
      _status = ChatStatus.loading;
      notifyListeners();
      
      _users = await _chatService.getUsers();
      
      _status = ChatStatus.success;
    } catch (e) {
      _status = ChatStatus.error;
      _error = e.toString();
      debugPrint('Error loading users: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadChatHistory(String userId) async {
    try {
      _currentChatPartnerId = userId;
      _status = ChatStatus.loading;
      notifyListeners();
      
      await _chatService.getChatHistory(userId);
      
      _status = ChatStatus.success;
    } catch (e) {
      _status = ChatStatus.error;
      _error = e.toString();
      debugPrint('Error loading chat history: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentChatPartnerId == null) return;
    
    try {
      await _chatService.sendMessage(_currentChatPartnerId!, content);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error sending message: $e');
      notifyListeners();
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
      notifyListeners();
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
} 