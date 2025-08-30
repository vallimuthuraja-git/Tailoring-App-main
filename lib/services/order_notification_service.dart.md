# Order Notification Service Documentation

## Overview
The `order_notification_service.dart` file contains the comprehensive real-time notification system for the AI-Enabled Tailoring Shop Management System. It provides instant notifications for all order-related events, ensuring stakeholders stay informed about order progress, status changes, and important updates throughout the tailoring workflow.

## Architecture

### Core Components
- **`OrderNotificationService`**: Singleton service managing notification streams
- **`OrderNotification`**: Data model for individual notifications
- **`NotificationManager`**: State management for notification collections
- **`NotificationWidget`**: UI component for displaying individual notifications
- **`NotificationPanel`**: Complete notification interface panel
- **Stream-based Delivery**: Real-time notification distribution system

### Key Features
- **Real-time Notifications**: Instant delivery of order-related events
- **Event-Specific Messaging**: Tailored notifications for different order states
- **Visual Differentiation**: Color-coded and icon-based notification types
- **State Management**: Persistent notification storage and read/unread tracking
- **UI Integration**: Complete widget library for notification display
- **Memory Efficient**: Stream-based delivery preventing memory leaks
- **User Experience**: Intuitive notification panel with interaction capabilities

## Singleton Service Implementation

### Service Initialization
```dart
class OrderNotificationService {
  static final OrderNotificationService _instance = OrderNotificationService._internal();
  factory OrderNotificationService() => _instance;
  OrderNotificationService._internal();

  final StreamController<OrderNotification> _notificationController =
      StreamController<OrderNotification>.broadcast();

  Stream<OrderNotification> get notifications => _notificationController.stream;
}
```

### Stream Management
```dart
// Broadcasting stream allows multiple listeners
final StreamController<OrderNotification> _notificationController =
    StreamController<OrderNotification>.broadcast();

// Public stream for subscribers
Stream<OrderNotification> get notifications => _notificationController.stream;

// Clean disposal
void dispose() {
  _notificationController.close();
}
```

## Order Event Notifications

### Order Creation Notification
```dart
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
```

### Status Change Notification
```dart
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
```

### Payment Notification
```dart
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
```

### Completion Notifications
```dart
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
```

### Issue Notifications
```dart
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
```

### Assignment Notifications
```dart
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
```

## Status Icon Mapping

### Order Status Icons
```dart
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
```

### Icon Categories
- **Scheduling**: `Icons.schedule` for pending states
- **Progress**: `Icons.work`, `Icons.build` for active work
- **Assignment**: `Icons.person` for employee assignments
- **Quality**: `Icons.verified` for quality checks
- **Completion**: `Icons.done_all`, `Icons.checkroom` for finished work
- **Delivery**: `Icons.local_shipping` for delivered orders
- **Issues**: `Icons.cancel`, `Icons.error` for problems

## Notification Data Model

### OrderNotification Class
```dart
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
}
```

### Notification Types
```dart
enum NotificationType {
  info,     // General information (blue)
  success,  // Successful operations (green)
  warning,  // Warnings/attention needed (orange)
  error,    // Errors/problems (red)
}
```

### Time Formatting
```dart
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
```

## State Management

### Notification Manager
```dart
class NotificationManager extends ChangeNotifier {
  final List<OrderNotification> _notifications = [];
  final OrderNotificationService _notificationService = OrderNotificationService();

  List<OrderNotification> get notifications => _notifications;
  List<OrderNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
}
```

### Stream Subscription
```dart
NotificationManager() {
  _notificationService.notifications.listen((notification) {
    _notifications.insert(0, notification); // Add to beginning for chronological order
    notifyListeners();
  });
}
```

### State Operations
```dart
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
```

## UI Components

### Individual Notification Widget
```dart
class NotificationWidget extends StatelessWidget {
  final OrderNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon container with colored background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(notification.icon, color: notification.color, size: 20),
              ),

              // Content area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    )),
                    Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(notification.timeAgo, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead) Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: notification.color, shape: BoxShape.circle),
              ),

              // Dismiss button
              if (onDismiss != null) IconButton(onPressed: onDismiss, icon: Icon(Icons.close)),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Notification Panel
```dart
class NotificationPanel extends StatelessWidget {
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
              ? const Center(child: Text('No notifications'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationWidget(
                      notification: notification,
                      onTap: () {
                        notificationManager.markAsRead(notification.id);
                        // Navigate to order details
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
```

## Usage Examples

### Basic Notification Integration
```dart
class OrderProvider extends ChangeNotifier {
  final OrderNotificationService _notificationService = OrderNotificationService();

  Future<void> createOrder(Order order) async {
    // Create order logic...
    await _saveOrderToDatabase(order);

    // Notify about order creation
    _notificationService.notifyOrderCreated(order);

    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final order = await _getOrderById(orderId);
    final oldStatus = order.status;

    // Update status logic...
    await _updateOrderStatusInDatabase(orderId, newStatus);

    // Notify about status change
    _notificationService.notifyOrderStatusChanged(order, oldStatus, newStatus);

    notifyListeners();
  }
}
```

### Notification Listener Setup
```dart
class NotificationListenerWidget extends StatefulWidget {
  @override
  _NotificationListenerWidgetState createState() => _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget> {
  late StreamSubscription<OrderNotification> _notificationSubscription;
  final OrderNotificationService _notificationService = OrderNotificationService();

  @override
  void initState() {
    super.initState();

    // Listen to notifications
    _notificationSubscription = _notificationService.notifications.listen((notification) {
      // Show in-app notification
      _showInAppNotification(notification);

      // Log notification
      _logNotification(notification);
    });
  }

  void _showInAppNotification(OrderNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.message),
        backgroundColor: notification.color,
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _navigateToOrder(notification.orderId),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }
}
```

### Notification Badge Integration
```dart
class NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationManager>(
      builder: (context, notificationManager, child) {
        final unreadCount = notificationManager.unreadCount;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _navigateToNotifications(context),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
```

### Order Status Monitoring
```dart
class OrderStatusMonitor {
  final OrderNotificationService _notificationService = OrderNotificationService();

  void setupStatusMonitoring(Order order) {
    // Monitor order status changes
    order.statusStream.listen((statusChange) {
      switch (statusChange.newStatus) {
        case OrderStatus.readyForFitting:
          _notificationService.notifyOrderReady(order);
          break;
        case OrderStatus.completed:
          _notificationService.notifyOrderCompleted(order);
          break;
        case OrderStatus.cancelled:
          _notificationService.notifyOrderCancelled(order, 'Order was cancelled');
          break;
        default:
          _notificationService.notifyOrderStatusChanged(
            order,
            statusChange.oldStatus,
            statusChange.newStatus,
          );
      }
    });
  }
}
```

### Notification Analytics
```dart
class NotificationAnalytics {
  final NotificationManager _notificationManager;

  Map<String, int> getNotificationStats() {
    final notifications = _notificationManager.notifications;

    return {
      'total': notifications.length,
      'unread': _notificationManager.unreadCount,
      'byType': {
        'info': notifications.where((n) => n.type == NotificationType.info).length,
        'success': notifications.where((n) => n.type == NotificationType.success).length,
        'warning': notifications.where((n) => n.type == NotificationType.warning).length,
        'error': notifications.where((n) => n.type == NotificationType.error).length,
      },
      'today': notifications.where((n) =>
        n.timestamp.day == DateTime.now().day &&
        n.timestamp.month == DateTime.now().month &&
        n.timestamp.year == DateTime.now().year
      ).length,
    };
  }

  double getAverageResponseTime() {
    final readNotifications = _notificationManager.notifications
        .where((n) => n.isRead)
        .toList();

    if (readNotifications.isEmpty) return 0;

    final totalTime = readNotifications.fold<int>(0, (sum, notification) {
      // Assuming we have a readTimestamp field
      // final timeToRead = notification.readTimestamp.difference(notification.timestamp).inMinutes;
      // return sum + timeToRead;
      return sum; // Placeholder
    });

    return totalTime / readNotifications.length;
  }
}
```

## Integration Points

### Provider Integration
```dart
class AppProviders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationManager()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        // Other providers...
      ],
      child: MaterialApp(
        // App configuration...
      ),
    );
  }
}
```

### Service Dependencies
- **Order Service**: Triggers notifications for order events
- **Employee Service**: Triggers notifications for assignments
- **Quality Control Service**: Triggers quality-related notifications
- **Payment Service**: Triggers payment notifications
- **Navigation Service**: Handles notification tap navigation

### Firebase Integration
```dart
class FirebaseNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderNotificationService _notificationService = OrderNotificationService();

  Future<void> syncNotificationsFromFirebase(String userId) async {
    final notificationsSnapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    for (final doc in notificationsSnapshot.docs) {
      final data = doc.data();
      // Convert Firebase data to OrderNotification and emit
      final notification = OrderNotification.fromJson(data);
      _notificationService._notificationController.add(notification);
    }
  }
}
```

## Best Practices

### Notification Design
- **Clear Messaging**: Use concise, understandable language
- **Actionable Content**: Include relevant order information
- **Consistent Branding**: Maintain visual consistency
- **Progressive Disclosure**: Show essential info first, details on tap

### Performance Considerations
- **Stream Management**: Always cancel subscriptions to prevent memory leaks
- **Batch Operations**: Group similar notifications when possible
- **Cleanup Routine**: Regularly remove old notifications
- **Efficient Rendering**: Use ListView.builder for large notification lists

### User Experience
- **Immediate Feedback**: Show notifications promptly
- **Non-intrusive**: Don't overwhelm users with too many notifications
- **Accessible**: Ensure notifications work with screen readers
- **Customizable**: Allow users to control notification preferences

### Error Handling
- **Graceful Degradation**: Continue app functionality if notification system fails
- **Retry Logic**: Implement retry for failed notification deliveries
- **Fallback Display**: Show basic text if rich notifications fail
- **Logging**: Log notification events for debugging

This comprehensive order notification service provides real-time communication for all order-related events, ensuring users stay informed and engaged throughout the tailoring process with a polished, professional notification experience.