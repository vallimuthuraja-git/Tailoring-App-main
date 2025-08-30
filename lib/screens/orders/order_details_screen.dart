import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderProvider, AuthProvider>(
      builder: (context, orderProvider, authProvider, child) {
        final isShopOwner = authProvider.isShopOwnerOrAdmin;
        final order = widget.order;

        return Scaffold(
          appBar: AppBar(
            title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            titleTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            actions: [
              if (isShopOwner) ...[
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, value, orderProvider, order),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'update_status',
                      child: Text('Update Status'),
                    ),
                    const PopupMenuItem(
                      value: 'update_payment',
                      child: Text('Update Payment'),
                    ),
                    const PopupMenuItem(
                      value: 'update_delivery',
                      child: Text('Update Delivery Date'),
                    ),
                  ],
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Status Card
                _buildStatusCard(order),

                const SizedBox(height: 20),

                // Order Items
                _buildOrderItems(order),

                const SizedBox(height: 20),

                // Pricing Details
                _buildPricingCard(order),

                const SizedBox(height: 20),

                // Measurements
                _buildMeasurementsCard(order),

                const SizedBox(height: 20),

                // Special Instructions
                if (order.specialInstructions != null && order.specialInstructions!.isNotEmpty)
                  _buildInstructionsCard(order),

                const SizedBox(height: 20),

                // Order Images
                if (order.orderImages.isNotEmpty)
                  _buildImagesCard(order),

                const SizedBox(height: 20),

                // Action Buttons
                _buildActionButtons(context, orderProvider, authProvider, order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${_getStatusText(order.status)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payment: ${_getPaymentStatusText(order.paymentStatus)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: order.paymentStatus == PaymentStatus.paid
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ordered: ${_formatDate(order.orderDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (order.deliveryDate != null)
                        Text(
                          'Delivery: ${_formatDate(order.deliveryDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.category} • Quantity: ${item.quantity}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Text(
                                'Notes: ${item.notes}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _PricingRow('Subtotal', '₹${order.totalAmount.toStringAsFixed(0)}'),
            const Divider(),
            _PricingRow('Advance Payment (30%)', '₹${order.advanceAmount.toStringAsFixed(0)}',
                color: Colors.green),
            _PricingRow('Remaining Amount', '₹${order.remainingAmount.toStringAsFixed(0)}',
                color: order.remainingAmount > 0 ? Colors.orange : Colors.green),
            const Divider(),
            _PricingRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}',
                isBold: true, fontSize: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementsCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Measurements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (order.measurements.isEmpty)
              const Text(
                'No measurements provided',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: order.measurements.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    backgroundColor: Colors.blue.shade50,
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Instructions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              order.specialInstructions!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesCard(Order order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order.orderImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _showImageDialog(context, order.orderImages[index]),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(order.orderImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderProvider orderProvider,
      AuthProvider authProvider, Order order) {
    final isShopOwner = authProvider.isShopOwnerOrAdmin;

    if (!isShopOwner) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Contact shop owner
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat with shop owner coming soon!')),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text('Contact Shop Owner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          if (order.remainingAmount > 0)
            ElevatedButton.icon(
              onPressed: () {
                // Make payment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment feature coming soon!')),
                );
              },
              icon: const Icon(Icons.payment),
              label: Text('Pay Remaining ₹${order.remainingAmount.toStringAsFixed(0)}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _handleMenuAction(BuildContext context, String action, OrderProvider orderProvider, Order order) {
    switch (action) {
      case 'update_status':
        _showStatusUpdateDialog(context, orderProvider, order);
        break;
      case 'update_payment':
        _showPaymentUpdateDialog(context, orderProvider, order);
        break;
      case 'update_delivery':
        _showDeliveryUpdateDialog(context, orderProvider, order);
        break;
    }
  }

  void _showStatusUpdateDialog(BuildContext context, OrderProvider orderProvider, Order order) {
    OrderStatus? selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: OrderStatus.values.map((status) {
              return RadioListTile<OrderStatus>(
                title: Text(_getStatusText(status)),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStatus != null && selectedStatus != order.status
                  ? () async {
                      Navigator.of(context).pop();
                      await orderProvider.updateOrderStatus(order.id, selectedStatus!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order status updated!')),
                        );
                      }
                    }
                  : null,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentUpdateDialog(BuildContext context, OrderProvider orderProvider, Order order) {
    PaymentStatus? selectedStatus = order.paymentStatus;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Payment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...PaymentStatus.values.map((status) {
                return RadioListTile<PaymentStatus>(
                  title: Text(_getPaymentStatusText(status)),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) => setState(() => selectedStatus = value),
                );
              }),
              if (selectedStatus == PaymentStatus.paid) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount Paid',
                    hintText: 'Enter amount',
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedStatus != null
                  ? () async {
                      Navigator.of(context).pop();
                      final amount = amountController.text.isEmpty
                          ? null
                          : double.tryParse(amountController.text);
                      await orderProvider.updatePaymentStatus(
                        order.id,
                        selectedStatus!,
                        paidAmount: amount,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment status updated!')),
                        );
                      }
                    }
                  : null,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeliveryUpdateDialog(BuildContext context, OrderProvider orderProvider, Order order) {
    DateTime selectedDate = order.deliveryDate ?? DateTime.now().add(const Duration(days: 7));

    showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) async {
      if (date != null) {
        await orderProvider.updateDeliveryDate(order.id, date);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delivery date updated!')),
          );
        }
      }
    });
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) =>
                const Text('Failed to load image'),
          ),
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).trim();
  }

  String _getPaymentStatusText(PaymentStatus status) {
    return status.toString().split('.').last;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.assigned:
        return Colors.teal;
      case OrderStatus.inProgress:
        return Colors.purple;
      case OrderStatus.inProduction:
        return Colors.deepPurple;
      case OrderStatus.qualityCheck:
        return Colors.amber;
      case OrderStatus.readyForFitting:
        return Colors.teal;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.indigo;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }
}

class _PricingRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;
  final double fontSize;
  final Color? color;

  const _PricingRow(
    this.label,
    this.amount, {
    this.isBold = false,
    this.fontSize = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
