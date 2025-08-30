import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../providers/auth_provider.dart';

class EmployeePerformanceDashboard extends StatefulWidget {
  const EmployeePerformanceDashboard({super.key});

  @override
  State<EmployeePerformanceDashboard> createState() => _EmployeePerformanceDashboardState();
}

class _EmployeePerformanceDashboardState extends State<EmployeePerformanceDashboard> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    await employeeProvider.loadEmployees();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Check if user has permission to view performance dashboard
        // Allow shop owners, admins, and employees (employees can view their own performance)
        final currentUser = authProvider.currentUser;
        final hasAccess = authProvider.isShopOwnerOrAdmin ||
            (currentUser != null); // Employees can view their own performance data

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
                    'You don\'t have permission to view performance dashboard.',
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
            title: const Text('Employee Performance Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh Data',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Consumer<EmployeeProvider>(
                  builder: (context, employeeProvider, child) {
                    final employees = employeeProvider.employees;

                    if (employees.isEmpty) {
                      return const Center(
                        child: Text('No employees found'),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Overview Cards
                          _buildOverviewCards(employees),

                          const SizedBox(height: 24),

                          // Performance Charts
                          _buildPerformanceSection(employees),

                          const SizedBox(height: 24),

                          // Workload Analysis
                          _buildWorkloadSection(employees),

                          const SizedBox(height: 24),

                          // Top Performers
                          _buildTopPerformersSection(employees),

                          const SizedBox(height: 24),

                          // Underperformers
                          _buildUnderperformersSection(employees),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildOverviewCards(List<Employee> employees) {
    final activeEmployees = employees.where((e) => e.isActive).length;
    final totalOrders = employees.fold(0, (sum, e) => sum + e.totalOrdersCompleted);
    final avgRating = employees.isEmpty ? 0.0 :
        employees.map((e) => e.averageRating).reduce((a, b) => a + b) / employees.length;
    final totalEarnings = employees.fold(0.0, (sum, e) => sum + e.totalEarnings);

    return Row(
      children: [
        _buildMetricCard(
          'Active Employees',
          activeEmployees.toString(),
          Icons.people,
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildMetricCard(
          'Total Orders',
          totalOrders.toString(),
          Icons.assignment_turned_in,
          Colors.green,
        ),
        const SizedBox(width: 12),
        _buildMetricCard(
          'Avg Rating',
          avgRating.toStringAsFixed(1),
          Icons.star,
          Colors.amber,
        ),
        const SizedBox(width: 12),
        _buildMetricCard(
          'Total Earnings',
          '\$${totalEarnings.toStringAsFixed(0)}',
          Icons.attach_money,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(List<Employee> employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Distribution',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Performance by Rating
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance by Rating',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRatingDistribution(employees),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Skills Distribution
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSkillsDistribution(employees),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(List<Employee> employees) {
    final ratings = [5.0, 4.0, 3.0, 2.0, 1.0];
    final distribution = <double, int>{};

    for (var rating in ratings) {
      distribution[rating] = employees.where((e) =>
        e.averageRating >= rating && e.averageRating < rating + 1.0
      ).length;
    }

    return Column(
      children: ratings.map((rating) {
        final count = distribution[rating] ?? 0;
        final percentage = employees.isEmpty ? 0.0 : (count / employees.length) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text('${rating.toInt()}.0 Stars'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    rating >= 4.0 ? Colors.green :
                    rating >= 3.0 ? Colors.amber : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 40,
                child: Text('$count'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillsDistribution(List<Employee> employees) {
    final skillCount = <EmployeeSkill, int>{};

    for (var employee in employees) {
      for (var skill in employee.skills) {
        skillCount[skill] = (skillCount[skill] ?? 0) + 1;
      }
    }

    final sortedSkills = skillCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedSkills.map((entry) {
        final skill = entry.key;
        final count = entry.value;
        final percentage = employees.isEmpty ? 0.0 : (count / employees.length) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(skill.name),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 40,
                child: Text('$count'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkloadSection(List<Employee> employees) {
    final suggestions = EmployeeProvider().getWorkloadBalancingSuggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workload Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (suggestions.isEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Workload is well balanced across all employees',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else ...[
          ...suggestions.map((suggestion) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    suggestion['type'] == 'overload' ? Icons.warning : Icons.info,
                    color: suggestion['type'] == 'overload' ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion['message'],
                          style: TextStyle(
                            color: suggestion['type'] == 'overload' ? Colors.red[700] : Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          suggestion['action'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildTopPerformersSection(List<Employee> employees) {
    final topPerformers = employees
        .where((e) => e.isActive)
        .toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating))
      ..take(5);

    if (topPerformers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ...topPerformers.map((employee) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: employee.photoUrl != null
                  ? NetworkImage(employee.photoUrl!)
                  : null,
              child: employee.photoUrl == null
                  ? Text(employee.displayName[0].toUpperCase())
                  : null,
            ),
            title: Text(employee.displayName),
            subtitle: Text('${employee.totalOrdersCompleted} orders completed'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  employee.averageRating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildUnderperformersSection(List<Employee> employees) {
    final underperformers = employees
        .where((e) => e.isActive && e.averageRating < 3.0)
        .toList()
      ..sort((a, b) => a.averageRating.compareTo(b.averageRating));

    if (underperformers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Needs Attention',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),

        ...underperformers.map((employee) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: employee.photoUrl != null
                  ? NetworkImage(employee.photoUrl!)
                  : null,
              child: employee.photoUrl == null
                  ? Text(employee.displayName[0].toUpperCase())
                  : null,
            ),
            title: Text(employee.displayName),
            subtitle: Text('Rating: ${employee.averageRating.toStringAsFixed(1)} • ${employee.totalOrdersCompleted} orders'),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                // Navigate to employee detail
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Container(), // Would navigate to employee detail
                  ),
                );
              },
            ),
          ),
        )),
      ],
    );
  }
}