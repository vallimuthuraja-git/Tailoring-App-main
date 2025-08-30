# Home Screen

## Overview
The `home_screen.dart` file implements the main navigation hub and dashboard for the AI-Enabled Tailoring Shop Management System. It provides a role-based interface with tabbed navigation, personalized dashboards, quick actions, and seamless integration with the AI chatbot and other core features. The dashboard now features a gradient background matching the authentication screens for visual consistency.

## Key Features

### Role-Based Dashboard
- **Dynamic UI**: Different interfaces for shop owners vs customers
- **Personalized Experience**: Tailored content based on user role
- **Permission-Aware**: Features shown based on user permissions

### Multi-Tab Navigation
- **Bottom Navigation**: 4 main sections (Dashboard, Products, Orders, Profile)
- **State Preservation**: Maintains tab state during navigation
- **Smooth Transitions**: Seamless switching between tabs

### AI Integration
- **Chatbot Access**: Direct AI assistant integration
- **Smart Recommendations**: Context-aware feature suggestions
- **Automated Workflows**: AI-powered process optimization

### Visual Design Consistency
- **Gradient Background**: Matching authentication screens for visual cohesion
- **Theme Integration**: Seamless adaptation to light/dark/glassy modes
- **Professional Appearance**: Consistent design language across all screens

## Architecture Components

### Main Screen Structure

#### HomeScreen Widget
```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
```

#### State Management
```dart
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardTab(...),
      const ProductCatalogScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];
  }
}
```

### Navigation System

#### Bottom Navigation Implementation
```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  type: BottomNavigationBarType.fixed,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_bag),
      label: 'Products',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long),
      label: 'Orders',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ],
)
```

#### Tab Content Management
- **DashboardTab**: Main dashboard with quick actions
- **ProductCatalogScreen**: Product browsing and selection
- **OrderHistoryScreen**: Order tracking and history
- **ProfileScreen**: User profile and settings

## Dashboard Implementation

### DashboardTab Widget
```dart
class DashboardTab extends StatelessWidget {
  final VoidCallback onNavigateToProducts;
  final VoidCallback onNavigateToOrders;

  const DashboardTab({
    super.key,
    required this.onNavigateToProducts,
    required this.onNavigateToOrders,
  });
}
```

### Gradient Background Design
The dashboard now features a gradient background matching the authentication screens for visual consistency:

```dart
class _DashboardBackground extends StatelessWidget {
  final Widget child;

  const _DashboardBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.isDarkMode
              ? [
                  DarkAppColors.surface,
                  DarkAppColors.background,
                  DarkAppColors.surface.withOpacity(0.8),
                ]
              : [
                  AppColors.surface,
                  AppColors.background,
                  AppColors.surface.withOpacity(0.8),
                ],
        ),
      ),
      child: child,
    );
  }
}
```

### Background Implementation
```dart
@override
Widget build(BuildContext context) {
  return Consumer2<AuthProvider, ThemeProvider>(
    builder: (context, authProvider, themeProvider, child) {
      final isShopOwner = authProvider.isShopOwnerOrAdmin;

      return Scaffold(
        backgroundColor: Colors.transparent, // Allow gradient to show
        body: _DashboardBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Dashboard content with transparent background
                  _buildWelcomeCard(authProvider.userProfile, isShopOwner),
                  // ... rest of dashboard content
                ],
              ),
            ),
          ),
        ),
        // ... bottom navigation
      );
    },
  );
}
```

### Role-Based Rendering
```dart
final isShopOwner = authProvider.isShopOwnerOrAdmin;

return Scaffold(
  appBar: AppBar(...),
  body: SingleChildScrollView(
    child: Column(
      children: [
        // Welcome Card - Role-agnostic
        _buildWelcomeCard(user, isShopOwner),

        // Quick Actions - Role-specific
        if (isShopOwner) ...[
          // Shop Owner Actions
          _buildShopOwnerActions(),
        ] else ...[
          // Customer Actions
          _buildCustomerActions(),
        ],

        // Recent Activity - Common
        _buildRecentActivity(),
      ],
    ),
  ),
);
```

## UI Components

### Welcome Card
```dart
Container(
  decoration: BoxDecoration(
    gradient: themeProvider.isGlassyMode
        ? LinearGradient(colors: [primary.withValues(alpha: 0.8), ...])
        : LinearGradient(colors: [primary, primaryVariant]),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    children: [
      CircleAvatar(
        backgroundImage: user?.photoUrl != null
            ? NetworkImage(user!.photoUrl!)
            : null,
        child: user?.photoUrl == null
            ? Icon(Icons.person, color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
            : null,
      ),
      Expanded(
        child: Column(
          children: [
            Text('Welcome back, ${user?.displayName ?? 'User'}'),
            Text(isShopOwner
                ? 'Manage your tailoring shop efficiently'
                : 'Discover perfect tailoring services'),
          ],
        ),
      ),
    ],
  ),
)
```

### Quick Action Cards
```dart
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: onSurface.withValues(alpha: 0.2)),
          boxShadow: themeProvider.isGlassyMode ? null : [BoxShadow(...)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
```

## Role-Based Features

### Shop Owner Dashboard
#### Quick Actions for Shop Owners
- **Add Product**: Navigate to product creation
- **Manage Stock**: Inventory management interface
- **Customers**: Customer database access
- **Reports**: Analytics and reporting dashboard
- **Demo Setup**: Test data configuration
- **Employee Management**: Staff administration

#### Management Focus
- **Business Operations**: Oversee daily shop activities
- **Inventory Control**: Monitor stock levels and supplies
- **Customer Relations**: Manage client interactions
- **Staff Coordination**: Employee scheduling and management
- **Financial Tracking**: Revenue and expense monitoring

### Customer Dashboard
#### Quick Actions for Customers
- **Browse Products**: Access product catalog
- **My Orders**: View order history and status
- **Favorites**: Saved products and preferences
- **AI Assistant**: Access intelligent customer support

#### Customer Experience
- **Personalized Service**: Tailored recommendations
- **Order Tracking**: Real-time order status updates
- **Easy Reordering**: Quick access to previous orders
- **24/7 Support**: AI-powered customer assistance

## AI Chatbot Integration

### Chatbot Implementation
```dart
void _showChatbot(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
      child: Container(
        width: 400,
        height: 500,
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: primary),
                Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: ListView(
                children: [
                  _ChatBubble(
                    message: "Hello! I'm your AI tailoring assistant...",
                    isUser: false,
                    themeProvider: themeProvider,
                  ),
                ],
              ),
            ),
            // Chat input area
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: onSurface.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Type your message...'),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {}, // Implement send functionality
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

### Chat Bubble Component
```dart
class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isUser
              ? (themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary)
              : (themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(
            color: isUser
                ? (themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary)
                : (themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}
```

## Integration Points

### With Authentication System
- **User Context**: Access to current user profile and role
  - Related: [`lib/providers/auth_provider.dart`](../providers/auth_provider.md)
- **Role-Based UI**: Conditional rendering based on permissions
- **Session Management**: Proper logout and session handling

### With Theme System
- **Dynamic Theming**: Automatic theme adaptation
  - Related: [`lib/providers/theme_provider.dart`](../providers/theme_provider.md)
- **Glassy Mode Support**: Advanced visual effects
- **Color Consistency**: Theme-aware UI components

### With Product Management
- **Product Catalog**: Direct navigation to product browsing
  - Related: [`lib/providers/product_provider.dart`](../providers/product_provider.md)
- **Quick Actions**: Direct product-related operations
- **Favorites System**: Customer product preferences

### With Order Management
- **Order History**: Access to customer order tracking
  - Related: [`lib/providers/order_provider.dart`](../providers/order_provider.md)
- **Order Status**: Real-time order status updates
- **Quick Reordering**: Easy access to reorder functionality

### With AI Chatbot
- **Intelligent Assistance**: Context-aware customer support
- **Product Recommendations**: AI-powered suggestions
- **Order Assistance**: Help with order placement and tracking

### With Employee Management
- **Staff Oversight**: Employee management for shop owners
  - Related: [`lib/screens/employee/employee_management_home.dart`](../employee/employee_management_home.md)
- **Performance Tracking**: Staff productivity monitoring
- **Schedule Management**: Employee scheduling and assignment

## Navigation Flow

### Tab-Based Navigation
```
HomeScreen
├── DashboardTab (Index 0)
│   ├── Welcome Section
│   ├── Quick Actions (Role-based)
│   └── Recent Activity
├── ProductCatalogScreen (Index 1)
│   ├── Product Grid/List
│   ├── Search & Filters
│   └── Product Details
├── OrderHistoryScreen (Index 2)
│   ├── Order List
│   ├── Order Details
│   └── Order Tracking
└── ProfileScreen (Index 3)
    ├── User Information
    ├── Preferences
    └── Settings
```

### Inter-Tab Communication
- **Dashboard → Products**: Direct navigation for product browsing
- **Dashboard → Orders**: Quick access to order history
- **Cross-tab State**: Maintain search and filter states

## Performance Optimizations

### Efficient Rendering
- **Conditional Building**: Only render active tab content
- **Lazy Loading**: Load content on demand
- **State Preservation**: Maintain tab state during navigation

### Memory Management
- **Widget Disposal**: Proper cleanup of unused resources
- **Image Optimization**: Efficient image loading and caching
- **Stream Management**: Proper listener cleanup

## Theme Integration

### Dynamic Styling
```dart
// AppBar theming
AppBar(
  backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
  iconTheme: IconThemeData(
    color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
  ),
)

// Card theming
Container(
  decoration: BoxDecoration(
    color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
    border: Border.all(color: onSurface.withValues(alpha: 0.2)),
    boxShadow: themeProvider.isGlassyMode ? null : [BoxShadow(...)],
  ),
)
```

### Glassmorphism Support
- **Conditional Effects**: Apply glass effects when enabled
- **Performance Consideration**: Skip shadows in glassy mode
- **Adaptive Colors**: Theme-aware transparency and blur

## Accessibility Features

### Screen Reader Support
- **Semantic Labels**: Proper labeling for assistive technologies
- **Navigation Hints**: Clear navigation descriptions
- **Focus Management**: Logical tab order and focus flow

### Visual Accessibility
- **High Contrast**: Sufficient color contrast ratios
- **Large Touch Targets**: Minimum 44px touch areas
- **Clear Typography**: Readable font sizes and weights
- **Icon Clarity**: High-visibility icons for quick actions

## Usage Examples

### Role-Based Dashboard Rendering
```dart
@override
Widget build(BuildContext context) {
  return Consumer2<AuthProvider, ThemeProvider>(
    builder: (context, authProvider, themeProvider, child) {
      final isShopOwner = authProvider.isShopOwnerOrAdmin;

      return Column(
        children: [
          _buildWelcomeCard(authProvider.userProfile, isShopOwner),

          if (isShopOwner) ...[
            _buildShopOwnerQuickActions(),
          ] else ...[
            _buildCustomerQuickActions(),
          ],

          _buildRecentActivity(themeProvider),
        ],
      );
    },
  );
}
```

### Navigation Between Tabs
```dart
// Navigate to Products tab
onNavigateToProducts: () => setState(() => _selectedIndex = 1),

// Navigate to Orders tab
onNavigateToOrders: () => setState(() => _selectedIndex = 2),
```

### Chatbot Integration
```dart
IconButton(
  icon: Icon(Icons.chat),
  onPressed: () => _showChatbot(context),
)
```

## Future Enhancements

### Advanced AI Features
- **Personalized Dashboard**: AI-curated content based on user behavior
- **Predictive Actions**: Anticipated user needs and actions
- **Smart Notifications**: Intelligent alert system
- **Automated Workflows**: AI-driven process automation

### Enhanced User Experience
- **Customizable Dashboard**: User-configurable quick actions
- **Advanced Search**: AI-powered content discovery
- **Gesture Navigation**: Swipe and gesture-based navigation
- **Offline Mode**: Limited functionality without network

### Integration Features
- **Calendar Integration**: Sync with external calendars
- **Notification Center**: Centralized notification management
- **Quick Actions**: Customizable action shortcuts
- **Widget Support**: Home screen widgets for key metrics

---

## Recent Enhancements

### ✅ **Gradient Background Design**
- **Visual Consistency**: Matching gradient background with authentication screens
- **Theme Integration**: Seamless adaptation to light/dark/glassy modes
- **Professional Appearance**: Cohesive design language across all screens
- **Transparent Scaffold**: Allows gradient background to show through
- **Dashboard Background Widget**: Dedicated component for gradient implementation

### ✅ **Enhanced Visual Cohesion**
- **Unified Experience**: Consistent background design throughout the app
- **Brand Consistency**: Matching visual theme across login, signup, forgot password, profile, and dashboard
- **Improved Aesthetics**: Modern gradient design with theme-aware colors

*This comprehensive HomeScreen serves as the central navigation hub for the AI-Enabled Tailoring Shop Management System, providing role-based dashboards, seamless navigation, AI integration, and a personalized user experience that adapts to both shop owners and customers with their unique needs and workflows. The dashboard now features a gradient background matching the authentication screens for enhanced visual consistency.*