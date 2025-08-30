# Customer Model

## Overview
The `customer.dart` file defines the core data structures for customer management in the AI-Enabled Tailoring Shop Management System. It provides comprehensive customer profiling with loyalty tiers, measurement tracking, preference management, and complete serialization support for Firebase integration.

## Key Features

### Customer Data Structure
- **Complete Customer Profile**: 13 comprehensive properties defining customer information
- **Loyalty Program**: 4-tier loyalty system (Bronze, Silver, Gold, Platinum)
- **Measurement Management**: Body measurements for tailoring accuracy
- **Preference Tracking**: Customer style and fabric preferences
- **Spending Analytics**: Purchase history and loyalty calculations

### Business Intelligence
- **Loyalty Tier Calculation**: Automated tier assignment based on spending
- **Customer Segmentation**: Active vs inactive customer tracking
- **Spending Analysis**: Total spent and purchase behavior insights
- **Preference Analysis**: Customer style and product preferences

## Architecture Components

### LoyaltyTier Enum

#### Customer Loyalty Levels (4 Tiers)
```dart
enum LoyaltyTier {
  bronze,    // New customers (₹0 - ₹9,999 spent)
  silver,    // Regular customers (₹10,000 - ₹24,999 spent)
  gold,      // Valued customers (₹25,000 - ₹49,999 spent)
  platinum   // VIP customers (₹50,000+ spent)
}
```

#### Tier Benefits and Requirements
- **Bronze**: Entry-level tier, basic benefits, ₹0-₹9,999 spending
- **Silver**: Enhanced benefits, priority service, ₹10,000-₹24,999 spending
- **Gold**: Premium benefits, express service, ₹25,000-₹49,999 spending
- **Platinum**: VIP benefits, dedicated service, ₹50,000+ spending

### Customer Class

#### Core Customer Properties
```dart
class Customer {
  final String id;                           // Unique customer identifier
  final String name;                         // Customer full name
  final String email;                        // Contact email address
  final String phone;                        // Contact phone number
  final String? photoUrl;                    // Profile photo URL
  final Map<String, dynamic> measurements;   // Body measurements
  final List<String> preferences;            // Style/fabric preferences
  final DateTime createdAt;                  // Account creation date
  final DateTime updatedAt;                  // Last profile update
  final double totalSpent;                   // Total spending amount
  final LoyaltyTier loyaltyTier;             // Current loyalty tier
  final bool isActive;                       // Account status
}
```

#### Customer Property Details

**Identity & Contact**
- **`id`**: Firebase document ID for unique identification
- **`name`**: Full customer name (e.g., "Rajesh Kumar")
- **`email`**: Primary contact email for communications
- **`phone`**: Contact phone number with formatting support

**Profile & Media**
- **`photoUrl`**: Optional profile photo for personalization
- **`measurements`**: Body measurements for tailoring accuracy
- **`preferences`**: Style, fabric, and service preferences

**Business Metrics**
- **`totalSpent`**: Lifetime customer value calculation
- **`loyaltyTier`**: Automated tier based on spending patterns
- **`isActive`**: Customer engagement status (active within 6 months)

**Audit Trail**
- **`createdAt`**: Account creation timestamp
- **`updatedAt`**: Last profile modification timestamp

## JSON Serialization

### Customer Serialization
```dart
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
```

## Business Logic

### Loyalty Tier Calculation
```dart
LoyaltyTier get loyaltyTier {
  final spent = totalSpent;
  if (spent >= 50000) return LoyaltyTier.platinum;
  if (spent >= 25000) return LoyaltyTier.gold;
  if (spent >= 10000) return LoyaltyTier.silver;
  return LoyaltyTier.bronze;
}
```

### Customer Activity Tracking
```dart
bool get isActive {
  // Customer is considered active if updated within last 6 months
  return updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 180)));
}
```

### Helper Getters
```dart
String get displayName => name;  // Formatted display name
```

## Measurement Management

### Standard Measurement Categories
```dart
// Upper Body Measurements
'chest': 'Chest circumference around fullest part',
'waist': 'Natural waist circumference',
'shoulder': 'Shoulder seam to shoulder seam',
'backWidth': 'Back width between armholes',

// Lower Body Measurements
'hip': 'Hip circumference at widest point',
'inseam': 'Inner leg length from crotch to ankle',
'outseam': 'Outer leg length from waist to ankle',
'thigh': 'Thigh circumference',

// Neck & Collar Measurements
'neck': 'Neck circumference',
'collarLength': 'Collar length around neck',

// Arms & Sleeves Measurements
'bicep': 'Bicep circumference',
'wrist': 'Wrist circumference',
'sleeveLength': 'Sleeve length from shoulder to wrist',
'armhole': 'Armhole circumference',

// Waist & Hips Measurements
'waist': 'Waist circumference',
'hip': 'Hip circumference',
'seat': 'Seat circumference',

// Length & Fit Measurements
'shirtLength': 'Shirt length from shoulder to bottom',
'trouserLength': 'Trouser length from waist to ankle',
'jacketLength': 'Jacket length from shoulder to bottom',
```

### Measurement Validation
```dart
// Validation ranges for measurements
'chest': {'min': 30.0, 'max': 60.0},
'waist': {'min': 25.0, 'max': 50.0},
'hip': {'min': 30.0, 'max': 55.0},
'neck': {'min': 12.0, 'max': 20.0},
'shoulder': {'min': 14.0, 'max': 24.0},
'sleeveLength': {'min': 20.0, 'max': 40.0},
'inseam': {'min': 25.0, 'max': 40.0},
'outseam': {'min': 30.0, 'max': 50.0},
```

## Customer Segmentation

### Loyalty Tier Distribution
- **Bronze Customers**: New and occasional customers
- **Silver Customers**: Regular customers with established purchase history
- **Gold Customers**: High-value customers with significant spending
- **Platinum Customers**: VIP customers with highest lifetime value

### Activity-Based Segmentation
- **Active Customers**: Recently engaged (within 6 months)
- **Inactive Customers**: Not engaged recently
- **High-Value Customers**: Top spenders regardless of recency
- **Regular Customers**: Consistent purchase patterns

### Preference-Based Segmentation
- **Style Preferences**: Traditional, modern, western, ethnic
- **Fabric Preferences**: Cotton, silk, wool, synthetic blends
- **Service Preferences**: Standard, express, premium, bespoke
- **Category Preferences**: Men's wear, women's wear, kids wear, etc.

## Usage Examples

### Creating a New Customer
```dart
final customer = Customer(
  id: 'customer-001',
  name: 'Rajesh Kumar',
  email: 'rajesh.kumar@email.com',
  phone: '+91-9876543210',
  photoUrl: 'https://example.com/photos/rajesh.jpg',
  measurements: {
    'chest': 40.0,
    'waist': 32.0,
    'shoulder': 18.0,
    'neck': 15.5,
    'sleeveLength': 25.0,
    'inseam': 32.0,
  },
  preferences: ['Men\'s Wear', 'Cotton', 'Business Formal'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  totalSpent: 15000.0,  // This will auto-calculate loyalty tier
);
```

### Customer with Auto-calculated Loyalty Tier
```dart
// Loyalty tier automatically calculated based on totalSpent
final goldCustomer = Customer(
  id: 'customer-002',
  name: 'Priya Sharma',
  email: 'priya.sharma@email.com',
  phone: '+91-9876543211',
  measurements: {
    'chest': 34.0,
    'waist': 28.0,
    'hip': 36.0,
    'shoulder': 14.5,
  },
  preferences: ['Women\'s Wear', 'Silk', 'Traditional', 'Party Wear'],
  createdAt: DateTime.now().subtract(const Duration(days: 180)),
  updatedAt: DateTime.now(),
  totalSpent: 35000.0,  // Will be Gold tier (₹25k-₹49k)
);
```

### Firebase Operations
```dart
// Save to Firebase
await firebaseService.addDocument('customers', customer.toJson());

// Load from Firebase
final doc = await firebaseService.getDocument('customers', 'customer-id');
final customer = Customer.fromJson(doc.data()!);

// Update customer
final updates = {
  'totalSpent': 25000.0,
  'updatedAt': DateTime.now().toIso8601String(),
};
await firebaseService.updateDocument('customers', customer.id, updates);
```

### Customer Segmentation Query
```dart
// Get all Gold tier customers
final goldCustomers = customers.where((c) => c.loyaltyTier == LoyaltyTier.gold);

// Get active customers
final activeCustomers = customers.where((c) => c.isActive);

// Get customers by preference
final cottonLovers = customers.where((c) => c.preferences.contains('Cotton'));
```

## Integration Points

### With Customer Provider
- **State Management**: Customer CRUD operations and real-time updates
  - Related: [`lib/providers/customer_provider.dart`](../../providers/customer_provider.md)
- **Search & Filtering**: Customer discovery and segmentation
- **Analytics Integration**: Customer statistics and insights
- **Profile Management**: Customer information updates and preferences

### With Order Provider
- **Order History**: Customer purchase tracking and history
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Spending Calculation**: Total spent and loyalty tier updates
- **Customer Insights**: Purchase behavior and preferences
- **Order Integration**: Customer data for order processing

### With Analytics Dashboard
- **Customer Metrics**: Analytics dashboard data source
  - Related: [`lib/screens/dashboard/analytics_dashboard_screen.dart`](../../screens/dashboard/analytics_dashboard_screen.md)
- **Segmentation Data**: Customer grouping for business intelligence
- **Performance Tracking**: Customer engagement and retention metrics
- **Revenue Analytics**: Customer lifetime value and spending patterns

### With Authentication Provider
- **User Profile Creation**: Automatic customer profile for new users
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Profile Synchronization**: Auth user data with customer profile
- **Session Management**: Customer context and preferences
- **Account Management**: Customer account status and updates

## Performance Considerations

### Data Efficiency
- **Indexed Enums**: Loyalty tiers stored as integers for query performance
- **Optimized Maps**: Efficient measurement and preference storage
- **Timestamp Management**: ISO string format for Firebase compatibility
- **Minimal Payloads**: Essential data only for faster operations

### Real-time Updates
- **Stream Optimization**: Efficient Firebase document streams
- **Batch Operations**: Bulk customer operations for performance
- **Memory Management**: Efficient state management
- **Caching Strategy**: Customer data caching for performance

## Future Enhancements

### Advanced Customer Features
- **Customer Journey Mapping**: Complete customer lifecycle tracking
- **Personalization Engine**: AI-driven product recommendations
- **Customer Feedback**: Review and rating system integration
- **Social Integration**: Social media profile linking

### Loyalty Program Enhancements
- **Tier Benefits**: Automated benefit application
- **Points System**: Flexible points and rewards management
- **Referral Program**: Customer acquisition incentives
- **Exclusive Offers**: Tier-based promotions and discounts

### Data Management
- **GDPR Compliance**: Data privacy and consent management
- **Data Export**: Customer data export capabilities
- **Backup & Recovery**: Customer data backup systems
- **Audit Trail**: Customer data change tracking

### Integration Features
- **CRM Integration**: Third-party CRM system connectivity
- **Email Marketing**: Automated customer communication
- **Mobile App Sync**: Cross-platform customer data sync
- **Customer Portal**: Self-service customer account management

---

*This Customer model serves as the comprehensive data foundation for the tailoring shop's customer relationship management, providing robust data structures, business logic, and integration capabilities that support personalized service delivery, loyalty programs, and data-driven customer insights.*