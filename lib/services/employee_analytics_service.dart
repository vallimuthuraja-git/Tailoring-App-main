import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart' as emp;

class EmployeeAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get comprehensive analytics for a specific employee
  Future<Map<String, dynamic>> getEmployeeAnalytics(String employeeId) async {
    try {
      // Get employee data
      final employeeDoc = await _firestore.collection('employees').doc(employeeId).get();
      if (!employeeDoc.exists) {
        throw Exception('Employee not found');
      }

      final employee = emp.Employee.fromJson({...employeeDoc.data()!, 'id': employeeDoc.id});

      // Get work assignments
      final assignmentsQuery = await _firestore
          .collection('work_assignments')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      final assignments = assignmentsQuery.docs
          .map((doc) => emp.WorkAssignment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Calculate analytics
      final completedAssignments = assignments.where((a) => a.status == emp.WorkStatus.completed).toList();
      final overdueAssignments = assignments.where((a) => a.isOverdue).toList();
      final onTimeAssignments = assignments.where((a) => a.isOnTime && a.status == emp.WorkStatus.completed).toList();

      // Monthly performance data (last 12 months)
      final monthlyData = await _getMonthlyPerformanceData(employeeId);

      // Skill utilization
      final skillUtilization = _calculateSkillUtilization(assignments);

      // Time tracking analytics
      final timeAnalytics = _calculateTimeAnalytics(assignments);

      // Quality analytics
      final qualityAnalytics = _calculateQualityAnalytics(completedAssignments);

      return {
        'employee': employee,
        'totalAssignments': assignments.length,
        'completedAssignments': completedAssignments.length,
        'pendingAssignments': assignments.where((a) => a.status == emp.WorkStatus.notStarted || a.status == emp.WorkStatus.inProgress).length,
        'overdueAssignments': overdueAssignments.length,
        'onTimeCompletionRate': assignments.isNotEmpty ? (onTimeAssignments.length / assignments.length) * 100 : 0,
        'averageCompletionTime': _calculateAverageCompletionTime(completedAssignments),
        'totalEarnings': employee.totalEarnings,
        'averageHourlyRate': employee.baseRatePerHour,
        'productivityTrend': monthlyData,
        'skillUtilization': skillUtilization,
        'timeAnalytics': timeAnalytics,
        'qualityAnalytics': qualityAnalytics,
        'efficiencyScore': _calculateEfficiencyScore(employee, assignments),
        'workloadBalance': _calculateWorkloadBalance(employee, assignments),
      };
    } catch (e) {
      throw Exception('Failed to get employee analytics: $e');
    }
  }

  // Get team-wide analytics
  Future<Map<String, dynamic>> getTeamAnalytics() async {
    try {
      // Get all employees
      final employeesQuery = await _firestore.collection('employees').get();
      final employees = employeesQuery.docs
          .map((doc) => emp.Employee.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Get all work assignments
      final assignmentsQuery = await _firestore.collection('work_assignments').get();
      final allAssignments = assignmentsQuery.docs
          .map((doc) => emp.WorkAssignment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Team statistics
      final activeEmployees = employees.where((e) => e.isActive).length;
      final totalCompletedOrders = employees.fold(0, (total, e) => total + e.totalOrdersCompleted);
      final totalEarnings = employees.fold(0.0, (total, e) => total + e.totalEarnings);
      final averageRating = employees.isNotEmpty ?
          employees.map((e) => e.averageRating).reduce((a, b) => a + b) / employees.length : 0.0;

      // Department breakdown
      final departmentBreakdown = _calculateDepartmentBreakdown(employees);

      // Workload distribution
      final workloadDistribution = _calculateWorkloadDistribution(employees, allAssignments);

      // Performance rankings
      final performanceRankings = _calculatePerformanceRankings(employees);

      // Productivity trends
      final productivityTrends = await _getTeamProductivityTrends();

      return {
        'totalEmployees': employees.length,
        'activeEmployees': activeEmployees,
        'totalCompletedOrders': totalCompletedOrders,
        'totalEarnings': totalEarnings,
        'averageTeamRating': averageRating,
        'departmentBreakdown': departmentBreakdown,
        'workloadDistribution': workloadDistribution,
        'performanceRankings': performanceRankings,
        'productivityTrends': productivityTrends,
        'utilizationRate': _calculateTeamUtilizationRate(employees, allAssignments),
        'costEfficiency': _calculateCostEfficiency(employees, allAssignments),
      };
    } catch (e) {
      throw Exception('Failed to get team analytics: $e');
    }
  }

  // Get work efficiency analytics
  Future<Map<String, dynamic>> getWorkEfficiencyAnalytics() async {
    try {
      final assignmentsQuery = await _firestore.collection('work_assignments').get();
      final assignments = assignmentsQuery.docs
          .map((doc) => emp.WorkAssignment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final completedAssignments = assignments.where((a) => a.status == emp.WorkStatus.completed).toList();

      // Efficiency metrics
      final averageCompletionTime = _calculateAverageCompletionTime(completedAssignments);
      final onTimeCompletionRate = completedAssignments.where((a) => a.isOnTime).length / completedAssignments.length * 100;
      final reworkRate = _calculateReworkRate(assignments);

      // Process optimization suggestions
      final optimizationSuggestions = _generateOptimizationSuggestions(assignments, completedAssignments);

      return {
        'averageCompletionTime': averageCompletionTime,
        'onTimeCompletionRate': onTimeCompletionRate,
        'reworkRate': reworkRate,
        'bottlenecks': await _identifyBottlenecks(assignments),
        'optimizationSuggestions': optimizationSuggestions,
        'efficiencyScore': _calculateOverallEfficiency(assignments, completedAssignments),
      };
    } catch (e) {
      throw Exception('Failed to get efficiency analytics: $e');
    }
  }

  // Helper methods for calculations
  Future<List<Map<String, dynamic>>> _getMonthlyPerformanceData(String employeeId) async {
    final now = DateTime.now();
    final monthlyData = <Map<String, dynamic>>[];

    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final assignmentsQuery = await _firestore
          .collection('work_assignments')
          .where('employeeId', isEqualTo: employeeId)
          .where('assignedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(month))
          .where('assignedAt', isLessThan: Timestamp.fromDate(nextMonth))
          .get();

      final monthAssignments = assignmentsQuery.docs
          .map((doc) => emp.WorkAssignment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final completedCount = monthAssignments.where((a) => a.status == emp.WorkStatus.completed).length;
      final totalEarnings = monthAssignments.fold(0.0, (total, a) => total + a.totalEarnings);
      final averageRating = completedCount > 0 ?
          monthAssignments.where((a) => a.qualityRating != null)
              .map((a) => a.qualityRating!)
              .reduce((a, b) => a + b) / completedCount : 0.0;

      monthlyData.add({
        'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
        'completedOrders': completedCount,
        'earnings': totalEarnings,
        'averageRating': averageRating,
        'utilizationRate': monthAssignments.isNotEmpty ? (completedCount / monthAssignments.length) * 100 : 0,
      });
    }

    return monthlyData;
  }

  Map<String, double> _calculateSkillUtilization(List<emp.WorkAssignment> assignments) {
    final skillUsage = <emp.EmployeeSkill, int>{};
    final skillEarnings = <emp.EmployeeSkill, double>{};

    for (final assignment in assignments) {
      skillUsage[assignment.requiredSkill] = (skillUsage[assignment.requiredSkill] ?? 0) + 1;
      skillEarnings[assignment.requiredSkill] = (skillEarnings[assignment.requiredSkill] ?? 0.0) + assignment.totalEarnings;
    }

    return skillEarnings.map((skill, earnings) =>
        MapEntry(skill.toString().split('.').last, earnings));
  }

  Map<String, dynamic> _calculateTimeAnalytics(List<emp.WorkAssignment> assignments) {
    final completedAssignments = assignments.where((a) => a.status == emp.WorkStatus.completed).toList();

    if (completedAssignments.isEmpty) {
      return {'averageHoursPerTask': 0.0, 'totalHoursWorked': 0.0, 'efficiencyRate': 0.0};
    }

    final totalHours = completedAssignments.fold(0.0, (total, a) => total + a.actualHours);
    final totalEstimatedHours = completedAssignments.fold(0.0, (total, a) => total + a.estimatedHours);
    final averageHoursPerTask = totalHours / completedAssignments.length;
    final efficiencyRate = totalEstimatedHours > 0 ? (totalHours / totalEstimatedHours) * 100 : 0.0;

    return {
      'averageHoursPerTask': averageHoursPerTask,
      'totalHoursWorked': totalHours,
      'efficiencyRate': efficiencyRate,
      'overtimeRate': _calculateOvertimeRate(completedAssignments),
    };
  }

  Map<String, dynamic> _calculateQualityAnalytics(List<emp.WorkAssignment> completedAssignments) {
    if (completedAssignments.isEmpty) {
      return {'averageQualityRating': 0.0, 'qualityConsistency': 0.0, 'topRatedSkills': []};
    }

    final ratedAssignments = completedAssignments.where((a) => a.qualityRating != null).toList();
    final averageRating = ratedAssignments.isNotEmpty ?
        ratedAssignments.map((a) => a.qualityRating!).reduce((a, b) => a + b) / ratedAssignments.length : 0.0;

    // Quality consistency (standard deviation of ratings)
    final ratings = ratedAssignments.map((a) => a.qualityRating!).toList();
    final mean = ratings.reduce((a, b) => a + b) / ratings.length;
    final variance = ratings.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) / ratings.length;
    final consistency = variance > 0 ? 100 - (variance * 25) : 100; // Higher consistency = lower variance

    // Top rated skills
    final skillRatings = <emp.EmployeeSkill, List<double>>{};
    for (final assignment in ratedAssignments) {
      if (!skillRatings.containsKey(assignment.requiredSkill)) {
        skillRatings[assignment.requiredSkill] = [];
      }
      skillRatings[assignment.requiredSkill]!.add(assignment.qualityRating!);
    }

    final topRatedSkills = skillRatings.entries
        .map((entry) => {
          'skill': entry.key.toString().split('.').last,
          'averageRating': entry.value.reduce((a, b) => a + b) / entry.value.length,
          'assignmentCount': entry.value.length,
        })
        .toList()
      ..sort((a, b) => (b['averageRating'] as double).compareTo(a['averageRating'] as double));

    return {
      'averageQualityRating': averageRating,
      'qualityConsistency': consistency,
      'topRatedSkills': topRatedSkills.take(5).toList(),
    };
  }

  double _calculateEfficiencyScore(emp.Employee employee, List<emp.WorkAssignment> assignments) {
    if (assignments.isEmpty) return 0.0;

    final completedAssignments = assignments.where((a) => a.status == emp.WorkStatus.completed).toList();
    if (completedAssignments.isEmpty) return 0.0;

    // Factors for efficiency score
    final completionRate = completedAssignments.length / assignments.length;
    final onTimeRate = completedAssignments.where((a) => a.isOnTime).length / completedAssignments.length;
    final qualityScore = employee.averageRating / 5.0; // Normalize to 0-1
    final utilizationRate = employee.ordersInProgress > 0 ? 1.0 : 0.5; // Bonus for active work

    // Weighted average
    return (completionRate * 0.3) + (onTimeRate * 0.3) + (qualityScore * 0.3) + (utilizationRate * 0.1);
  }

  double _calculateWorkloadBalance(emp.Employee employee, List<emp.WorkAssignment> assignments) {
    // Ideal workload: 2-4 assignments per employee
    const idealWorkload = 3.0;
    final currentWorkload = employee.ordersInProgress.toDouble();

    if (currentWorkload == 0) return 0.0; // No work
    if (currentWorkload <= idealWorkload) return 1.0; // Optimal workload

    // Calculate balance score (decreases as workload increases beyond ideal)
    return idealWorkload / currentWorkload;
  }

  Map<String, dynamic> _calculateDepartmentBreakdown(List<emp.Employee> employees) {
    // Group employees by their primary skill/role
    final departments = <String, Map<String, dynamic>>{};

    for (final employee in employees) {
      String department = 'General';
      if (employee.hasSkill(emp.EmployeeSkill.cutting)) {
        department = 'Cutting';
      } else if (employee.hasSkill(emp.EmployeeSkill.stitching)) {
        department = 'Stitching';
      } else if (employee.hasSkill(emp.EmployeeSkill.finishing)) {
        department = 'Finishing';
      } else if (employee.hasSkill(emp.EmployeeSkill.alterations)) {
        department = 'Alterations';
      } else if (employee.hasSkill(emp.EmployeeSkill.embroidery)) {
        department = 'Embroidery';
      }

      if (!departments.containsKey(department)) {
        departments[department] = {
          'count': 0,
          'averageRating': 0.0,
          'totalEarnings': 0.0,
          'activeEmployees': 0,
        };
      }

      departments[department]!['count']++;
      departments[department]!['averageRating'] += employee.averageRating;
      departments[department]!['totalEarnings'] += employee.totalEarnings;
      if (employee.isActive) departments[department]!['activeEmployees']++;
    }

    // Calculate averages
    departments.forEach((dept, data) {
      if (data['count'] > 0) {
        data['averageRating'] = data['averageRating'] / data['count'];
      }
    });

    return departments;
  }

  Map<String, dynamic> _calculateWorkloadDistribution(List<emp.Employee> employees, List<emp.WorkAssignment> assignments) {
    final workloadData = <String, Map<String, dynamic>>{};

    for (final employee in employees) {
      final employeeAssignments = assignments.where((a) => a.employeeId == employee.id).toList();
      final completedCount = employeeAssignments.where((a) => a.status == emp.WorkStatus.completed).length;

      workloadData[employee.displayName] = {
        'totalAssignments': employeeAssignments.length,
        'completedAssignments': completedCount,
        'pendingAssignments': employeeAssignments.where((a) => a.status != emp.WorkStatus.completed).length,
        'currentWorkload': employee.ordersInProgress,
        'completionRate': employeeAssignments.isNotEmpty ? (completedCount / employeeAssignments.length) * 100 : 0.0,
      };
    }

    return workloadData;
  }

  List<Map<String, dynamic>> _calculatePerformanceRankings(List<emp.Employee> employees) {
    return employees
        .map((employee) => {
          'id': employee.id,
          'name': employee.displayName,
          'efficiencyScore': _calculateEfficiencyScore(employee, []), // Would need assignments
          'completionRate': employee.completionRate,
          'averageRating': employee.averageRating,
          'totalEarnings': employee.totalEarnings,
          'ordersCompleted': employee.totalOrdersCompleted,
        })
        .toList()
      ..sort((a, b) => (b['efficiencyScore'] as double).compareTo(a['efficiencyScore'] as double));
  }

  Future<List<Map<String, dynamic>>> _getTeamProductivityTrends() async {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final assignmentsQuery = await _firestore
          .collection('work_assignments')
          .where('assignedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(month))
          .where('assignedAt', isLessThan: Timestamp.fromDate(nextMonth))
          .get();

      final monthAssignments = assignmentsQuery.docs
          .map((doc) => emp.WorkAssignment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final completedCount = monthAssignments.where((a) => a.status == emp.WorkStatus.completed).length;
      final totalEarnings = monthAssignments.fold(0.0, (total, a) => total + a.totalEarnings);

      trends.add({
        'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
        'completedOrders': completedCount,
        'totalEarnings': totalEarnings,
        'productivityIndex': completedCount > 0 ? totalEarnings / completedCount : 0.0,
      });
    }

    return trends;
  }

  double _calculateTeamUtilizationRate(List<emp.Employee> employees, List<emp.WorkAssignment> assignments) {
    if (employees.isEmpty) return 0.0;

    final activeEmployees = employees.where((e) => e.isActive).length;
    final employeesWithWork = assignments
        .map((a) => a.employeeId)
        .toSet()
        .length;

    return employeesWithWork / activeEmployees;
  }

  double _calculateCostEfficiency(List<emp.Employee> employees, List<emp.WorkAssignment> assignments) {
    if (assignments.isEmpty) return 0.0;

    final totalCost = assignments.fold(0.0, (total, a) => total + (a.hourlyRate * a.actualHours));
    final totalValue = assignments.where((a) => a.status == emp.WorkStatus.completed)
        .fold(0.0, (total, a) => total + a.totalEarnings);

    return totalCost > 0 ? (totalValue / totalCost) * 100 : 0.0;
  }

  double _calculateAverageCompletionTime(List<emp.WorkAssignment> completedAssignments) {
    if (completedAssignments.isEmpty) return 0.0;

    final totalHours = completedAssignments.fold(0.0, (total, a) => total + a.actualHours);
    return totalHours / completedAssignments.length;
  }

  double _calculateOvertimeRate(List<emp.WorkAssignment> assignments) {
    final overtimeAssignments = assignments.where((a) => a.actualHours > a.estimatedHours * 1.2).length;
    return assignments.isNotEmpty ? (overtimeAssignments / assignments.length) * 100 : 0.0;
  }

  double _calculateReworkRate(List<emp.WorkAssignment> assignments) {
    final reworkAssignments = assignments.where((a) => a.status == emp.WorkStatus.rejected).length;
    return assignments.isNotEmpty ? (reworkAssignments / assignments.length) * 100 : 0.0;
  }

  Future<List<Map<String, dynamic>>> _identifyBottlenecks(List<emp.WorkAssignment> assignments) async {
    final bottlenecks = <Map<String, dynamic>>[];

    // Analyze by skill
    final skillDelays = <emp.EmployeeSkill, List<double>>{};
    for (final assignment in assignments.where((a) => a.status == emp.WorkStatus.completed)) {
      if (!skillDelays.containsKey(assignment.requiredSkill)) {
        skillDelays[assignment.requiredSkill] = [];
      }

      final delay = assignment.actualHours - assignment.estimatedHours;
      if (delay > 0) {
        skillDelays[assignment.requiredSkill]!.add(delay);
      }
    }

    // Find skills with highest average delays
    final sortedSkills = skillDelays.entries
        .map((entry) => {
          'skill': entry.key.toString().split('.').last,
          'averageDelay': entry.value.reduce((a, b) => a + b) / entry.value.length,
          'affectedAssignments': entry.value.length,
        })
        .toList()
      ..sort((a, b) => (b['averageDelay'] as double).compareTo(a['averageDelay'] as double));

    return sortedSkills.take(3).toList();
  }

  List<String> _generateOptimizationSuggestions(List<emp.WorkAssignment> allAssignments, List<emp.WorkAssignment> completedAssignments) {
    final suggestions = <String>[];

    // Analyze completion patterns
    final averageCompletionTime = _calculateAverageCompletionTime(completedAssignments);
    final onTimeRate = completedAssignments.where((a) => a.isOnTime).length / completedAssignments.length;

    if (onTimeRate < 0.7) {
      suggestions.add('Consider increasing time estimates by 20% to improve on-time completion rate');
    }

    if (averageCompletionTime > 8.0) {
      suggestions.add('Long tasks detected - consider breaking complex orders into smaller assignments');
    }

    // Check for skill imbalances
    final skillCounts = <emp.EmployeeSkill, int>{};
    for (final assignment in allAssignments) {
      skillCounts[assignment.requiredSkill] = (skillCounts[assignment.requiredSkill] ?? 0) + 1;
    }

    final maxSkillCount = skillCounts.values.reduce((a, b) => a > b ? a : b);
    final minSkillCount = skillCounts.values.reduce((a, b) => a < b ? a : b);

    if (maxSkillCount > minSkillCount * 2) {
      suggestions.add('Skill utilization imbalance detected - consider cross-training employees');
    }

    // Quality feedback
    final averageRating = completedAssignments
        .where((a) => a.qualityRating != null)
        .map((a) => a.qualityRating!)
        .reduce((a, b) => a + b) / completedAssignments.where((a) => a.qualityRating != null).length;

    if (averageRating < 3.5) {
      suggestions.add('Quality ratings could be improved - consider additional training or quality checks');
    }

    return suggestions;
  }

  double _calculateOverallEfficiency(List<emp.WorkAssignment> allAssignments, List<emp.WorkAssignment> completedAssignments) {
    if (completedAssignments.isEmpty) return 0.0;

    final completionRate = completedAssignments.length / allAssignments.length;
    final onTimeRate = completedAssignments.where((a) => a.isOnTime).length / completedAssignments.length;

    return (completionRate * 0.4) + (onTimeRate * 0.4) + (_calculateTeamUtilizationRate([], allAssignments) * 0.2);
  }
}
