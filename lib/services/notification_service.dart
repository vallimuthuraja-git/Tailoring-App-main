import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/employee.dart' as emp;

enum NotificationType {
  workAssignment,      // New work assigned
  workUpdate,          // Work status update
  qualityCheck,        // Quality inspection result
  deadlineReminder,    // Upcoming deadline
  reworkRequired,      // Work needs rework
  paymentReceived,     // Payment confirmation
  orderCompleted,      // Order finished
  feedbackReceived,    // Customer feedback
  systemAlert,         // System notifications
  scheduleChange,      // Schedule changes
  emergencyAlert,      // Emergency notifications
  trainingReminder,    // Training due
  performanceReview,   // Performance review due
}

enum NotificationPriority {
  low,      // General information
  normal,   // Regular updates
  high,     // Important notifications
  urgent,   // Requires immediate attention
  critical, // Emergency situations
}

class Notification {
  final String id;
  final String recipientId;
  final String recipientName;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String message;
  final Map<String, dynamic> data; // Additional context data
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionUrl; // Deep link for action
  final bool requiresAction;
  final String? senderId;
  final String? senderName;
  final String? category; // Grouping category

  const Notification({
    required this.id,
    required this.recipientId,
    required this.recipientName,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.actionUrl,
    required this.requiresAction,
    this.senderId,
    this.senderName,
    this.category,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      recipientId: json['recipientId'] ?? '',
      recipientName: json['recipientName'] ?? '',
      type: NotificationType.values[json['type'] ?? 0],
      priority: NotificationPriority.values[json['priority'] ?? 1],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] ?? {},
      isRead: json['isRead'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      readAt: json['readAt'] != null ? (json['readAt'] as Timestamp).toDate() : null,
      actionUrl: json['actionUrl'],
      requiresAction: json['requiresAction'] ?? false,
      senderId: json['senderId'],
      senderName: json['senderName'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'type': type.index,
      'priority': priority.index,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'actionUrl': actionUrl,
      'requiresAction': requiresAction,
      'senderId': senderId,
      'senderName': senderName,
      'category': category,
    };
  }

  NotificationPriority get effectivePriority {
    // Escalate priority for urgent deadlines
    if (type == NotificationType.deadlineReminder && data['hoursUntilDeadline'] < 4) {
      return NotificationPriority.urgent;
    }
    return priority;
  }

  bool get isOverdue => !isRead && createdAt.isBefore(DateTime.now().subtract(const Duration(days: 7)));

  Color get priorityColor {
    switch (effectivePriority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
      case NotificationPriority.critical:
        return Colors.red.shade900;
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.workAssignment:
        return Icons.assignment;
      case NotificationType.workUpdate:
        return Icons.update;
      case NotificationType.qualityCheck:
        return Icons.check_circle;
      case NotificationType.deadlineReminder:
        return Icons.schedule;
      case NotificationType.reworkRequired:
        return Icons.refresh;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.orderCompleted:
        return Icons.done_all;
      case NotificationType.feedbackReceived:
        return Icons.feedback;
      case NotificationType.systemAlert:
        return Icons.info;
      case NotificationType.scheduleChange:
        return Icons.calendar_today;
      case NotificationType.emergencyAlert:
        return Icons.warning;
      case NotificationType.trainingReminder:
        return Icons.school;
      case NotificationType.performanceReview:
        return Icons.assessment;
    }
  }
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send notification
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
  }) async {
    try {
      final notification = Notification(
        id: '',
        recipientId: recipientId,
        recipientName: recipientName,
        type: type,
        priority: priority,
        title: title,
        message: message,
        data: data ?? {},
        isRead: false,
        createdAt: DateTime.now(),
        actionUrl: actionUrl,
        requiresAction: requiresAction,
        senderId: senderId,
        senderName: senderName,
        category: category,
      );

      final notificationData = notification.toJson();
      notificationData.remove('id');

      await _firestore.collection('notifications').add(notificationData);
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Work assignment notifications
  Future<void> sendWorkAssignmentNotification({
    required String employeeId,
    required String employeeName,
    required String orderId,
    required String taskDescription,
    required DateTime deadline,
    required String assignedBy,
  }) async {
    await sendNotification(
      recipientId: employeeId,
      recipientName: employeeName,
      type: NotificationType.workAssignment,
      priority: NotificationPriority.high,
      title: 'New Work Assignment',
      message: 'You have been assigned: $taskDescription',
      data: {
        'orderId': orderId,
        'taskDescription': taskDescription,
        'deadline': deadline.toIso8601String(),
        'assignedBy': assignedBy,
      },
      actionUrl: '/work-assignment/$orderId',
      requiresAction: true,
      senderId: assignedBy,
      category: 'work',
    );
  }

  // Quality check notifications
  Future<void> sendQualityCheckNotification({
    required String employeeId,
    required String employeeName,
    required String orderId,
    required String checkpointName,
    required String result,
    required double score,
    required String feedback,
    required String inspectorName,
  }) async {
    final priority = score < 7.0 ? NotificationPriority.urgent : NotificationPriority.normal;

    await sendNotification(
      recipientId: employeeId,
      recipientName: employeeName,
      type: NotificationType.qualityCheck,
      priority: priority,
      title: 'Quality Check Result',
      message: '$checkpointName: $result (Score: ${score.toStringAsFixed(1)}/10)',
      data: {
        'orderId': orderId,
        'checkpointName': checkpointName,
        'result': result,
        'score': score,
        'feedback': feedback,
        'inspectorName': inspectorName,
      },
      actionUrl: '/quality-check/$orderId',
      senderName: inspectorName,
      category: 'quality',
    );
  }

  // Rework required notification
  Future<void> sendReworkRequiredNotification({
    required String employeeId,
    required String employeeName,
    required String orderId,
    required String workDescription,
    required List<String> issues,
    required String requestedBy,
  }) async {
    await sendNotification(
      recipientId: employeeId,
      recipientName: employeeName,
      type: NotificationType.reworkRequired,
      priority: NotificationPriority.urgent,
      title: 'Rework Required',
      message: 'Your work on order $orderId needs corrections',
      data: {
        'orderId': orderId,
        'workDescription': workDescription,
        'issues': issues,
        'requestedBy': requestedBy,
      },
      actionUrl: '/rework/$orderId',
      requiresAction: true,
      senderName: requestedBy,
      category: 'quality',
    );
  }

  // Deadline reminder notifications
  Future<void> sendDeadlineReminder({
    required String employeeId,
    required String employeeName,
    required String orderId,
    required String taskDescription,
    required DateTime deadline,
    required int hoursUntilDeadline,
  }) async {
    final priority = hoursUntilDeadline < 4
        ? NotificationPriority.urgent
        : hoursUntilDeadline < 24
            ? NotificationPriority.high
            : NotificationPriority.normal;

    await sendNotification(
      recipientId: employeeId,
      recipientName: employeeName,
      type: NotificationType.deadlineReminder,
      priority: priority,
      title: 'Deadline Reminder',
      message: '${hoursUntilDeadline}h remaining: $taskDescription',
      data: {
        'orderId': orderId,
        'taskDescription': taskDescription,
        'deadline': deadline.toIso8601String(),
        'hoursUntilDeadline': hoursUntilDeadline,
      },
      actionUrl: '/work-assignment/$orderId',
      requiresAction: hoursUntilDeadline < 24,
      category: 'deadline',
    );
  }

  // Payment notifications
  Future<void> sendPaymentNotification({
    required String recipientId,
    required String recipientName,
    required String orderId,
    required double amount,
    required String paymentType,
  }) async {
    await sendNotification(
      recipientId: recipientId,
      recipientName: recipientName,
      type: NotificationType.paymentReceived,
      priority: NotificationPriority.normal,
      title: 'Payment Received',
      message: '\$${amount.toStringAsFixed(2)} received for order $orderId',
      data: {
        'orderId': orderId,
        'amount': amount,
        'paymentType': paymentType,
        'timestamp': DateTime.now().toIso8601String(),
      },
      category: 'payment',
    );
  }

  // Order completion notifications
  Future<void> sendOrderCompletionNotification({
    required String employeeId,
    required String employeeName,
    required String orderId,
    required String customerName,
    required double earnings,
  }) async {
    await sendNotification(
      recipientId: employeeId,
      recipientName: employeeName,
      type: NotificationType.orderCompleted,
      priority: NotificationPriority.normal,
      title: 'Order Completed',
      message: 'Order $orderId for $customerName has been completed',
      data: {
        'orderId': orderId,
        'customerName': customerName,
        'earnings': earnings,
        'completionDate': DateTime.now().toIso8601String(),
      },
      category: 'completion',
    );
  }

  // Training reminder notifications
  Future<void> sendTrainingReminder({
    required String employeeId,
    required String employeeName,
    required String trainingName,
    required DateTime dueDate,
    required int daysUntilDue,
  }) async {
    final priority = daysUntilDue <= 1 ? NotificationPriority.urgent : NotificationPriority.normal;

    await sendNotification(
      recipientId: employeeId,
      recipientName: employeeName,
      type: NotificationType.trainingReminder,
      priority: priority,
      title: 'Training Reminder',
      message: '$trainingName due in $daysUntilDue days',
      data: {
        'trainingName': trainingName,
        'dueDate': dueDate.toIso8601String(),
        'daysUntilDue': daysUntilDue,
      },
      actionUrl: '/training/$trainingName',
      requiresAction: daysUntilDue <= 7,
      category: 'training',
    );
  }

  // Performance review notifications
  Future<void> sendPerformanceReviewNotification({
    required String employeeId,
    required String employeeName,
    required DateTime reviewDate,
    required String reviewerName,
  }) async {
    await sendNotification(
      recipientId: employeeId,
      recipientName: employeeName,
      type: NotificationType.performanceReview,
      priority: NotificationPriority.high,
      title: 'Performance Review Due',
      message: 'Performance review scheduled with $reviewerName',
      data: {
        'reviewDate': reviewDate.toIso8601String(),
        'reviewerName': reviewerName,
      },
      actionUrl: '/performance-review',
      requiresAction: true,
      senderName: reviewerName,
      category: 'performance',
    );
  }

  // Emergency notifications
  Future<void> sendEmergencyNotification({
    required List<String> recipientIds,
    required List<String> recipientNames,
    required String title,
    required String message,
    required String emergencyType,
    Map<String, dynamic>? additionalData,
  }) async {
    for (int i = 0; i < recipientIds.length; i++) {
      await sendNotification(
        recipientId: recipientIds[i],
        recipientName: recipientNames[i],
        type: NotificationType.emergencyAlert,
        priority: NotificationPriority.critical,
        title: title,
        message: message,
        data: {
          'emergencyType': emergencyType,
          'timestamp': DateTime.now().toIso8601String(),
          ...?additionalData,
        },
        requiresAction: true,
        category: 'emergency',
      );
    }
  }

  // Get notifications for user
  Future<List<Notification>> getUserNotifications(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Notification.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  // Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Stream notifications for real-time updates
  Stream<List<Notification>> getNotificationStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Notification.fromJson(data);
          }).toList();
        });
  }

  // Stream unread count for real-time updates
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Schedule deadline reminders
  Future<void> scheduleDeadlineReminders() async {
    try {
      // Get work assignments with upcoming deadlines (next 24 hours)
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      final assignmentsQuery = await _firestore
          .collection('work_assignments')
          .where('deadline', isLessThanOrEqualTo: Timestamp.fromDate(tomorrow))
          .where('status', isEqualTo: emp.WorkStatus.inProgress.index)
          .get();

      for (final doc in assignmentsQuery.docs) {
        final data = doc.data();
        final deadline = (data['deadline'] as Timestamp).toDate();
        final employeeId = data['employeeId'] as String;
        final employeeName = data['employeeId'] as String; // This should be employee name
        final orderId = data['orderId'] as String;
        final taskDescription = data['taskDescription'] as String;

        final hoursUntilDeadline = deadline.difference(DateTime.now()).inHours;

        if (hoursUntilDeadline > 0 && hoursUntilDeadline <= 24) {
          await sendDeadlineReminder(
            employeeId: employeeId,
            employeeName: employeeName,
            orderId: orderId,
            taskDescription: taskDescription,
            deadline: deadline,
            hoursUntilDeadline: hoursUntilDeadline,
          );
        }
      }
    } catch (e) {
      print('Error scheduling deadline reminders: $e');
    }
  }

  // Clean up old notifications (older than 30 days)
  Future<void> cleanupOldNotifications() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      final oldNotifications = await _firestore
          .collection('notifications')
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (final doc in oldNotifications.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error cleaning up old notifications: $e');
    }
  }

  // Get notification statistics
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    try {
      final allNotifications = await getUserNotifications(userId);

      final unreadCount = allNotifications.where((n) => !n.isRead).length;
      final urgentCount = allNotifications.where((n) => n.effectivePriority == NotificationPriority.urgent).length;
      final criticalCount = allNotifications.where((n) => n.effectivePriority == NotificationPriority.critical).length;

      final typeBreakdown = <NotificationType, int>{};
      for (final notification in allNotifications) {
        typeBreakdown[notification.type] = (typeBreakdown[notification.type] ?? 0) + 1;
      }

      return {
        'totalNotifications': allNotifications.length,
        'unreadCount': unreadCount,
        'urgentCount': urgentCount,
        'criticalCount': criticalCount,
        'typeBreakdown': typeBreakdown.map((key, value) => MapEntry(key.toString().split('.').last, value)),
        'averageResponseTime': _calculateAverageResponseTime(allNotifications),
      };
    } catch (e) {
      print('Error getting notification stats: $e');
      return {
        'totalNotifications': 0,
        'unreadCount': 0,
        'urgentCount': 0,
        'criticalCount': 0,
        'typeBreakdown': {},
        'averageResponseTime': 0.0,
      };
    }
  }

  double _calculateAverageResponseTime(List<Notification> notifications) {
    final readNotifications = notifications.where((n) => n.readAt != null).toList();

    if (readNotifications.isEmpty) return 0.0;

    final totalResponseTime = readNotifications
        .map((n) => n.readAt!.difference(n.createdAt).inMinutes)
        .reduce((a, b) => a + b);

    return totalResponseTime / readNotifications.length;
  }
}
