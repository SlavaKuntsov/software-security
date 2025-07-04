import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../domain/models/chat_user.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Safely load users
    _safeLoadUsers();
  }
  
  Future<void> _safeLoadUsers() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
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
        title: const Text('Контакты'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          // Local loading state takes priority
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
                  Text('Ошибка: ${chatProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _safeLoadUsers,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }
          
          if (chatProvider.users.isEmpty) {
            return const Center(child: Text('Нет доступных пользователей'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chatProvider.users.length,
            itemBuilder: (context, index) {
              final user = chatProvider.users[index];
              return _buildContactItem(context, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, ChatUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Text(
            user.initials,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.fullName),
        subtitle: Text(user.email),
        trailing: IconButton(
          icon: const Icon(Icons.message, color: AppTheme.accentColor),
          onPressed: () {
            // Navigate to chat with this user
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatPartnerId: user.id,
                  chatPartnerName: user.fullName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 