# Employee Analytics Service Documentation

## Overview
The `employee_analytics_service.dart` file contains the comprehensive employee performance analytics and business intelligence system for the AI-Enabled Tailoring Shop Management System. It provides detailed insights into individual employee performance, team-wide analytics, work efficiency optimization, and data-driven decision-making capabilities for tailoring shop management.

## Architecture

### Core Components
- **`EmployeeAnalyticsService`**: Main service providing comprehensive analytics
- **Firebase Firestore Integration**: Real-time data retrieval and analysis
- **Individual Performance Tracking**: Detailed employee performance metrics
- **Team Analytics**: Organization-wide performance insights
- **Efficiency Optimization**: Process improvement recommendations
- **Predictive Analytics**: Trend analysis and forecasting
- **Workload Balancing**: Optimal resource allocation algorithms

### Key Features
- **Real-time Performance Monitoring**: Live tracking of employee productivity and efficiency
- **Comprehensive Metric Calculation**: Multi-dimensional performance analysis
- **Trend Analysis**: Historical performance patterns and forecasting
- **Optimization Recommendations**: Data-driven process improvement suggestions
- **Skill Utilization Analysis**: Optimal workforce skill distribution
- **Cost Efficiency Tracking**: Financial performance and ROI analysis
- **Quality Assurance Metrics**: Work quality and consistency tracking

## Individual Employee Analytics

### Core Performance Metrics
```dart
Future<Map<String, dynamic>> getEmployeeAnalytics(String employeeId) async {
  // Returns comprehensive employee performance data including:
  // - Total assignments and completion rates
  // - On-time delivery performance
  // - Earnings and productivity trends
  // - Skill utilization breakdown
  // - Quality ratings and consistency
  // - Efficiency scores and workload balance
}
```

### Performance Data Structure
```dart
{
  'employee': Employee,                           // Employee profile
  'totalAssignments': int,                        // Total work assignments
  'completedAssignments': int,                    // Successfully completed work
  'pendingAssignments': int,                      // Active work in progress
  'overdueAssignments': int,                      // Assignments past deadline
  'onTimeCompletionRate': double,                 // % of work completed on time
  'averageCompletionTime': double,                // Average hours per task
  'totalEarnings': double,                        // Total earnings from completed work
  'averageHourlyRate': double,                    // Base hourly compensation
  'productivityTrend': List<Map>,                 // Monthly performance data
  'skillUtilization': Map<String, double>,        // Earnings by skill type
  'timeAnalytics': Map<String, dynamic>,          // Time tracking metrics
  'qualityAnalytics': Map<String, dynamic>,       // Quality performance data
  'efficiencyScore': double,                      // Overall efficiency rating
  'workloadBalance': double,                      // Current workload assessment
}
```

### Monthly Performance Tracking
```dart
Future<List<Map<String, dynamic>>> _getMonthlyPerformanceData(String employeeId) async {
  // Analyzes last 12 months of performance data
  // Returns: completed orders, earnings, ratings, utilization rates
  final monthlyData = [];

  for (int i = 11; i >= 0; i--) {
    final monthData = {
      'month': 'YYYY-MM',
      'completedOrders': int,
      'earnings': double,
      'averageRating': double,
      'utilizationRate': double,
    };
    monthlyData.add(monthData);
  }

  return monthlyData;
}
```

## Team Analytics System

### Organization-Wide Insights
```dart
Future<Map<String, dynamic>> getTeamAnalytics() async {
  // Returns comprehensive team performance data including:
  // - Employee counts and department breakdown
  // - Total productivity and earnings
  // - Workload distribution analysis
  // - Performance rankings and trends
  // - Cost efficiency metrics
}
```

### Department Breakdown Analysis
```dart
Map<String, dynamic> _calculateDepartmentBreakdown(List<Employee> employees) {
  // Categorizes employees by primary skill/department:
  // - Cutting: Precision cutting specialists
  // - Stitching: Hand/machine stitching experts
  // - Finishing: Final touches and quality control
  // - Alterations: Modification and repair specialists
  // - Embroidery: Decorative stitching specialists
  // - General: Versatile employees

  return {
    'Cutting': {
      'count': int,
      'averageRating': double,
      'totalEarnings': double,
      'activeEmployees': int,
    },
    'Stitching': { /* ... */ },
    'Finishing': { /* ... */ },
    // ...
  };
}
```

### Workload Distribution
```dart
Map<String, dynamic> _calculateWorkloadDistribution(List<Employee> employees, List<WorkAssignment> assignments) {
  // Analyzes current workload across all employees
  return {
    'employeeName': {
      'totalAssignments': int,
      'completedAssignments': int,
      'pendingAssignments': int,
      'currentWorkload': int,
      'completionRate': double,
    }
  };
}
```

## Efficiency Analytics

### Work Efficiency Metrics
```dart
Future<Map<String, dynamic>> getWorkEfficiencyAnalytics() async {
  // Returns process efficiency insights including:
  // - Average completion times
  // - On-time delivery rates
  // - Rework and quality issue rates
  // - Process bottlenecks identification
  // - Optimization recommendations
}
```

### Bottleneck Identification
```dart
Future<List<Map<String, dynamic>>> _identifyBottlenecks(List<WorkAssignment> assignments) async {
  // Identifies process delays by skill area
  // Analyzes time overruns and delay patterns
  return [
    {
      'skill': 'stitching',
      'averageDelay': 2.5,      // Hours over estimated time
      'affectedAssignments': 12, // Number of delayed assignments
    },
    // ... top 3 bottleneck areas
  ];
}
```

### Optimization Recommendations
```dart
List<String> _generateOptimizationSuggestions(List<WorkAssignment> allAssignments, List<WorkAssignment> completedAssignments) {
  // Generates actionable improvement recommendations:
  // - "Consider increasing time estimates by 20% to improve on-time completion rate"
  // - "Long tasks detected - consider breaking complex orders into smaller assignments"
  // - "Skill utilization imbalance detected - consider cross-training employees"
  // - "Quality ratings could be improved - consider additional training"

  return optimizationSuggestions;
}
```

## Skill Utilization Analytics

### Skill Performance Analysis
```dart
Map<String, double> _calculateSkillUtilization(List<WorkAssignment> assignments) {
  // Analyzes earnings and usage by skill type
  return {
    'stitching': 15000.0,      // Total earnings from stitching work
    'cutting': 12000.0,        // Total earnings from cutting work
    'finishing': 8000.0,       // Total earnings from finishing work
    'alterations': 10000.0,    // Total earnings from alteration work
  };
}
```

### Quality Analytics by Skill
```dart
Map<String, dynamic> _calculateQualityAnalytics(List<WorkAssignment> completedAssignments) {
  // Analyzes quality performance across different skills
  return {
    'averageQualityRating': 4.2,
    'qualityConsistency': 85.5,  // Consistency percentage
    'topRatedSkills': [
      {
        'skill': 'embroidery',
        'averageRating': 4.8,
        'assignmentCount': 15,
      },
      // ... top 5 performing skills
    ]
  };
}
```

## Time Tracking and Efficiency

### Time Analytics Calculation
```dart
Map<String, dynamic> _calculateTimeAnalytics(List<WorkAssignment> assignments) {
  final completedAssignments = assignments.where((a) => a.status == WorkStatus.completed).toList();

  final totalHours = completedAssignments.fold(0.0, (total, a) => total + a.actualHours);
  final totalEstimatedHours = completedAssignments.fold(0.0, (total, a) => total + a.estimatedHours);

  return {
    'averageHoursPerTask': totalHours / completedAssignments.length,
    'totalHoursWorked': totalHours,
    'efficiencyRate': (totalHours / totalEstimatedHours) * 100,  // Actual vs estimated time
    'overtimeRate': _calculateOvertimeRate(completedAssignments), // Assignments exceeding 120% of estimated time
  };
}
```

### Efficiency Score Calculation
```dart
double _calculateEfficiencyScore(Employee employee, List<WorkAssignment> assignments) {
  if (assignments.isEmpty) return 0.0;

  final completedAssignments = assignments.where((a) => a.status == WorkStatus.completed).toList();

  // Weighted efficiency factors
  final completionRate = completedAssignments.length / assignments.length;  // 30%
  final onTimeRate = completedAssignments.where((a) => a.isOnTime).length / completedAssignments.length;  // 30%
  final qualityScore = employee.averageRating / 5.0;  // 30% - normalized quality rating
  final utilizationRate = employee.ordersInProgress > 0 ? 1.0 : 0.5;  // 10% - activity bonus

  return (completionRate * 0.3) + (onTimeRate * 0.3) + (qualityScore * 0.3) + (utilizationRate * 0.1);
}
```

## Workload Balancing

### Workload Balance Assessment
```dart
double _calculateWorkloadBalance(Employee employee, List<WorkAssignment> assignments) {
  const idealWorkload = 3.0;  // Optimal assignments per employee
  final currentWorkload = employee.ordersInProgress.toDouble();

  if (currentWorkload == 0) return 0.0;  // No active work
  if (currentWorkload <= idealWorkload) return 1.0;  // Optimal workload

  // Balance score decreases as workload exceeds ideal
  return idealWorkload / currentWorkload;
}
```

### Team Utilization Rate
```dart
double _calculateTeamUtilizationRate(List<Employee> employees, List<WorkAssignment> assignments) {
  final activeEmployees = employees.where((e) => e.isActive).length;
  final employeesWithWork = assignments.map((a) => a.employeeId).toSet().length;

  return employeesWithWork / activeEmployees;  // Percentage of active employees with current work
}
```

## Cost Efficiency Analysis

### Cost Efficiency Calculation
```dart
double _calculateCostEfficiency(List<Employee> employees, List<WorkAssignment> assignments) {
  final totalCost = assignments.fold(0.0, (total, a) => total + (a.hourlyRate * a.actualHours));
  final totalValue = assignments
      .where((a) => a.status == WorkStatus.completed)
      .fold(0.0, (total, a) => total + a.totalEarnings);

  return totalCost > 0 ? (totalValue / totalCost) * 100 : 0.0;  // Revenue per cost percentage
}
```

### Performance Rankings
```dart
List<Map<String, dynamic>> _calculatePerformanceRankings(List<Employee> employees) {
  return employees
      .map((employee) => {
          'id': employee.id,
          'name': employee.displayName,
          'efficiencyScore': _calculateEfficiencyScore(employee, []),
          'completionRate': employee.completionRate,
          'averageRating': employee.averageRating,
          'totalEarnings': employee.totalEarnings,
          'ordersCompleted': employee.totalOrdersCompleted,
        })
      .toList()
    ..sort((a, b) => (b['efficiencyScore'] as double).compareTo(a['efficiencyScore'] as double));
}
```

## Trend Analysis

### Team Productivity Trends
```dart
Future<List<Map<String, dynamic>>> _getTeamProductivityTrends() async {
  // Analyzes last 6 months of team performance
  final trends = [];

  for (int i = 5; i >= 0; i--) {
    final monthData = {
      'month': 'YYYY-MM',
      'completedOrders': int,      // Total orders completed by team
      'totalEarnings': double,     // Total team earnings
      'productivityIndex': double, // Earnings per completed order
    };
    trends.add(monthData);
  }

  return trends;
}
```

## Usage Examples

### Individual Employee Dashboard
```dart
class EmployeeDashboard extends StatefulWidget {
  final String employeeId;

  @override
  _EmployeeDashboardState createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final EmployeeAnalyticsService _analyticsService = EmployeeAnalyticsService();
  Map<String, dynamic>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final data = await _analyticsService.getEmployeeAnalytics(widget.employeeId);
    setState(() => _analyticsData = data);
  }

  @override
  Widget build(BuildContext context) {
    if (_analyticsData == null) return CircularProgressIndicator();

    return Column(
      children: [
        _buildPerformanceOverview(_analyticsData!),
        _buildSkillUtilizationChart(_analyticsData!['skillUtilization']),
        _buildMonthlyTrendChart(_analyticsData!['productivityTrend']),
        _buildQualityMetrics(_analyticsData!['qualityAnalytics']),
      ],
    );
  }
}
```

### Team Performance Dashboard
```dart
class TeamAnalyticsDashboard extends StatelessWidget {
  final EmployeeAnalyticsService _analyticsService = EmployeeAnalyticsService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsService.getTeamAnalytics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final data = snapshot.data!;
        return Column(
          children: [
            _buildTeamOverview(data),
            _buildDepartmentBreakdown(data['departmentBreakdown']),
            _buildWorkloadDistribution(data['workloadDistribution']),
            _buildPerformanceRankings(data['performanceRankings']),
            _buildProductivityTrends(data['productivityTrends']),
          ],
        );
      },
    );
  }
}
```

### Efficiency Optimization Dashboard
```dart
class EfficiencyDashboard extends StatelessWidget {
  final EmployeeAnalyticsService _analyticsService = EmployeeAnalyticsService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsService.getWorkEfficiencyAnalytics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final data = snapshot.data!;
        return Column(
          children: [
            _buildEfficiencyMetrics(data),
            _buildBottleneckAnalysis(data['bottlenecks']),
            _buildOptimizationSuggestions(data['optimizationSuggestions']),
          ],
        );
      },
    );
  }
}
```

### Performance Alerts System
```dart
class PerformanceAlertSystem {
  final EmployeeAnalyticsService _analyticsService = EmployeeAnalyticsService();

  Future<List<String>> generatePerformanceAlerts() async {
    final alerts = <String>[];

    final teamAnalytics = await _analyticsService.getTeamAnalytics();

    // Check for underperforming employees
    final rankings = teamAnalytics['performanceRankings'] as List<Map<String, dynamic>>;
    final lowPerformers = rankings.where((r) => r['efficiencyScore'] < 0.5);

    for (final performer in lowPerformers) {
      alerts.add('${performer['name']} has low efficiency score (${(performer['efficiencyScore'] * 100).toStringAsFixed(1)}%)');
    }

    // Check for workload imbalances
    final workloadData = teamAnalytics['workloadDistribution'] as Map<String, dynamic>;
    final overloadedEmployees = workloadData.values.where((w) => w['currentWorkload'] > 5);

    for (final employee in overloadedEmployees) {
      alerts.add('${employee['name']} has ${employee['currentWorkload']} assignments - consider redistributing work');
    }

    return alerts;
  }
}
```

### Predictive Analytics
```dart
class PredictiveAnalytics {
  final EmployeeAnalyticsService _analyticsService = EmployeeAnalyticsService();

  Future<Map<String, dynamic>> predictMonthlyPerformance(String employeeId) async {
    final monthlyData = await _analyticsService.getEmployeeAnalytics(employeeId)
        .then((data) => data['productivityTrend'] as List<Map<String, dynamic>>);

    if (monthlyData.length < 3) return {}; // Need minimum data for prediction

    // Calculate trend line
    final recentPerformance = monthlyData.take(3).toList();
    final avgCompletion = recentPerformance.map((m) => m['completedOrders']).reduce((a, b) => a + b) / 3;
    final avgEarnings = recentPerformance.map((m) => m['earnings']).reduce((a, b) => a + b) / 3;

    // Simple linear trend prediction
    final trend = _calculateTrend(recentPerformance);

    return {
      'predictedCompletions': (avgCompletion + trend).round(),
      'predictedEarnings': avgEarnings * (1 + trend / avgCompletion),
      'confidence': _calculatePredictionConfidence(recentPerformance),
    };
  }

  double _calculateTrend(List<Map<String, dynamic>> data) {
    // Simple linear regression for trend calculation
    final n = data.length;
    final sumX = (n * (n - 1)) / 2;
    final sumY = data.map((d) => d['completedOrders'] as int).reduce((a, b) => a + b);
    final sumXY = data.asMap().entries.map((e) => e.key * (e.value['completedOrders'] as int)).reduce((a, b) => a + b);
    final sumX2 = (n * (n - 1) * (2 * n - 1)) / 6;

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }
}
```

## Integration Points

### Provider Integration
```dart
class AnalyticsProvider extends ChangeNotifier {
  final EmployeeAnalyticsService _analyticsService = EmployeeAnalyticsService();

  Future<Map<String, dynamic>> getEmployeeAnalytics(String employeeId) async {
    final analytics = await _analyticsService.getEmployeeAnalytics(employeeId);
    notifyListeners();
    return analytics;
  }

  Future<Map<String, dynamic>> getTeamAnalytics() async {
    final analytics = await _analyticsService.getTeamAnalytics();
    notifyListeners();
    return analytics;
  }

  // Cache analytics data to prevent excessive API calls
  final Map<String, Map<String, dynamic>> _cache = {};

  Future<Map<String, dynamic>> getCachedEmployeeAnalytics(String employeeId) async {
    if (_cache.containsKey(employeeId)) {
      return _cache[employeeId]!;
    }

    final analytics = await getEmployeeAnalytics(employeeId);
    _cache[employeeId] = analytics;
    return analytics;
  }
}
```

### Dashboard Integration
```dart
class AnalyticsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analyticsProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: analyticsProvider.getTeamAnalytics(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  TeamOverviewCard(data: data),
                  DepartmentBreakdownChart(data: data['departmentBreakdown']),
                  WorkloadDistributionChart(data: data['workloadDistribution']),
                  PerformanceRankingsTable(data: data['performanceRankings']),
                  ProductivityTrendsChart(data: data['productivityTrends']),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
```

## Best Practices

### Performance Optimization
- **Caching**: Implement intelligent caching for frequently accessed analytics
- **Pagination**: Use pagination for large datasets in trend analysis
- **Background Processing**: Run heavy calculations in background isolates
- **Data Aggregation**: Pre-aggregate data for faster dashboard loading

### Data Accuracy
- **Real-time Updates**: Ensure analytics reflect current data state
- **Data Validation**: Validate input data before calculations
- **Error Handling**: Graceful handling of missing or corrupted data
- **Outlier Detection**: Identify and handle statistical outliers

### User Experience
- **Progressive Loading**: Load critical metrics first, detailed analysis second
- **Visual Clarity**: Use appropriate charts and graphs for different metric types
- **Actionable Insights**: Provide recommendations based on analytics
- **Historical Context**: Show trends and comparisons over time

This comprehensive employee analytics service provides the business intelligence foundation for data-driven decision making in the tailoring shop management system, offering deep insights into performance, efficiency, and optimization opportunities across individual employees and the entire organization.