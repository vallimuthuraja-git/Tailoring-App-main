import '../models/chat.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../product_data_access.dart';

class ChatbotService {
  final List<ChatbotIntent> _intents = tailoringChatbotIntents;

  // Analyze user message and determine intent
  String _analyzeIntent(String message) {
    final lowerMessage = message.toLowerCase().trim();

    // Check for exact matches first
    for (final intent in _intents) {
      for (final keyword in intent.keywords) {
        if (lowerMessage.contains(keyword)) {
          return intent.intent;
        }
      }
    }

    // If no exact match, check for partial matches
    for (final intent in _intents) {
      for (final keyword in intent.keywords) {
        if (keyword.contains(lowerMessage) || lowerMessage.contains(keyword)) {
          return intent.intent;
        }
      }
    }

    // Check for order number pattern (8 characters, alphanumeric)
    final orderNumberPattern = RegExp(r'\b[a-zA-Z0-9]{8}\b');
    if (orderNumberPattern.hasMatch(lowerMessage)) {
      return 'order_number_provided';
    }

    // Check for phone number pattern
    final phonePattern = RegExp(r'\b\d{10}\b');
    if (phonePattern.hasMatch(lowerMessage)) {
      return 'phone_number_provided';
    }

    return 'unknown';
  }

  // Generate response based on intent
  BotResponse generateResponse(
    String message, {
    String? userId,
    String? userName,
    OrderProvider? orderProvider,
    ProductProvider? productProvider,
  }) {
    final intent = _analyzeIntent(message);
    final lowerMessage = message.toLowerCase().trim();

    switch (intent) {
      case 'greeting':
        final greetingIntent =
            _intents.firstWhere((i) => i.intent == 'greeting');
        return BotResponse(
          message: userName != null
              ? 'Hello $userName! 👋 Welcome to our tailoring shop. How can I help you today?'
              : greetingIntent.response,
          type: greetingIntent.responseType,
          metadata: greetingIntent.metadata,
          quickReplies: [
            'Browse Products',
            'Check Order Status',
            'Get Pricing Info',
            'Book Appointment'
          ],
        );

      case 'order_status':
        return BotResponse(
          message:
              'I can help you check your order status. Could you please provide your order number (8 characters)?',
          type: MessageType.text,
          metadata: {'action': 'request_order_number'},
          quickReplies: ['I need help with order', 'Check different order'],
        );

      case 'order_number_provided':
        final orderNumberPattern = RegExp(r'\b[a-zA-Z0-9]{8}\b');
        final match = orderNumberPattern.firstMatch(lowerMessage);
        if (match != null) {
          final orderNumber = match.group(0)!;
          // This would integrate with order provider to check actual order status
          return BotResponse(
            message: 'Let me check the status of order $orderNumber for you...',
            type: MessageType.orderStatus,
            metadata: {
              'orderNumber': orderNumber,
              'action': 'check_order_status'
            },
          );
        }
        return BotResponse(
          message:
              'I couldn\'t identify the order number. Please provide an 8-character order number.',
          type: MessageType.text,
        );

      case 'pricing':
        final pricingIntent = _intents.firstWhere((i) => i.intent == 'pricing');
        return BotResponse(
          message: pricingIntent.response,
          type: pricingIntent.responseType,
          metadata: pricingIntent.metadata,
          quickReplies: ['View Catalog', 'Get Quote', 'Book Consultation'],
        );

      case 'appointment':
        return BotResponse(
          message:
              'I\'d be happy to help you schedule an appointment! 📅\n\nOur working hours:\n🕐 Monday - Saturday: 10:00 AM - 8:00 PM\n🕐 Sunday: 11:00 AM - 6:00 PM\n\nPlease let me know your preferred date and time.',
          type: MessageType.appointment,
          metadata: {'action': 'schedule_appointment'},
          quickReplies: ['Today', 'Tomorrow', 'This Week', 'Next Week'],
        );

      case 'measurements':
        return BotResponse(
          message:
              'Perfect fit starts with accurate measurements! 📏\n\nWe offer:\n\n🏪 Professional measurement service at shop\n📱 Digital measurement guide\n📝 Measurement form for self-measurement\n\nWhich option would you prefer?',
          type: MessageType.text,
          metadata: {'action': 'provide_measurement_help'},
          quickReplies: [
            'Professional Service',
            'Digital Guide',
            'Measurement Form'
          ],
        );

      case 'help':
        final helpIntent = _intents.firstWhere((i) => i.intent == 'help');
        return BotResponse(
          message: helpIntent.response,
          type: helpIntent.responseType,
          quickReplies: [
            'Browse Products',
            'Check Order Status',
            'Get Pricing',
            'Book Appointment'
          ],
        );

      case 'location':
        final locationIntent =
            _intents.firstWhere((i) => i.intent == 'location');
        return BotResponse(
          message: locationIntent.response,
          type: locationIntent.responseType,
          quickReplies: ['Get Directions', 'Call Shop', 'Book Appointment'],
        );

      default:
        // Try to find the best matching intent
        for (final intentData in _intents) {
          if (intentData.keywords
              .any((keyword) => lowerMessage.contains(keyword))) {
            return BotResponse(
              message: intentData.response,
              type: intentData.responseType,
              metadata: intentData.metadata,
              quickReplies: _generateQuickReplies(intentData.intent),
            );
          }
        }

        // If no match found, provide helpful response
        return BotResponse(
          message:
              'I\'m here to help you with your tailoring needs! 🤗\n\nYou can ask me about:\n\n• Product catalog and pricing\n• Order status and tracking\n• Appointment booking\n• Measurement guidance\n• Alteration services\n• Shop location and hours\n\nWhat would you like to know about?',
          type: MessageType.text,
          quickReplies: [
            'Browse Products',
            'Check Order Status',
            'Get Pricing Info',
            'Book Appointment'
          ],
        );
    }
  }

  List<String> _generateQuickReplies(String intent) {
    switch (intent) {
      case 'pricing':
        return ['View Catalog', 'Get Quote', 'Book Consultation'];
      case 'appointment':
        return ['Today', 'Tomorrow', 'This Week', 'Next Week'];
      case 'measurements':
        return ['Professional Service', 'Digital Guide', 'Measurement Form'];
      case 'location':
        return ['Get Directions', 'Call Shop', 'Book Appointment'];
      default:
        return ['Yes', 'No', 'Tell me more'];
    }
  }

  // Create a new chat message
  ChatMessage createUserMessage({
    required String conversationId,
    required String userId,
    required String content,
    MessageType messageType = MessageType.text,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: userId,
      senderType: SenderType.user,
      content: content,
      messageType: messageType,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }

  // Create a bot response message
  ChatMessage createBotMessage({
    required String conversationId,
    required BotResponse response,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: 'bot',
      senderType: SenderType.bot,
      content: response.message,
      messageType: response.type,
      metadata: response.metadata,
      timestamp: DateTime.now(),
    );
  }

  // Process user message and generate bot response
  Future<List<ChatMessage>> processUserMessage({
    required String conversationId,
    required String userId,
    required String userName,
    required String message,
    OrderProvider? orderProvider,
    ProductProvider? productProvider,
  }) async {
    final userMessage = createUserMessage(
      conversationId: conversationId,
      userId: userId,
      content: message,
    );

    final botResponse = generateResponse(
      message,
      userId: userId,
      userName: userName,
      orderProvider: orderProvider,
      productProvider: productProvider,
    );

    final botMessage = createBotMessage(
      conversationId: conversationId,
      response: botResponse,
    );

    return [userMessage, botMessage];
  }

  // Get conversation suggestions based on context
  List<String> getContextualSuggestions({
    bool hasActiveOrders = false,
    bool hasRecentOrders = false,
    bool isNewUser = true,
  }) {
    final suggestions = <String>[];

    if (isNewUser) {
      suggestions.addAll([
        'What services do you offer?',
        'How much do your services cost?',
        'Can I see your product catalog?',
      ]);
    }

    if (hasActiveOrders) {
      suggestions.addAll([
        'Check my order status',
        'When will my order be ready?',
        'Can I change my order details?',
      ]);
    }

    if (hasRecentOrders) {
      suggestions.addAll([
        'I need alterations on my recent order',
        'Can I place another order?',
        'Do you offer maintenance services?',
      ]);
    }

    suggestions.addAll([
      'Book an appointment',
      'Get measurement guidance',
      'Find your shop location',
    ]);

    return suggestions.take(6).toList(); // Return top 6 suggestions
  }

  // Analyze message sentiment (basic implementation)
  String analyzeSentiment(String message) {
    final positiveWords = [
      'good',
      'great',
      'excellent',
      'amazing',
      'love',
      'perfect',
      'happy',
      'satisfied',
      'thank you',
      'thanks'
    ];
    final negativeWords = [
      'bad',
      'terrible',
      'awful',
      'horrible',
      'angry',
      'disappointed',
      'frustrated',
      'problem',
      'issue',
      'complaint'
    ];

    final lowerMessage = message.toLowerCase();
    int positiveScore = 0;
    int negativeScore = 0;

    for (final word in positiveWords) {
      if (lowerMessage.contains(word)) positiveScore++;
    }

    for (final word in negativeWords) {
      if (lowerMessage.contains(word)) negativeScore++;
    }

    if (positiveScore > negativeScore) return 'positive';
    if (negativeScore > positiveScore) return 'negative';
    return 'neutral';
  }

  // Get customer service escalation keywords
  bool needsHumanEscalation(String message) {
    final escalationKeywords = [
      'speak to human',
      'talk to person',
      'real person',
      'customer service',
      'manager',
      'supervisor',
      'complaint',
      'problem',
      'issue',
      'wrong',
      'mistake',
      'error',
      'refund',
      'return',
      'cancel',
      'urgent',
      'emergency',
    ];

    final lowerMessage = message.toLowerCase();
    return escalationKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  // Generate personalized greeting
  String getPersonalizedGreeting(String userName, {bool isReturning = false}) {
    final timeOfDay = _getTimeOfDay();
    final greeting = isReturning
        ? 'Welcome back, $userName! $timeOfDay'
        : 'Hello $userName! $timeOfDay';

    return '$greeting 👋 How can I assist you with your tailoring needs today?';
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // Get chatbot capabilities description
  String getChatbotCapabilities() {
    return '''
🤖 I'm your AI tailoring assistant and I can help you with:

🛍️ **Product Information**
• Browse our catalog
• Get pricing details
• Learn about materials & fabrics
• Understand customization options

📋 **Order Management**
• Check order status
• Track delivery progress
• Get order updates
• Handle order inquiries

📅 **Appointments & Services**
• Book consultation appointments
• Schedule measurement sessions
• Arrange alteration services
• Set up pickup/delivery

📏 **Measurement Guidance**
• Provide measurement tips
• Explain fitting requirements
• Guide through self-measurement
• Recommend professional services

🏪 **Shop Information**
• Location & directions
• Working hours
• Contact information
• Warranty & guarantee details

💬 **General Support**
• Answer frequently asked questions
• Provide service information
• Help with common issues
• Direct to human support when needed

What would you like to know about?''';
  }
}
