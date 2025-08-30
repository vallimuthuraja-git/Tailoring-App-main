import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart' as emp;

class WorkAssignmentRecommendation {
  final String employeeId;
  final String employeeName;
  final double suitabilityScore;
  final List<String> reasons;
  final double estimatedHours;
  final double confidenceLevel;
  final Map<String, dynamic> assignmentDetails;

  const WorkAssignmentRecommendation({
    required this.employeeId,
    required this.employeeName,
    required this.suitabilityScore,
    required this.reasons,
    required this.estimatedHours,
    required this.confidenceLevel,
    required this.assignmentDetails,
  });
}

class WorkAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Main method to get assignment recommendations for an order
  Future<List<WorkAssignmentRecommendation>> getAssignmentRecommendations({
    required String orderId,
    required List<String> requiredSkills,
    required DateTime deadline,
    required double estimatedHours,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      // Get all available employees
      final employeesQuery = await _firestore.collection('employees').get();
      final employees = employeesQuery.docs
          .map((doc) => emp.Employee.fromJson({...doc.data(), 'id': doc.id}))
          .where((emp) => emp.isActive)
          .toList();

      final recommendations = <WorkAssignmentRecommendation>[];

      for (final employee in employees) {
        final suitability = await _calculateSuitabilityScore(
          employee: employee,
          requiredSkills: requiredSkills,
          deadline: deadline,
          estimatedHours: estimatedHours,
          orderDetails: orderDetails,
        );

        if (suitability.suitabilityScore > 0.3) { // Only include reasonably suitable employees
          recommendations.add(suitability);
        }
      }

      // Sort by suitability score (descending)
      recommendations.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));

      return recommendations.take(5).toList(); // Return top 5 recommendations
    } catch (e) {
      // print('Error getting assignment recommendations: $e');
      return [];
    }
  }

  // Calculate suitability score for an employee
  Future<WorkAssignmentRecommendation> _calculateSuitabilityScore({
    required emp.Employee employee,
    required List<String> requiredSkills,
    required DateTime deadline,
    required double estimatedHours,
    required Map<String, dynamic> orderDetails,
  }) async {
    double score = 0.0;
    final reasons = <String>[];
    double confidence = 0.8;

    // 1. Skills Matching (40% weight)
    final skillScore = _calculateSkillScore(employee, requiredSkills);
    score += skillScore * 0.4;

    if (skillScore > 0.8) {
      reasons.add('Excellent skill match');
    } else if (skillScore > 0.6) {
      reasons.add('Good skill match');
    } else if (skillScore > 0.4) {
      reasons.add('Moderate skill match');
    }

    // 2. Availability and Workload (25% weight)
    final availabilityScore = await _calculateAvailabilityScore(employee, deadline, estimatedHours);
    score += availabilityScore * 0.25;

    if (availabilityScore > 0.8) {
      reasons.add('Low workload, highly available');
    } else if (availabilityScore < 0.4) {
      reasons.add('High workload, limited availability');
      confidence -= 0.2;
    }

    // 3. Performance History (20% weight)
    final performanceScore = _calculatePerformanceScore(employee, requiredSkills);
    score += performanceScore * 0.2;

    if (performanceScore > 0.8) {
      reasons.add('Strong performance history');
    } else if (performanceScore < 0.5) {
      reasons.add('Performance concerns noted');
      confidence -= 0.1;
    }

    // 4. Experience Level (10% weight)
    final experienceScore = _calculateExperienceScore(employee, requiredSkills);
    score += experienceScore * 0.1;

    if (experienceScore > 0.7) {
      reasons.add('Extensive relevant experience');
    }

    // 5. Work Preferences (5% weight)
    final preferenceScore = _calculatePreferenceScore(employee, orderDetails);
    score += preferenceScore * 0.05;

    if (preferenceScore > 0.8) {
      reasons.add('Matches work preferences');
    }

    // Adjust confidence based on data completeness
    if (employee.totalOrdersCompleted == 0) {
      confidence -= 0.3;
      reasons.add('Limited work history');
    }

    // Calculate estimated hours based on employee's historical performance
    final adjustedHours = _estimateWorkHours(employee, estimatedHours, requiredSkills);

    return WorkAssignmentRecommendation(
      employeeId: employee.id,
      employeeName: employee.displayName,
      suitabilityScore: score.clamp(0.0, 1.0),
      reasons: reasons,
      estimatedHours: adjustedHours,
      confidenceLevel: confidence.clamp(0.0, 1.0),
      assignmentDetails: {
        'skillScore': skillScore,
        'availabilityScore': availabilityScore,
        'performanceScore': performanceScore,
        'experienceScore': experienceScore,
        'preferenceScore': preferenceScore,
        'requiredSkills': requiredSkills,
        'workloadBalance': _calculateWorkloadBalance(employee),
      },
    );
  }

  double _calculateSkillScore(emp.Employee employee, List<String> requiredSkills) {
    if (requiredSkills.isEmpty) return 1.0;

    int matchedSkills = 0;
    for (final requiredSkill in requiredSkills) {
      final skill = _parseSkillFromString(requiredSkill);
      if (employee.hasSkill(skill)) {
        matchedSkills++;
      }
    }

    final primarySkillMatch = matchedSkills / requiredSkills.length;

    // Bonus for having multiple relevant skills
    final totalRelevantSkills = employee.skills.where((skill) {
      final skillName = skill.toString().split('.').last.toLowerCase();
      return requiredSkills.any((req) => req.toLowerCase().contains(skillName));
    }).length;

    final skillDiversityBonus = totalRelevantSkills > 1 ? 0.1 : 0.0;

    return (primarySkillMatch + skillDiversityBonus).clamp(0.0, 1.0);
  }

  Future<double> _calculateAvailabilityScore(
    emp.Employee employee,
    DateTime deadline,
    double estimatedHours,
  ) async {
    // Check current workload
    final currentAssignments = await _firestore
        .collection('work_assignments')
        .where('employeeId', isEqualTo: employee.id)
        .where('status', isEqualTo: emp.WorkStatus.inProgress.index)
        .get();

    final currentWorkload = currentAssignments.docs.length;
    final maxWorkload = employee.availability == emp.EmployeeAvailability.fullTime ? 3 : 2;

    // Calculate workload factor
    final workloadFactor = currentWorkload >= maxWorkload ? 0.0 :
                          currentWorkload >= maxWorkload - 1 ? 0.5 : 1.0;

    // Check time availability
    final timeFactor = _checkTimeAvailability(employee, deadline);

    // Check consecutive work days
    final consecutiveDaysFactor = employee.consecutiveDaysWorked > 5 ? 0.7 :
                                 employee.consecutiveDaysWorked > 3 ? 0.9 : 1.0;

    return (workloadFactor * 0.5) + (timeFactor * 0.3) + (consecutiveDaysFactor * 0.2);
  }

  double _calculatePerformanceScore(emp.Employee employee, List<String> requiredSkills) {
    if (employee.totalOrdersCompleted == 0) return 0.5; // Neutral for new employees

    // Base performance score
    double score = employee.averageRating / 5.0; // Normalize to 0-1

    // Adjust based on completion rate
    final completionAdjustment = (employee.completionRate - 0.8) * 0.5; // Target 80% completion rate
    score += completionAdjustment;

    // Adjust based on recent performance (last 10 orders)
    if (employee.recentAssignments.isNotEmpty) {
      final recentAssignments = employee.recentAssignments.take(5).toList();
      final recentAvgRating = recentAssignments
          .where((a) => a.qualityRating != null)
          .map((a) => a.qualityRating!)
          .reduce((a, b) => a + b) / recentAssignments.length;

      final recentAdjustment = (recentAvgRating / 5.0 - score) * 0.3;
      score += recentAdjustment;
    }

    return score.clamp(0.0, 1.0);
  }

  double _calculateExperienceScore(emp.Employee employee, List<String> requiredSkills) {
    // Base experience score
    final experienceScore = (employee.experienceYears / 10.0).clamp(0.0, 1.0);

    // Bonus for relevant certifications
    final certificationBonus = employee.certifications.length * 0.1;
    final specializationBonus = employee.specializations.length * 0.05;

    return (experienceScore + certificationBonus + specializationBonus).clamp(0.0, 1.0);
  }

  double _calculatePreferenceScore(emp.Employee employee, Map<String, dynamic> orderDetails) {
    double score = 0.0;
    int factors = 0;

    // Check if order type matches employee specializations
    final orderType = orderDetails['category'] as String?;
    if (orderType != null) {
      if (employee.specializations.any((spec) =>
          spec.toLowerCase().contains(orderType.toLowerCase()))) {
        score += 1.0;
        factors++;
      }
    }

    // Check if employee prefers remote work when applicable
    final isRemoteWork = orderDetails['isRemoteWork'] as bool? ?? false;
    if (isRemoteWork && employee.canWorkRemotely) {
      score += 1.0;
      factors++;
    }

    // Check work hours alignment
    final preferredStartTime = employee.preferredStartTime;
    final preferredEndTime = employee.preferredEndTime;
    if (preferredStartTime != null && preferredEndTime != null) {
      // This would need actual work time data from the order
      score += 0.5; // Placeholder
      factors++;
    }

    return factors > 0 ? score / factors : 0.5;
  }

  double _checkTimeAvailability(emp.Employee employee, DateTime deadline) {
    final now = DateTime.now();
    final hoursUntilDeadline = deadline.difference(now).inHours;

    // Check if deadline is within employee's availability
    if (hoursUntilDeadline < 0) return 0.0; // Overdue
    if (hoursUntilDeadline < 8) return 0.3; // Very urgent
    if (hoursUntilDeadline < 24) return 0.6; // Urgent
    if (hoursUntilDeadline < 72) return 0.9; // Soon
    return 1.0; // Plenty of time
  }

  double _calculateWorkloadBalance(emp.Employee employee) {
    // Ideal workload: 2-4 assignments
    const idealMin = 2.0;
    const idealMax = 4.0;
    final currentWorkload = employee.ordersInProgress.toDouble();

    if (currentWorkload < idealMin) return 0.8; // Room for more work
    if (currentWorkload <= idealMax) return 1.0; // Optimal workload
    return 0.5 / currentWorkload; // Overloaded, decreasing score
  }

  double _estimateWorkHours(
    emp.Employee employee,
    double baseEstimatedHours,
    List<String> requiredSkills,
  ) {
    if (employee.totalOrdersCompleted == 0) return baseEstimatedHours;

    // Calculate employee's average time per similar task
    final similarAssignments = employee.recentAssignments.where((assignment) {
      final assignmentSkill = assignment.requiredSkill.toString().split('.').last;
      return requiredSkills.any((skill) => skill.toLowerCase().contains(assignmentSkill.toLowerCase()));
    }).toList();

    if (similarAssignments.isEmpty) {
      return baseEstimatedHours * (employee.experienceYears > 3 ? 0.9 : 1.1);
    }

    // Calculate average actual hours vs estimated hours for similar tasks
    final avgEfficiency = similarAssignments
        .map((a) => a.estimatedHours > 0 ? a.actualHours / a.estimatedHours : 1.0)
        .reduce((a, b) => a + b) / similarAssignments.length;

    return baseEstimatedHours * avgEfficiency;
  }

  emp.EmployeeSkill _parseSkillFromString(String skillString) {
    final skill = skillString.toLowerCase();

    if (skill.contains('cutting')) return emp.EmployeeSkill.cutting;
    if (skill.contains('stitching') || skill.contains('sewing')) return emp.EmployeeSkill.stitching;
    if (skill.contains('finishing') || skill.contains('final')) return emp.EmployeeSkill.finishing;
    if (skill.contains('alteration') || skill.contains('alter')) return emp.EmployeeSkill.alterations;
    if (skill.contains('embroidery') || skill.contains('embroider')) return emp.EmployeeSkill.embroidery;
    if (skill.contains('quality') || skill.contains('check')) return emp.EmployeeSkill.qualityCheck;
    if (skill.contains('pattern')) return emp.EmployeeSkill.patternMaking;

    return emp.EmployeeSkill.stitching; // Default
  }

  // Auto-assign work to the best available employee
  Future<bool> autoAssignWork({
    required String orderId,
    required List<String> requiredSkills,
    required DateTime deadline,
    required double estimatedHours,
    required String assignedBy,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      final recommendations = await getAssignmentRecommendations(
        orderId: orderId,
        requiredSkills: requiredSkills,
        deadline: deadline,
        estimatedHours: estimatedHours,
        orderDetails: orderDetails,
      );

      if (recommendations.isEmpty) {
        // print('No suitable employees found for auto-assignment');
        return false;
      }

      final bestMatch = recommendations.first;
      if (bestMatch.confidenceLevel < 0.6) {
        // print('Best match has low confidence (${bestMatch.confidenceLevel}), manual assignment recommended');
        return false;
      }

      // Create work assignment
      final assignmentData = {
        'id': '',
        'orderId': orderId,
        'employeeId': bestMatch.employeeId,
        'requiredSkill': _parseSkillFromString(requiredSkills.first).index,
        'taskDescription': 'Auto-assigned: ${requiredSkills.join(', ')} work',
        'assignedAt': Timestamp.fromDate(DateTime.now()),
        'deadline': Timestamp.fromDate(deadline),
        'status': emp.WorkStatus.notStarted.index,
        'estimatedHours': bestMatch.estimatedHours,
        'actualHours': 0.0,
        'hourlyRate': bestMatch.assignmentDetails['hourlyRate'] ?? 15.0,
        'bonusRate': (bestMatch.assignmentDetails['hourlyRate'] ?? 15.0) * 0.1,
        'updates': [],
        'materials': orderDetails['materials'] ?? {},
        'isRemoteWork': orderDetails['isRemoteWork'] ?? false,
        'assignedBy': assignedBy,
      };

      await _firestore.collection('work_assignments').add(assignmentData);

      // Update employee's workload
      final employeeRef = _firestore.collection('employees').doc(bestMatch.employeeId);
      await employeeRef.update({
        'ordersInProgress': FieldValue.increment(1),
        'lastActive': Timestamp.fromDate(DateTime.now()),
      });

      // print('Successfully auto-assigned work to ${bestMatch.employeeName}');
      return true;
    } catch (e) {
      // print('Error in auto-assignment: $e');
      return false;
    }
  }

  // Get assignment analytics for optimization
  Future<Map<String, dynamic>> getAssignmentAnalytics() async {
    try {
      final assignmentsQuery = await _firestore.collection('work_assignments').get();
      final assignments = assignmentsQuery.docs
          .map((doc) => emp.WorkAssignment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Calculate assignment success metrics
      final completedAssignments = assignments.where((a) => a.status == emp.WorkStatus.completed).toList();
      final autoAssigned = assignments.where((a) => a.assignedBy.toLowerCase().contains('auto')).toList();

      final autoAssignmentSuccess = autoAssigned.isNotEmpty ?
          autoAssigned.where((a) => a.status == emp.WorkStatus.completed).length / autoAssigned.length : 0.0;

      // Calculate skill utilization efficiency
      final skillEfficiency = _calculateSkillEfficiency(assignments);

      // Calculate workload distribution
      final workloadDistribution = await _calculateWorkloadDistribution();

      return {
        'totalAssignments': assignments.length,
        'completedAssignments': completedAssignments.length,
        'autoAssignmentRate': autoAssigned.length / assignments.length,
        'autoAssignmentSuccessRate': autoAssignmentSuccess,
        'averageCompletionTime': _calculateAverageCompletionTime(completedAssignments),
        'skillEfficiency': skillEfficiency,
        'workloadDistribution': workloadDistribution,
        'assignmentOptimization': _generateAssignmentOptimization(assignments),
      };
    } catch (e) {
      // print('Error getting assignment analytics: $e');
      return {};
    }
  }

  Map<String, double> _calculateSkillEfficiency(List<emp.WorkAssignment> assignments) {
    final skillStats = <emp.EmployeeSkill, Map<String, dynamic>>{};

    for (final assignment in assignments) {
      if (!skillStats.containsKey(assignment.requiredSkill)) {
        skillStats[assignment.requiredSkill] = {
          'total': 0,
          'completed': 0,
          'totalHours': 0.0,
          'efficiency': 0.0,
        };
      }

      skillStats[assignment.requiredSkill]!['total']++;
      skillStats[assignment.requiredSkill]!['totalHours'] += assignment.actualHours;

      if (assignment.status == emp.WorkStatus.completed) {
        skillStats[assignment.requiredSkill]!['completed']++;
      }
    }

    // Calculate efficiency for each skill
    return skillStats.map((skill, stats) {
      final completionRate = stats['total'] > 0 ? stats['completed'] / stats['total'] : 0.0;
      final avgHours = stats['completed'] > 0 ? stats['totalHours'] / stats['completed'] : 0.0;
      final efficiency = completionRate * (avgHours > 0 ? 1.0 / avgHours : 0.0);

      return MapEntry(skill.toString().split('.').last, efficiency);
    });
  }

  Future<Map<String, dynamic>> _calculateWorkloadDistribution() async {
    final employeesQuery = await _firestore.collection('employees').get();
    final employees = employeesQuery.docs
        .map((doc) => emp.Employee.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    final workloadData = <String, int>{};
    for (final employee in employees) {
      final workload = employee.ordersInProgress;
      workloadData[employee.displayName] = workload;
    }

    return workloadData;
  }

  double _calculateAverageCompletionTime(List<emp.WorkAssignment> completedAssignments) {
    if (completedAssignments.isEmpty) return 0.0;

    final totalHours = completedAssignments
        .map((a) => a.actualHours)
        .reduce((a, b) => a + b);

    return totalHours / completedAssignments.length;
  }

  List<String> _generateAssignmentOptimization(List<emp.WorkAssignment> assignments) {
    final optimizations = <String>[];

    // Analyze assignment patterns
    final overdueAssignments = assignments.where((a) => a.isOverdue).length;
    if (overdueAssignments > assignments.length * 0.1) {
      optimizations.add('High overdue rate detected - consider adjusting time estimates');
    }

    // Check skill utilization balance
    final skillCounts = <emp.EmployeeSkill, int>{};
    for (final assignment in assignments) {
      skillCounts[assignment.requiredSkill] = (skillCounts[assignment.requiredSkill] ?? 0) + 1;
    }

    if (skillCounts.isNotEmpty) {
      final maxSkillCount = skillCounts.values.reduce((a, b) => a > b ? a : b);
      final minSkillCount = skillCounts.values.reduce((a, b) => a < b ? a : b);

      if (maxSkillCount > minSkillCount * 2) {
        optimizations.add('Skill utilization imbalance - consider cross-training');
      }
    }

    return optimizations;
  }

  // Batch assignment for multiple orders
  Future<Map<String, dynamic>> batchAssignWork({
    required List<String> orderIds,
    required List<String> requiredSkills,
    required DateTime deadline,
    required String assignedBy,
  }) async {
    final results = <String, dynamic>{};
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final orderId in orderIds) {
      try {
        final success = await autoAssignWork(
          orderId: orderId,
          requiredSkills: requiredSkills,
          deadline: deadline,
          estimatedHours: 8.0, // Default
          assignedBy: assignedBy,
          orderDetails: {},
        );

        if (success) {
          successCount++;
          results[orderId] = 'success';
        } else {
          failureCount++;
          results[orderId] = 'no_suitable_employee';
        }
      } catch (e) {
        failureCount++;
        results[orderId] = 'error: $e';
        errors.add('Order $orderId: $e');
      }
    }

    return {
      'totalOrders': orderIds.length,
      'successfulAssignments': successCount,
      'failedAssignments': failureCount,
      'results': results,
      'errors': errors,
      'successRate': orderIds.isNotEmpty ? successCount / orderIds.length : 0.0,
    };
  }
}