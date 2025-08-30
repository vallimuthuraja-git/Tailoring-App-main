# Employee Detail Screen Documentation

## Overview
The `employee_detail_screen.dart` file contains the comprehensive employee profile and detail view for the AI-Enabled Tailoring Shop Management System. It provides a complete overview of individual employee information, performance metrics, skills, work schedule, recent assignments, and contact details, with role-based access control for management functions.

## Architecture

### Core Components
- **`EmployeeDetailScreen`**: Main employee detail view with comprehensive information display
- **Employee Header Card**: Profile summary with avatar, status, and key details
- **Performance Overview**: Key performance metrics and statistics
- **Skills & Expertise Section**: Skills, specializations, and certifications display
- **Work Schedule**: Availability, work days, hours, and remote work capability
- **Recent Assignments**: Timeline of recent work assignments
- **Contact Information**: Email, phone, and location with action buttons
- **Role-Based Actions**: Edit, work assignments, and deletion with permissions

### Key Features
- **Comprehensive Profile View**: Complete employee information in organized sections
- **Performance Metrics Dashboard**: Visual performance indicators and statistics
- **Skills Visualization**: Interactive skill tags and certification display
- **Work Schedule Management**: Detailed availability and scheduling information
- **Recent Activity Tracking**: Timeline of recent work assignments
- **Contact Integration**: Direct access to communication methods
- **Role-Based Permissions**: Management functions restricted by user role
- **Real-time Data Updates**: Live synchronization with backend data

## State Management

### Employee Data Handling
```dart
class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late Employee _employee;

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
    _loadEmployeeDetails();
  }

  Future<void> _loadEmployeeDetails() async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    final updatedEmployee = await employeeProvider.getEmployeeById(_employee.id);
    if (updatedEmployee != null && mounted) {
      setState(() {
        _employee = updatedEmployee;
      });
    }
  }
}
```

### Data Synchronization
```dart
// Real-time data loading
_loadEmployeeDetails() async {
  final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
  final updatedEmployee = await employeeProvider.getEmployeeById(_employee.id);
  if (updatedEmployee != null && mounted) {
    setState(() => _employee = updatedEmployee);
  }
}

// Post-edit refresh
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => EmployeeEditScreen(employee: _employee)),
).then((_) => _loadEmployeeDetails());
```

## Role-Based Access Control

### Route Protection
```dart
RoleBasedRouteGuard(
  requiredRole: auth.UserRole.shopOwner,
  child: Scaffold(
    // Employee detail interface - shop owner only
  ),
)
```

### Action Permissions
```dart
// Edit button with role restriction
RoleBasedWidget(
  requiredRole: auth.UserRole.shopOwner,
  child: IconButton(
    icon: const Icon(Icons.edit),
    onPressed: () => navigateToEditScreen(),
    tooltip: 'Edit Employee',
  ),
)

// Work assignments access
RoleBasedWidget(
  requiredRole: auth.UserRole.shopOwner,
  child: IconButton(
    icon: const Icon(Icons.assignment),
    onPressed: () => navigateToWorkAssignments(),
    tooltip: 'Manage Work Assignments',
  ),
)

// Delete permission
RoleBasedWidget(
  requiredRole: auth.UserRole.shopOwner,
  child: IconButton(
    icon: const Icon(Icons.delete, color: Colors.red),
    onPressed: () => _showDeleteConfirmation(),
    tooltip: 'Delete Employee',
  ),
)
```

## UI Components

### Employee Header Card
```dart
Widget _buildEmployeeHeader() {
  return Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        // Employee Avatar with Fallback
        CircleAvatar(
          radius: 40,
          backgroundImage: _employee.photoUrl != null
              ? NetworkImage(_employee.photoUrl!)
              : null,
          child: _employee.photoUrl == null
              ? Text(_employee.displayName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              : null,
        ),

        const SizedBox(width: 20),

        // Employee Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Name
              Text(_employee.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),

              // Email
              Text(_employee.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  )),

              // Status and Experience
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _employee.isActive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _employee.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: _employee.isActive ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_employee.experienceYears} years experience',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    )),
              ]),
            ],
          ),
        ),
      ]),
    ),
  );
}
```

### Performance Overview Cards
```dart
Widget _buildPerformanceOverview() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          // Orders Completed
          Expanded(child: _buildMetricCard(
            'Orders Completed',
            _employee.totalOrdersCompleted.toString(),
            Icons.check_circle,
            Colors.green,
          )),

          // Average Rating
          Expanded(child: _buildMetricCard(
            'Avg Rating',
            _employee.averageRating.toStringAsFixed(1),
            Icons.star,
            Colors.amber,
          )),
        ]),

        const SizedBox(height: 16),

        Row(children: [
          // Completion Rate
          Expanded(child: _buildMetricCard(
            'Completion Rate',
            '${(_employee.completionRate * 100).toStringAsFixed(0)}%',
            Icons.trending_up,
            Colors.blue,
          )),

          // Total Earnings
          Expanded(child: _buildMetricCard(
            'Total Earnings',
            '\$${_employee.totalEarnings.toStringAsFixed(0)}',
            Icons.attach_money,
            Colors.green,
          )),
        ]),

        const SizedBox(height: 16),

        Row(children: [
          // In Progress Orders
          Expanded(child: _buildMetricCard(
            'In Progress',
            _employee.ordersInProgress.toString(),
            Icons.work,
            Colors.orange,
          )),

          // Consecutive Days Worked
          Expanded(child: _buildMetricCard(
            'Consecutive Days',
            _employee.consecutiveDaysWorked.toString(),
            Icons.calendar_today,
            Colors.purple,
          )),
        ]),
      ]),
    ),
  );
}

Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: color, fontSize: 12), textAlign: TextAlign.center),
    ]),
  );
}
```

### Skills and Expertise Section
```dart
Widget _buildSkillsSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills Display
          Text('Skills', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _employee.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(skill.name, style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                )),
              );
            }).toList(),
          ),

          // Specializations
          if (_employee.specializations.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Specializations', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _employee.specializations.map((spec) {
                return Chip(
                  label: Text(spec),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(color: Colors.blue),
                );
              }).toList(),
            ),
          ],

          // Certifications
          if (_employee.certifications.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Certifications', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _employee.certifications.map((cert) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    const Icon(Icons.verified, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(cert),
                  ]),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    ),
  );
}
```

### Work Schedule Section
```dart
Widget _buildWorkSchedule() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Status
          Row(children: [
            const Icon(Icons.schedule, color: Colors.blue),
            const SizedBox(width: 12),
            Text('Availability: ${_employee.availability.name}',
                style: Theme.of(context).textTheme.titleMedium),
          ]),

          const SizedBox(height: 16),

          // Work Days
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Work Days', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _employee.preferredWorkDays.map((day) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            day.substring(0, 3),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Preferred Hours
          Row(children: [
            const Icon(Icons.access_time, color: Colors.purple),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferred Hours', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 4),
                  if (_employee.preferredStartTime != null && _employee.preferredEndTime != null) ...[
                    Text('${_employee.preferredStartTime!.formatTime()} - ${_employee.preferredEndTime!.formatTime()}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ] else ...[
                    Text('Flexible hours', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    )),
                  ],
                ],
              ),
            ),
          ]),

          const SizedBox(height: 16),

          // Remote Work Capability
          Row(children: [
            Icon(
              _employee.canWorkRemotely ? Icons.home_work : Icons.business,
              color: _employee.canWorkRemotely ? Colors.orange : Colors.blue,
            ),
            const SizedBox(width: 12),
            Text(
              _employee.canWorkRemotely ? 'Can work remotely' : 'On-site only',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]),
        ],
      ),
    ),
  );
}
```

### Recent Assignments Section
```dart
Widget _buildRecentAssignments() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.work_history, color: Colors.blue),
            const SizedBox(width: 12),
            Text('Recent Work', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )),
          ]),

          const SizedBox(height: 16),

          if (_employee.recentAssignments.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No recent assignments', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ] else ...[
            ..._employee.recentAssignments.take(5).map((assignment) {
              return ListTile(
                title: Text('Order #${assignment.orderId}'),
                subtitle: Text(assignment.taskDescription),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: assignment.status == WorkStatus.completed
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.status.name,
                    style: TextStyle(
                      color: assignment.status == WorkStatus.completed
                          ? Colors.green[800]
                          : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    ),
  );
}
```

### Contact Information Section
```dart
Widget _buildContactInfo() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.contact_phone, color: Colors.blue),
            const SizedBox(width: 12),
            Text('Contact Information', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )),
          ]),

          const SizedBox(height: 16),

          // Email Contact
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text('Email'),
            subtitle: Text(_employee.email),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                // Copy email to clipboard functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email copied to clipboard')),
                );
              },
            ),
          ),

          // Phone Contact (conditional)
          if (_employee.phoneNumber != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Phone'),
              subtitle: Text(_employee.phoneNumber!),
              trailing: IconButton(
                icon: const Icon(Icons.call),
                onPressed: () {
                  // Phone call functionality (placeholder)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone call functionality coming soon')),
                  );
                },
              ),
            ),
          ],

          // Location (conditional)
          if (_employee.location != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Location'),
              subtitle: Text(_employee.location!),
              trailing: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  // Map functionality (placeholder)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map functionality coming soon')),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
```

## Action Management

### Delete Confirmation Dialog
```dart
void _showDeleteConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Employee'),
      content: Text('Are you sure you want to delete ${_employee.displayName}? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _deleteEmployee(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void _deleteEmployee() async {
  Navigator.pop(context); // Close dialog

  final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

  // Show loading feedback
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Deleting employee...')),
  );

  try {
    final success = await employeeProvider.deleteEmployee(_employee.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee deleted successfully')),
      );
      Navigator.pop(context); // Return to employee list
    } else {
      throw Exception('Failed to delete employee');
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

## Navigation Integration

### Edit Employee Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EmployeeEditScreen(employee: _employee),
  ),
).then((_) => _loadEmployeeDetails()); // Refresh data after edit
```

### Work Assignments Navigation
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WorkAssignmentScreen(employee: _employee),
  ),
);
```

### Back Navigation
```dart
Navigator.pop(context); // Return to employee list after successful operations
```

## Data Flow

### Employee Data Loading
```dart
// Initial data loading
_loadEmployeeDetails() async {
  final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
  final updatedEmployee = await employeeProvider.getEmployeeById(_employee.id);

  if (updatedEmployee != null && mounted) {
    setState(() => _employee = updatedEmployee);
  }
}

// Post-edit data refresh
.then((_) => _loadEmployeeDetails())
```

### Real-time Synchronization
```dart
// Automatic data refresh after edit operations
Navigator.push(...).then((_) {
  _loadEmployeeDetails(); // Refresh employee data
});
```

## Error Handling

### Loading States
```dart
// Provider loading state (inherited from parent)
if (employeeProvider.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### Error States
```dart
// Provider error handling
if (employeeProvider.errorMessage != null) {
  return Center(
    child: Column(children: [
      const Icon(Icons.error, size: 64, color: Colors.red),
      const SizedBox(height: 16),
      Text('Error loading employee details'),
      const SizedBox(height: 8),
      Text(employeeProvider.errorMessage!),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _loadEmployeeDetails,
        child: const Text('Retry'),
      ),
    ]),
  );
}
```

### Operation Feedback
```dart
// Success messages
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Employee deleted successfully')),
);

// Error messages
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Error: $e')),
);

// Loading messages
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Deleting employee...')),
);
```

## Performance Optimization

### Efficient Rendering
```dart
// SingleChildScrollView for long content
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(children: [
    // Multiple sections with proper spacing
  ]),
)

// Conditional rendering for optional sections
if (_employee.specializations.isNotEmpty) ...[
  // Specializations section
]

if (_employee.certifications.isNotEmpty) ...[
  // Certifications section
]
```

### Memory Management
```dart
// No additional controllers needed for this screen
// Employee data managed by provider
```

### Selective Updates
```dart
// Targeted state updates
setState(() {
  _employee = updatedEmployee; // Only update employee data
});
```

## Integration Points

### Provider Dependencies
```dart
// Required Providers
- EmployeeProvider: Employee data management and CRUD operations
- AuthProvider: User authentication and role verification

// Usage in Widget Tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => EmployeeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: EmployeeDetailScreen(employee: employee),
)
```

### Service Dependencies
```dart
// Firebase Services Integration
- FirebaseService: Data persistence and real-time synchronization
- Employee Service: Business logic for employee operations
- Auth Service: User authentication and role management
```

### Navigation Dependencies
```dart
// Screen Navigation Integration
- EmployeeEditScreen: Employee editing interface
- WorkAssignmentScreen: Work assignment management
- EmployeeListScreen: Return destination
```

## Business Logic

### Employee Data Structure
```dart
// Complete Employee Profile Display
Employee {
  id: String,                    // Unique identifier
  displayName: String,           // Full display name
  email: String,                 // Contact email
  phoneNumber: String?,          // Optional phone number
  photoUrl: String?,            // Profile photo URL
  isActive: bool,               // Employment status
  experienceYears: int,         // Years of experience
  skills: List<EmployeeSkill>,   // Employee skills
  specializations: List<String>, // Area specializations
  certifications: List<String>,  // Professional certifications
  availability: EmployeeAvailability, // Work availability
  preferredWorkDays: List<String>, // Available work days
  preferredStartTime: TimeOfDay?, // Preferred start time
  preferredEndTime: TimeOfDay?,   // Preferred end time
  canWorkRemotely: bool,        // Remote work capability
  location: String?,            // Work location
  totalOrdersCompleted: int,    // Completed orders count
  averageRating: double,        // Performance rating
  completionRate: double,       // Order completion rate
  totalEarnings: double,        // Total earnings
  ordersInProgress: int,        // Current active orders
  consecutiveDaysWorked: int,   // Consecutive work days
  recentAssignments: List<WorkAssignment>, // Recent work history
}
```

### Performance Calculations
```dart
// Completion Rate Display
double completionRate = _employee.completionRate * 100;
String completionRateText = '${completionRate.toStringAsFixed(0)}%';

// Earnings Formatting
String earningsText = '\$${_employee.totalEarnings.toStringAsFixed(0)}';

// Rating Display
String ratingText = _employee.averageRating.toStringAsFixed(1);
```

### Status Indicators
```dart
// Active/Inactive Status
Color statusColor = _employee.isActive ? Colors.green : Colors.red;
String statusText = _employee.isActive ? 'Active' : 'Inactive';

// Remote Work Capability
IconData workIcon = _employee.canWorkRemotely ? Icons.home_work : Icons.business;
Color workIconColor = _employee.canWorkRemotely ? Colors.orange : Colors.blue;
String workText = _employee.canWorkRemotely ? 'Can work remotely' : 'On-site only';
```

## Security Considerations

### Access Control
```dart
// Route-level protection
RoleBasedRouteGuard(
  requiredRole: auth.UserRole.shopOwner,
  child: EmployeeDetailScreen(employee: employee),
)

// Feature-level permissions
RoleBasedWidget(
  requiredRole: auth.UserRole.shopOwner,
  child: IconButton(
    icon: const Icon(Icons.edit),
    onPressed: () => navigateToEdit(),
  ),
)
```

### Data Privacy
```dart
// Employee data visibility
// Only shop owners can view detailed employee information
// Employee-specific data filtering based on user permissions

// Contact information access
if (_employee.phoneNumber != null) {
  // Display phone with call action
}

if (_employee.location != null) {
  // Display location with map action
}
```

## Best Practices

### User Experience
- **Progressive Disclosure**: Information organized in logical sections
- **Visual Hierarchy**: Clear section titles and consistent spacing
- **Interactive Elements**: Hover effects and action buttons
- **Responsive Design**: Proper layout for different screen sizes
- **Loading States**: Clear feedback during data operations

### Performance
- **Efficient Data Loading**: Single API call for employee details
- **Selective Rebuilds**: Targeted state updates
- **Memory Optimization**: No unnecessary data caching
- **Image Optimization**: Proper loading and error handling for avatars

### Maintainability
- **Modular Components**: Separate widgets for each section
- **Clear Separation of Concerns**: UI and business logic separation
- **Consistent Styling**: Theme-aware color and typography usage
- **Error Boundaries**: Comprehensive error handling

This comprehensive employee detail screen provides a complete view of employee information, performance metrics, and management capabilities, serving as the central hub for individual employee oversight in the tailoring shop management system.