import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/employee_provider.dart';
import '../../services/auth_service.dart' as auth;
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';

class TailoringWorkflowScreen extends StatefulWidget {
  const TailoringWorkflowScreen({super.key});

  @override
  State<TailoringWorkflowScreen> createState() =>
      _TailoringWorkflowScreenState();
}

class _TailoringWorkflowScreenState extends State<TailoringWorkflowScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Workflow stages
  final List<String> _stages = [
    'Cutting',
    'Stitching',
    'Finishing',
    'Quality Check',
    'Ready'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _stages.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load orders and work assignments
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final employeeProvider =
          Provider.of<EmployeeProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load all orders
      await orderProvider.loadOrders();

      // Load current employee's work assignments if user is employee
      if (authProvider.userRole == auth.UserRole.employee) {
        // Employee-specific loading would go here
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading workflow data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<OrderProvider, AuthProvider, EmployeeProvider,
        ThemeProvider>(
      builder: (context, orderProvider, authProvider, employeeProvider,
          themeProvider, child) {
        final userRole = authProvider.userRole;

        final orders = orderProvider.orders;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tailoring Workflow'),
            elevation: 0,
            backgroundColor: themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
            titleTextStyle: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _stages.map((stage) => Tab(text: stage)).toList(),
              labelColor: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
              unselectedLabelColor: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
              indicatorColor: themeProvider.isDarkMode
                  ? DarkAppColors.primary
                  : AppColors.primary,
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: _stages
                      .map((stage) => _buildStageContent(
                          stage, orders, userRole, employeeProvider))
                      .toList(),
                ),
        );
      },
    );
  }

  Widget _buildStageContent(String stage, List<Order> allOrders,
      auth.UserRole userRole, EmployeeProvider employeeProvider) {
    // Filter orders based on current workflow stage
    final stageOrders = _filterOrdersByStage(stage, allOrders, userRole);

    if (stageOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStageIcon(stage),
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders in $stage stage',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            if (userRole != auth.UserRole.employee) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to assign orders to this stage
                  _showStageAssignmentDialog(
                      stage, allOrders, employeeProvider);
                },
                icon: const Icon(Icons.assignment),
                label: const Text('Assign Orders'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stageOrders.length,
      itemBuilder: (context, index) {
        final order = stageOrders[index];
        return _buildOrderCard(order, stage, userRole);
      },
    );
  }

  Widget _buildOrderCard(
      Order order, String currentStage, auth.UserRole userRole) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: order.status.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getOrderIcon(order.status),
                    color: order.status.statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Customer: ${order.customerName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPriorityBadge(order),
              ],
            ),

            const SizedBox(height: 12),

            // Order items preview
            if (order.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${order.items.length} item${order.items.length > 1 ? 's' : ''}: ${order.items.map((item) => item.productName).join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Timeline and progress
            _buildWorkflowProgress(order),

            const SizedBox(height: 16),

            // Action buttons based on user role and current stage
            _buildRoleActions(order, currentStage, userRole),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowProgress(Order order) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, size: 14, color: Colors.blue),
              SizedBox(width: 4),
              Text(
                'Workflow Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildProgressStep('Cutting', _getStageStatus(order, 'cutting')),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 12, color: Colors.blue),
              const SizedBox(width: 4),
              _buildProgressStep(
                  'Stitching', _getStageStatus(order, 'stitching')),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 12, color: Colors.blue),
              const SizedBox(width: 4),
              _buildProgressStep(
                  'Finishing', _getStageStatus(order, 'finishing')),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward, size: 12, color: Colors.blue),
              const SizedBox(width: 4),
              _buildProgressStep('QC', _getStageStatus(order, 'quality')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, WorkflowStageStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case WorkflowStageStatus.pending:
        color = Colors.grey;
        icon = Icons.schedule;
        break;
      case WorkflowStageStatus.inProgress:
        color = Colors.orange;
        icon = Icons.build;
        break;
      case WorkflowStageStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }

  Widget _buildRoleActions(
      Order order, String currentStage, auth.UserRole userRole) {
    if (userRole == auth.UserRole.employee) {
      // Employee can only see actions for their role-appropriate stages
      return _buildEmployeeActions(order, currentStage);
    } else if (userRole == auth.UserRole.shopOwner) {
      // Shop owner can manage workflow transitions
      return _buildOwnerActions(order, currentStage);
    } else {
      // Customer view
      return _buildCustomerActions(order);
    }
  }

  Widget _buildEmployeeActions(Order order, String currentStage) {
    final actions = _getActionButtonsForStageAndRole(currentStage, 'employee');

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions
          .map((action) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _handleAction(action, order),
                  icon: Icon(action.icon, size: 16),
                  label: Text(action.label),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: action.color,
                    side:
                        BorderSide(color: action.color.withValues(alpha: 0.5)),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildOwnerActions(Order order, String currentStage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showAssignDialog(order, currentStage),
          icon: const Icon(Icons.person_add, size: 16),
          label: const Text('Assign'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showMoveDialog(order, currentStage),
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text('Move Stage'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerActions(Order order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: order.status.statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: order.status.statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: order.status.statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Status: ${order.statusText}',
              style: TextStyle(
                color: order.status.statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (order.deliveryDate != null)
            Text(
              'Due: ${order.deliveryDate!.toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(Order order) {
    if (order.deliveryDate
            ?.isBefore(DateTime.now().add(const Duration(days: 2))) ==
        true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.priority_high, size: 12, color: Colors.red),
            SizedBox(width: 4),
            Text(
              'URGENT',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Helper methods
  List<Order> _filterOrdersByStage(
      String stage, List<Order> orders, auth.UserRole userRole) {
    return orders.where((order) {
      // Filter logic based on stage and user role
      switch (stage) {
        case 'Cutting':
          return order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.inProgress;
        case 'Stitching':
          return order.status == OrderStatus.inProgress ||
              order.status == OrderStatus.inProduction;
        case 'Finishing':
          return order.status == OrderStatus.inProduction;
        case 'Quality Check':
          return order.status == OrderStatus.qualityCheck;
        case 'Ready':
          return order.status == OrderStatus.readyForFitting ||
              order.status == OrderStatus.completed;
        default:
          return true;
      }
    }).toList();
  }

  IconData _getStageIcon(String stage) {
    switch (stage) {
      case 'Cutting':
        return Icons.cut;
      case 'Stitching':
        return Icons.build;
      case 'Finishing':
        return Icons.apartment;
      case 'Quality Check':
        return Icons.check_circle;
      case 'Ready':
        return Icons.checklist;
      default:
        return Icons.work;
    }
  }

  IconData _getOrderIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.task_alt;
      case OrderStatus.inProgress:
        return Icons.build;
      case OrderStatus.inProduction:
        return Icons.build_circle;
      case OrderStatus.qualityCheck:
        return Icons.check_circle;
      case OrderStatus.readyForFitting:
        return Icons.checklist;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.delivered:
        return Icons.local_shipping;
      case OrderStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.assignment;
    }
  }

  void _handleAction(ActionConfig action, Order order) {
    switch (action.actionType) {
      case 'start_work':
        // Start working on assignment
        _startWorkOnOrder(order, action);
        break;
      case 'complete_work':
        // Complete work assignment
        _completeWorkOnOrder(order, action);
        break;
      case 'quality_check':
        // Perform quality check
        _performQualityCheck(order);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Action "${action.label}" not implemented yet')),
        );
    }
  }

  void _showAssignDialog(Order order, String currentStage) {
    // Show dialog to assign employee to order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Assign dialog for stage "$currentStage" - Coming soon')),
    );
  }

  // Keep only one version of _showMoveDialog
  // Removed duplicate

  void _startWorkOnOrder(Order order, ActionConfig action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Started ${action.label.toLowerCase()} for order ${order.id}')),
    );
  }

  void _completeWorkOnOrder(Order order, ActionConfig action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Completed ${action.label.toLowerCase()} for order ${order.id}')),
    );
  }

  void _performQualityCheck(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quality check performed for order ${order.id}')),
    );
  }

  // Placeholder for action config
  List<ActionConfig> _getActionButtonsForStageAndRole(
      String stage, String role) {
    switch (stage) {
      case 'Cutting':
        return [
          const ActionConfig(
            label: 'Start Cutting',
            icon: Icons.cut,
            color: Colors.blue,
            actionType: 'start_work',
          ),
          const ActionConfig(
            label: 'Finish Cutting',
            icon: Icons.check,
            color: Colors.green,
            actionType: 'complete_work',
          ),
        ];
      case 'Stitching':
        return [
          const ActionConfig(
            label: 'Start Stitching',
            icon: Icons.build,
            color: Colors.blue,
            actionType: 'start_work',
          ),
          const ActionConfig(
            label: 'Finish Stitching',
            icon: Icons.done,
            color: Colors.green,
            actionType: 'complete_work',
          ),
        ];
      case 'Finishing':
        return [
          const ActionConfig(
            label: 'Start Finishing',
            icon: Icons.brush,
            color: Colors.blue,
            actionType: 'start_work',
          ),
          const ActionConfig(
            label: 'Finish Work',
            icon: Icons.check_circle,
            color: Colors.green,
            actionType: 'complete_work',
          ),
        ];
      default:
        return [];
    }
  }

  void _showStageAssignmentDialog(
      String stage, List<Order> allOrders, EmployeeProvider employeeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Orders to $stage Stage'),
        content: Text(
            'This feature will allow you to assign orders to specific employees for the $stage stage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  WorkflowStageStatus _getStageStatus(Order order, String stage) {
    switch (order.status) {
      case OrderStatus.confirmed:
        return stage == 'cutting'
            ? WorkflowStageStatus.pending
            : WorkflowStageStatus.pending;
      case OrderStatus.inProgress:
      case OrderStatus.inProduction:
        return WorkflowStageStatus.inProgress;
      case OrderStatus.qualityCheck:
      case OrderStatus.readyForFitting:
        return WorkflowStageStatus.completed;
      case OrderStatus.completed:
      case OrderStatus.delivered:
        return WorkflowStageStatus.completed;
      default:
        return WorkflowStageStatus.pending;
    }
  }

  void _showMoveDialog(Order order, String currentStage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move Order to Next Stage'),
        content: Text(
            'Move order ${order.id} from $currentStage stage to the next stage in the workflow?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Move'),
          ),
        ],
      ),
    );
  }
}

// Action configuration
class ActionConfig {
  final String label;
  final IconData icon;
  final Color color;
  final String actionType;

  const ActionConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.actionType,
  });
}

// Workflow stage status
enum WorkflowStageStatus {
  pending,
  inProgress,
  completed,
}
