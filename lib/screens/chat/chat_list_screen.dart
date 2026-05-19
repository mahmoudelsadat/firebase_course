import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../models/user_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final FirebaseAuth auth = FirebaseAuth.instance;

    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color surfaceColor = Theme.of(context).colorScheme.surface;
    Color accentColor = isLight ? Theme.of(context).primaryColor : const Color(0xFF4ADE80);
    Color textColor = isLight ? Colors.black87 : const Color(0xFFF8FAFC);
    Color textMutedColor = isLight ? Colors.black54 : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<List<UserModel>>(
        stream: chatService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading chats', style: TextStyle(color: Theme.of(context).colorScheme.error)));
          }

          final users = snapshot.data?.where((u) => u.uid != auth.currentUser?.uid).toList() ?? [];

          if (users.isEmpty) {
            return Center(child: Text('No users found.', style: TextStyle(color: textMutedColor)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isLight ? accentColor.withOpacity(0.15) : surfaceColor,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                title: Text(
                  user.name,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  user.role.toString().split('.').last,
                  style: TextStyle(color: textMutedColor, fontSize: 13),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: user.uid,
                        receiverName: user.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}