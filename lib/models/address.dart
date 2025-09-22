/// Address model for delivery addresses
class Address {
  final String id;
  final String userId;
  final String label; // e.g., "Home", "Work", "Other"
  final String fullName;
  final String phoneNumber;
  final String streetAddress;
  final String? apartmentNumber;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.streetAddress,
    this.apartmentNumber,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['userId'] as String,
      label: json['label'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      streetAddress: json['streetAddress'] as String,
      apartmentNumber: json['apartmentNumber'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String? ?? 'India',
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'apartmentNumber': apartmentNumber,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullName,
    String? phoneNumber,
    String? streetAddress,
    String? apartmentNumber,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted address for display
  String get formattedAddress {
    final addressParts = [
      if (apartmentNumber != null) apartmentNumber,
      streetAddress,
      city,
      state,
      postalCode,
      country,
    ];
    return addressParts.where((part) => part != null && part.isNotEmpty).join(', ');
  }

  // Get display title for address
  String get displayTitle {
    return '$label${fullName.isNotEmpty ? ' ($fullName)' : ''}';
  }

  // Validation methods
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{8,}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidPostalCode(String postalCode) {
    final postalRegex = RegExp(r'^\d{6}$'); // Indian postal code format
    return postalRegex.hasMatch(postalCode);
  }

  // Empty constructor for form validation
  static Address empty() {
    return Address(
      id: '',
      userId: '',
      label: '',
      fullName: '',
      phoneNumber: '',
      streetAddress: '',
      city: '',
      state: '',
      postalCode: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

// Common address labels
const List<String> commonAddressLabels = ['Home', 'Work', 'Other'];

// Demo addresses for testing
List<Address> demoAddresses = [
  Address(
    id: 'demo-addr-1',
    userId: 'demo-user-1',
    label: 'Home',
    fullName: 'Test User',
    phoneNumber: '+91-9876543210',
    streetAddress: '123 Main Street',
    apartmentNumber: 'Apartment 4B',
    city: 'Mumbai',
    state: 'Maharashtra',
    postalCode: '400001',
    country: 'India',
    isDefault: true,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Address(
    id: 'demo-addr-2',
    userId: 'demo-user-1',
    label: 'Work',
    fullName: 'Test User',
    phoneNumber: '+91-9876543210',
    streetAddress: '456 Business Plaza',
    city: 'Mumbai',
    state: 'Maharashtra',
    postalCode: '400002',
    country: 'India',
    isDefault: false,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
