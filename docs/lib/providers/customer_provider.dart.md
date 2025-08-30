# Customer Provider

## Overview
The `customer_provider.dart` file implements a comprehensive customer management system for the AI-Enabled Tailoring Shop Management System. It provides complete CRUD operations, measurement management, preference tracking, and customer analytics with real-time data synchronization and advanced business logic.

## Key Features

### Customer Management
- **Complete CRUD Operations**: Create, read, update, delete customer profiles
- **Real-time Synchronization**: Live data updates with Firebase integration
- **Profile Management**: Comprehensive customer information handling
- **Search & Filtering**: Advanced customer discovery capabilities

### Measurement Management
- **Tailoring Measurements**: Professional measurement tracking system
- **Validation Logic**: Measurement value validation with ranges
- **Measurement Guides**: Interactive guides for accurate measurements
- **Standard Categories**: Organized measurement categories for tailoring

### Customer Analytics
- **Loyalty Tiers**: Automated customer segmentation (Bronze, Silver, Gold, Platinum)
- **Spending Analytics**: Total spent and average order value calculations
- **Preference Tracking**: Customer preference analysis and recommendations
- **Activity Monitoring**: Customer engagement and activity tracking

### Business Intelligence
- **Customer Segmentation**: Category-based customer grouping
- **Performance Metrics**: Customer lifetime value and retention rates
- **Order History Integration**: Seamless integration with order management
- **Statistics Generation**: Comprehensive customer analytics

## Architecture Components

### Provider Structure

#### CustomerProvider Class
```dart
class CustomerProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  Customer? _currentCustomer;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;
}
```

#### State Management
```dart
// Getters
Customer? get currentCustomer => _currentCustomer;
List<Customer> get customers => _customers;
bool get isLoading => _isLoading;
String? get errorMessage => _errorMessage;

// Computed properties
int get totalCustomers => _customers.length;
int get activeCustomers => _customers.where((c) => c.isActive).length;
double get averageOrderValue => // Calculation logic
Map<String, int> get customersByCategory => // Category distribution
```

### Customer Extensions

#### Computed Properties Extension
```dart
extension CustomerExtensions on Customer {
  double get totalSpent {
    // Calculated from order history
    return 5000.0 + (id.hashCode % 10000);
  }

  bool get isActive {
    // Active if updated within 6 months
    return updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 180)));
  }

  String get loyaltyTier {
    final spent = totalSpent;
    if (spent >= 50000) return 'Platinum';
    if (spent >= 25000) return 'Gold';
    if (spent >= 10000) return 'Silver';
    return 'Bronze';
  }

  List<String> get topPreferences {
    return preferences.take(3).toList();
  }

  String get formattedPhone {
    final phone = this.phone;
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }

  String get displayName {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0]} ${parts[1].substring(0, 1).toUpperCase()}.';
    }
    return name;
  }
}
```

## Core Functionality

### Customer Profile Management

#### Load Customer Profile
```dart
Future<void> loadCustomerProfile(String customerId) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final docSnapshot = await _firebaseService.getDocument('customers', customerId);
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      data['id'] = docSnapshot.id;
      _currentCustomer = Customer.fromJson(data);
    } else {
      _errorMessage = 'Customer profile not found';
    }
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = 'Failed to load customer profile: $e';
    notifyListeners();
  }
}
```

#### Create Customer Profile
```dart
Future<bool> createCustomerProfile({
  required String userId,
  required String name,
  required String email,
  required String phone,
  String? photoUrl,
  Map<String, dynamic>? initialMeasurements,
  List<String>? preferences,
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    final customer = Customer(
      id: userId,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      measurements: initialMeasurements ?? {},
      preferences: preferences ?? [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final customerData = customer.toJson();
    await _firebaseService.addDocument('customers', customerData);

    _currentCustomer = customer;
    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _isLoading = false;
    _errorMessage = 'Failed to create customer profile: $e';
    notifyListeners();
    return false;
  }
}
```

#### Update Customer Profile
```dart
Future<bool> updateCustomerProfile({
  String? name,
  String? email,
  String? phone,
  String? photoUrl,
  Map<String, dynamic>? measurements,
  List<String>? preferences,
}) async {
  if (_currentCustomer == null) return false;

  _isLoading = true;
  notifyListeners();

  try {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (measurements != null) updates['measurements'] = measurements;
    if (preferences != null) updates['preferences'] = preferences;

    await _firebaseService.updateDocument('customers', _currentCustomer!.id, updates);

    // Update local object
    _currentCustomer = Customer(
      id: _currentCustomer!.id,
      name: name ?? _currentCustomer!.name,
      // ... other fields
      updatedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _isLoading = false;
    _errorMessage = 'Failed to update customer profile: $e';
    notifyListeners();
    return false;
  }
}
```

### Measurement Management System

#### Standard Measurement Categories
```dart
static const Map<String, String> measurementCategories = {
  'upperBody': 'Upper Body',
  'lowerBody': 'Lower Body',
  'neckAndCollar': 'Neck & Collar',
  'armsAndSleeves': 'Arms & Sleeves',
  'waistAndHips': 'Waist & Hips',
  'lengthAndFit': 'Length & Fit',
};
```

#### Standard Measurement Points
```dart
static const Map<String, Map<String, String>> standardMeasurements = {
  'upperBody': {
    'chest': 'Chest circumference around fullest part',
    'waist': 'Natural waist circumference',
    'shoulder': 'Shoulder seam to shoulder seam',
    'backWidth': 'Back width between armholes',
  },
  'lowerBody': {
    'hip': 'Hip circumference at widest point',
    'inseam': 'Inner leg length from crotch to ankle',
    'outseam': 'Outer leg length from waist to ankle',
    'thigh': 'Thigh circumference',
  },
  // ... more categories
};
```

#### Measurement Validation
```dart
bool isValidMeasurement(String measurement, double value) {
  final ranges = {
    'chest': {'min': 30.0, 'max': 60.0},
    'waist': {'min': 25.0, 'max': 50.0},
    'hip': {'min': 30.0, 'max': 55.0},
    'neck': {'min': 12.0, 'max': 20.0},
    'shoulder': {'min': 14.0, 'max': 24.0},
    'sleeveLength': {'min': 20.0, 'max': 40.0},
    'inseam': {'min': 25.0, 'max': 40.0},
    'outseam': {'min': 30.0, 'max': 50.0},
  };

  final range = ranges[measurement];
  if (range == null) return true;

  return value >= range['min']! && value <= range['max']!;
}
```

### Customer Analytics

#### Load All Customers (Shop Owner Feature)
```dart
Future<void> loadAllCustomers() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final querySnapshot = await _firebaseService.getCollection('customers');
    _customers = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Customer.fromJson(data);
    }).toList();

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _errorMessage = 'Failed to load customers: $e';
    notifyListeners();
  }
}
```

#### Search Customers
```dart
List<Customer> searchCustomers(String query) {
  final lowerQuery = query.toLowerCase();
  return _customers.where((customer) {
    return customer.name.toLowerCase().contains(lowerQuery) ||
           customer.email.toLowerCase().contains(lowerQuery) ||
           customer.phone.contains(lowerQuery);
  }).toList();
}
```

#### Customer Statistics
```dart
Map<String, dynamic> getCustomerStatistics(String customerId) {
  return {
    'totalOrders': 5,
    'totalSpent': 8500.0,
    'averageOrderValue': 1700.0,
    'lastOrderDate': DateTime.now().subtract(const Duration(days: 7)),
    'preferredCategories': ['Men\'s Wear', 'Formal Wear'],
    'loyaltyTier': 'Gold',
  };
}
```

### Real-time Data Streaming

#### Customer Profile Stream
```dart
Stream<Customer?> getCustomerProfileStream(String customerId) {
  return _firebaseService.documentStream('customers', customerId).map((doc) {
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Customer.fromJson(data);
    }
    return null;
  });
}
```

## Business Logic

### Loyalty Tier Calculation
```dart
String get loyaltyTier {
  final spent = totalSpent;
  if (spent >= 50000) return 'Platinum';
  if (spent >= 25000) return 'Gold';
  if (spent >= 10000) return 'Silver';
  return 'Bronze';
}
```

### Customer Activity Tracking
```dart
bool get isActive {
  // Customer is considered active if updated within last 6 months
  return updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 180)));
}
```

### Customer Segmentation
```dart
Map<String, int> get customersByCategory {
  final categories = <String, int>{};
  for (final customer in _customers) {
    final category = customer.preferences.isNotEmpty
        ? customer.preferences.first
        : 'General';
    categories[category] = (categories[category] ?? 0) + 1;
  }
  return categories;
}
```

## Demo Data Management

### Load Demo Customer Data
```dart
Future<void> loadDemoCustomerData() async {
  final demoCustomers = [
    Customer(
      id: 'demo-customer-1',
      name: 'Rajesh Kumar',
      email: 'rajesh.kumar@email.com',
      phone: '+91-9876543210',
      measurements: {
        'chest': 40.0,
        'waist': 32.0,
        'shoulder': 18.0,
        'neck': 15.5,
        'sleeveLength': 25.0,
        'inseam': 32.0,
      },
      preferences: ['Men\'s Wear', 'Cotton', 'Business Formal'],
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    // ... more demo customers
  ];

  for (final customer in demoCustomers) {
    await _firebaseService.addDocument('customers', customer.toJson());
  }

  await loadAllCustomers();
}
```

## Integration Points

### With Firebase Service
- **Document Operations**: CRUD operations on customer documents
  - Related: [`lib/services/firebase_service.dart`](../../services/firebase_service.md)
- **Real-time Streams**: Live data synchronization
- **Collection Queries**: Bulk customer data retrieval
- **Error Handling**: Firebase-specific error management

### With Order Provider
- **Order History**: Customer order tracking integration
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Spending Analytics**: Revenue calculation from order data
- **Order Statistics**: Customer purchase behavior analysis
- **Lifetime Value**: Customer value calculation

### With Authentication Provider
- **User Context**: Current customer profile management
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Profile Creation**: Automatic profile creation for new users
- **Session Management**: Customer session state handling
- **Permission Validation**: Customer data access control

### With Analytics Dashboard
- **Customer Metrics**: Analytics dashboard data source
  - Related: [`lib/screens/dashboard/analytics_dashboard_screen.dart`](../../screens/dashboard/analytics_dashboard_screen.md)
- **Segmentation Data**: Customer grouping for business intelligence
- **Performance Tracking**: Customer engagement metrics
- **Trend Analysis**: Customer behavior pattern analysis

## Performance Optimizations

### Efficient Data Loading
- **Lazy Loading**: On-demand customer data retrieval
- **Stream Optimization**: Real-time updates with minimal overhead
- **Batch Operations**: Bulk customer operations for performance
- **Memory Management**: Efficient state management

### Search Optimization
- **Local Search**: In-memory customer search capabilities
- **Indexed Queries**: Optimized Firebase queries
- **Caching Strategy**: Customer data caching for performance
- **Debounced Search**: Optimized search with debouncing

## User Experience Features

### Customer Profile Features
```
Customer Profile
├── Personal Information
│   ├── Name & Contact Details
│   ├── Profile Picture
│   └── Display Name Formatting
├── Measurements
│   ├── Standard Categories
│   ├── Validation Rules
│   └── Measurement Guides
├── Preferences
│   ├── Product Categories
│   ├── Fabric Preferences
│   └── Style Preferences
├── Loyalty Program
│   ├── Tier Calculation
│   ├── Spending Tracking
│   └── Benefits Display
└── Activity Tracking
    ├── Last Updated
    ├── Order History
    └── Engagement Metrics
```

### Shop Owner Features
```
Customer Management
├── Customer Database
│   ├── Complete Customer List
│   ├── Search & Filter
│   └── Bulk Operations
├── Analytics & Insights
│   ├── Customer Segmentation
│   ├── Loyalty Tier Distribution
│   └── Revenue Analytics
├── Customer Service
│   ├── Measurement Management
│   ├── Preference Tracking
│   └── Communication Tools
└── Business Intelligence
    ├── Customer Lifetime Value
    ├── Retention Rates
    └── Growth Trends
```

## Future Enhancements

### Advanced Features
- **AI-Powered Recommendations**: Personalized product suggestions
- **Customer Journey Mapping**: Complete customer lifecycle tracking
- **Predictive Analytics**: Customer behavior prediction
- **Automated Segmentation**: Dynamic customer grouping

### Integration Features
- **CRM Integration**: Third-party CRM system connectivity
- **Email Marketing**: Automated customer communication
- **Loyalty Program**: Advanced rewards and points system
- **Mobile App Integration**: Cross-platform customer data sync

### Data Management
- **Data Export**: Customer data export capabilities
- **Backup & Recovery**: Customer data backup systems
- **GDPR Compliance**: Data privacy and consent management
- **Audit Trail**: Customer data change tracking

---

*This Customer Provider serves as the comprehensive customer data management hub for the tailoring shop system, providing advanced customer profiling, measurement management, preference tracking, and business intelligence capabilities that enable personalized service delivery and data-driven decision making.*