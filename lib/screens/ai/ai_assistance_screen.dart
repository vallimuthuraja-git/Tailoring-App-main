import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:async';
import '../../models/chat.dart';
import '../../services/chatbot_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class AIAssistanceScreen extends StatefulWidget {
  const AIAssistanceScreen({super.key});

  @override
  State<AIAssistanceScreen> createState() => _AIAssistanceScreenState();
}

class _AIAssistanceScreenState extends State<AIAssistanceScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final String _conversationId =
      DateTime.now().millisecondsSinceEpoch.toString();

  late ChatbotService _chatbotService;
  bool _isTyping = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _chatbotService = ChatbotService();

    // Add initial greeting from bot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    if (!mounted || _isInitialized) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userProfile?.displayName ?? 'User';

    final greetingMessage = _chatbotService.generateResponse(
      'hello',
      userId: authProvider.userProfile?.id ?? 'guest',
      userName: userName,
    );

    final botMessage = _chatbotService.createBotMessage(
      conversationId: _conversationId,
      response: greetingMessage,
    );

    setState(() {
      _messages.add(botMessage);
      _isInitialized = true;
    });

    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isTyping = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userProfile?.id ?? 'guest';
    final userName = authProvider.userProfile?.displayName ?? 'User';

    final userMessage = _chatbotService.createUserMessage(
      conversationId: _conversationId,
      userId: userId,
      content: text,
    );

    setState(() {
      _messages.add(userMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 500));

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    final messages = await _chatbotService.processUserMessage(
      conversationId: _conversationId,
      userId: userId,
      userName: userName,
      message: text,
      orderProvider: orderProvider,
      productProvider: productProvider,
    );

    setState(() {
      _messages.add(messages[1]); // Add bot response
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _handleQuickReply(String reply) {
    _sendMessage(reply);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ThemeProvider, OrderProvider>(
      builder: (context, authProvider, themeProvider, orderProvider, child) {
        // Screen width available for future responsive features

        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Assistant'),
            toolbarHeight: kToolbarHeight + 5,
            backgroundColor: themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
            elevation: 0,
            iconTheme: IconThemeData(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
            titleTextStyle: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface
                      : AppColors.onSurface,
                ),
                onPressed: () =>
                    _showCapabilitiesDialog(context, _chatbotService),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.isDarkMode
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DarkAppColors.background,
                        DarkAppColors.surface.withValues(alpha: 0.8),
                        DarkAppColors.primary.withValues(alpha: 0.1),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.05),
                        AppColors.background,
                        AppColors.secondary.withValues(alpha: 0.05),
                      ],
                    ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Quick Action Buttons
                  _buildQuickActions(context, themeProvider),

                  // Messages List
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: themeProvider.isGlassyMode
                            ? [
                                BoxShadow(
                                  color: (themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black)
                                      .withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: themeProvider.isGlassyMode
                              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: themeProvider.isGlassyMode
                                  ? (themeProvider.isDarkMode
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.2))
                                  : (themeProvider.isDarkMode
                                      ? DarkAppColors.surface
                                          .withValues(alpha: 0.95)
                                      : AppColors.surface
                                          .withValues(alpha: 0.95)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: themeProvider.isDarkMode
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: _messages.isEmpty
                                ? _buildWelcomeMessage(themeProvider)
                                : _buildMessagesList(themeProvider),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Typing Indicator
                  if (_isTyping) _buildTypingIndicator(themeProvider),

                  // Message Input
                  _buildMessageInput(context, themeProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeProvider themeProvider) {
    final quickActions = [
      {
        'icon': Icons.shopping_bag,
        'label': 'Browse Products',
        'action': 'show me your products'
      },
      {
        'icon': Icons.receipt,
        'label': 'Order Status',
        'action': 'check my order status'
      },
      {
        'icon': Icons.schedule,
        'label': 'Book Appointment',
        'action': 'schedule an appointment'
      },
      {
        'icon': Icons.straighten,
        'label': 'Measurements',
        'action': 'help with measurements'
      },
    ];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () => _handleQuickReply(action['action'] as String),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary.withValues(alpha: 0.9)
                    : AppColors.primary.withValues(alpha: 0.9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action['icon'] as IconData, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeMessage(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              size: 48,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI Tailoring Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about our tailoring services!',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground.withValues(alpha: 0.7)
                  : AppColors.onBackground.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ThemeProvider themeProvider) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message.senderType == SenderType.user;

        return _buildMessageBubble(message, isUser, themeProvider);
      },
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, bool isUser, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    : (themeProvider.isDarkMode
                        ? DarkAppColors.surface.withValues(alpha: 0.8)
                        : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: !isUser
                    ? Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.shade200,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (themeProvider.isDarkMode
                              ? DarkAppColors.onSurface
                              : AppColors.onSurface),
                    ),
                  ),
                  if (message.metadata != null &&
                      message.metadata!['quickReplies'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (message.metadata!['quickReplies'] as List<String>)
                                .map((reply) {
                          return ElevatedButton(
                            onPressed: () => _handleQuickReply(reply),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeProvider.isDarkMode
                                  ? DarkAppColors.surface.withValues(alpha: 0.8)
                                  : Colors.grey.shade100,
                              foregroundColor: themeProvider.isDarkMode
                                  ? DarkAppColors.onSurface
                                  : AppColors.onSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                            child: Text(
                              reply,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 16,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.surface.withValues(alpha: 0.8)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'AI is typing',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface
                        : AppColors.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  child: Row(
                    children: List.generate(3, (index) {
                      return Container(
                        width: 2,
                        height: 2,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface.withValues(alpha: 0.95)
            : AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything about tailoring...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                      : AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface
                    : AppColors.onSurface,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
            onPressed: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }

  void _showCapabilitiesDialog(
      BuildContext context, ChatbotService chatbotService) {
    final capabilities = chatbotService.getChatbotCapabilities();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Assistant Capabilities'),
        content: SingleChildScrollView(
          child: Text(capabilities),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
