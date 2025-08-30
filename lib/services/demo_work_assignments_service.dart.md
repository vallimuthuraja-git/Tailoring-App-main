# Demo Work Assignments Service Documentation

## Overview
The `demo_work_assignments_service.dart` file contains the comprehensive demo work assignment generation system for the AI-Enabled Tailoring Shop Management System. It creates realistic work assignments for demo employees, simulating a complete tailoring workshop workflow with various task types, skill requirements, and progress tracking.

## Architecture

### Core Components
- **`DemoWorkAssignmentsService`**: Main service for creating and managing demo work assignments
- **Firebase Integration**: Firestore-based storage for work assignments
- **Role-Based Assignments**: Specialized assignments for different employee types
- **Work Status Tracking**: Complete lifecycle management from assignment to completion
- **Quality Management**: Rating and feedback systems for completed work
- **Time Tracking**: Estimated vs actual hours with deadline management
- **Materials Management**: Tracking of materials used in assignments

### Key Features
- **Realistic Workflow Simulation**: Complete tailoring process from cutting to finishing
- **Multi-Role Employee Support**: Specialized assignments for different skill sets
- **Comprehensive Status Tracking**: All stages of work completion
- **Quality Assurance Integration**: Built-in quality checks and ratings
- **Progress Monitoring**: Detailed updates and timeline tracking
- **Resource Management**: Materials and location tracking
- **Cleanup Utilities**: Demo data management and removal

## Firebase Integration

### Firestore Collections
```dart
// Work assignments storage
_firestore.collection('work_assignments')

// Employee data retrieval
_firestore.collection('employees')
```

### Data Structure
```dart
// Work Assignment Document Structure
{
  'id': 'assignment_id',
  'orderId': 'order_001',
  'employeeId': 'employee_id',
  'requiredSkill': 0, // EmployeeSkill enum index
  'taskDescription': 'Task description',
  'assignedAt': Timestamp,
  'deadline': Timestamp,
  'status': 0, // WorkStatus enum index
  'estimatedHours': 3.0,
  'actualHours': 2.5,
  'hourlyRate': 150.0,
  'bonusRate': 50.0,
  'updates': [...], // WorkUpdate array
  'materials': {...}, // Material map
  'isRemoteWork': false,
  'location': 'Main Workshop',
  'assignedBy': 'Shop Owner',
  // Optional fields
  'startedAt': Timestamp,
  'completedAt': Timestamp,
  'qualityNotes': 'Quality feedback',
  'qualityRating': 4.8
}
```

## Demo Employee Setup

### Employee Types
The service creates assignments for four specialized employee roles:

#### General Employee (`employee@demo.com`)
- **Skills**: Mixed assignments (stitching, finishing, alterations)
- **Work Focus**: Versatile tasks across different garment types
- **Location**: Main Workshop

#### Master Tailor (`tailor@demo.com`)
- **Skills**: Complex stitching, alterations, embroidery
- **Work Focus**: Premium garments requiring specialized techniques
- **Location**: Premium Workshop

#### Cutter (`cutter@demo.com`)
- **Skills**: Pattern making, fabric cutting
- **Work Focus**: Precision cutting and pattern development
- **Location**: Cutting Room

#### Finisher (`finisher@demo.com`)
- **Skills**: Finishing touches, quality inspection
- **Work Focus**: Final assembly, quality control, and packaging
- **Location**: Finishing Station / Quality Station

### Employee Retrieval
```dart
Future<List<emp.Employee>> _getDemoEmployees() async {
  final employeeEmails = [
    'employee@demo.com',
    'tailor@demo.com',
    'cutter@demo.com',
    'finisher@demo.com'
  ];

  for (final email in employeeEmails) {
    final employeeDoc = await _firestore
        .collection('employees')
        .where('email', isEqualTo: email)
        .get();
  }
}
```

## Work Assignment Categories

### General Employee Assignments

#### Not Started Assignment
```dart
emp.WorkAssignment(
  id: 'general_1_${employee.id}',
  orderId: 'order_001',
  employeeId: employee.id,
  requiredSkill: emp.EmployeeSkill.stitching,
  taskDescription: 'Stitch collar and cuffs for business shirt',
  assignedAt: now.subtract(const Duration(hours: 2)),
  deadline: now.add(const Duration(days: 2)),
  status: emp.WorkStatus.notStarted,
  estimatedHours: 3.0,
  actualHours: 0.0,
  materials: {'fabric': 'Cotton blend', 'thread': 'Matching color'},
  location: 'Main Workshop',
)
```

#### In Progress Assignment
```dart
emp.WorkAssignment(
  id: 'general_2_${employee.id}',
  orderId: 'order_002',
  employeeId: employee.id,
  requiredSkill: emp.EmployeeSkill.finishing,
  taskDescription: 'Attach buttons and finish hems on dress shirt',
  startedAt: now.subtract(const Duration(hours: 3)),
  status: emp.WorkStatus.inProgress,
  actualHours: 1.5,
  updates: [
    emp.WorkUpdate(
      id: 'update_1',
      timestamp: now.subtract(const Duration(hours: 2)),
      message: 'Started button attachment',
      status: emp.WorkStatus.inProgress,
    ),
  ],
)
```

#### Completed Assignment
```dart
emp.WorkAssignment(
  id: 'general_3_${employee.id}',
  orderId: 'order_003',
  completedAt: now.subtract(const Duration(days: 1)),
  status: emp.WorkStatus.completed,
  actualHours: 1.2,
  qualityNotes: 'Excellent work, sleeves perfectly aligned',
  qualityRating: 4.8,
)
```

#### Quality Check Assignment
```dart
emp.WorkAssignment(
  id: 'general_4_${employee.id}',
  orderId: 'order_004',
  completedAt: now.subtract(const Duration(hours: 6)),
  status: emp.WorkStatus.qualityCheck,
  actualHours: 0.8,
)
```

### Tailor Assignments

#### Complex Stitching Work
```dart
emp.WorkAssignment(
  id: 'tailor_1_${employee.id}',
  orderId: 'order_005',
  requiredSkill: emp.EmployeeSkill.stitching,
  taskDescription: 'Hand-stitch lapel and collar on premium suit',
  estimatedHours: 8.0,
  actualHours: 3.5,
  materials: {'suit': 'Premium wool', 'thread': 'Silk blend'},
  location: 'Premium Workshop',
)
```

#### Alterations Work
```dart
emp.WorkAssignment(
  id: 'tailor_2_${employee.id}',
  orderId: 'order_006',
  requiredSkill: emp.EmployeeSkill.alterations,
  taskDescription: 'Take in wedding gown for perfect fit',
  qualityRating: 5.0,
  qualityNotes: 'Beautiful work on delicate fabric',
)
```

#### Embroidery Work
```dart
emp.WorkAssignment(
  id: 'tailor_3_${employee.id}',
  orderId: 'order_007',
  requiredSkill: emp.EmployeeSkill.embroidery,
  taskDescription: 'Add monogram to suit pocket',
  materials: {'suit': 'Charcoal wool', 'thread': 'Gold metallic'},
)
```

#### Paused Work
```dart
emp.WorkAssignment(
  id: 'tailor_4_${employee.id}',
  orderId: 'order_008',
  status: emp.WorkStatus.paused,
  taskDescription: 'Repair vintage suit with period-accurate techniques',
  materials: {'vintage_suit': '1950s wool', 'special_thread': 'Period authentic'},
)
```

### Cutter Assignments

#### Pattern Making
```dart
emp.WorkAssignment(
  id: 'cutter_1_${employee.id}',
  orderId: 'order_009',
  requiredSkill: emp.EmployeeSkill.patternMaking,
  taskDescription: 'Create pattern for custom dress design',
  materials: {'paper': 'Pattern paper', 'measurements': 'Client measurements'},
  location: 'Cutting Room',
)
```

#### Fabric Cutting
```dart
emp.WorkAssignment(
  id: 'cutter_2_${employee.id}',
  orderId: 'order_010',
  requiredSkill: emp.EmployeeSkill.cutting,
  taskDescription: 'Cut fabric for 3-piece suit',
  qualityRating: 4.9,
  qualityNotes: 'Excellent precision cutting, minimal waste',
  materials: {'suit_fabric': 'Italian wool', 'lining': 'Silk blend'},
)
```

#### Complex Cutting Work
```dart
emp.WorkAssignment(
  id: 'cutter_3_${employee.id}',
  orderId: 'order_011',
  taskDescription: 'Cut delicate silk fabric for evening gown',
  materials: {'silk_fabric': 'Premium silk', 'special_tools': 'Sharp scissors'},
)
```

### Finisher Assignments

#### Button Attachment
```dart
emp.WorkAssignment(
  id: 'finisher_1_${employee.id}',
  orderId: 'order_013',
  requiredSkill: emp.EmployeeSkill.finishing,
  taskDescription: 'Attach premium buttons to suit jacket',
  materials: {'buttons': 'Horn buttons', 'thread': 'Matching'},
  location: 'Finishing Station',
)
```

#### Hemming Work
```dart
emp.WorkAssignment(
  id: 'finisher_2_${employee.id}',
  orderId: 'order_014',
  taskDescription: 'Hem trousers with invisible stitches',
  qualityRating: 4.7,
  qualityNotes: 'Perfect invisible hemming, excellent finish',
  materials: {'trousers': 'Wool blend', 'thread': 'Invisible hem thread'},
)
```

#### Quality Inspection
```dart
emp.WorkAssignment(
  id: 'finisher_3_${employee.id}',
  orderId: 'order_015',
  requiredSkill: emp.EmployeeSkill.qualityCheck,
  taskDescription: 'Quality inspection of completed suit',
  materials: {'suit': 'Complete suit', 'inspection_tools': 'Magnifying glass'},
  location: 'Quality Station',
)
```

#### Final Touches
```dart
emp.WorkAssignment(
  id: 'finisher_4_${employee.id}',
  orderId: 'order_016',
  taskDescription: 'Add final touches and packaging',
  qualityRating: 4.8,
  qualityNotes: 'Perfect finishing, excellent presentation',
  materials: {'packaging': 'Premium box', 'tags': 'Branded tags'},
)
```

## Work Status Management

### Status Types
- **`WorkStatus.notStarted`**: Assignment created but work not begun
- **`WorkStatus.inProgress`**: Work currently being performed
- **`WorkStatus.paused`**: Work temporarily stopped (waiting for materials, etc.)
- **`WorkStatus.completed`**: Work finished successfully
- **`WorkStatus.qualityCheck`**: Work completed, awaiting quality inspection

### Status Transitions
```dart
// Automatic status progression
notStarted → inProgress (when work begins)
inProgress → paused (when work is temporarily stopped)
paused → inProgress (when work resumes)
inProgress → completed (when work is finished)
completed → qualityCheck (if quality inspection required)
qualityCheck → completed (after quality approval)
```

## Quality Management

### Quality Rating System
```dart
// Rating scale: 1.0 - 5.0
qualityRating: 4.8, // Excellent work
qualityRating: 5.0, // Perfect work
qualityRating: 4.9, // Outstanding work
qualityRating: 4.7, // Very good work
```

### Quality Notes
```dart
qualityNotes: 'Excellent work, sleeves perfectly aligned'
qualityNotes: 'Beautiful work on delicate fabric'
qualityNotes: 'Excellent precision cutting, minimal waste'
qualityNotes: 'Perfect invisible hemming, excellent finish'
```

## Time Tracking

### Estimated vs Actual Hours
```dart
// Realistic time estimates
estimatedHours: 3.0, actualHours: 2.5  // Efficient work
estimatedHours: 8.0, actualHours: 3.5  // Complex work in progress
estimatedHours: 1.5, actualHours: 1.2  // Quick completion
estimatedHours: 4.0, actualHours: 3.8  // Slight overrun
```

### Deadline Management
```dart
// Deadline examples
deadline: now.add(const Duration(days: 2)),     // Standard deadline
deadline: now.add(const Duration(days: 3)),     // Extended deadline
deadline: now.add(const Duration(hours: 12)),   // Urgent deadline
deadline: now.subtract(const Duration(days: 2)), // Overdue work
```

## Materials Tracking

### Material Categories
```dart
materials: {
  // Fabrics
  'fabric': 'Cotton blend',
  'suit_fabric': 'Italian wool',
  'silk_fabric': 'Premium silk',
  'vintage_suit': '1950s wool',

  // Threads and accessories
  'thread': 'Matching color',
  'special_thread': 'Period authentic',
  'buttons': 'Horn buttons',
  'gold metallic': 'Gold metallic',

  // Tools and supplies
  'special_tools': 'Sharp scissors',
  'inspection_tools': 'Magnifying glass',
  'paper': 'Pattern paper',

  // Packaging
  'packaging': 'Premium box',
  'tags': 'Branded tags'
}
```

## Work Update System

### Update Structure
```dart
emp.WorkUpdate(
  id: 'update_1',
  timestamp: now.subtract(const Duration(hours: 2)),
  message: 'Started button attachment',
  status: emp.WorkStatus.inProgress,
  updatedBy: employee.displayName,
)
```

### Progress Tracking
```dart
updates: [
  {
    'id': 'update_1',
    'timestamp': '2024-01-01T10:00:00Z',
    'message': 'Started work on assignment',
    'status': 'inProgress',
    'updatedBy': 'John Smith'
  },
  {
    'id': 'update_2',
    'timestamp': '2024-01-01T12:00:00Z',
    'message': 'Completed initial phase',
    'status': 'inProgress',
    'updatedBy': 'John Smith'
  }
]
```

## Query Methods

### Employee-Specific Queries
```dart
Future<List<emp.WorkAssignment>> getEmployeeWorkAssignments(String employeeId) async {
  final assignmentsQuery = await _firestore
      .collection('work_assignments')
      .where('employeeId', isEqualTo: employeeId)
      .orderBy('assignedAt', descending: true)
      .get();
}
```

### Status-Based Queries
```dart
Future<List<emp.WorkAssignment>> getWorkAssignmentsByStatus(emp.WorkStatus status) async {
  final assignmentsQuery = await _firestore
      .collection('work_assignments')
      .where('status', isEqualTo: status.index)
      .orderBy('assignedAt', descending: true)
      .get();
}
```

### Overdue Assignments
```dart
Future<List<emp.WorkAssignment>> getOverdueAssignments() async {
  final assignments = await _firestore
      .collection('work_assignments')
      .where('status', isNotEqualTo: emp.WorkStatus.completed.index)
      .get();

  return assignments.docs
      .map((doc) => emp.WorkAssignment.fromJson({...doc.data(), 'id': doc.id}))
      .where((assignment) => assignment.isOverdue)
      .toList();
}
```

## Cleanup and Management

### Demo Data Cleanup
```dart
Future<void> cleanupDemoAssignments() async {
  final demoOrderIds = [
    'order_001', 'order_002', 'order_003', 'order_004', 'order_005',
    'order_006', 'order_007', 'order_008', 'order_009', 'order_010',
    'order_011', 'order_012', 'order_013', 'order_014', 'order_015', 'order_016'
  ];

  for (final orderId in demoOrderIds) {
    final assignmentsQuery = await _firestore
        .collection('work_assignments')
        .where('orderId', isEqualTo: orderId)
        .get();

    for (final doc in assignmentsQuery.docs) {
      await doc.reference.delete();
    }
  }
}
```

## Usage Examples

### Creating Demo Assignments
```dart
class DemoSetupManager {
  final DemoWorkAssignmentsService _assignmentsService = DemoWorkAssignmentsService();

  Future<void> setupDemoEnvironment() async {
    try {
      print('🚀 Setting up demo work assignments...');
      await _assignmentsService.createDemoWorkAssignments();
      print('✅ Demo setup complete!');
    } catch (e) {
      print('❌ Error setting up demo: $e');
    }
  }
}
```

### Monitoring Work Progress
```dart
class WorkAssignmentMonitor {
  final DemoWorkAssignmentsService _service = DemoWorkAssignmentsService();

  Future<void> printWorkSummary() async {
    final allAssignments = await _service.getWorkAssignmentsByStatus(emp.WorkStatus.values);

    print('📊 Work Assignment Summary:');
    for (final status in emp.WorkStatus.values) {
      final count = allAssignments.where((a) => a.status == status).length;
      print('${status.toString()}: $count assignments');
    }
  }

  Future<void> checkOverdueWork() async {
    final overdue = await _service.getOverdueAssignments();
    if (overdue.isNotEmpty) {
      print('⚠️  ${overdue.length} assignments are overdue');
      for (final assignment in overdue) {
        print('  - ${assignment.taskDescription} (Due: ${assignment.deadline})');
      }
    }
  }
}
```

### Quality Analysis
```dart
class QualityAnalyzer {
  final DemoWorkAssignmentsService _service = DemoWorkAssignmentsService();

  Future<Map<String, dynamic>> analyzeWorkQuality() async {
    final completedAssignments = await _service.getWorkAssignmentsByStatus(emp.WorkStatus.completed);

    if (completedAssignments.isEmpty) {
      return {'averageRating': 0.0, 'totalReviewed': 0};
    }

    final totalRating = completedAssignments
        .where((a) => a.qualityRating != null)
        .fold<double>(0, (sum, a) => sum + (a.qualityRating ?? 0));

    final reviewedCount = completedAssignments.where((a) => a.qualityRating != null).length;

    return {
      'averageRating': totalRating / reviewedCount,
      'totalReviewed': reviewedCount,
      'totalCompleted': completedAssignments.length,
      'qualityBreakdown': _categorizeQuality(completedAssignments)
    };
  }

  Map<String, int> _categorizeQuality(List<emp.WorkAssignment> assignments) {
    return assignments.where((a) => a.qualityRating != null).fold<Map<String, int>>({}, (map, a) {
      final rating = a.qualityRating!;
      if (rating >= 4.5) {
        map['Excellent'] = (map['Excellent'] ?? 0) + 1;
      } else if (rating >= 4.0) {
        map['Good'] = (map['Good'] ?? 0) + 1;
      } else {
        map['Needs Improvement'] = (map['Needs Improvement'] ?? 0) + 1;
      }
      return map;
    });
  }
}
```

### Employee Performance Tracking
```dart
class EmployeePerformanceTracker {
  final DemoWorkAssignmentsService _service = DemoWorkAssignmentsService();

  Future<Map<String, dynamic>> trackEmployeePerformance(String employeeId) async {
    final assignments = await _service.getEmployeeWorkAssignments(employeeId);

    final completedCount = assignments.where((a) => a.status == emp.WorkStatus.completed).length;
    final inProgressCount = assignments.where((a) => a.status == emp.WorkStatus.inProgress).length;
    final overdueCount = assignments.where((a) => a.isOverdue).length;

    final totalHours = assignments.fold<double>(0, (sum, a) => sum + a.actualHours);
    final estimatedHours = assignments.fold<double>(0, (sum, a) => sum + a.estimatedHours);

    final averageRating = assignments
        .where((a) => a.qualityRating != null)
        .fold<double>(0, (sum, a) => sum + (a.qualityRating ?? 0)) /
        assignments.where((a) => a.qualityRating != null).length;

    return {
      'totalAssignments': assignments.length,
      'completedAssignments': completedCount,
      'inProgressAssignments': inProgressCount,
      'overdueAssignments': overdueCount,
      'completionRate': assignments.isNotEmpty ? completedCount / assignments.length : 0,
      'totalActualHours': totalHours,
      'totalEstimatedHours': estimatedHours,
      'efficiency': estimatedHours > 0 ? totalHours / estimatedHours : 0,
      'averageQualityRating': averageRating.isNaN ? 0 : averageRating,
    };
  }
}
```

## Integration Points

### Related Components
- **Work Assignment Service**: Core work assignment management
- **Employee Service**: Employee data and skill management
- **Quality Control Service**: Quality assessment and feedback
- **Notification Service**: Assignment updates and alerts
- **Analytics Service**: Performance metrics and reporting

### Provider Integration
```dart
class WorkAssignmentProvider extends ChangeNotifier {
  final DemoWorkAssignmentsService _demoService = DemoWorkAssignmentsService();

  List<emp.WorkAssignment> _assignments = [];

  Future<void> loadDemoAssignments() async {
    await _demoService.createDemoWorkAssignments();
    await loadAssignments(); // Reload from Firestore
    notifyListeners();
  }

  Future<void> loadAssignments() async {
    // Load assignments from Firestore
    _assignments = await _demoService.getEmployeeWorkAssignments('current_employee_id');
    notifyListeners();
  }
}
```

## Business Logic

### Workflow Simulation
- **Complete Tailoring Process**: Demonstrates full workflow from cutting to delivery
- **Role Specialization**: Shows how different skills contribute to final product
- **Quality Control**: Illustrates quality checkpoints throughout the process
- **Time Management**: Realistic timelines for different types of work
- **Resource Allocation**: Proper assignment of tasks based on employee skills

### Performance Metrics
- **Completion Rates**: Track assignment completion over time
- **Quality Scores**: Monitor work quality and consistency
- **Time Efficiency**: Compare estimated vs actual work hours
- **Skill Utilization**: Ensure employees are working within their expertise
- **Deadline Compliance**: Monitor on-time delivery performance

### Operational Insights
- **Workload Distribution**: Balance assignments across employees
- **Skill Gap Analysis**: Identify areas needing additional training
- **Process Optimization**: Find bottlenecks in the workflow
- **Quality Improvement**: Target areas for quality enhancement
- **Resource Planning**: Forecast staffing needs based on workload

This comprehensive demo work assignments service provides realistic workflow simulation for testing and demonstrating the tailoring shop management system's work assignment capabilities, offering valuable insights into operational efficiency and employee performance.