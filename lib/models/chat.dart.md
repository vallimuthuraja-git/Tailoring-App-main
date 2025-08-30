# Chat Model Documentation

## Overview
The `chat.dart` file contains the comprehensive chat and AI chatbot system for the AI-Enabled Tailoring Shop Management System. It defines the structure for chat conversations, messages, and an intelligent chatbot specifically designed for tailoring shop customer service, supporting real-time communication and automated customer assistance.

## Architecture

### Core Classes
- **`ChatMessage`**: Individual message in a chat conversation
- **`ChatConversation`**: Chat conversation management with metadata
- **`BotResponse`**: AI chatbot response structure
- **`ChatbotIntent`**: Predefined chatbot intent definitions

### Enums
- **`MessageType`**: Types of messages (text, image, order status, etc.)
- **`SenderType`**: Message sender type (user or bot)

## ChatMessage Model

### Properties
- **`id`**: Unique message identifier
- **`conversationId`**: Parent conversation identifier
- **`senderId`**: ID of the message sender
- **`senderType`**: Whether sender is user or bot
- **`content`**: Message content text
- **`messageType`**: Type of message content
- **`metadata`**: Additional structured data (optional)
- **`timestamp`**: Message creation timestamp
- **`isRead`**: Read status flag

### Supported Message Types
```dart
enum MessageType {
  text,         // Plain text messages
  image,        // Image messages
  orderStatus,  // Order status updates
  productInfo,  // Product information
  appointment   // Appointment scheduling
}
```

## ChatConversation Model

### Properties
- **`id`**: Unique conversation identifier
- **`userId`**: ID of the user in conversation
- **`userName`**: Display name of the user
- **`lastMessage`**: Preview of most recent message
- **`lastMessageTime`**: Timestamp of last message
- **`unreadCount`**: Number of unread messages
- **`isActive`**: Conversation active status
- **`createdAt`**: Conversation creation timestamp
- **`updatedAt`**: Last conversation update timestamp

## BotResponse Model

### Properties
- **`message`**: Bot response text
- **`type`**: Response message type
- **`metadata`**: Additional response data (optional)
- **`quickReplies`**: Suggested user reply options (optional)

## ChatbotIntent Model

### Properties
- **`intent`**: Intent identifier (e.g., 'greeting', 'pricing')
- **`keywords`**: Trigger keywords for the intent
- **`response`**: Bot response text
- **`responseType`**: Type of response message
- **`metadata`**: Additional intent data (optional)

## Predefined Chatbot Intents

The system includes 12 comprehensive intents specifically designed for tailoring shop operations:

### 1. Greeting Intent
- **Keywords**: hello, hi, hey, good morning, good evening, namaste, assalamualaikum
- **Response**: Welcoming message with assistance offer

### 2. Order Status Intent
- **Keywords**: order, status, where, tracking, progress, ready, delivery
- **Response**: Requests order number for status lookup
- **Metadata**: Action to request order number

### 3. Pricing Intent
- **Keywords**: price, cost, rate, charge, fee, how much, payment
- **Response**: Comprehensive pricing information for different garments
- **Includes**: Shirt, Suit, Dress, Coat pricing ranges

### 4. Delivery Time Intent
- **Keywords**: delivery, time, when, ready, pickup, collect, duration
- **Response**: Standard and express delivery options with pricing

### 5. Measurements Intent
- **Keywords**: measurement, size, fit, body, chest, waist, length, shoulder
- **Response**: Measurement service options and guidance

### 6. Alteration Intent
- **Keywords**: alteration, alter, modify, change, fix, repair, adjustment
- **Response**: Detailed alteration services and pricing

### 7. Appointment Intent
- **Keywords**: appointment, booking, visit, meet, consultation, schedule
- **Response**: Business hours and scheduling assistance
- **Metadata**: Action to schedule appointment

### 8. Location Intent
- **Keywords**: location, address, where, find, shop, store, visit
- **Response**: Shop address and location details

### 9. Materials Intent
- **Keywords**: material, fabric, cloth, quality, cotton, wool, silk, linen
- **Response**: Fabric types and pricing information

### 10. Warranty Intent
- **Keywords**: warranty, guarantee, return, exchange, refund, quality
- **Response**: Comprehensive warranty and guarantee information

### 11. Thank You Intent
- **Keywords**: thank you, thanks, thankyou, appreciate, grateful
- **Response**: Polite acknowledgment with further assistance offer

### 12. Goodbye Intent
- **Keywords**: bye, goodbye, see you, farewell, talk later, good night
- **Response**: Polite farewell message

### 13. Help Intent
- **Keywords**: help, assist, support, what can you do, options
- **Response**: Comprehensive list of available assistance options

## Firebase Integration

### Data Structure
```json
{
  "id": "msg_123",
  "conversationId": "conv_456",
  "senderId": "user_789",
  "senderType": 0,
  "content": "Hello, I need help with pricing",
  "messageType": 0,
  "metadata": null,
  "timestamp": "Timestamp",
  "isRead": false
}
```

### Collection Structure
- **conversations**: ChatConversation documents
- **messages**: ChatMessage documents (subcollection of conversations)
- **chatbot_intents**: Predefined intent configurations

### Real-time Features
- **Live Conversations**: Real-time conversation updates
- **Message Status**: Read/unread status tracking
- **Typing Indicators**: User typing status (can be extended)
- **Online Status**: User online/offline status

## Usage Examples

### Creating a Chat Message
```dart
final message = ChatMessage(
  id: 'msg_123',
  conversationId: 'conv_456',
  senderId: 'user_789',
  senderType: SenderType.user,
  content: 'Hello, I need help with pricing',
  messageType: MessageType.text,
  timestamp: DateTime.now(),
  isRead: false,
);
```

### Creating a Conversation
```dart
final conversation = ChatConversation(
  id: 'conv_456',
  userId: 'user_789',
  userName: 'John Doe',
  lastMessage: 'Hello, I need help with pricing',
  lastMessageTime: DateTime.now(),
  unreadCount: 0,
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Firebase Operations
```dart
// Save message to Firestore
await FirebaseFirestore.instance
    .collection('conversations')
    .doc(conversationId)
    .collection('messages')
    .doc(message.id)
    .set(message.toJson());

// Get conversation with messages
final conversationDoc = await FirebaseFirestore.instance
    .collection('conversations')
    .doc(conversationId)
    .get();

final messagesQuery = await FirebaseFirestore.instance
    .collection('conversations')
    .doc(conversationId)
    .collection('messages')
    .orderBy('timestamp', descending: false)
    .get();
```

### Chatbot Integration
```dart
// Find matching intent
ChatbotIntent? findIntent(String userMessage) {
  final lowerMessage = userMessage.toLowerCase();

  for (final intent in tailoringChatbotIntents) {
    for (final keyword in intent.keywords) {
      if (lowerMessage.contains(keyword)) {
        return intent;
      }
    }
  }
  return null;
}

// Generate bot response
BotResponse generateBotResponse(ChatbotIntent intent) {
  return BotResponse(
    message: intent.response,
    type: intent.responseType,
    metadata: intent.metadata,
    quickReplies: intent.intent == 'help'
        ? ['Order Status', 'Pricing', 'Appointment', 'Location']
        : null,
  );
}
```

## Integration Points

### Related Components
- **Chat Service**: Manages chat operations and real-time updates
- **Chat Screen**: UI for chat conversations
- **Chatbot Service**: AI chatbot logic and intent processing
- **Order Management**: Order status updates via chat
- **Appointment System**: Appointment scheduling through chat

### Dependencies
- **Firebase Firestore**: Data persistence and real-time subscriptions
- **Cloud Firestore**: Timestamp handling and subcollections
- **Flutter Framework**: UI components and state management

## AI Chatbot Features

### Natural Language Processing
- **Keyword Matching**: Intent recognition through keyword matching
- **Context Awareness**: Maintains conversation context
- **Multi-language Support**: Support for Hindi greetings (namaste)
- **Cultural Sensitivity**: Appropriate responses for different cultures

### Business-Specific Intelligence
- **Tailoring Knowledge**: Comprehensive understanding of tailoring services
- **Pricing Awareness**: Up-to-date pricing information
- **Service Knowledge**: Detailed knowledge of all offered services
- **Location Awareness**: Shop location and directions

### Automated Actions
- **Order Status Checks**: Automated order tracking
- **Appointment Scheduling**: Guided appointment booking
- **Measurement Guidance**: Step-by-step measurement instructions
- **Price Quotes**: Instant pricing information

## Security Considerations

### Data Privacy
- **User Data Protection**: Secure handling of user information
- **Conversation Privacy**: Private conversation data
- **Message Encryption**: Secure message storage
- **Access Control**: User-specific conversation access

### Content Moderation
- **Input Validation**: Message content validation
- **Spam Prevention**: Rate limiting and spam detection
- **Appropriate Content**: Content filtering for business environment
- **Language Detection**: Multi-language support with moderation

## Performance Optimization

### Data Loading Strategies
- **Pagination**: Load messages in chunks for long conversations
- **Lazy Loading**: Load conversation history on demand
- **Caching**: Cache recent conversations and messages
- **Real-time Updates**: Efficient real-time listeners

### Query Optimization
- **Message Indexing**: Efficient message timestamp queries
- **Conversation Filtering**: Fast active conversation queries
- **Unread Count**: Optimized unread message counting
- **Search Functionality**: Full-text search in conversations

## Analytics Integration

### Chat Metrics
- **Conversation Volume**: Number of conversations over time
- **Response Times**: Average response time analysis
- **Intent Frequency**: Most common user intents
- **Conversion Rates**: Chat-to-sale conversion tracking

### User Insights
- **Common Questions**: Frequently asked questions
- **Peak Hours**: Chat activity patterns
- **User Satisfaction**: Chat satisfaction ratings
- **Bot Performance**: AI response effectiveness

## Future Enhancements

### Advanced AI Features
- **Machine Learning**: ML-based intent recognition
- **Sentiment Analysis**: User sentiment detection
- **Personalization**: Personalized responses based on user history
- **Multi-turn Conversations**: Complex multi-step conversations

### Integration Features
- **Voice Support**: Voice message support
- **Video Chat**: Video consultation integration
- **WhatsApp Integration**: WhatsApp Business API integration
- **SMS Integration**: SMS notification system

### Business Intelligence
- **Customer Insights**: Customer behavior analysis from chats
- **Sales Funnel**: Chat contribution to sales process
- **Service Optimization**: Optimize services based on chat data
- **Quality Improvement**: Continuous improvement from chat feedback

This comprehensive chat system provides intelligent customer service automation specifically tailored for the tailoring business, combining traditional chat functionality with AI-powered assistance and seamless integration with the shop's operations and services.