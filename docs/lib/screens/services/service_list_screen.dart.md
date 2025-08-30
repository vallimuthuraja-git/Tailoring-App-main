# Service List Screen

## Overview
The `service_list_screen.dart` file implements a comprehensive service management interface for the AI-Enabled Tailoring Shop Management System. It provides shop owners with advanced tools to view, manage, and analyze their service offerings with sophisticated filtering, search capabilities, and real-time statistics.

## Key Features

### Advanced Service Management
- **Role-Based Access Control**: Restricted to shop owners and administrators
- **Real-time Search**: Instant service search with live filtering
- **Multi-criteria Filtering**: Filter by category, type, and active status
- **Service Analytics**: Live statistics and performance metrics
- **Offline Sync**: Server synchronization with visual indicators

### Service Portfolio Overview
- **Comprehensive Service Cards**: Detailed service information display
- **Visual Status Indicators**: Active/inactive status with color coding
- **Category-Based Organization**: Color-coded categories with icons
- **Performance Metrics**: Ratings, pricing, and booking statistics
- **Feature Highlights**: Key service features and complexity levels

### Business Intelligence
- **Real-time Statistics**: Total services, active count, revenue, bookings
- **Performance Tracking**: Service popularity and usage metrics
- **Revenue Analytics**: Financial performance indicators
- **Service Health**: Active vs inactive service ratios

## Architecture Components

### Main Widget Structure

#### ServiceListScreen Widget
```dart
class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}
```

#### State Management
```dart
class _ServiceListScreenState extends State<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ServiceCategory? _selectedCategoryFilter;
  ServiceType? _selectedTypeFilter;
  bool? _activeStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }
}
```

### Role-Based Access Control
```dart
@override
Widget build(BuildContext context) {
  return RoleBasedRouteGuard(
    requiredRole: auth.UserRole.shopOwner,
    child: Scaffold(
      // Service management interface - shop owner only
    ),
  );
}
```

### Service Loading with Offline Support
```dart
Future<void> _loadServices() async {
  final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
  await serviceProvider.loadServices();

  // If no services exist, load demo data
  if (serviceProvider.services.isEmpty) {
    await serviceProvider.loadDemoData();
  }
}
```

## Search and Filter System

### Enhanced Search Interface
```dart
Widget _buildSearchAndFilters() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search services...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onChanged: (value) {
            final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
            serviceProvider.searchServices(value);
          },
        ),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                label: 'Category',
                value: _selectedCategoryFilter?.name ?? 'All',
                onTap: () => _showCategoryFilterDialog(),
              ),
              // Additional filter chips...
            ],
          ),
        ),
      ],
    ),
  );
}
```

### Filter Chip Implementation
```dart
Widget _buildFilterChip({required String label, required String value, required VoidCallback onTap}) {
  return FilterChip(
    label: Text('$label: $value'),
    selected: false,
    onSelected: (_) => onTap(),
    avatar: Icon(
      label == 'Category' ? Icons.category :
      label == 'Type' ? Icons.build :
      Icons.toggle_on,
      size: 16,
    ),
  );
}
```

## Statistics Overview

### Real-time Statistics Dashboard
```dart
Widget _buildStatsOverview() {
  return Consumer<ServiceProvider>(
    builder: (context, serviceProvider, child) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _buildStatChip(
              '${serviceProvider.services.length}',
              'Total Services',
              Icons.business,
              Colors.blue,
            ),
            _buildStatChip(
              '${serviceProvider.activeServices.length}',
              'Active',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatChip(
              '\$${serviceProvider.totalRevenue.toStringAsFixed(0)}',
              'Revenue',
              Icons.attach_money,
              Colors.amber,
            ),
            _buildStatChip(
              '${serviceProvider.totalBookings}',
              'Bookings',
              Icons.book_online,
              Colors.purple,
            ),
          ],
        ),
      );
    },
  );
}
```

### Statistics Chip Component
```dart
Widget _buildStatChip(String value, String label, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

## Service Card Design

### Comprehensive Service Card
```dart
Widget _buildServiceCard(Service service) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceHeader(service),
            _buildServiceFeatures(service),
            _buildServiceStats(service),
          ],
        ),
      ),
    ),
  );
}
```

### Service Header with Visual Elements
```dart
Row(
  children: [
    // Service Icon/Avatar
    Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getServiceColor(service.category).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getServiceColor(service.category).withOpacity(0.3),
        ),
      ),
      child: Icon(
        _getServiceIcon(service.category),
        color: _getServiceColor(service.category),
      ),
    ),
    const SizedBox(width: 12),

    // Service Info
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            service.shortDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getServiceColor(service.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service.categoryName,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getServiceColor(service.category),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: service.isActive ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 10,
                    color: service.isActive ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),

    // Price and Rating
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${service.effectivePrice.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star, size: 14, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              service.averageRating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    ),
  ],
)
```

### Service Features Display
```dart
if (service.features.isNotEmpty) ...[
  Text(
    'Key Features:',
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.grey[700],
    ),
  ),
  const SizedBox(height: 4),
  Wrap(
    spacing: 6,
    runSpacing: 4,
    children: service.features.take(3).map((feature) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          feature,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[700],
          ),
        ),
      );
    }).toList(),
  ),
  if (service.features.length > 3) ...[
    Text(
      '+${service.features.length - 3} more features',
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[600],
      ),
    ),
  ],
]
```

### Service Statistics
```dart
Row(
  children: [
    Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          service.durationText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
    const SizedBox(width: 16),
    Row(
      children: [
        Icon(Icons.build, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          service.complexityText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
    const Spacer(),
    if (service.isPopular) ...[
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Popular',
          style: TextStyle(
            fontSize: 10,
            color: Colors.amber[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ],
)
```

## Advanced Filtering System

### Category Filter Dialog
```dart
void _showCategoryFilterDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Filter by Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ServiceCategory.values.map((category) {
          return ListTile(
            title: Text(category.name),
            leading: Icon(
              category == _selectedCategoryFilter
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            onTap: () {
              setState(() {
                _selectedCategoryFilter = category;
              });
              final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
              serviceProvider.filterByCategory(category);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCategoryFilter = null;
            });
            final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
            serviceProvider.filterByCategory(null);
            Navigator.pop(context);
          },
          child: const Text('Clear Filter'),
        ),
      ],
    ),
  );
}
```

### Type Filter Dialog
```dart
void _showTypeFilterDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Filter by Type'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ServiceType.values.map((type) {
            return ListTile(
              title: Text(type.name),
              leading: Icon(
                type == _selectedTypeFilter
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _selectedTypeFilter = type;
                });
                final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
                serviceProvider.filterByType(type);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    ),
  );
}
```

### Status Filter Dialog
```dart
void _showStatusFilterDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Filter by Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('All'),
            leading: Icon(
              _activeStatusFilter == null
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            onTap: () {
              setState(() {
                _activeStatusFilter = null;
              });
              final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
              serviceProvider.filterByActiveStatus(null);
              Navigator.pop(context);
            },
          ),
          // Active/Inactive filter options...
        ],
      ),
    ),
  );
}
```

## Category and Visual Design

### Service Category Color System
```dart
Color _getServiceColor(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.sareeServices:
      return Colors.pink;
    case ServiceCategory.garmentServices:
      return Colors.blue;
    case ServiceCategory.alterationServices:
      return Colors.green;
    case ServiceCategory.customDesign:
      return Colors.purple;
    case ServiceCategory.consultation:
      return Colors.orange;
    case ServiceCategory.measurements:
      return Colors.teal;
    case ServiceCategory.specialOccasion:
      return Colors.red;
    case ServiceCategory.corporateWear:
      return Colors.indigo;
    case ServiceCategory.uniformServices:
      return Colors.brown;
    case ServiceCategory.bridalServices:
      return Colors.deepPurple;
  }
}
```

### Service Category Icon System
```dart
IconData _getServiceIcon(ServiceCategory category) {
  switch (category) {
    case ServiceCategory.sareeServices:
      return Icons.woman;
    case ServiceCategory.garmentServices:
      return Icons.checkroom;
    case ServiceCategory.alterationServices:
      return Icons.content_cut;
    case ServiceCategory.customDesign:
      return Icons.design_services;
    case ServiceCategory.consultation:
      return Icons.chat;
    case ServiceCategory.measurements:
      return Icons.straighten;
    case ServiceCategory.specialOccasion:
      return Icons.celebration;
    case ServiceCategory.corporateWear:
      return Icons.business;
    case ServiceCategory.uniformServices:
      return Icons.school;
    case ServiceCategory.bridalServices:
      return Icons.diamond;
  }
}
```

## Error Handling and Loading States

### Loading State
```dart
if (serviceProvider.isLoading) {
  return const Center(
    child: CircularProgressIndicator(),
  );
}
```

### Error State
```dart
if (serviceProvider.errorMessage != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(
          'Error loading services',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          serviceProvider.errorMessage!,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loadServices,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
```

### Empty State
```dart
if (services.isEmpty) {
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.business_center, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'No services found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        SizedBox(height: 8),
        Text(
          'Add your first service to get started',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}
```

## Offline Sync Functionality

### Sync Indicator
```dart
Consumer<ServiceProvider>(
  builder: (context, provider, child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        icon: Icon(
          Icons.sync,
          color: provider.isLoading ? Colors.orange : Colors.green,
        ),
        onPressed: provider.isLoading ? null : _loadServices,
        tooltip: 'Sync with server',
      ),
    );
  },
)
```

### Service Loading Logic
```dart
Future<void> _loadServices() async {
  final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
  await serviceProvider.loadServices();

  // Handle offline/demo data fallback
  if (serviceProvider.services.isEmpty) {
    await serviceProvider.loadDemoData();
  }
}
```

## Action Components

### Role-Based Action Buttons
```dart
RoleBasedWidget(
  requiredRole: auth.UserRole.shopOwner,
  child: IconButton(
    icon: const Icon(Icons.add_business),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ServiceCreateScreen(),
        ),
      );
    },
    tooltip: 'Add Service',
  ),
)
```

```dart
floatingActionButton: RoleBasedWidget(
  requiredRole: auth.UserRole.shopOwner,
  child: FloatingActionButton.extended(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ServiceCreateScreen(),
        ),
      );
    },
    icon: const Icon(Icons.add_business),
    label: const Text('Add Service'),
  ),
)
```

## Integration Points

### With Service Provider
- **Data Management**: Centralized service data handling
  - Related: [`lib/providers/service_provider.dart`](../../providers/service_provider.md)
- **Search & Filter**: Advanced query capabilities
- **Real-time Updates**: Live service data synchronization
- **Offline Support**: Demo data loading and sync management

### With Authentication Provider
- **User Context**: Role-based access and UI adaptation
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Permission Validation**: Shop owner vs customer features
- **Session Management**: Secure user context handling

### With Navigation System
- **Screen Transitions**: Seamless navigation to service details
- **State Preservation**: Maintain search and filter state
- **Deep Linking**: Direct access to specific services
- **Role-Based Routing**: Conditional navigation based on permissions

## Performance Optimizations

### Efficient Rendering
- **Conditional Card Display**: Only show relevant service information
- **Lazy Loading**: On-demand service data loading
- **Minimal Rebuilds**: Targeted widget updates
- **Memory Management**: Proper resource disposal

### State Management
- **Provider Integration**: Centralized state access
- **Real-time Updates**: Live data synchronization
- **Search Optimization**: Efficient search algorithms
- **Filter Caching**: Cached filter results

## User Experience Features

### Service Information Hierarchy
```
Service Card
├── Header Section
│   ├── Category Icon & Color
│   ├── Service Name & Description
│   ├── Category & Status Badges
│   └── Price & Rating
├── Features Section
│   ├── Key Features (up to 3)
│   └── "More features" indicator
└── Statistics Section
    ├── Duration & Complexity
    └── Popularity Badge
```

### Shop Owner Workflow
```
Service Management
├── View Service Portfolio
│   ├── Search & Filter Services
│   ├── View Statistics Dashboard
│   └── Monitor Service Health
├── Service Operations
│   ├── Add New Service
│   ├── Edit Existing Services
│   └── View Service Details
└── Business Analytics
    ├── Track Revenue & Bookings
    ├── Monitor Service Popularity
    └── Manage Service Lifecycle
```

### Visual Design System
- **Category-Based Colors**: Consistent color coding across categories
- **Status Indicators**: Clear active/inactive status visualization
- **Rating System**: Star-based rating display
- **Price Highlighting**: Prominent price display with currency
- **Feature Tags**: Organized feature presentation
- **Statistics Chips**: Compact metrics display

## Future Enhancements

### Advanced Features
- **Bulk Operations**: Mass service status updates
- **Service Templates**: Pre-configured service templates
- **Analytics Dashboard**: Detailed service performance metrics
- **Service Scheduling**: Time-slot based service booking

### Integration Features
- **Calendar Integration**: Service availability scheduling
- **Payment Integration**: Service-based pricing and billing
- **Customer Management**: Service history and preferences
- **Inventory Linking**: Material and resource management

### AI-Powered Features
- **Smart Recommendations**: Service popularity predictions
- **Dynamic Pricing**: Market-based price optimization
- **Service Personalization**: Customer preference-based suggestions
- **Automated Scheduling**: AI-optimized service planning

---

*This Service List Screen represents the sophisticated service management command center for tailoring businesses, offering comprehensive tools to manage, analyze, and optimize their service portfolio with advanced filtering, real-time analytics, and seamless integration with the broader business management system.*