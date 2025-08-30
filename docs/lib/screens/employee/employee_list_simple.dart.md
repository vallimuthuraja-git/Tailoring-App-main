# Employee List Simple

## Overview
The `employee_list_simple.dart` file implements a comprehensive employee management interface for the AI-Enabled Tailoring Shop Management System. It provides shop owners and administrators with powerful tools to view, search, filter, and manage employee information, featuring an intuitive card-based layout with detailed employee profiles and performance metrics.

## Key Features

### Advanced Search & Filtering
- **Real-time Search**: Instant employee search by name and email
- **Status Filtering**: Filter by employee status (Active/Inactive/All)
- **Multi-criteria Search**: Combined search and filter functionality
- **Dynamic Results**: Live updates as search criteria change

### Employee Management
- **Comprehensive Profiles**: Detailed employee information cards
- **CRUD Operations**: Create, Read, Update, Delete employee records
- **Performance Tracking**: Rating and order completion metrics
- **Skills Management**: Employee skill sets and specializations

### Role-Based Security
- **Shop Owner Access**: Restricted to authorized personnel only
- **Permission Validation**: Automatic access control enforcement
- **Secure Operations**: Protected employee data management

## Architecture Components

### Main Widget Structure

#### EmployeeListSimple Widget
```dart
class EmployeeListSimple extends StatefulWidget {
  const EmployeeListSimple({super.key});

  @override
  State<EmployeeListSimple> createState() => _EmployeeListSimpleState();
}
```

#### State Management
```dart
class _EmployeeListSimpleState extends State<EmployeeListSimple> {
  final List<Map<String, dynamic>> mockEmployees = [...]; // Employee data
  String _searchQuery = '';
  String _selectedFilter = 'All';
}
```

### Mock Data Structure
```dart
{
  'id': '1',
  'name': 'John Doe',
  'email': 'john@example.com',
  'skills': ['Stitching', 'Cutting'],
  'experience': 5,
  'status': 'Active',
  'rating': 4.5,
  'ordersCompleted': 25,
}
```

## Search and Filter System

### Search Implementation
```dart
List<Map<String, dynamic>> get filteredEmployees {
  var employees = mockEmployees;

  // Apply search filter
  if (_searchQuery.isNotEmpty) {
    employees = employees.where((employee) {
      final name = employee['name'].toString().toLowerCase();
      final email = employee['email'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  // Apply status filter
  if (_selectedFilter != 'All') {
    employees = employees.where((employee) {
      return employee['status'] == _selectedFilter;
    }).toList();
  }

  return employees;
}
```

### Search Interface
```dart
TextField(
  decoration: InputDecoration(
    hintText: 'Search employees...',
    prefixIcon: const Icon(Icons.search),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surface,
  ),
  onChanged: (value) {
    setState(() {
      _searchQuery = value;
    });
  },
)
```

### Filter Chips
```dart
Wrap(
  spacing: 8,
  children: [
    FilterChip(
      label: const Text('All'),
      selected: _selectedFilter == 'All',
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? 'All' : 'All';
        });
      },
    ),
    // Additional filter chips for Active/Inactive
  ],
)
```

## Employee Card Design

### Card Layout
```dart
Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => _showEmployeeDetails(context, employee),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmployeeHeader(employee),
          _buildEmployeeStats(employee),
        ],
      ),
    ),
  ),
)
```

### Employee Header
```dart
Row(
  children: [
    CircleAvatar(
      radius: 24,
      backgroundColor: Theme.of(context).primaryColor,
      child: Text(
        employee['name'].toString()[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employee['name'],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            employee['email'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: employee['status'] == 'Active'
            ? Colors.green[100]
            : Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        employee['status'],
        style: TextStyle(
          color: employee['status'] == 'Active'
              ? Colors.green[800]
              : Colors.red[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
)
```

### Employee Statistics
```dart
Row(
  children: [
    // Skills Section
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills', style: TextStyle(color: Colors.grey[600])),
          Wrap(
            spacing: 4,
            children: (employee['skills'] as List).take(2).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),

    // Performance Stats
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                employee['rating'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '${employee['ordersCompleted']} orders',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  ],
)
```

## CRUD Operations

### Add Employee Dialog
```dart
void _showAddEmployeeDialog(BuildContext context) {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add New Employee'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
              setState(() {
                mockEmployees.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameController.text,
                  'email': emailController.text,
                  'skills': ['Stitching'],
                  'experience': 0,
                  'status': 'Active',
                  'rating': 0.0,
                  'ordersCompleted': 0,
                });
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${nameController.text} successfully!')),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
```

### Edit Employee Dialog
```dart
void _showEditEmployeeDialog(BuildContext context, Map<String, dynamic> employee) {
  final nameController = TextEditingController(text: employee['name']);
  final emailController = TextEditingController(text: employee['email']);

  // Similar structure to add dialog with pre-populated fields
}
```

### Employee Details Dialog
```dart
void _showEmployeeDetails(BuildContext context, Map<String, dynamic> employee) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(employee['name']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${employee['email']}'),
          Text('Experience: ${employee['experience']} years'),
          Text('Status: ${employee['status']}'),
          Text('Rating: ${employee['rating']}/5.0'),
          Text('Orders Completed: ${employee['ordersCompleted']}'),
          const SizedBox(height: 12),
          const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 4,
            children: (employee['skills'] as List).map((skill) {
              return Chip(label: Text(skill.toString()));
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showEditEmployeeDialog(context, employee);
          },
          child: const Text('Edit'),
        ),
      ],
    ),
  );
}
```

## Security Implementation

### Role-Based Access Control
```dart
@override
Widget build(BuildContext context) {
  return RoleBasedRouteGuard(
    requiredRole: auth.UserRole.shopOwner,
    child: Scaffold(
      // Protected employee management interface
    ),
  );
}
```

### Permission Validation
```dart
floatingActionButton: Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isShopOwnerOrAdmin) {
      return FloatingActionButton.extended(
        onPressed: () => _showAddEmployeeDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      );
    }
    return const SizedBox.shrink();
  },
)
```

## User Interface Features

### Empty State Handling
```dart
filteredEmployees.isEmpty
    ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
    : ListView.builder(...)
```

### Performance Dashboard Access
```dart
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.analytics),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Performance Dashboard - Coming Soon!')),
        );
      },
      tooltip: 'Performance Dashboard',
    ),
  ],
)
```

## Integration Points

### With Authentication System
- **User Context**: Access to current user permissions
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)
- **Role Validation**: Real-time permission checking
- **Session Management**: Proper authentication state handling

### With Employee Management System
- **Employee Data**: Mock data structure for employee records
- **CRUD Operations**: Full create, read, update, delete functionality
- **Performance Tracking**: Integration with performance metrics
- **Skills Management**: Employee skill set tracking

### With Role-Based Access Control
- **Route Guard**: Automatic access protection
  - Related: [`lib/widgets/role_based_guard.dart`](../../widgets/role_based_guard.md)
- **Permission System**: Hierarchical access control
- **Security Policies**: Enforced organizational boundaries

## Performance Metrics

### Employee Performance Tracking
- **Rating System**: 5-star rating for employee performance
- **Order Completion**: Track number of completed orders
- **Skills Assessment**: Employee skill specialization tracking
- **Experience Level**: Years of experience monitoring

### Search and Filter Performance
- **Real-time Filtering**: Instant search results
- **Efficient Queries**: Optimized data filtering algorithms
- **Memory Management**: Efficient state management
- **UI Responsiveness**: Smooth user interactions

## Future Enhancements

### Advanced Features
- **Bulk Operations**: Mass employee management actions
- **Advanced Search**: Multi-field search capabilities
- **Export/Import**: Employee data export and import
- **Photo Management**: Employee profile photo support

### AI-Powered Features
- **Smart Search**: AI-assisted employee discovery
- **Performance Prediction**: Predictive analytics for employee performance
- **Automated Scheduling**: AI-optimized shift planning
- **Talent Insights**: AI-driven employee insights

### Integration Features
- **HR System Integration**: Third-party HR system connectivity
- **Calendar Integration**: Employee schedule synchronization
- **Notification System**: Automated alerts and notifications
- **Reporting Tools**: Advanced employee analytics and reporting

---

*This Employee List Simple screen provides a comprehensive, user-friendly interface for managing employees in the tailoring shop, combining powerful search and filtering capabilities with intuitive CRUD operations and robust security measures to ensure only authorized personnel can access sensitive employee data.*