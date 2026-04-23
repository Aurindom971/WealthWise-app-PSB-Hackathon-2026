import 'package:flutter/material.dart';
import '../../home/widgets/home_navigation_widgets.dart';
import '../../../services/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class SecureWealthAIScreen extends StatefulWidget {
  final VoidCallback onBack;

  const SecureWealthAIScreen({super.key, required this.onBack});

  @override
  State<SecureWealthAIScreen> createState() => _SecureWealthAIScreenState();
}

class _SecureWealthAIScreenState extends State<SecureWealthAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSuggestionTap(String text) {
    setState(() {
      _controller.text = text;
    });
    _handleSendMessage();
  }

  // 🔥 NEW SIMPLIFIED SEND LOGIC
  Future<void> _handleSendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty || _isTyping) return;

    // 1. Add user message to UI
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _controller.clear();
      _isTyping = true;
    });

    // 2. Call Backend AI Chat
    final reply = await AIService.getChatReply(message: userMessage);

    // 3. Add AI reply to UI
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: reply, isUser: false));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: kCard,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: kForest, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'SAGE',
                              style: TextStyle(
                                color: kForest,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: kAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: kAccent.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user_rounded, color: kAccent, size: 10),
                                  SizedBox(width: 3),
                                  Text(
                                    'SECURE',
                                    style: TextStyle(
                                      color: kAccent,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Ask anything about your finances',
                          style: TextStyle(
                            color: kSub,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _messages.isEmpty ? _buildEmptyState() : _buildChatList(),
            ),

            // --- Bottom Controls ---
            Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Suggestion Chips ---
                  if (_messages.isEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _SuggestionChip(
                            text: 'Why was my last transaction risky?',
                            onTap: () => _onSuggestionTap('Why was my last transaction risky?'),
                          ),
                          const SizedBox(width: 10),
                          _SuggestionChip(
                            text: 'How much did I spend this week?',
                            onTap: () => _onSuggestionTap('How much did I spend this week?'),
                          ),
                          const SizedBox(width: 10),
                          _SuggestionChip(
                            text: 'Check my savings',
                            onTap: () => _onSuggestionTap('Check my savings'),
                          ),
                        ],
                      ),
                    ),
                  if (_messages.isEmpty) const SizedBox(height: 16),
                  // --- Input Bar ---
                  Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(29),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (val) => setState(() {}),
                            onSubmitted: (_) => _handleSendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Ask something...',
                              hintStyle: TextStyle(color: kSub, fontSize: 15),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: _handleSendMessage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _controller.text.trim().isNotEmpty 
                                  ? const Color(0xFF2ECC71) 
                                  : (_isTyping ? kAccent.withValues(alpha: 0.5) : const Color(0xFFD1DAD5)),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (_controller.text.trim().isNotEmpty)
                                  BoxShadow(
                                    color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'SAGE may reference your account data to personalize answers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kSub,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kMid.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ai_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'How can I help you today?',
                    style: TextStyle(
                      color: kForest,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You can ask about transactions, security, spending, and more.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        return _buildChatRow(msg);
      },
    );
  }

  Widget _buildChatRow(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isUser) _buildAIAvatar(),
          if (!msg.isUser) const SizedBox(width: 8),
          _buildChatBubble(msg),
        ],
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: kMid,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/ai_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      decoration: BoxDecoration(
        color: msg.isUser ? kForest : kCard,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
          bottomRight: Radius.circular(msg.isUser ? 4 : 18),
        ),
        boxShadow: [
          if (!msg.isUser)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Text(
        msg.text,
        style: TextStyle(
          color: msg.isUser ? Colors.white : kForest,
          fontSize: 14,
          fontWeight: msg.isUser ? FontWeight.w500 : FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAIAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "AI is thinking...",
              style: TextStyle(color: kSub, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: kLightGreenBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: kMid,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
