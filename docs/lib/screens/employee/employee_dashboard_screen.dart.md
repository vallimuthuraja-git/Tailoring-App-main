# Employee Dashboard Screen Documentation

## Overview
The `employee_dashboard_screen.dart` file contains the personalized employee dashboard for the AI-Enabled Tailoring Shop Management System. It provides employees with a comprehensive view of their profile, performance metrics, current assignments, and recent activity, serving as their central hub for work tracking and performance monitoring.

## Architecture

### Core Components
- **`EmployeeDashboardScreen`**: Main dashboard widget with state management
- **Profile Card**: Employee personal information and status display
- **Quick Stats**: Key performance metrics at a glance
- **Current Assignments**: Active work assignments tracking
- **Performance Overview**: Detailed performance analytics
- **Recent Activity**: Timeline of recent work assignments

### Key Features
- **Personalized View**: Tailored dashboard for each authenticated employee
- **Real-time Data**: Live updates from Firebase backend
- **Performance Tracking**: Comprehensive metrics and analytics
- **Visual Design**: Modern card-based layout with intuitive icons
- **Responsive Layout**: Optimized for various screen sizes
- **Interactive Elements**: Refresh functionality and navigation

## State Management

### Initialization and Data Loading
```dart
@override
void initState() {
  super.initState();
  _loadEmployeeData();
}

Future<void> _loadEmployeeData() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

  if (authProvider.currentUser != null) {
    await employeeProvider.loadEmployees();
  }
}
```

### Provider Integration
```dart
Consumer2<AuthProvider, EmployeeProvider>(
  builder: (context, authProvider, employeeProvider, child) {
    // Access to authentication state and employee data
    final currentUser = authProvider.currentUser;
    final employees = employeeProvider.employees;
  }
)
```

## UI Components

### Profile Card Component
```dart
Widget _buildProfileCard(emp.Employee employee) {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Employee avatar with fallback
          CircleAvatar(
            radius: 40,
            backgroundImage: employee.photoUrl != null
                ? NetworkImage(employee.photoUrl!)
                : null,
            child: employee.photoUrl == null
                ? Text(employee.displayName[0].toUpperCase())
                : null,
          ),

          // Employee details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.displayName, style: Theme.of(context).textTheme.headlineSmall),
                Text(employee.email, style: Theme.of(context).textTheme.bodyMedium),

                // Status indicators
                Row(children: [
                  Icon(employee.isActive ? Icons.check_circle : Icons.pause_circle,
                       color: employee.isActive ? Colors.green : Colors.orange),
                  Text(employee.isActive ? 'Active' : 'Inactive'),
                  // Remote work capability
                  Icon(employee.canWorkRemotely ? Icons.home_work : Icons.business),
                  Text(employee.canWorkRemotely ? 'Remote Available' : 'On-site Only'),
                ]),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Quick Stats Component
```dart
Widget _buildQuickStats(emp.Employee employee) {
  return Row(
    children: [
      // Orders Completed
      Expanded(child: _buildStatCard(
        'Orders Completed',
        employee.totalOrdersCompleted.toString(),
        Icons.check_circle,
        Colors.green,
      )),

      // In Progress Orders
      Expanded(child: _buildStatCard(
        'In Progress',
        employee.ordersInProgress.toString(),
        Icons.work,
        Colors.blue,
      )),

      // Average Rating
      Expanded(child: _buildStatCard(
        'Avg Rating',
        employee.averageRating.toStringAsFixed(1),
        Icons.star,
        Colors.amber,
      )),
    ],
  );
}
```

### Current Assignments Component
```dart
Widget _buildCurrentAssignments(emp.Employee employee) {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Assignments', style: Theme.of(context).textTheme.titleLarge),

          if (employee.ordersInProgress > 0) ...[
            Text('You have ${employee.ordersInProgress} assignments in progress'),

            // Progress indicator
            LinearProgressIndicator(
              value: employee.totalOrdersCompleted > 0
                  ? employee.totalOrdersCompleted / (employee.totalOrdersCompleted + employee.ordersInProgress)
                  : 0,
            ),
          ] else ...[
            // No assignments state
            Center(child: Column(children: [
              Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
              Text('No current assignments'),
              Text('You\'ll be notified when new work is assigned'),
            ])),
          ],
        ],
      ),
    ),
  );
}
```

### Performance Overview Component
```dart
Widget _buildPerformanceOverview(emp.Employee employee) {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Overview', style: Theme.of(context).textTheme.titleLarge),

          // Performance metrics
          _buildPerformanceMetric('Completion Rate', '${(employee.completionRate * 100).toStringAsFixed(1)}%', _getCompletionRateColor(employee.completionRate)),
          _buildPerformanceMetric('Experience', '${employee.experienceYears} years', Colors.blue),
          _buildPerformanceMetric('Total Earnings', '\$${employee.totalEarnings.toStringAsFixed(2)}', Colors.green),

          // Employee strengths
          if (employee.strengths.isNotEmpty) ...[
            Text('Strengths', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: employee.strengths.map((strength) =>
                Chip(label: Text(strength), backgroundColor: Colors.green.withOpacity(0.1))
              ).toList(),
            ),
          ],
        ],
      ),
    ),
  );
}
```

### Recent Activity Component
```dart
Widget _buildRecentActivity(emp.Employee employee) {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),

          if (employee.recentAssignments.isNotEmpty) ...[
            ...employee.recentAssignments.take(3).map((assignment) {
              return ListTile(
                leading: Icon(_getAssignmentStatusIcon(assignment.status), color: _getAssignmentStatusColor(assignment.status)),
                title: Text(assignment.taskDescription),
                subtitle: Text('Assigned: ${assignment.assignedAt.toString().split(' ')[0]}'),
                trailing: assignment.qualityRating != null
                    ? Row(children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(assignment.qualityRating!.toStringAsFixed(1)),
                      ])
                    : null,
              );
            }),
          ] else ...[
            Center(child: Text('No recent activity')),
          ],
        ],
      ),
    ),
  );
}
```

## Data Flow

### Employee Data Retrieval
```dart
// Find current employee's data from the list
final currentEmployee = employees.where((emp) => emp.userId == currentUser?.uid)
    .cast<emp.Employee?>()
    .firstWhere((element) => true, orElse: () => null);

if (currentEmployee == null) {
  return Center(child: Text('Employee profile not found. Please contact your administrator.'));
}
```

### Error Handling
```dart
if (employeeProvider.errorMessage != null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: ${employeeProvider.errorMessage}'),
        ElevatedButton(onPressed: _loadEmployeeData, child: Text('Retry')),
      ],
    ),
  );
}
```

### Loading States
```dart
if (employeeProvider.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

## Performance Metrics

### Completion Rate Color Coding
```dart
Color _getCompletionRateColor(double rate) {
  if (rate >= 0.9) return Colors.green;      // Excellent (>=90%)
  if (rate >= 0.7) return Colors.orange;     // Good (70-89%)
  return Colors.red;                         // Needs Improvement (<70%)
}
```

### Assignment Status Icons
```dart
IconData _getAssignmentStatusIcon(emp.WorkStatus status) {
  switch (status) {
    case emp.WorkStatus.completed:
      return Icons.check_circle;
    case emp.WorkStatus.inProgress:
      return Icons.work;
    case emp.WorkStatus.notStarted:
      return Icons.schedule;
    default:
      return Icons.assignment;
  }
}

Color _getAssignmentStatusColor(emp.WorkStatus status) {
  switch (status) {
    case emp.WorkStatus.completed:
      return Colors.green;
    case emp.WorkStatus.inProgress:
      return Colors.blue;
    case emp.WorkStatus.notStarted:
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
```

## User Experience Features

### Pull to Refresh
```dart
AppBar(
  title: const Text('Employee Dashboard'),
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: _loadEmployeeData,
    ),
  ],
)
```

### Empty States
```dart
// No assignments
if (employee.ordersInProgress == 0) {
  Center(child: Column(children: [
    Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
    Text('No current assignments'),
    Text('You\'ll be notified when new work is assigned'),
  ]));
}

// No recent activity
if (employee.recentAssignments.isEmpty) {
  Center(child: Text('No recent activity'));
}
```

### Visual Feedback
```dart
// Progress indicators
LinearProgressIndicator(
  value: employee.totalOrdersCompleted / (employee.totalOrdersCompleted + employee.ordersInProgress),
)

// Status chips for strengths
Chip(
  label: Text(strength),
  backgroundColor: Colors.green.withOpacity(0.1),
)

// Performance metric containers
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  decoration: BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
)
```

## Integration Points

### Provider Dependencies
```dart
// Required providers for the dashboard
- AuthProvider: User authentication and current user data
- EmployeeProvider: Employee data management and CRUD operations

// Usage in widget tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => EmployeeProvider()),
  ],
  child: EmployeeDashboardScreen(),
)
```

### Navigation Integration
```dart
// Deep linking support
Navigator.pushNamed(context, '/employee-dashboard');

// Push replacement after login
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => const EmployeeDashboardScreen()),
);
```

### Data Synchronization
```dart
// Automatic data refresh
_refreshIndicatorKey.currentState?.show();

// Manual refresh capability
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: () async {
    await employeeProvider.loadEmployees();
    setState(() {});
  },
)
```

## Business Logic

### Employee Matching
```dart
// Match employee with current user
final currentEmployee = employees.firstWhere(
  (emp) => emp.userId == currentUser?.uid,
  orElse: () => null,
);

// Handle missing employee profile
if (currentEmployee == null) {
  return Center(child: Text('Employee profile not found'));
}
```

### Performance Calculation
```dart
// Overall completion rate
double completionRate = employee.completionRate;

// Progress ratio for visual indicator
double progressRatio = employee.totalOrdersCompleted /
    (employee.totalOrdersCompleted + employee.ordersInProgress);

// Performance color coding based on thresholds
Color performanceColor = _getCompletionRateColor(completionRate);
```

### Activity Timeline
```dart
// Recent assignments (last 3)
List<recentAssignments> recentWork = employee.recentAssignments.take(3).toList();

// Assignment status prioritization
assignments.sort((a, b) {
  // Completed first, then in progress, then not started
  return b.status.index.compareTo(a.status.index);
});
```

## Security Considerations

### Access Control
```dart
// Verify user authentication
if (authProvider.currentUser == null) {
  Navigator.of(context).pushReplacementNamed('/login');
  return;
}

// Employee profile validation
if (currentEmployee == null) {
  return Center(child: Text('Unauthorized access'));
}
```

### Data Privacy
```dart
// Only show current user's data
final currentEmployee = employees.firstWhere(
  (emp) => emp.userId == currentUser?.uid,
);

// Hide sensitive information from other employees
if (currentEmployee.id != requestedEmployeeId) {
  return Center(child: Text('Access denied'));
}
```

## Performance Optimization

### Efficient Rendering
```dart
// SingleChildScrollView for long content
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(children: [...]),
)

// Selective rebuilds with Consumer
Consumer2<AuthProvider, EmployeeProvider>(
  builder: (context, authProvider, employeeProvider, child) {
    // Only rebuild when relevant data changes
  }
)
```

### Memory Management
```dart
// Proper disposal of resources
@override
void dispose() {
  // Clean up any controllers or listeners
  super.dispose();
}

// Efficient list building
...employee.recentAssignments.take(3).map((assignment) {
  // Limit items to prevent performance issues
})
```

## Accessibility Features

### Screen Reader Support
```dart
// Semantic labels for icons
Icon(
  Icons.check_circle,
  semanticLabel: 'Completed assignment',
)

// Descriptive text for visual elements
Text(
  'Completion Rate',
  style: TextStyle(fontWeight: FontWeight.bold),
)
```

### Touch Targets
```dart
// Adequate touch target sizes
IconButton(
  icon: Icon(Icons.refresh),
  onPressed: _loadEmployeeData,
  padding: EdgeInsets.all(12), // Minimum 44px
)
```

### Color Contrast
```dart
// High contrast color combinations
Text(
  employee.displayName,
  style: TextStyle(
    color: Theme.of(context).textTheme.headlineSmall?.color,
  ),
)

// Status color coding with sufficient contrast
Icon(
  employee.isActive ? Icons.check_circle : Icons.pause_circle,
  color: employee.isActive ? Colors.green : Colors.orange,
)
```

This comprehensive employee dashboard screen provides employees with a complete overview of their work status, performance metrics, and recent activity, serving as their central hub for work management and performance tracking within the tailoring shop management system.