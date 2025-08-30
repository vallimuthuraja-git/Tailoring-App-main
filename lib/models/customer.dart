enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum
}

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final Map<String, dynamic> measurements;
  final List<String> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalSpent;
  final LoyaltyTier loyaltyTier;
  final bool isActive;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.measurements,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.totalSpent = 0.0,
    this.loyaltyTier = LoyaltyTier.bronze,
    this.isActive = true,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photoUrl: json['photoUrl'],
      measurements: Map<String, dynamic>.from(json['measurements'] ?? {}),
      preferences: List<String>.from(json['preferences'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
      loyaltyTier: LoyaltyTier.values[json['loyaltyTier'] ?? 0],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'measurements': measurements,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalSpent': totalSpent,
      'loyaltyTier': loyaltyTier.index,
      'isActive': isActive,
    };
  }

  // Helper getters
  String get displayName => name;
}
