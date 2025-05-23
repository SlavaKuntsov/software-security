import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Контакты'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Dummy data
        itemBuilder: (context, index) {
          return _buildContactItem(index);
        },
      ),
    );
  }

  Widget _buildContactItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentColor,
          child: Text(
            'U${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Пользователь ${index + 1}'),
        subtitle: const Text('Онлайн'),
        trailing: IconButton(
          icon: const Icon(Icons.message, color: AppTheme.accentColor),
          onPressed: () {
            // Navigate to chat with this user
          },
        ),
      ),
    );
  }
} 