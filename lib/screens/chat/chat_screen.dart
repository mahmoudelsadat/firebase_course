import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({super.key, required this.receiverId, required this.receiverName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverId,
        _auth.currentUser!.uid,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color surfaceColor = isLight ? Colors.white : const Color(0xFF1E293B);
    Color accentColor = isLight ? Theme.of(context).primaryColor : const Color(0xFF4ADE80);
    Color textColor = isLight ? Colors.black87 : const Color(0xFFF8FAFC);
    Color textMutedColor = isLight ? Colors.black54 : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildPremiumAppBar(isLight, bgColor, surfaceColor, accentColor, textColor, textMutedColor),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isLight ? Colors.black.withOpacity(0.05) : surfaceColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'TODAY, ${DateFormat('hh:mm a').format(DateTime.now())}',
                style: TextStyle(color: textMutedColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(_auth.currentUser!.uid, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: accentColor));
                }

                final messages = snapshot.data!.docs;
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = messages[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == _auth.currentUser!.uid;
                    Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                    String time = DateFormat('hh:mm a').format(timestamp.toDate());

                    bool isPrescriptionCard = data['message'].toString().contains('[PRESCRIPTION]');
                    String cleanMessage = data['message'].toString().replaceAll('[PRESCRIPTION]', '').trim();

                    return _buildChatBubble(isMe, cleanMessage, time, isPrescriptionCard, isLight, surfaceColor, accentColor, textColor, textMutedColor);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(isLight, bgColor, surfaceColor, accentColor, textColor, textMutedColor),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar(bool isLight, Color bgColor, Color surfaceColor, Color accentColor, Color textColor, Color textMutedColor) {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: accentColor),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isLight ? accentColor.withOpacity(0.15) : surfaceColor,
                child: Text(
                  widget.receiverName[0].toUpperCase(),
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: bgColor, width: 2),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.receiverName,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
              ),
              Text(
                'ACTIVE NOW • CONSULTATION',
                style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: Icon(Icons.videocam_outlined, color: accentColor, size: 26), onPressed: () {}),
        IconButton(icon: Icon(Icons.info_outline, color: accentColor), onPressed: () {}),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: isLight ? Colors.black12 : surfaceColor, height: 1),
      ),
    );
  }

  Widget _buildChatBubble(bool isMe, String message, String time, bool isCard, bool isLight, Color surfaceColor, Color accentColor, Color textColor, Color textMutedColor) {
    if (isCard) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, right: 40),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isLight ? Colors.black12 : surfaceColor),
            boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLight ? accentColor.withOpacity(0.1) : const Color(0xFF0B141A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication, color: accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.isEmpty ? 'Prescription Update' : message, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('1 Tablet Daily • 30 Day Supply', style: TextStyle(color: textMutedColor, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: accentColor.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('READY', style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      );
    }

    Color bubbleColor = isMe ? accentColor : surfaceColor;
    Color bubbleTextColor = isMe ? Colors.white : textColor;
    if (isMe && !isLight) bubbleTextColor = const Color(0xFF064E3B); // Keep dark green text on teal bubble in dark mode

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isLight ? accentColor.withOpacity(0.15) : surfaceColor,
                  child: Text(widget.receiverName[0].toUpperCase(), style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    boxShadow: isLight ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: bubbleTextColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (isMe) Icon(Icons.done_all, size: 14, color: accentColor),
              if (isMe) const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(fontSize: 11, color: textMutedColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isLight, Color bgColor, Color surfaceColor, Color accentColor, Color textColor, Color textMutedColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isLight ? Colors.white : bgColor,
        border: Border(top: BorderSide(color: isLight ? Colors.black12 : surfaceColor, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: textMutedColor),
            onPressed: () {
              _messageController.text = "[PRESCRIPTION] Lisinopril 20mg";
              sendMessage();
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isLight ? const Color(0xFFF5F8FA) : surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isLight ? Colors.black12 : Colors.transparent),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: textColor),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: textMutedColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: isLight ? Colors.white : const Color(0xFF064E3B), size: 22),
            ),
          ),
        ],
      ),
    );
  }
}