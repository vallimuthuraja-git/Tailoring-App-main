# Employee Model Documentation

## Overview
The `employee.dart` file contains comprehensive employee management models for the AI-Enabled Tailoring Shop Management System. It defines the structure for employee data, work assignments, progress tracking, and performance metrics, supporting a complete workforce management solution.

## Architecture

### Core Classes
- **`Employee`**: Main employee model with comprehensive profile and performance data
- **`WorkAssignment`**: Work order assignment tracking with progress and quality metrics
- **`WorkUpdate`**: Progress updates and status changes for work assignments
- **`TimeOfDay`**: Time utility class for work scheduling

### Enums
- **`EmployeeSkill`**: Available employee skills and specializations
- **`EmployeeAvailability`**: Work availability types and schedules
- **`WorkStatus`**: Work assignment status tracking

## Employee Model Properties

### Basic Information
- **`id`**: Unique employee identifier
- **`userId`**: Reference to Firebase Auth user
- **`displayName`**: Employee's display name
- **`email`**: Contact email address
- **`phoneNumber`**: Contact phone number (optional)
- **`photoUrl`**: Profile photo URL (optional)

### Skills and Expertise
- **`skills`**: List of `EmployeeSkill` enums
- **`specializations`**: Custom specialization strings
- **`experienceYears`**: Years of professional experience
- **`certifications`**: Professional certifications list

### Availability & Work Preferences
- **`availability`**: Employee availability type
- **`preferredWorkDays`**: Days of the week available
- **`preferredStartTime`**: Preferred work start time
- **`preferredEndTime`**: Preferred work end time
- **`canWorkRemotely`**: Remote work capability
- **`location`**: Work location (optional)

### Performance Metrics
- **`totalOrdersCompleted`**: Total completed work orders
- **`ordersInProgress`**: Currently active assignments
- **`averageRating`**: Quality rating average (0-5)
- **`completionRate`**: On-time completion percentage
- **`strengths`**: Performance strengths list
- **`areasForImprovement`**: Areas needing development

### Compensation
- **`baseRatePerHour`**: Base hourly wage
- **`performanceBonusRate`**: Additional performance bonus
- **`paymentTerms`**: Payment frequency (weekly, bi-weekly, monthly)
- **`totalEarnings`**: Cumulative earnings to date

### Work History
- **`recentAssignments`**: List of recent `WorkAssignment` objects
- **`lastActive`**: Last activity timestamp
- **`consecutiveDaysWorked`**: Current work streak

### Administrative
- **`isActive`**: Employee active status
- **`joinedDate`**: Employment start date
- **`deactivatedDate`**: Deactivation date (optional)
- **`deactivationReason`**: Reason for deactivation (optional)
- **`additionalInfo`**: Flexible additional data

## Enums Documentation

### EmployeeSkill
```dart
enum EmployeeSkill {
  cutting,      // Fabric cutting
  stitching,    // Sewing/tailoring
  finishing,    // Final touches (buttons, hems, etc.)
  alterations,  // Alteration work
  embroidery,   // Embroidery work
  qualityCheck, // Quality inspection
  patternMaking // Pattern creation
}
```

### EmployeeAvailability
```dart
enum EmployeeAvailability {
  fullTime,     // 8 hours/day
  partTime,     // 4 hours/day
  flexible,     // Variable hours
  projectBased, // Per project basis
  remote,       // Works from home
  unavailable   // Currently not available
}
```

### WorkStatus
```dart
enum WorkStatus {
  notStarted,   // Order assigned but not started
  inProgress,   // Currently working on order
  paused,       // Work temporarily paused
  completed,    // Work finished
  qualityCheck, // Under quality review
  approved,     // Quality approved
  rejected      // Quality rejected, needs rework
}
```

## WorkAssignment Model

### Properties
- **`id`**: Unique assignment identifier
- **`orderId`**: Reference to the work order
- **`employeeId`**: Assigned employee identifier
- **`requiredSkill`**: Required skill for the assignment
- **`taskDescription`**: Detailed task description
- **`assignedAt`**: Assignment timestamp
- **`startedAt`**: Work start timestamp (optional)
- **`completedAt`**: Completion timestamp (optional)
- **`deadline`**: Assignment deadline (optional)
- **`status`**: Current work status
- **`estimatedHours`**: Estimated work hours
- **`actualHours`**: Actual hours worked
- **`hourlyRate`**: Pay rate for this assignment
- **`bonusRate`**: Bonus pay rate
- **`qualityNotes`**: Quality feedback notes
- **`qualityRating`**: Quality rating (0-5)
- **`updates`**: List of `WorkUpdate` objects
- **`materials`**: Materials provided for the work
- **`isRemoteWork`**: Remote work assignment flag
- **`location`**: Work location (optional)
- **`assignedBy`**: Manager who assigned the work

### Computed Properties
- **`totalEarnings`**: Total pay for the assignment
- **`isOverdue`**: Whether assignment is past deadline
- **`isOnTime`**: Whether completed on time

## WorkUpdate Model

### Properties
- **`id`**: Update identifier
- **`timestamp`**: Update timestamp
- **`message`**: Status update message
- **`status`**: Work status at time of update
- **`photoUrl`**: Progress photo URL (optional)
- **`hoursWorked`**: Hours worked to this point (optional)
- **`updatedBy`**: Person who made the update

## TimeOfDay Utility Class

### Properties
- **`hour`**: Hour in 24-hour format (0-23)
- **`minute`**: Minute (0-59)

### Methods
- **`formatTime()`**: Returns formatted time string (e.g., "9:30 AM")
- **`isBefore(other)`**: Compares if time is before another
- **`isAfter(other)`**: Compares if time is after another

## Key Methods

### Employee Methods
- **`hasSkill(skill)`**: Checks if employee has specific skill
- **`isAvailableOnDay(day)`**: Checks availability for specific day
- **`getHourlyRateWithBonus()`**: Returns total hourly rate with bonus
- **`isCurrentlyAvailable`**: Returns current availability status
- **`copyWith()`**: Creates modified employee copy

### WorkAssignment Methods
- **`totalEarnings`**: Calculates total pay (base + bonus)
- **`isOverdue`**: Checks if assignment is past deadline
- **`isOnTime`**: Checks if completed before deadline

## Firebase Integration

### Data Structure
```json
{
  "id": "emp_123",
  "userId": "auth_user_456",
  "displayName": "Sarah Johnson",
  "email": "sarah@tailorshop.com",
  "skills": [1, 2, 3],
  "specializations": ["Saree draping", "Bridal wear"],
  "experienceYears": 5,
  "availability": 0,
  "preferredWorkDays": ["Monday", "Tuesday", "Wednesday"],
  "baseRatePerHour": 25.0,
  "totalOrdersCompleted": 150,
  "averageRating": 4.8,
  "recentAssignments": [...],
  "isActive": true,
  "joinedDate": "Timestamp",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### Serialization Features
- **Enum Storage**: Skills and status stored as indices
- **Timestamp Handling**: Proper conversion between Dart DateTime and Firestore Timestamp
- **Nested Objects**: Complex relationships with assignments and updates
- **Optional Fields**: Flexible data structure with optional properties

## Usage Examples

### Creating an Employee
```dart
final employee = Employee(
  id: 'emp_sarah_johnson',
  userId: 'auth_user_456',
  displayName: 'Sarah Johnson',
  email: 'sarah@tailorshop.com',
  skills: [EmployeeSkill.stitching, EmployeeSkill.finishing],
  specializations: ['Saree draping', 'Bridal wear'],
  experienceYears: 5,
  certifications: ['Advanced Tailoring Certificate'],
  availability: EmployeeAvailability.fullTime,
  preferredWorkDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
  canWorkRemotely: false,
  totalOrdersCompleted: 150,
  ordersInProgress: 3,
  averageRating: 4.8,
  completionRate: 0.95,
  strengths: ['Attention to detail', 'Fast worker'],
  areasForImprovement: ['Documentation'],
  baseRatePerHour: 25.0,
  performanceBonusRate: 5.0,
  paymentTerms: 'Bi-weekly',
  totalEarnings: 25000.0,
  recentAssignments: [],
  consecutiveDaysWorked: 12,
  isActive: true,
  joinedDate: DateTime.now().subtract(Duration(days: 365)),
  additionalInfo: {},
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Creating a Work Assignment
```dart
final assignment = WorkAssignment(
  id: 'work_789',
  orderId: 'order_123',
  employeeId: 'emp_sarah_johnson',
  requiredSkill: EmployeeSkill.stitching,
  taskDescription: 'Stitch wedding gown with beading work',
  assignedAt: DateTime.now(),
  deadline: DateTime.now().add(Duration(days: 7)),
  status: WorkStatus.notStarted,
  estimatedHours: 16.0,
  actualHours: 0.0,
  hourlyRate: 25.0,
  bonusRate: 5.0,
  updates: [],
  materials: {'fabric': 'satin', 'beads': 'pearl'},
  isRemoteWork: false,
  assignedBy: 'manager_jane',
);
```

### Firebase Operations
```dart
// Save employee to Firestore
await FirebaseFirestore.instance
    .collection('employees')
    .doc(employee.id)
    .set(employee.toJson());

// Query available employees by skill
final availableEmployees = await FirebaseFirestore.instance
    .collection('employees')
    .where('isActive', isEqualTo: true)
    .where('skills', arrayContains: EmployeeSkill.stitching.index)
    .get();
```

## Integration Points

### Related Components
- **Employee Provider**: Manages employee state and operations
- **Employee Management Screens**: CRUD operations for employees
- **Work Assignment Service**: Manages work assignments and tracking
- **Analytics Service**: Employee performance analytics
- **Order Management**: Assigns work to employees

### Dependencies
- **Firebase Firestore**: Data persistence and real-time updates
- **Firebase Auth**: User authentication integration
- **Cloud Firestore**: Timestamp handling

## Business Logic

### Performance Tracking
- **Quality Metrics**: Rating system for work quality
- **Completion Rates**: On-time delivery tracking
- **Productivity Analytics**: Hours worked vs. estimated
- **Skill Development**: Areas for improvement tracking

### Compensation Management
- **Base Pay**: Hourly rate structure
- **Performance Bonuses**: Incentive-based compensation
- **Payment Terms**: Flexible payment scheduling
- **Earnings Tracking**: Cumulative earnings calculation

### Work Scheduling
- **Availability Management**: Flexible scheduling options
- **Work Assignment**: Skill-based task assignment
- **Progress Tracking**: Real-time work status updates
- **Quality Control**: Multi-stage approval process

## Security Considerations

### Data Access Control
- **Role-Based Access**: Different permissions for managers vs. employees
- **Employee Data Privacy**: Secure handling of personal information
- **Performance Data**: Protected performance metrics
- **Assignment Visibility**: Appropriate access to work assignments

### Data Validation
- **Skill Requirements**: Validation of required skills for assignments
- **Time Tracking**: Accurate time logging for payroll
- **Quality Standards**: Consistent quality rating criteria
- **Availability Rules**: Business rule validation for scheduling

## Performance Optimization

### Data Loading Strategies
- **Lazy Loading**: Load employee details on demand
- **Pagination**: Handle large employee lists efficiently
- **Caching**: Cache frequently accessed employee data
- **Real-time Updates**: Stream updates for active assignments

### Query Optimization
- **Skill Indexing**: Efficient skill-based queries
- **Availability Filtering**: Fast availability lookups
- **Performance Metrics**: Optimized analytics queries
- **Assignment Tracking**: Efficient work assignment queries

## Analytics Integration

### Key Metrics
- **Employee Productivity**: Orders completed per time period
- **Quality Scores**: Average quality ratings over time
- **Skill Utilization**: How often specific skills are used
- **Assignment Completion**: Success rates for different assignment types

### Reporting Features
- **Performance Reports**: Individual employee performance
- **Team Analytics**: Team-level productivity metrics
- **Skill Gap Analysis**: Identify training needs
- **Workload Balancing**: Optimize assignment distribution

This comprehensive employee model provides a solid foundation for managing a tailoring shop's workforce, supporting everything from basic employee information to complex work assignment tracking and performance analytics.