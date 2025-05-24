import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../domain/models/chat_user.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class RecentChatsScreen extends StatefulWidget {
  const RecentChatsScreen({super.key});

  @override
  State<RecentChatsScreen> createState() => _RecentChatsScreenState();
}

class _RecentChatsScreenState extends State<RecentChatsScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Безопасная загрузка пользователей
    _safeLoadUsers();
  }
  
  // Безопасная загрузка пользователей с проверкой mounted
  Future<void> _safeLoadUsers() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Безопасно получаем провайдер
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      // Check if provider is initialized
      if (!chatProvider.isInitialized) {
        await chatProvider.initialize();
      }
      
      await chatProvider.loadUsers();
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          // Локальное состояние загрузки приоритетнее
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (chatProvider.status == ChatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (chatProvider.status == ChatStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ошибка: ${chatProvider.error ?? "Не удалось загрузить данные"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _safeLoadUsers,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          
          // Безопасная проверка на пустой список
          final usersList = chatProvider.users;
          if (usersList.isEmpty) {
            return const Center(child: Text('Нет доступных пользователей'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usersList.length,
            itemBuilder: (context, index) {
              if (index >= usersList.length) {
                // Защита от IndexOutOfBounds
                return const SizedBox.shrink();
              }
              final user = usersList[index];
              return _buildChatItem(context, user, chatProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatUser user, ChatProvider chatProvider) {
    // Проверка на null и пустые строки для безопасности
    final initials = user.initials.isNotEmpty ? user.initials : '?';
    final fullName = user.fullName.isNotEmpty ? user.fullName : 'Пользователь';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Text(
            initials,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(fullName),
        subtitle: const Text('Нажмите, чтобы начать чат'),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.accentColor),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatPartnerId: user.id,
                chatPartnerName: fullName,
              ),
            ),
          );
        },
      ),
    );
  }
} 