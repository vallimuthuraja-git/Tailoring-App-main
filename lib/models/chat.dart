import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  orderStatus,
  productInfo,
  appointment
}

enum SenderType {
  user,
  bot
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final SenderType senderType;
  final String content;
  final MessageType messageType;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.messageType,
    this.metadata,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      senderType: SenderType.values[json['senderType']],
      content: json['content'],
      messageType: MessageType.values[json['messageType']],
      metadata: json['metadata'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderType': senderType.index,
      'content': content,
      'messageType': messageType.index,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    SenderType? senderType,
    String? content,
    MessageType? messageType,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ChatConversation {
  final String id;
  final String userId;
  final String userName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.userId,
    required this.userName,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? (json['lastMessageTime'] as Timestamp).toDate()
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'unreadCount': unreadCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class BotResponse {
  final String message;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final List<String>? quickReplies;

  BotResponse({
    required this.message,
    required this.type,
    this.metadata,
    this.quickReplies,
  });
}

class ChatbotIntent {
  final String intent;
  final List<String> keywords;
  final String response;
  final MessageType responseType;
  final Map<String, dynamic>? metadata;

  ChatbotIntent({
    required this.intent,
    required this.keywords,
    required this.response,
    required this.responseType,
    this.metadata,
  });
}

// Pre-defined chatbot intents for tailoring shop
final List<ChatbotIntent> tailoringChatbotIntents = [
  ChatbotIntent(
    intent: 'greeting',
    keywords: ['hello', 'hi', 'hey', 'good morning', 'good evening', 'namaste', 'assalamualaikum'],
    response: 'Hello! 👋 Welcome to our tailoring shop. How can I help you today?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'order_status',
    keywords: ['order', 'status', 'where', 'tracking', 'progress', 'ready', 'delivery'],
    response: 'I can help you check your order status. Could you please provide your order number?',
    responseType: MessageType.text,
    metadata: {'action': 'request_order_number'},
  ),
  ChatbotIntent(
    intent: 'pricing',
    keywords: ['price', 'cost', 'rate', 'charge', 'fee', 'how much', 'payment'],
    response: 'Our pricing varies depending on the type of garment and complexity. Here are our general rates:\n\n👗 Shirt: ₹1,299 - ₹2,499\n👔 Suit: ₹8,999 - ₹15,999\n👘 Dress: ₹5,999 - ₹12,999\n🧥 Coat: ₹6,999 - ₹13,999\n\nWould you like to see our full catalog?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'delivery_time',
    keywords: ['delivery', 'time', 'when', 'ready', 'pickup', 'collect', 'duration'],
    response: 'Our standard delivery time is 7-10 business days depending on the complexity of your order. Express service (3-5 days) is available for an additional 20% charge. Would you like to place an order?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'measurements',
    keywords: ['measurement', 'size', 'fit', 'body', 'chest', 'waist', 'length', 'shoulder'],
    response: 'Perfect fit starts with accurate measurements! We offer:\n\n📏 Professional measurement service at shop\n📱 Digital measurement guide\n📝 Measurement form for self-measurement\n\nWould you like me to send you our measurement guide?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'alteration',
    keywords: ['alteration', 'alter', 'modify', 'change', 'fix', 'repair', 'adjustment'],
    response: 'We provide expert alteration services for all types of garments:\n\n✂️ Hemming & shortening\n📏 Waist adjustment\n👔 Shoulder fitting\n🔧 Button & zipper repair\n\nStarting from ₹299. Would you like to schedule an alteration service?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'appointment',
    keywords: ['appointment', 'booking', 'visit', 'meet', 'consultation', 'schedule'],
    response: 'I\'d be happy to help you schedule an appointment! Our working hours are:\n\n🕐 Monday - Saturday: 10:00 AM - 8:00 PM\n🕐 Sunday: 11:00 AM - 6:00 PM\n\nWhat day and time works best for you?',
    responseType: MessageType.text,
    metadata: {'action': 'schedule_appointment'},
  ),
  ChatbotIntent(
    intent: 'location',
    keywords: ['location', 'address', 'where', 'find', 'shop', 'store', 'visit'],
    response: '📍 We\'re located at:\n123 Fashion Street\nMG Road, Bangalore - 560001\n\n🗺️ Easy to reach from MG Road Metro Station\n🚗 Ample parking available\n\nWould you like directions?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'materials',
    keywords: ['material', 'fabric', 'cloth', 'quality', 'cotton', 'wool', 'silk', 'linen'],
    response: 'We use premium quality fabrics for all our garments:\n\n👕 Cotton: ₹1,299 - ₹3,999\n🧥 Wool: ₹4,999 - ₹9,999\n✨ Silk: ₹6,999 - ₹15,999\n🌿 Linen: ₹3,999 - ₹8,999\n\nAll materials come with quality guarantee. Would you like to see fabric samples?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'warranty',
    keywords: ['warranty', 'guarantee', 'return', 'exchange', 'refund', 'quality'],
    response: 'We stand behind our quality with comprehensive warranty:\n\n✅ 3 months stitching warranty\n✅ 6 months fabric warranty (premium materials)\n✅ Free alterations within 30 days\n✅ Quality guarantee on all work\n\nYour satisfaction is our priority!',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'thank_you',
    keywords: ['thank you', 'thanks', 'thankyou', 'appreciate', 'grateful'],
    response: 'You\'re very welcome! 😊 It was my pleasure assisting you. Is there anything else I can help you with today?',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'goodbye',
    keywords: ['bye', 'goodbye', 'see you', 'farewell', 'talk later', 'good night'],
    response: 'Goodbye! 👋 Thank you for choosing our tailoring services. We look forward to serving you. Have a wonderful day!',
    responseType: MessageType.text,
  ),
  ChatbotIntent(
    intent: 'help',
    keywords: ['help', 'assist', 'support', 'what can you do', 'options'],
    response: 'I can help you with:\n\n🛍️ Browse our product catalog\n📋 Check order status\n💰 Pricing information\n📅 Schedule appointments\n📏 Measurement guidance\n📍 Location & directions\n🔧 Alteration services\n💬 General inquiries\n\nWhat would you like to know about?',
    responseType: MessageType.text,
  ),
];
