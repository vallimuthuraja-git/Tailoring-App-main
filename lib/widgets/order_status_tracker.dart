import 'package:flutter/material.dart';
import '../models/order.dart';
import '../providers/theme_provider.dart';
import '../utils/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderStatusTracker extends StatelessWidget {
  final Order order;
  final bool showDetails;
  final double height;

  const OrderStatusTracker({
    super.key,
    required this.order,
    this.showDetails = true,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Current Status Header
          Row(
            children: [
              Icon(
                _getStatusIcon(order.status),
                color: order.status.statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      order.status.statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order.status.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: order.status.statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Timeline
          Expanded(
            child: Row(
              children: _buildStatusSteps(themeProvider),
            ),
          ),

          if (showDetails) ...[
            const SizedBox(height: 12),
            // Additional Details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Order Date',
                    DateFormat('MMM dd, yyyy').format(order.orderDate),
                    Icons.calendar_today,
                    themeProvider,
                  ),
                ),
                if (order.deliveryDate != null) ...[
                  Container(
                    width: 1,
                    height: 20,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                        : AppColors.onSurface.withValues(alpha: 0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      'Delivery Date',
                      DateFormat('MMM dd, yyyy').format(order.deliveryDate!),
                      Icons.local_shipping,
                      themeProvider,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
              : AppColors.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                    : AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildStatusSteps(ThemeProvider themeProvider) {
    final allStatuses = OrderStatus.values.where((status) => status != OrderStatus.cancelled).toList();
    final currentStatusIndex = allStatuses.indexOf(order.status);

    return List.generate(allStatuses.length, (index) {
      final status = allStatuses[index];
      final isCompleted = index <= currentStatusIndex;
      final isCurrent = index == currentStatusIndex;
      final isCancelled = order.status == OrderStatus.cancelled;

      return Expanded(
        child: Column(
          children: [
            // Status Circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCancelled
                    ? Colors.red
                    : isCompleted
                        ? status.statusColor
                        : themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                            : AppColors.onSurface.withValues(alpha: 0.2),
                border: isCurrent
                    ? Border.all(
                        color: status.statusColor,
                        width: 3,
                      )
                    : null,
              ),
              child: Center(
                child: isCompleted || isCancelled
                    ? Icon(
                        isCancelled ? Icons.cancel : Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            // Status Label
            Text(
              _getShortStatusName(status),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                color: isCurrent
                    ? status.statusColor
                    : themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                        : AppColors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Connection Line (except for last item)
            if (index < allStatuses.length - 1) ...[
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: 2,
                  color: isCancelled
                      ? Colors.red
                      : index < currentStatusIndex
                          ? status.statusColor
                          : themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                              : AppColors.onSurface.withValues(alpha: 0.2),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _getShortStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.assigned:
        return 'Assigned';
      case OrderStatus.inProduction:
        return 'Production';
      case OrderStatus.qualityCheck:
        return 'Quality Check';
      case OrderStatus.readyForFitting:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
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
}

// Enhanced Order Card Widget for Dashboard
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;
  final VoidCallback? onPayment;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onStatusUpdate,
    this.onPayment,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Order ID and Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(order.orderDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                                : AppColors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status, themeProvider),
                ],
              ),

              const SizedBox(height: 12),

              // Order Summary
              if (order.items.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.items.first.productName,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (order.items.length > 1)
                      Text(
                        ' +${order.items.length - 1} more',
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                              : AppColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Progress Indicator
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                      : AppColors.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _getProgressValue(order.status),
                  child: Container(
                    decoration: BoxDecoration(
                      color: order.status.statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Footer with Amount and Actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                          ),
                        ),
                        if (order.remainingAmount > 0)
                          Text(
                            'Due: ₹${order.remainingAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (onPayment != null && order.remainingAmount > 0)
                        IconButton(
                          onPressed: onPayment,
                          icon: const Icon(Icons.payment, size: 20),
                          tooltip: 'Add Payment',
                        ),
                      if (onStatusUpdate != null)
                        IconButton(
                          onPressed: onStatusUpdate,
                          icon: const Icon(Icons.update, size: 20),
                          tooltip: 'Update Status',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        status.statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.statusColor,
        ),
      ),
    );
  }

  double _getProgressValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.1;
      case OrderStatus.confirmed:
        return 0.25;
      case OrderStatus.inProgress:
      case OrderStatus.assigned:
        return 0.4;
      case OrderStatus.inProduction:
        return 0.6;
      case OrderStatus.qualityCheck:
        return 0.75;
      case OrderStatus.readyForFitting:
        return 0.85;
      case OrderStatus.completed:
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }
}
