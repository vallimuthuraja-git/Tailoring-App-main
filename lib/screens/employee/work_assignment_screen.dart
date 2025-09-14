import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/user_avatar.dart';

class WorkAssignmentScreen extends StatefulWidget {
  final Employee employee;

  const WorkAssignmentScreen({required this.employee, super.key});

  @override
  State<WorkAssignmentScreen> createState() => _WorkAssignmentScreenState();
}

class _WorkAssignmentScreenState extends State<WorkAssignmentScreen> {
  bool _isLoading = false;
  List<WorkAssignment> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employeeProvider =
          Provider.of<EmployeeProvider>(context, listen: false);
      final assignments =
          await employeeProvider.getEmployeeAssignments(widget.employee.id);

      if (mounted) {
        setState(() {
          _assignments = assignments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assignments: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user has permission to view work assignments
        // Allow shop owners, admins, and the employee themselves
        final currentUser = authProvider.currentUser;
        final hasAccess = authProvider.isShopOwnerOrAdmin ||
            (currentUser != null && currentUser.uid == widget.employee.userId);

        if (!hasAccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You don\'t have permission to view this employee\'s assignments.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('${widget.employee.displayName} - Work Assignments'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAssignments,
                tooltip: 'Refresh',
              ),
              if (authProvider.isShopOwnerOrAdmin)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreateAssignmentDialog(),
                  tooltip: 'Assign Work',
                ),
            ],
          ),
          body: Column(
            children: [
              // Employee Summary Card
              _buildEmployeeSummary(),

              // Assignments List
              Expanded(
                child: _buildAssignmentsList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmployeeSummary() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                UserAvatar(
                  displayName: widget.employee.displayName,
                  imageUrl: widget.employee.photoUrl,
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employee.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.employee.experienceYears} years experience',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip(
                  'Active',
                  widget.employee.ordersInProgress.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Completed',
                  widget.employee.totalOrdersCompleted.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  'Rating',
                  widget.employee.averageRating.toStringAsFixed(1),
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No work assignments',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Assign work to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Group assignments by status
    final activeAssignments =
        _assignments.where((a) => a.status != WorkStatus.completed).toList();
    final completedAssignments =
        _assignments.where((a) => a.status == WorkStatus.completed).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (activeAssignments.isNotEmpty) ...[
          _buildSectionHeader('Active Assignments', Colors.blue),
          ...activeAssignments
              .map((assignment) => _buildAssignmentCard(assignment)),
        ],
        if (completedAssignments.isNotEmpty) ...[
          if (activeAssignments.isNotEmpty) const SizedBox(height: 24),
          _buildSectionHeader('Completed Assignments', Colors.green),
          ...completedAssignments
              .take(5)
              .map((assignment) => _buildAssignmentCard(assignment)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: color,
            margin: const EdgeInsets.only(right: 12),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(WorkAssignment assignment) {
    final isCompleted = assignment.status == WorkStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${assignment.orderId}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.taskDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(assignment.status)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.status.name,
                    style: TextStyle(
                      color: _getStatusColor(assignment.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Est: ${assignment.estimatedHours}h',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  '\$${(assignment.hourlyRate * assignment.estimatedHours).toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
                if (assignment.actualHours > 0) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Actual: ${assignment.actualHours}h',
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Due: ${assignment.deadline?.toString().split(' ')[0] ?? 'No deadline'}',
              style: TextStyle(
                color:
                    (assignment.deadline?.isBefore(DateTime.now()) ?? false) &&
                            !isCompleted
                        ? Colors.red[600]
                        : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _updateAssignmentStatus(
                        assignment, WorkStatus.inProgress),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCompleteDialog(assignment),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Complete'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateAssignmentDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateAssignmentDialog(employee: widget.employee),
    ).then((_) => _loadAssignments());
  }

  void _showCompleteDialog(WorkAssignment assignment) {
    final hoursController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hoursController,
              decoration: const InputDecoration(
                labelText: 'Actual Hours Worked',
                hintText: 'e.g., 4.5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Quality Notes (Optional)',
                hintText: 'Any notes about the work quality...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final hours = double.tryParse(hoursController.text) ?? 0;
              final notes = notesController.text;
              Navigator.pop(context);
              _completeAssignment(assignment, hours, notes);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _updateAssignmentStatus(
      WorkAssignment assignment, WorkStatus status) async {
    try {
      final employeeProvider =
          Provider.of<EmployeeProvider>(context, listen: false);
      await employeeProvider.updateWorkAssignment(
        assignmentId: assignment.id,
        status: status,
      );
      _loadAssignments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Assignment status updated to ${status.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating assignment: $e')),
        );
      }
    }
  }

  void _completeAssignment(
      WorkAssignment assignment, double actualHours, String notes) async {
    try {
      final employeeProvider =
          Provider.of<EmployeeProvider>(context, listen: false);
      await employeeProvider.updateWorkAssignment(
        assignmentId: assignment.id,
        status: WorkStatus.completed,
        actualHours: actualHours,
        qualityNotes: notes.isNotEmpty ? notes : null,
      );
      _loadAssignments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing assignment: $e')),
        );
      }
    }
  }

  Color _getStatusColor(WorkStatus status) {
    switch (status) {
      case WorkStatus.notStarted:
        return Colors.grey;
      case WorkStatus.inProgress:
        return Colors.blue;
      case WorkStatus.paused:
        return Colors.orange;
      case WorkStatus.completed:
        return Colors.green;
      case WorkStatus.qualityCheck:
        return Colors.purple;
      case WorkStatus.approved:
        return Colors.green;
      case WorkStatus.rejected:
        return Colors.red;
    }
  }
}

class CreateAssignmentDialog extends StatefulWidget {
  final Employee employee;

  const CreateAssignmentDialog({required this.employee, super.key});

  @override
  State<CreateAssignmentDialog> createState() => _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<CreateAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _orderIdController = TextEditingController();
  final _taskController = TextEditingController();
  final _hoursController = TextEditingController();
  final _rateController = TextEditingController();
  final _bonusController = TextEditingController();

  EmployeeSkill _selectedSkill = EmployeeSkill.stitching;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _rateController.text = widget.employee.baseRatePerHour.toString();
    _bonusController.text = widget.employee.performanceBonusRate.toString();
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _taskController.dispose();
    _hoursController.dispose();
    _rateController.dispose();
    _bonusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assign Work to ${widget.employee.displayName}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _orderIdController,
                  decoration: const InputDecoration(
                    labelText: 'Order ID *',
                    hintText: 'e.g., ORD-001',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter order ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Task Description *',
                    hintText: 'Describe the work to be done',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter task description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EmployeeSkill>(
                  initialValue: _selectedSkill,
                  decoration: const InputDecoration(
                    labelText: 'Required Skill *',
                  ),
                  items: EmployeeSkill.values.map((skill) {
                    return DropdownMenuItem(
                      value: skill,
                      child: Text(skill.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSkill = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Hours *',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Required';
                          }
                          final hours = double.tryParse(value!);
                          if (hours == null || hours <= 0) {
                            return 'Invalid hours';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectDeadline(context),
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(
                          'Due: ${_deadline.toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _rateController,
                        decoration: const InputDecoration(
                          labelText: 'Hourly Rate (USD)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bonusController,
                        decoration: const InputDecoration(
                          labelText: 'Bonus Rate (USD)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _createAssignment,
                      child: const Text('Assign Work'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectDeadline(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _deadline = date;
      });
    }
  }

  void _createAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final employeeProvider =
          Provider.of<EmployeeProvider>(context, listen: false);

      await employeeProvider.assignWorkToEmployee(
        employeeId: widget.employee.id,
        orderId: _orderIdController.text,
        requiredSkill: _selectedSkill,
        taskDescription: _taskController.text,
        deadline: _deadline,
        estimatedHours: double.parse(_hoursController.text),
        hourlyRate: double.tryParse(_rateController.text) ?? 0,
        bonusRate: double.tryParse(_bonusController.text) ?? 0,
        materials: {},
        isRemoteWork: widget.employee.canWorkRemotely,
        assignedBy: 'Shop Owner', // Should be actual user ID
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work assigned successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning work: $e')),
        );
      }
    }
  }
}
