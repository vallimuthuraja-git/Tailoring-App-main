# Chatbot Service Documentation

## Overview
The `chatbot_service.dart` file contains the AI-powered chatbot system for the AI-Enabled Tailoring Shop Management System. It provides intelligent conversation handling, intent recognition, contextual responses, and seamless integration with order management and product catalog systems, offering a sophisticated customer service experience.

## Architecture

### Core Components
- **`ChatbotService`**: Main chatbot service class
- **`Intent Analysis`**: Natural language processing for user intent detection
- **`Response Generation`**: Context-aware response creation
- **`Provider Integration`**: Integration with Order and Product providers
- **`Contextual Intelligence`**: Personalized suggestions and responses

### Key Features
- **Multi-intent Recognition**: Supports 13+ predefined intents for tailoring services
- **Pattern Matching**: Regex-based detection for order numbers and phone numbers
- **Real-time Integration**: Live connection to order and product data
- **Sentiment Analysis**: Basic emotional tone detection
- **Human Escalation**: Automatic detection of complex queries
- **Personalized Responses**: Context-aware, user-specific replies

## Intent Recognition System

### Intent Analysis Engine
```dart
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

  // Check for order number pattern (8 characters, alphanumeric)
  final orderNumberPattern = RegExp(r'\b[a-zA-Z0-9]{8}\b');
  if (orderNumberPattern.hasMatch(lowerMessage)) {
    return 'order_number_provided';
  }

  return 'unknown';
}
```

### Supported Intents
The chatbot recognizes 13+ specialized intents for tailoring services:

#### 1. Greeting Intent
- **Keywords**: hello, hi, hey, good morning, good evening, namaste, assalamualaikum
- **Response**: Personalized greeting with assistance options
- **Features**: Time-based greetings, user name recognition

#### 2. Order Status Intent
- **Keywords**: order, status, where, tracking, progress, ready, delivery
- **Response**: Order number request with tracking guidance
- **Integration**: Connects to OrderProvider for real-time status

#### 3. Pricing Intent
- **Keywords**: price, cost, rate, charge, fee, how much, payment
- **Response**: Comprehensive pricing information for all services
- **Data**: Shirt, Suit, Dress, Coat pricing with tiers

#### 4. Delivery Time Intent
- **Keywords**: delivery, time, when, ready, pickup, collect, duration
- **Response**: Service timeline information with express options
- **Business Logic**: Standard (7-10 days) and express (3-5 days) services

#### 5. Measurements Intent
- **Keywords**: measurement, size, fit, body, chest, waist, length, shoulder
- **Response**: Measurement service options and guidance
- **Services**: Professional, digital guide, and self-measurement options

#### 6. Alteration Intent
- **Keywords**: alteration, alter, modify, change, fix, repair, adjustment
- **Response**: Detailed alteration services with pricing
- **Services**: Hemming, waist adjustment, button repair, zipper repair

#### 7. Appointment Intent
- **Keywords**: appointment, booking, visit, meet, consultation, schedule
- **Response**: Appointment scheduling with business hours
- **Integration**: Calendar and availability checking

#### 8. Location Intent
- **Keywords**: location, address, where, find, shop, store, visit
- **Response**: Shop location with directions and contact info
- **Features**: Parking info, metro station proximity

#### 9. Materials Intent
- **Keywords**: material, fabric, cloth, quality, cotton, wool, silk, linen
- **Response**: Fabric information with pricing ranges
- **Categories**: Cotton, Wool, Silk, Linen with quality tiers

#### 10. Warranty Intent
- **Keywords**: warranty, guarantee, return, exchange, refund, quality
- **Response**: Comprehensive warranty and guarantee information
- **Coverage**: 3 months stitching, 6 months fabric warranty

#### 11. Help Intent
- **Keywords**: help, assist, support, what can you do, options
- **Response**: Complete service overview with all capabilities
- **Features**: Interactive help with quick action buttons

## Response Generation System

### Context-Aware Responses
```dart
BotResponse generateResponse(String message, {
  String? userId,
  String? userName,
  OrderProvider? orderProvider,
  ProductProvider? productProvider,
}) {
  final intent = _analyzeIntent(message);
  final lowerMessage = message.toLowerCase().trim();

  switch (intent) {
    case 'greeting':
      return BotResponse(
        message: userName != null
            ? 'Hello $userName! 👋 Welcome to our tailoring shop...'
            : 'Hello! 👋 Welcome to our tailoring shop...',
        type: MessageType.text,
        quickReplies: ['Browse Products', 'Check Order Status', 'Get Pricing Info'],
      );
  }
}
```

### Quick Reply Generation
```dart
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
```

### Message Creation Methods
```dart
// Create user message
ChatMessage createUserMessage({
  required String conversationId,
  required String userId,
  required String content,
  MessageType messageType = MessageType.text,
  Map<String, dynamic>? metadata,
})

// Create bot response message
ChatMessage createBotMessage({
  required String conversationId,
  required BotResponse response,
})
```

## Advanced AI Features

### Contextual Suggestions
```dart
List<String> getContextualSuggestions({
  bool hasActiveOrders = false,
  bool hasRecentOrders = false,
  bool isNewUser = true,
})
```
Provides intelligent suggestions based on user context:
- **New Users**: Product browsing, pricing, catalog exploration
- **Active Orders**: Status checking, timeline inquiries, modifications
- **Recent Orders**: Alterations, re-orders, maintenance services
- **General**: Appointments, measurements, location services

### Sentiment Analysis
```dart
String analyzeSentiment(String message) {
  final positiveWords = ['good', 'great', 'excellent', 'amazing', 'love', 'perfect'];
  final negativeWords = ['bad', 'terrible', 'awful', 'horrible', 'angry', 'disappointed'];

  // Analyze message and return 'positive', 'negative', or 'neutral'
}
```
- **Positive Detection**: Praise, satisfaction, appreciation keywords
- **Negative Detection**: Complaints, issues, dissatisfaction keywords
- **Neutral Response**: Balanced or unclear sentiment

### Human Escalation Detection
```dart
bool needsHumanEscalation(String message) {
  final escalationKeywords = [
    'speak to human', 'talk to person', 'real person',
    'customer service', 'manager', 'supervisor',
    'complaint', 'problem', 'issue', 'urgent', 'emergency'
  ];
  // Return true if human assistance is needed
}
```
Automatically detects when complex issues require human intervention.

### Personalized Greetings
```dart
String getPersonalizedGreeting(String userName, {bool isReturning = false}) {
  final timeOfDay = _getTimeOfDay(); // Good morning/afternoon/evening
  final greeting = isReturning
      ? 'Welcome back, $userName! $timeOfDay'
      : 'Hello $userName! $timeOfDay';

  return '$greeting 👋 How can I assist you with your tailoring needs today?';
}
```

## Integration Capabilities

### Order Provider Integration
```dart
Future<List<ChatMessage>> processUserMessage({
  required String conversationId,
  required String userId,
  required String userName,
  required String message,
  OrderProvider? orderProvider,    // Real-time order status
  ProductProvider? productProvider, // Product catalog access
}) async {
  // Process message with full context awareness
  final userMessage = createUserMessage(...);
  final botResponse = generateResponse(message,
    userId: userId,
    userName: userName,
    orderProvider: orderProvider,
    productProvider: productProvider,
  );
  final botMessage = createBotMessage(...);

  return [userMessage, botMessage];
}
```

### Real-time Order Status
- **Order Lookup**: Automatic order number detection and status retrieval
- **Live Updates**: Real-time order progress information
- **Status Translation**: User-friendly status explanations
- **Action Integration**: Direct links to order management

### Product Catalog Integration
- **Product Information**: Real-time product data and availability
- **Pricing Updates**: Current pricing information
- **Customization Options**: Available customizations and add-ons
- **Recommendation Engine**: Product suggestions based on user context

## Chatbot Capabilities

### Comprehensive Service Description
```dart
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
```

## Usage Examples

### Basic Chat Interaction
```dart
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatbotService _chatbotService = ChatbotService();

  Future<void> _sendMessage(String message) async {
    final messages = await _chatbotService.processUserMessage(
      conversationId: widget.conversationId,
      userId: widget.userId,
      userName: widget.userName,
      message: message,
      orderProvider: Provider.of<OrderProvider>(context, listen: false),
      productProvider: Provider.of<ProductProvider>(context, listen: false),
    );

    // Add messages to chat UI
    for (final message in messages) {
      await _chatService.saveMessage(message);
    }
  }
}
```

### Contextual Suggestions
```dart
class ChatSuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatbotService = ChatbotService();

    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final suggestions = chatbotService.getContextualSuggestions(
          hasActiveOrders: orderProvider.pendingOrdersCount > 0,
          hasRecentOrders: orderProvider.completedOrdersCount > 0,
          isNewUser: true, // Check user registration date
        );

        return Wrap(
          children: suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              onPressed: () => _sendMessage(suggestion),
            );
          }).toList(),
        );
      },
    );
  }
}
```

### Sentiment-Based Responses
```dart
class SmartChatResponse extends StatelessWidget {
  final String userMessage;
  final ChatbotService chatbotService = ChatbotService();

  @override
  Widget build(BuildContext context) {
    final sentiment = chatbotService.analyzeSentiment(userMessage);
    final needsEscalation = chatbotService.needsHumanEscalation(userMessage);

    if (needsEscalation) {
      return _buildEscalationResponse();
    }

    return _buildSentimentResponse(sentiment);
  }

  Widget _buildSentimentResponse(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Text('😊 I\'m glad you\'re happy with our service!');
      case 'negative':
        return Text('😔 I\'m sorry to hear that. Let me help resolve this issue.');
      default:
        return Text('🤔 How can I assist you today?');
    }
  }
}
```

### Advanced Intent Processing
```dart
class OrderStatusHandler {
  final ChatbotService _chatbotService = ChatbotService();

  Future<String> handleOrderStatusRequest(String message, String userId) async {
    final response = _chatbotService.generateResponse(message, userId: userId);

    if (response.metadata?['action'] == 'check_order_status') {
      final orderNumber = response.metadata?['orderNumber'];
      if (orderNumber != null) {
        // Fetch actual order status from provider
        final orderStatus = await _getOrderStatus(orderNumber, userId);
        return 'Your order $orderNumber is currently: $orderStatus';
      }
    }

    return response.message;
  }
}
```

## Integration Points

### Related Components
- **Chat Model**: Core message and conversation data structures
- **Order Provider**: Real-time order status and management
- **Product Provider**: Product catalog and pricing information
- **Chat Screen**: User interface for chatbot interaction
- **Notification Service**: Chat-based notifications and updates

### Dependencies
- **Chat Model**: Message and conversation structures
- **Order Provider**: Order data and status integration
- **Product Provider**: Product information and catalog access
- **Flutter Framework**: UI integration and state management

## Performance Optimization

### Message Processing
- **Intent Caching**: Cache frequently matched intents
- **Response Templates**: Pre-built response templates for common queries
- **Async Processing**: Non-blocking message processing
- **Memory Management**: Efficient cleanup of chat history

### Context Awareness
- **User Session Tracking**: Maintain conversation context
- **Preference Learning**: Learn user preferences over time
- **Response Personalization**: Tailored responses based on user history
- **Smart Suggestions**: Context-relevant suggestion generation

## Security Considerations

### Data Privacy
- **User Data Protection**: Secure handling of personal information
- **Conversation Privacy**: Private chat data management
- **Order Security**: Secure order number validation
- **Access Control**: User-specific conversation access

### Content Safety
- **Input Validation**: Message content validation and sanitization
- **Spam Detection**: Automated spam and abuse detection
- **Appropriate Content**: Business-appropriate responses only
- **Escalation Security**: Secure human escalation processes

## Business Logic

### Customer Service Automation
- **24/7 Availability**: Always-on customer support
- **Instant Responses**: Immediate answers to common questions
- **Guided Experience**: Step-by-step assistance for complex tasks
- **Seamless Escalation**: Smooth transition to human support when needed

### Sales and Marketing Integration
- **Product Promotion**: Intelligent product recommendations
- **Service Upselling**: Contextual service suggestions
- **Appointment Booking**: Direct appointment scheduling
- **Customer Retention**: Personalized follow-up and support

### Operational Efficiency
- **Query Automation**: Handle routine inquiries automatically
- **Data Collection**: Gather customer preferences and feedback
- **Analytics Integration**: Chat performance and effectiveness metrics
- **Quality Assurance**: Consistent service quality across interactions

This comprehensive chatbot service provides intelligent, context-aware customer service automation specifically designed for the tailoring business, combining natural language processing with deep integration into the shop's operations and customer data systems.