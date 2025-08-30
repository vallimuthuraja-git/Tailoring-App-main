import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../services/employee_analytics_service.dart';
import '../../models/employee.dart';

class EmployeeAnalyticsScreen extends StatefulWidget {
  const EmployeeAnalyticsScreen({super.key});

  @override
  State<EmployeeAnalyticsScreen> createState() => _EmployeeAnalyticsScreenState();
}

class _EmployeeAnalyticsScreenState extends State<EmployeeAnalyticsScreen> {
  late EmployeeAnalyticsService _analyticsService;
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _analyticsService = EmployeeAnalyticsService();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.currentUser != null) {
        // Get individual employee analytics
        final employeeAnalytics = await _analyticsService.getEmployeeAnalytics(authProvider.currentUser!.uid);

        // Get team analytics
        final teamAnalytics = await _analyticsService.getTeamAnalytics();

        // Get efficiency analytics
        final efficiencyAnalytics = await _analyticsService.getWorkEfficiencyAnalytics();

        setState(() {
          _analyticsData = {
            'employee': employeeAnalytics,
            'team': teamAnalytics,
            'efficiency': efficiencyAnalytics,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load analytics: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_analyticsData == null) {
      return const Center(child: Text('No analytics data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employee Performance Overview
          _buildSectionTitle('Your Performance'),
          _buildEmployeePerformanceCard(),
          const SizedBox(height: 24),

          // Productivity Trends
          _buildSectionTitle('Productivity Trends'),
          _buildProductivityChart(),
          const SizedBox(height: 24),

          // Team Overview
          _buildSectionTitle('Team Overview'),
          _buildTeamOverviewCard(),
          const SizedBox(height: 24),

          // Work Efficiency
          _buildSectionTitle('Work Efficiency'),
          _buildEfficiencyCard(),
          const SizedBox(height: 24),

          // Skill Analysis
          _buildSectionTitle('Skill Analysis'),
          _buildSkillAnalysisCard(),
          const SizedBox(height: 24),

          // Recommendations
          _buildSectionTitle('Recommendations'),
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmployeePerformanceCard() {
    final employeeData = _analyticsData!['employee'] as Map<String, dynamic>;
    final employee = employeeData['employee'] as Employee;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: employee.photoUrl != null
                      ? NetworkImage(employee.photoUrl!)
                      : null,
                  child: employee.photoUrl == null
                      ? Text(employee.displayName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${employee.experienceYears} years experience',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Orders Completed',
                    employee.totalOrdersCompleted.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Avg Rating',
                    employee.averageRating.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Completion Rate',
                    '${(employee.completionRate * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Earnings',
                    '\$${employee.totalEarnings.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'In Progress',
                    employee.ordersInProgress.toString(),
                    Icons.work,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Efficiency Score',
                    (employeeData['efficiencyScore'] as double).toStringAsFixed(1),
                    Icons.speed,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityChart() {
    final employeeData = _analyticsData!['employee'] as Map<String, dynamic>;
    final productivityTrend = employeeData['productivityTrend'] as List<Map<String, dynamic>>;

    if (productivityTrend.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No productivity data available yet'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Performance Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < productivityTrend.length) {
                            final month = productivityTrend[value.toInt()]['month'] as String;
                            return Text(month.split('-')[1]); // Show month only
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: productivityTrend.asMap().entries.map((entry) {
                        final index = entry.key.toDouble();
                        final data = entry.value;
                        return FlSpot(index, (data['completedOrders'] as num).toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Orders Completed', Colors.blue),
                _buildLegendItem('Earnings', Colors.green),
                _buildLegendItem('Rating', Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTeamOverviewCard() {
    final teamData = _analyticsData!['team'] as Map<String, dynamic>;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Team Performance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTeamMetric(
                    'Total Employees',
                    teamData['totalEmployees'].toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTeamMetric(
                    'Active Employees',
                    teamData['activeEmployees'].toString(),
                    Icons.person,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTeamMetric(
                    'Orders Completed',
                    teamData['totalCompletedOrders'].toString(),
                    Icons.check_circle,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTeamMetric(
                    'Total Earnings',
                    '\$${teamData['totalEarnings'].toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTeamMetric(
                    'Avg Rating',
                    (teamData['averageTeamRating'] as double).toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTeamMetric(
                    'Utilization',
                    '${((teamData['utilizationRate'] as double) * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
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
            style: TextStyle(color: color, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard() {
    final efficiencyData = _analyticsData!['efficiency'] as Map<String, dynamic>;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work Efficiency Metrics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildEfficiencyMetric(
              'Average Completion Time',
              '${(efficiencyData['averageCompletionTime'] as double).toStringAsFixed(1)} hours',
              Icons.schedule,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildEfficiencyMetric(
              'On-Time Completion Rate',
              '${(efficiencyData['onTimeCompletionRate'] as double).toStringAsFixed(1)}%',
              Icons.check_circle,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildEfficiencyMetric(
              'Rework Rate',
              '${(efficiencyData['reworkRate'] as double).toStringAsFixed(1)}%',
              Icons.refresh,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildEfficiencyMetric(
              'Overall Efficiency',
              '${(efficiencyData['efficiencyScore'] as double).toStringAsFixed(1)}/10',
              Icons.speed,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetric(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillAnalysisCard() {
    final employeeData = _analyticsData!['employee'] as Map<String, dynamic>;
    final skillUtilization = employeeData['skillUtilization'] as Map<String, double>;

    if (skillUtilization.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No skill data available'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skill Utilization & Earnings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...skillUtilization.entries.map((entry) {
              final skillName = entry.key.replaceAll('EmployeeSkill.', '');
              final earnings = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(skillName),
                    ),
                    Text(
                      '\$${earnings.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final efficiencyData = _analyticsData!['efficiency'] as Map<String, dynamic>;
    final suggestions = efficiencyData['optimizationSuggestions'] as List<String>;

    if (suggestions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recommendations available'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Recommendations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodyMedium,
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
}