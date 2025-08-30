# Notification Service Documentation

## Overview
The `notification_service.dart` file contains the comprehensive notification and communication system for the AI-Enabled Tailoring Shop Management System. It provides real-time notifications, priority management, and automated communication for all business operations, supporting work assignments, quality control, deadlines, and customer interactions.

## Architecture

### Core Components
- **`Notification`**: Individual notification data structure with comprehensive metadata
- **`NotificationService`**: Main service handling all notification operations
- **Notification Types**: 13 specialized notification categories for tailoring operations
- **Priority System**: 5-level priority system from low to critical
- **Real-time Updates**: Live notification streaming and status updates

### Key Features
- **Multi-channel Notifications**: Support for different notification types and priorities
- **Real-time Delivery**: Instant notification delivery with live updates
- **Automated Scheduling**: Deadline reminders and automated notifications
- **Priority Management**: Intelligent priority escalation based on context
- **Action Integration**: Deep linking and action-required notifications
- **Analytics & Reporting**: Notification statistics and performance metrics
- **Data Management**: Comprehensive CRUD operations and cleanup utilities

## Notification Types

### Business Operation Notifications
```dart
enum NotificationType {
  workAssignment,      // New work assigned to employee
  workUpdate,          // Work status/progress updates
  qualityCheck,        // Quality inspection results
  deadlineReminder,    // Upcoming deadline alerts
  reworkRequired,      // Work needs corrections
  paymentReceived,     // Payment confirmations
  orderCompleted,      // Order finished notifications
  feedbackReceived,    // Customer feedback alerts
  systemAlert,         // General system notifications
  scheduleChange,      // Schedule modification alerts
  emergencyAlert,      // Critical emergency notifications
  trainingReminder,    // Training due notifications
  performanceReview,   // Performance review scheduling
}
```

### Priority Levels
```dart
enum NotificationPriority {
  low,      // General information and updates
  normal,   // Regular business communications
  high,     // Important notifications requiring attention
  urgent,   // Time-sensitive notifications requiring immediate action
  critical, // Emergency situations requiring immediate response
}
```

## Notification Class

### Comprehensive Notification Structure
```dart
class Notification {
  final String id;
  final String recipientId;
  final String recipientName;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final Map<String, dynamic> data;    // Context-specific data
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionUrl;           // Deep link for actions
  final bool requiresAction;
  final String? senderId;
  final String? senderName;
  final String? category;            // Grouping category
}
```

### Computed Properties

#### Effective Priority with Escalation
```dart
NotificationPriority get effectivePriority {
  // Escalate priority for urgent deadlines
  if (type == NotificationType.deadlineReminder && data['hoursUntilDeadline'] < 4) {
    return NotificationPriority.urgent;
  }
  return priority;
}
```

#### Status and UI Properties
```dart
bool get isOverdue => !isRead && createdAt.isBefore(DateTime.now().subtract(const Duration(days: 7)));

Color get priorityColor {
  switch (effectivePriority) {
    case NotificationPriority.low: return Colors.grey;
    case NotificationPriority.normal: return Colors.blue;
    case NotificationPriority.high: return Colors.orange;
    case NotificationPriority.urgent: return Colors.red;
    case NotificationPriority.critical: return Colors.red.shade900;
  }
}

IconData get icon {
  switch (type) {
    case NotificationType.workAssignment: return Icons.assignment;
    case NotificationType.qualityCheck: return Icons.check_circle;
    case NotificationType.deadlineReminder: return Icons.schedule;
    case NotificationType.emergencyAlert: return Icons.warning;
    // ... specialized icons for each type
  }
}
```

## NotificationService Class

### Core Notification Operations

#### Send Notification
```dart
Future<bool> sendNotification({
  required String recipientId,
  required String recipientName,
  required NotificationType type,
  required NotificationPriority priority,
  required String title,
  required String message,
  Map<String, dynamic>? data,
  String? actionUrl,
  bool requiresAction = false,
  String? senderId,
  String? senderName,
  String? category,
})
```
**Universal Notification Creation:**
- Flexible recipient targeting
- Rich metadata support
- Action integration with deep linking
- Category-based grouping
- Sender identification

#### Notification Management
```dart
Future<List<Notification>> getUserNotifications(String userId)
Future<int> getUnreadCount(String userId)
Future<bool> markAsRead(String notificationId)
Future<bool> markAllAsRead(String userId)
Future<bool> deleteNotification(String notificationId)
```

#### Real-time Updates
```dart
Stream<List<Notification>> getNotificationStream(String userId)
Stream<int> getUnreadCountStream(String userId)
```
**Live Data Features:**
- Real-time notification delivery
- Live unread count updates
- Automatic UI refresh
- Connection status monitoring

## Specialized Notification Methods

### Work Assignment Notifications
```dart
Future<void> sendWorkAssignmentNotification({
  required String employeeId,
  required String employeeName,
  required String orderId,
  required String taskDescription,
  required DateTime deadline,
  required String assignedBy,
})
```
**Work Assignment Features:**
- Automatic priority assignment (high)
- Deadline integration
- Task description inclusion
- Assignment tracking
- Action-required flag

### Quality Control Notifications
```dart
Future<void> sendQualityCheckNotification({
  required String employeeId,
  required String employeeName,
  required String orderId,
  required String checkpointName,
  required String result,
  required double score,
  required String feedback,
  required String inspectorName,
})
```
**Quality Notification Features:**
- Dynamic priority based on score (< 7.0 = urgent)
- Comprehensive quality data
- Inspector identification
- Performance feedback inclusion

### Deadline Management
```dart
Future<void> sendDeadlineReminder({
  required String employeeId,
  required String employeeName,
  required String orderId,
  required String taskDescription,
  required DateTime deadline,
  required int hoursUntilDeadline,
})
```
**Intelligent Deadline Features:**
- Dynamic priority based on time remaining
- Hours-based escalation (< 4 hours = urgent)
- Task context preservation
- Action-required for urgent deadlines

### Automated Scheduling
```dart
Future<void> scheduleDeadlineReminders()
```
**Automated Reminder System:**
- Scans active work assignments
- Identifies upcoming deadlines (24-hour window)
- Sends contextual reminders
- Prevents duplicate notifications
- Handles scheduling conflicts

## Business-Specific Notifications

### Financial Notifications
```dart
Future<void> sendPaymentNotification({
  required String recipientId,
  required String recipientName,
  required String orderId,
  required double amount,
  required String paymentType,
})
```
**Payment Communication:**
- Amount formatting and context
- Payment type identification
- Order association
- Financial record integration

### Completion Notifications
```dart
Future<void> sendOrderCompletionNotification({
  required String employeeId,
  required String employeeName,
  required String orderId,
  required String customerName,
  required double earnings,
})
```
**Completion Features:**
- Customer name inclusion
- Earnings calculation
- Completion timestamp
- Performance tracking

### Training & Development
```dart
Future<void> sendTrainingReminder({
  required String employeeId,
  required String employeeName,
  required String trainingName,
  required DateTime dueDate,
  required int daysUntilDue,
})
```
**Training Management:**
- Dynamic priority based on due date
- Training context preservation
- Progress tracking
- Compliance monitoring

### Performance Management
```dart
Future<void> sendPerformanceReviewNotification({
  required String employeeId,
  required String employeeName,
  required DateTime reviewDate,
  required String reviewerName,
})
```
**Review Coordination:**
- High priority assignment
- Reviewer identification
- Review scheduling
- Performance tracking integration

### Emergency Communications
```dart
Future<void> sendEmergencyNotification({
  required List<String> recipientIds,
  required List<String> recipientNames,
  required String title,
  required String message,
  required String emergencyType,
  Map<String, dynamic>? additionalData,
})
```
**Emergency Features:**
- Bulk recipient handling
- Critical priority assignment
- Emergency type classification
- Immediate action requirements

## Rework Management
```dart
Future<void> sendReworkRequiredNotification({
  required String employeeId,
  required String employeeName,
  required String orderId,
  required String workDescription,
  required List<String> issues,
  required String requestedBy,
})
```
**Rework Coordination:**
- Urgent priority assignment
- Detailed issue listing
- Quality requirement communication
- Resolution tracking

## Analytics and Reporting

### Notification Statistics
```dart
Future<Map<String, dynamic>> getNotificationStats(String userId)
```
**Comprehensive Analytics:**
- **Volume Metrics**: Total, unread, urgent, critical counts
- **Type Breakdown**: Notification distribution by category
- **Response Time**: Average time to read notifications
- **Priority Analysis**: Priority distribution and handling
- **Trend Analysis**: Notification patterns over time

### Response Time Calculation
```dart
double _calculateAverageResponseTime(List<Notification> notifications)
```
**Response Analytics:**
- Read timestamp tracking
- Average response calculation
- Performance benchmarking
- Efficiency monitoring

## Data Management

### Cleanup Operations
```dart
Future<void> cleanupOldNotifications()
```
**Data Maintenance:**
- Automatic 30-day cleanup
- Storage optimization
- Performance maintenance
- Data retention compliance

### Batch Operations
```dart
Future<bool> markAllAsRead(String userId)
```
**Bulk Management:**
- Efficient batch updates
- Performance optimization
- User experience enhancement
- Data consistency maintenance

## Firebase Integration

### Data Structure
```json
{
  "id": "notification_123",
  "recipientId": "employee_456",
  "recipientName": "John Smith",
  "type": 1,
  "priority": 2,
  "title": "New Work Assignment",
  "message": "You have been assigned: Custom suit stitching",
  "data": {
    "orderId": "order_789",
    "taskDescription": "Custom suit stitching",
    "deadline": "2024-01-15T17:00:00.000Z",
    "assignedBy": "manager_jane"
  },
  "isRead": false,
  "createdAt": "Timestamp",
  "readAt": null,
  "actionUrl": "/work-assignment/order_789",
  "requiresAction": true,
  "senderId": "manager_jane",
  "senderName": "Jane Manager",
  "category": "work"
}
```

### Collections
- **`notifications`**: Main notification storage
- **Indexing**: Optimized queries by recipient and status
- **Real-time**: Live updates for active notifications

### Performance Optimizations
- **Compound Queries**: Efficient recipient filtering
- **Pagination**: Limited result sets for performance
- **Batch Operations**: Optimized bulk updates
- **Stream Management**: Efficient real-time subscriptions

## Usage Examples

### Notification Center Implementation
```dart
class NotificationCenter extends StatefulWidget {
  final String userId;

  @override
  _NotificationCenterState createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  final NotificationService _notificationService = NotificationService();
  late Stream<List<Notification>> _notificationStream;

  @override
  void initState() {
    super.initState();
    _notificationStream = _notificationService.getNotificationStream(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Notification>>(
      stream: _notificationStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data!;
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationTile(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onMarkAsRead: () => _markAsRead(notification.id),
            );
          },
        );
      },
    );
  }

  Future<void> _handleNotificationTap(Notification notification) async {
    // Mark as read
    await _notificationService.markAsRead(notification.id);

    // Navigate to action URL if provided
    if (notification.actionUrl != null) {
      Navigator.pushNamed(context, notification.actionUrl!);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }
}
```

### Work Assignment Integration
```dart
class WorkAssignmentHandler {
  final NotificationService _notificationService = NotificationService();

  Future<void> assignWork({
    required String employeeId,
    required String employeeName,
    required String orderId,
    required String taskDescription,
    required DateTime deadline,
  }) async {
    // Create work assignment in database
    // ...

    // Send notification
    await _notificationService.sendWorkAssignmentNotification(
      employeeId: employeeId,
      employeeName: employeeName,
      orderId: orderId,
      taskDescription: taskDescription,
      deadline: deadline,
      assignedBy: 'system',
    );
  }
}
```

### Quality Control Integration
```dart
class QualityInspector {
  final NotificationService _notificationService = NotificationService();

  Future<void> submitQualityInspection({
    required String employeeId,
    required String employeeName,
    required String orderId,
    required String checkpointName,
    required double score,
    required String feedback,
  }) async {
    // Submit quality inspection
    // ...

    // Send notification
    await _notificationService.sendQualityCheckNotification(
      employeeId: employeeId,
      employeeName: employeeName,
      orderId: orderId,
      checkpointName: checkpointName,
      result: score >= 7.0 ? 'Passed' : 'Needs Improvement',
      score: score,
      feedback: feedback,
      inspectorName: 'Quality Inspector',
    );
  }
}
```

### Deadline Monitoring System
```dart
class DeadlineMonitor {
  final NotificationService _notificationService = NotificationService();

  Future<void> startMonitoring() async {
    // Schedule deadline reminders every hour
    Timer.periodic(Duration(hours: 1), (timer) async {
      await _notificationService.scheduleDeadlineReminders();
    });
  }
}
```

### Emergency Alert System
```dart
class EmergencyAlertSystem {
  final NotificationService _notificationService = NotificationService();

  Future<void> sendEmergencyAlert({
    required List<String> employeeIds,
    required List<String> employeeNames,
    required String emergencyType,
    required String message,
  }) async {
    await _notificationService.sendEmergencyNotification(
      recipientIds: employeeIds,
      recipientNames: employeeNames,
      title: 'EMERGENCY ALERT',
      message: message,
      emergencyType: emergencyType,
      additionalData: {
        'alertLevel': 'critical',
        'requiresImmediateAction': true,
      },
    );
  }
}
```

## Integration Points

### Related Components
- **Work Assignment Service**: Automatic assignment notifications
- **Quality Control Service**: Quality inspection notifications
- **Order Provider**: Order status and completion notifications
- **Employee Provider**: Employee-specific notifications
- **Authentication Service**: User identification for notifications

### Dependencies
- **Firebase Firestore**: Notification data persistence
- **Flutter Framework**: UI integration and navigation
- **Timer Service**: Scheduled notification delivery
- **Deep Linking**: Action URL navigation support

## Security Considerations

### Notification Privacy
- **Recipient Verification**: Secure recipient identification
- **Data Encryption**: Sensitive data protection
- **Access Control**: Notification access based on user roles
- **Audit Trail**: Complete notification history tracking

### Business Logic Security
- **Priority Validation**: Secure priority level assignment
- **Action URL Security**: Safe deep linking implementation
- **Data Sanitization**: Safe data handling and validation
- **Rate Limiting**: Prevention of notification spam

## Performance Optimization

### Efficient Delivery
- **Batch Operations**: Bulk notification processing
- **Stream Optimization**: Efficient real-time subscriptions
- **Pagination**: Limited result sets for performance
- **Cleanup Automation**: Automatic old notification removal

### Scalability Features
- **Horizontal Scaling**: Support for multiple notification channels
- **Queue Management**: Efficient notification queuing
- **Priority Queuing**: Urgent notification fast-tracking
- **Resource Management**: Memory-efficient notification handling

## Business Logic

### Communication Workflow
- **Contextual Notifications**: Relevant information based on user role and context
- **Action-Driven Design**: Clear call-to-action for important notifications
- **Escalation Paths**: Automatic priority escalation for time-sensitive items
- **Feedback Loops**: Notification effectiveness tracking and optimization

### Operational Efficiency
- **Automated Reminders**: Reduced manual follow-up requirements
- **Real-time Updates**: Immediate status communication
- **Issue Resolution**: Faster problem identification and resolution
- **Quality Assurance**: Consistent communication standards

### Customer Experience
- **Transparent Communication**: Clear status updates and expectations
- **Proactive Notifications**: Anticipatory communication about deadlines
- **Personalized Alerts**: Context-aware, user-specific messaging
- **Mobile Optimization**: Mobile-friendly notification design

This comprehensive notification service provides enterprise-grade communication infrastructure specifically designed for the dynamic environment of a tailoring shop, supporting all aspects of business operations from work assignments to quality control to customer service with real-time delivery and intelligent prioritization.