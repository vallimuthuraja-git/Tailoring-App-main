import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';

class OrderNotificationService {
  static final OrderNotificationService _instance = OrderNotificationService._internal();
  factory OrderNotificationService() => _instance;
  OrderNotificationService._internal();

  final StreamController<OrderNotification> _notificationController =
      StreamController<OrderNotification>.broadcast();

  Stream<OrderNotification> get notifications => _notificationController.stream;

  // Notification types for different order events
  void notifyOrderCreated(Order order) {
    _notificationController.add(OrderNotification(
      id: 'order_created_${order.id}',
      title: 'Order Created',
      message: 'New order #${order.id.substring(0, 8)} has been created successfully',
      type: NotificationType.success,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.check_circle,
      color: Colors.green,
    ));
  }

  void notifyOrderStatusChanged(Order order, OrderStatus oldStatus, OrderStatus newStatus) {
    _notificationController.add(OrderNotification(
      id: 'status_changed_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Order Status Updated',
      message: 'Order #${order.id.substring(0, 8)} status changed from ${oldStatus.statusText} to ${newStatus.statusText}',
      type: NotificationType.info,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: _getStatusIcon(newStatus),
      color: newStatus.statusColor,
    ));
  }

  void notifyPaymentReceived(Order order, double amount) {
    _notificationController.add(OrderNotification(
      id: 'payment_received_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Payment Received',
      message: 'Payment of ₹${amount.toStringAsFixed(0)} received for order #${order.id.substring(0, 8)}',
      type: NotificationType.success,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.payment,
      color: Colors.green,
    ));
  }

  void notifyOrderReady(Order order) {
    _notificationController.add(OrderNotification(
      id: 'order_ready_${order.id}',
      title: 'Order Ready',
      message: 'Order #${order.id.substring(0, 8)} is ready for fitting',
      type: NotificationType.warning,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.checkroom,
      color: Colors.blue,
    ));
  }

  void notifyOrderCompleted(Order order) {
    _notificationController.add(OrderNotification(
      id: 'order_completed_${order.id}',
      title: 'Order Completed',
      message: 'Order #${order.id.substring(0, 8)} has been completed successfully',
      type: NotificationType.success,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.done_all,
      color: Colors.green,
    ));
  }

  void notifyOrderDelayed(Order order, String reason) {
    _notificationController.add(OrderNotification(
      id: 'order_delayed_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Order Delayed',
      message: 'Order #${order.id.substring(0, 8)} has been delayed: $reason',
      type: NotificationType.warning,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.schedule,
      color: Colors.orange,
    ));
  }

  void notifyOrderCancelled(Order order, String reason) {
    _notificationController.add(OrderNotification(
      id: 'order_cancelled_${order.id}',
      title: 'Order Cancelled',
      message: 'Order #${order.id.substring(0, 8)} has been cancelled',
      type: NotificationType.error,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.cancel,
      color: Colors.red,
    ));
  }

  void notifyEmployeeAssigned(Order order, String employeeName) {
    _notificationController.add(OrderNotification(
      id: 'employee_assigned_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Employee Assigned',
      message: '$employeeName has been assigned to order #${order.id.substring(0, 8)}',
      type: NotificationType.info,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.person,
      color: Colors.blue,
    ));
  }

  void notifyQualityCheckFailed(Order order, String reason) {
    _notificationController.add(OrderNotification(
      id: 'quality_failed_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Quality Check Failed',
      message: 'Order #${order.id.substring(0, 8)} failed quality check: $reason',
      type: NotificationType.error,
      orderId: order.id,
      timestamp: DateTime.now(),
      icon: Icons.error,
      color: Colors.red,
    ));
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.inProgress:
        return Icons.work;
      case OrderStatus.assigned:
        return Icons.person;
      case OrderStatus.inProduction:
        return Icons.build;
      case OrderStatus.qualityCheck:
        return Icons.verified;
      case OrderStatus.readyForFitting:
        return Icons.checkroom;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.delivered:
        return Icons.local_shipping;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  void dispose() {
    _notificationController.close();
  }
}

// Notification data model
class OrderNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? orderId;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const OrderNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.orderId,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.isRead = false,
    this.metadata,
  });

  OrderNotification copyWith({
    bool? isRead,
  }) {
    return OrderNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      orderId: orderId,
      timestamp: timestamp,
      icon: icon,
      color: color,
      isRead: isRead ?? this.isRead,
      metadata: metadata,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
}

// Notification Manager for handling notification state
class NotificationManager extends ChangeNotifier {
  final List<OrderNotification> _notifications = [];
  final OrderNotificationService _notificationService = OrderNotificationService();

  List<OrderNotification> get notifications => _notifications;
  List<OrderNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  NotificationManager() {
    _notificationService.notifications.listen((notification) {
      _notifications.insert(0, notification);
      notifyListeners();
    });
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void clearNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void clearOldNotifications({Duration maxAge = const Duration(days: 7)}) {
    final cutoffDate = DateTime.now().subtract(maxAge);
    _notifications.removeWhere((n) => n.timestamp.isBefore(cutoffDate));
    notifyListeners();
  }
}

// Widget for displaying notifications
class NotificationWidget extends StatelessWidget {
  final OrderNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: notification.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Notification Panel Widget
class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationManager>(
      builder: (context, notificationManager, child) {
        final notifications = notificationManager.notifications;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              if (notifications.isNotEmpty)
                TextButton(
                  onPressed: notificationManager.markAllAsRead,
                  child: const Text('Mark All Read'),
                ),
            ],
          ),
          body: notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationWidget(
                      notification: notification,
                      onTap: () {
                        // Handle notification tap (e.g., navigate to order details)
                        notificationManager.markAsRead(notification.id);
                      },
                      onDismiss: () {
                        notificationManager.clearNotification(notification.id);
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
