import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wealthwise/features/home/widgets/home_navigation_widgets.dart';
import '../../loans/widgets/loan_header.dart';
import '../../home/screens/notifications_screen.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class RmChatPage extends StatefulWidget {
  const RmChatPage({super.key});

  @override
  State<RmChatPage> createState() => _RmChatPageState();
}

class _RmChatPageState extends State<RmChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello Mr. Kumar, how can I assist you with your accounts or investments today?",
      isMe: false,
      time: "10:02 AM",
    ),
    ChatMessage(
      text: "Hi Rajesh, I wanted to ask about the interest rate changes on Fixed Deposits.",
      isMe: true,
      time: "10:05 AM",
    ),
    ChatMessage(
      text: "Of course! Our current interest rate for a 1-year FD has been increased to 7.1% p.a. for general citizens and 7.6% p.a. for senior citizens.",
      isMe: false,
      time: "10:06 AM",
    ),
    ChatMessage(
      text: "That sounds great, I'll review my options.",
      isMe: true,
      time: "10:07 AM",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Scroll to bottom on initial build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final timeStr = DateFormat('h:mm a').format(DateTime.now());

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMe: true,
        time: timeStr,
      ));
    });
    
    // Allow the list to build then scroll down
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    // Trigger mock relationship manager reply after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      String replyText = "Thank you for the message. I will check the details and get back to you shortly.";
      final lowerText = text.toLowerCase();
      
      if (lowerText.contains("balance") || lowerText.contains("account")) {
        replyText = "Sure, I can help you check your account balance details. Please navigate to the 'Account Details' page or let me know if you want me to fetch a specific statement.";
      } else if (lowerText.contains("loan") || lowerText.contains("borrow") || lowerText.contains("interest")) {
        replyText = "We have attractive loan interest rates starting at 8.5% p.a. for home loans. Let me know if you would like me to arrange a callback from our loan specialist.";
      } else if (lowerText.contains("thank") || lowerText.contains("thanks")) {
        replyText = "You're welcome! Always here to assist you, Mr. Kumar.";
      } else if (lowerText.contains("hi") || lowerText.contains("hello")) {
        replyText = "Hello Mr. Kumar! How can I assist you with your wealth management queries today?";
      }

      final replyTime = DateFormat('h:mm a').format(DateTime.now());
      setState(() {
        _messages.add(ChatMessage(
          text: replyText,
          isMe: false,
          time: replyTime,
        ));
      });
      
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: TopBar(
                onHomeTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onLogoutTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                onNotificationTap: () => showNotifications(context),
              ),
            ),
            LoanHeader(
              title: "",
              subtitle: "Chat with RM",
              icon: Icons.chat_bubble_outline_rounded,
              onBack: () => Navigator.pop(context),
            ),
            
            // Chat Message List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),
            ),

            // Input field
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _textController,
                        style: const TextStyle(color: kInk, fontSize: 15),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: kSub),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: kForest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            BottomNav(
              currentIndex: -1,
              onTap: (i) =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isMe ? kForest : const Color(0xFFF1F4F2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
          border: msg.isMe
              ? null
              : Border.all(color: kMid.withOpacity(0.08), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: msg.isMe ? Colors.white : kForest,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                msg.time,
                style: TextStyle(
                  color: msg.isMe ? Colors.white60 : kSub,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
