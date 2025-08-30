# Employee Provider Documentation

## Overview
The `employee_provider.dart` file contains the comprehensive state management solution for employee operations in the AI-Enabled Tailoring Shop Management System. It extends `ChangeNotifier` to provide reactive state management for employee data, work assignments, performance tracking, and workforce analytics.

## Architecture

### Core Features
- **Employee CRUD Operations**: Complete lifecycle management of employee records
- **Advanced Filtering**: Multi-criteria search and filtering capabilities
- **Work Assignment Management**: Full workflow for assigning and tracking work
- **Performance Analytics**: Comprehensive employee performance metrics
- **Real-time Updates**: Stream-based live data synchronization
- **Workload Balancing**: Intelligent work distribution suggestions

### State Management
```dart
class EmployeeProvider with ChangeNotifier {
  // Core data
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];

  // UI state
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _searchQuery = '';
  EmployeeAvailability? _selectedAvailabilityFilter;
  EmployeeSkill? _selectedSkillFilter;
  bool? _activeStatusFilter;
}
```

## Core Functionality

### Employee Data Management

#### Loading Employees
```dart
Future<void> loadEmployees()
```
- Loads all employees from Firestore
- Applies current filters automatically
- Handles loading states and error management
- Updates UI through `notifyListeners()`

#### Real-time Employee Stream
```dart
Stream<List<Employee>> getEmployeesStream()
```
- Provides real-time updates when employee data changes
- Automatically maps Firestore documents to Employee objects
- Enables reactive UI updates without manual polling

#### CRUD Operations
- **`createEmployee()`**: Creates new employee with default performance metrics
- **`updateEmployee()`**: Updates employee data with timestamp tracking
- **`deleteEmployee()`**: Removes employee and related work assignments
- **`toggleEmployeeStatus()`**: Activates/deactivates employees with reason tracking

### Advanced Filtering System

#### Filter Types
- **Text Search**: Searches across name, email, and specializations
- **Availability Filter**: Filters by employment type (full-time, part-time, etc.)
- **Skill Filter**: Filters employees with specific skills
- **Active Status**: Filters by active/inactive status

#### Filter Implementation
```dart
void _applyFilters() {
  List<Employee> filtered = _employees;

  // Apply search filter
  if (_searchQuery.isNotEmpty) {
    filtered = filtered.where((employee) {
      return employee.displayName.toLowerCase().contains(_searchQuery) ||
             employee.email.toLowerCase().contains(_searchQuery) ||
             employee.specializations.any((spec) =>
               spec.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  // Apply additional filters...
  _filteredEmployees = filtered;
  notifyListeners();
}
```

### Work Assignment Management

#### Work Assignment Creation
```dart
Future<bool> assignWorkToEmployee({
  required String employeeId,
  required String orderId,
  required EmployeeSkill requiredSkill,
  required String taskDescription,
  required DateTime deadline,
  required double estimatedHours,
  required double hourlyRate,
  required double bonusRate,
  required Map<String, dynamic> materials,
  required bool isRemoteWork,
  required String assignedBy,
})
```
- Creates new work assignment with comprehensive details
- Updates employee's in-progress order count
- Tracks assignment metadata and materials
- Handles both remote and on-site work assignments

#### Assignment Progress Tracking
```dart
Future<bool> updateWorkAssignment({
  required String assignmentId,
  WorkStatus? status,
  double? actualHours,
  String? qualityNotes,
  double? qualityRating,
  String? photoUrl,
})
```
- Updates assignment status and progress
- Tracks actual hours worked vs. estimated
- Records quality metrics and feedback
- Supports progress photo uploads

### Performance Analytics

#### Employee Statistics
```dart
// Computed properties
int get totalEmployees => _employees.length;
int get activeEmployeesCount => activeEmployees.length;
int get availableEmployeesCount => availableEmployees.length;

double get averageRating => _employees.isEmpty ? 0.0 :
  _employees.map((e) => e.averageRating).reduce((a, b) => a + b) / _employees.length;

double get totalEarnings => _employees.map((e) => e.totalEarnings).reduce((a, b) => a + b);

Map<EmployeeSkill, int> get skillDistribution {
  final Map<EmployeeSkill, int> distribution = {};
  for (var employee in _employees) {
    for (var skill in employee.skills) {
      distribution[skill] = (distribution[skill] ?? 0) + 1;
    }
  }
  return distribution;
}
```

#### Individual Analytics
```dart
Map<String, dynamic> getEmployeeAnalytics(String employeeId)
```
Returns comprehensive analytics for specific employee:
- Total orders completed and in progress
- Average rating and completion rate
- Total earnings and skill count
- Experience years and active status
- Consecutive days worked

### Workload Balancing

#### Intelligent Suggestions
```dart
List<Map<String, dynamic>> getWorkloadBalancingSuggestions()
```
Provides automated workload balancing recommendations:

**Overloaded Employees**: Identifies employees with >3 assignments
```dart
{
  'type': 'overload',
  'employee': employee,
  'message': 'Sarah Johnson has 5 assignments',
  'action': 'Consider redistributing some work'
}
```

**Underutilized Employees**: Identifies active employees with no assignments
```dart
{
  'type': 'underutilized',
  'employee': employee,
  'message': 'Mike Davis has no current assignments',
  'action': 'Assign new work based on skills and availability'
}
```

## Firebase Integration

### Data Operations
- **Collection**: `employees` - Main employee records
- **Collection**: `work_assignments` - Work assignment tracking
- **Real-time Streams**: Live updates for employee and assignment data
- **Batch Operations**: Efficient bulk updates and cascading deletes

### Data Flow
```dart
// Load employees with real-time updates
Stream<List<Employee>> employeeStream = getEmployeesStream();

// Create new employee
await createEmployee(
  userId: 'auth_user_123',
  displayName: 'Sarah Johnson',
  email: 'sarah@tailorshop.com',
  skills: [EmployeeSkill.stitching, EmployeeSkill.finishing],
  // ... other parameters
);

// Assign work with performance tracking
await assignWorkToEmployee(
  employeeId: 'emp_sarah_123',
  orderId: 'order_456',
  requiredSkill: EmployeeSkill.stitching,
  taskDescription: 'Stitch wedding gown with beading',
  // ... work details
);
```

## Usage Examples

### Basic Employee Management
```dart
class EmployeeManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        if (employeeProvider.isLoading) {
          return CircularProgressIndicator();
        }

        return ListView.builder(
          itemCount: employeeProvider.employees.length,
          itemBuilder: (context, index) {
            final employee = employeeProvider.employees[index];
            return ListTile(
              title: Text(employee.displayName),
              subtitle: Text('${employee.skills.length} skills'),
              trailing: Text('${employee.averageRating}⭐'),
            );
          },
        );
      },
    );
  }
}
```

### Advanced Filtering
```dart
class EmployeeFilters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: 'Search employees'),
          onChanged: (value) => employeeProvider.searchEmployees(value),
        ),
        DropdownButton<EmployeeSkill>(
          hint: Text('Filter by skill'),
          value: employeeProvider.selectedSkillFilter,
          items: EmployeeSkill.values.map((skill) {
            return DropdownMenuItem(
              value: skill,
              child: Text(skill.toString().split('.').last),
            );
          }).toList(),
          onChanged: (skill) => employeeProvider.filterBySkill(skill),
        ),
      ],
    );
  }
}
```

### Work Assignment
```dart
class WorkAssignmentScreen extends StatelessWidget {
  Future<void> assignWork(BuildContext context) async {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

    final success = await employeeProvider.assignWorkToEmployee(
      employeeId: 'emp_sarah_123',
      orderId: 'order_456',
      requiredSkill: EmployeeSkill.stitching,
      taskDescription: 'Custom suit tailoring with monogramming',
      deadline: DateTime.now().add(Duration(days: 5)),
      estimatedHours: 8.0,
      hourlyRate: 25.0,
      bonusRate: 5.0,
      materials: {
        'fabric': 'wool',
        'buttons': 'brass',
        'thread': 'matching'
      },
      isRemoteWork: false,
      assignedBy: 'manager_jane',
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Work assigned successfully!')),
      );
    }
  }
}
```

### Performance Dashboard
```dart
class EmployeeAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, child) {
        final analytics = employeeProvider.getEmployeeAnalytics('emp_sarah_123');

        return Column(
          children: [
            Text('Total Orders: ${analytics['totalOrdersCompleted']}'),
            Text('Average Rating: ${analytics['averageRating']}⭐'),
            Text('Total Earnings: \$${analytics['totalEarnings']}'),
            Text('Skills: ${analytics['skills']}'),
            Text('Consecutive Days: ${analytics['consecutiveDaysWorked']}'),
          ],
        );
      },
    );
  }
}
```

## Integration Points

### Related Components
- **Employee Model**: Core data structure for employee information
- **Employee Management Screens**: UI components for employee CRUD operations
- **Work Assignment Service**: Handles complex work assignment logic
- **Analytics Service**: Performance metrics and reporting
- **Order Management**: Integration with order assignment workflow

### Dependencies
- **Firebase Firestore**: Data persistence and real-time subscriptions
- **Cloud Firestore**: Timestamp handling and document relationships
- **Provider Package**: State management and dependency injection
- **Flutter Framework**: UI updates and reactive programming

## Performance Optimization

### Data Loading Strategies
- **Lazy Loading**: Load employee details on demand
- **Pagination**: Handle large employee lists efficiently
- **Caching**: Cache frequently accessed employee data
- **Real-time Updates**: Efficient listeners for live data

### Query Optimization
- **Filtered Queries**: Apply filters before loading full datasets
- **Stream Optimization**: Efficient real-time data subscriptions
- **Batch Operations**: Minimize database round trips
- **Memory Management**: Clear unused data to reduce memory footprint

## Security Considerations

### Data Access Control
- **Role-Based Access**: Different permissions for managers vs. employees
- **Employee Data Privacy**: Secure handling of personal information
- **Assignment Security**: Validate assignment permissions
- **Audit Trail**: Track all employee and assignment changes

### Data Validation
- **Input Validation**: Validate all employee and assignment data
- **Business Rules**: Enforce business logic constraints
- **Data Integrity**: Ensure data consistency across operations
- **Error Handling**: Comprehensive error management and user feedback

## Business Logic

### Employee Lifecycle Management
- **Onboarding**: Streamlined employee creation with default values
- **Performance Tracking**: Continuous monitoring and improvement
- **Skill Development**: Track certifications and specializations
- **Workload Management**: Balanced assignment distribution

### Compensation Management
- **Base Pay**: Hourly rate structure with bonuses
- **Performance Incentives**: Quality-based compensation
- **Payment Terms**: Flexible payment scheduling
- **Earnings Tracking**: Accurate payroll calculations

### Quality Assurance
- **Quality Ratings**: Customer feedback integration
- **Performance Metrics**: Completion rates and efficiency tracking
- **Continuous Improvement**: Areas for development identification
- **Standards Compliance**: Maintain service quality standards

This comprehensive employee provider serves as the central hub for all employee-related operations, providing a robust foundation for workforce management in the tailoring shop system.