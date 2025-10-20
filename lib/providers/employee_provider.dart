import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../models/user_role.dart';

import '../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Use alias to avoid TimeOfDay conflict
import '../models/employee.dart' as emp;

class EmployeeProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  EmployeeAvailability? _selectedAvailabilityFilter;
  EmployeeSkill? _selectedSkillFilter;
  bool? _activeStatusFilter; // null = all, true = active, false = inactive

  // Getters
  List<Employee> get employees => _searchQuery.isEmpty &&
      _selectedAvailabilityFilter == null &&
      _selectedSkillFilter == null &&
      _activeStatusFilter == null
      ? _employees
      : _filteredEmployees;

  List<Employee> get activeEmployees => _employees.where((emp) => emp.isActive).toList();
  List<Employee> get availableEmployees => _employees.where((emp) => emp.isCurrentlyAvailable).toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistics
  int get totalEmployees => _employees.length;
  int get activeEmployeesCount => activeEmployees.length;
  int get availableEmployeesCount => availableEmployees.length;

  double get averageRating => _employees.isEmpty ? 0.0 :
    _employees.map((e) => e.averageRating).reduce((a, b) => a + b) / _employees.length;

  double get totalEarnings => _employees.map((e) => e.totalEarnings).reduce((a, b) => a + b);

  Map<EmployeeSkill, int> get skillDistribution {
    final Map<EmployeeSkill, int> distribution = {};
    for (var employee in _employees) {
      for (var skill in employee.skills) {
        distribution[skill] = (distribution[skill] ?? 0) + 1;
      }
    }
    return distribution;
  }

  // Filter methods
  void searchEmployees(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void filterByAvailability(EmployeeAvailability? availability) {
    _selectedAvailabilityFilter = availability;
    _applyFilters();
  }

  void filterBySkill(EmployeeSkill? skill) {
    _selectedSkillFilter = skill;
    _applyFilters();
  }

  void filterByActiveStatus(bool? isActive) {
    _activeStatusFilter = isActive;
    _applyFilters();
  }

  void _applyFilters() {
    List<Employee> filtered = _employees;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((employee) {
        return employee.displayName.toLowerCase().contains(_searchQuery) ||
               employee.email.toLowerCase().contains(_searchQuery) ||
               employee.specializations.any((spec) => spec.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    // Apply availability filter
    if (_selectedAvailabilityFilter != null) {
      filtered = filtered.where((employee) => employee.availability == _selectedAvailabilityFilter).toList();
    }

    // Apply skill filter
    if (_selectedSkillFilter != null) {
      filtered = filtered.where((employee) => employee.hasSkill(_selectedSkillFilter!)).toList();
    }

    // Apply active status filter
    if (_activeStatusFilter != null) {
      filtered = filtered.where((employee) => employee.isActive == _activeStatusFilter).toList();
    }

    _filteredEmployees = filtered;
    notifyListeners();
  }

  // Load employees from Firestore with improved error handling
  Future<void> loadEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    debugdebugPrint('ðŸ‘¥ Loading employees from Firebase...');
    notifyListeners();

    try {
      // Skip connection check for first attempt - just try to fetch data
      debugdebugPrint('ðŸ“‹ Fetching employees collection from Firebase...');
      final querySnapshot = await _firebaseService.getCollection('employees');

      _employees = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        Employee? employee;
        try {
          employee = Employee.fromJson(data);
        } catch (parseError) {
          debugdebugPrint('âš ï¸ Failed to parse employee ${doc.id}: $parseError');
          debugdebugPrint('ðŸ“„ Raw data: $data');
          employee = null;
        }

        return employee;
      }).whereType<Employee>().toList();

      debugdebugPrint('âœ… Successfully loaded ${_employees.length} employees from database');

      _applyFilters();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();

    } catch (e) {
      debugdebugPrint('âŒ Failed to load employees from database: $e');

      // Try one more time with connection check
      try {
        debugdebugPrint('ðŸ”„ Retrying with connection check...');
        final connectionStatus = await _firebaseService.getConnectionStatus();

        if (!connectionStatus['connected']) {
          throw Exception('No Firebase connection: ${connectionStatus['error']}');
        }

        // If connection is OK, rethrow original error
        rethrow;
      } catch (retryError) {
        debugdebugPrint('âŒ Retry also failed: $retryError');
        _isLoading = false;
        _errorMessage = _getUserFriendlyErrorMessage(e);
        _employees = []; // Clear local data on error to force fresh load
        notifyListeners();
        rethrow;
      }
    }
  }

  // Force reload from database (bypassing any potential caching)
  Future<void> forceReloadEmployees() async {
    debugdebugPrint('ðŸ”„ Force reloading employees...');
    await loadEmployees();
  }

  // Stream employees for real-time updates
  Stream<List<Employee>> getEmployeesStream() {
    return _firebaseService.collectionStream('employees').map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Employee.fromJson(data);
      }).toList();
    });
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(String employeeId) async {
    try {
      final docSnapshot = await _firebaseService.getDocument('employees', employeeId);
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        data['id'] = docSnapshot.id;
        return Employee.fromJson(data);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Failed to load employee: $e';
      notifyListeners();
      return null;
    }
  }

  // Stream single employee
  Stream<Employee?> getEmployeeStream(String employeeId) {
    return _firebaseService.documentStream('employees', employeeId).map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Employee.fromJson(data);
      }
      return null;
    });
  }

  // Create new employee with database verification
  Future<bool> createEmployee({
    required String userId,
    required String displayName,
    required String email,
    String? phoneNumber,
    String? photoUrl,
    UserRole? role,
    required List<EmployeeSkill> skills,
    required List<String> specializations,
    required int experienceYears,
    required List<String> certifications,
    required EmployeeAvailability availability,
    required List<String> preferredWorkDays,
    emp.TimeOfDay? preferredStartTime,
    emp.TimeOfDay? preferredEndTime,
    required bool canWorkRemotely,
    String? location,
    required double baseRatePerHour,
    required double performanceBonusRate,
    required String paymentTerms,
  }) async {
    debugdebugPrint('ðŸ‘¤ Creating new employee: $displayName');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check database connection first
      final connectionStatus = await _firebaseService.getConnectionStatus();
      if (!connectionStatus['connected']) {
        throw Exception('No database connection: ${connectionStatus['error']}');
      }

      final employee = Employee(
        id: '',
        userId: userId,
        displayName: displayName,
        email: email,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        role: role,
        skills: skills,
        specializations: specializations,
        experienceYears: experienceYears,
        certifications: certifications,
        availability: availability,
        preferredWorkDays: preferredWorkDays,
        preferredStartTime: preferredStartTime,
        preferredEndTime: preferredEndTime,
        canWorkRemotely: canWorkRemotely,
        location: location,
        totalOrdersCompleted: 0,
        ordersInProgress: 0,
        averageRating: 0.0,
        completionRate: 0.0,
        strengths: [],
        areasForImprovement: [],
        baseRatePerHour: baseRatePerHour,
        performanceBonusRate: performanceBonusRate,
        paymentTerms: paymentTerms,
        totalEarnings: 0.0,
        recentAssignments: [],
        consecutiveDaysWorked: 0,
        isActive: true,
        joinedDate: DateTime.now(),
        additionalInfo: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final employeeData = employee.toJson();
      employeeData.remove('id');

      debugdebugPrint('ðŸ’¾ Saving employee data to Firebase...');
      final docRef = await _firebaseService.addDocument('employees', employeeData);

      debugdebugPrint('âœ… Employee created successfully with ID: ${docRef.id}');

      // Immediate reload to reflect changes in UI
      await loadEmployees();

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;

    } catch (e) {
      debugdebugPrint('âŒ Failed to create employee $displayName: $e');
      _isLoading = false;
      _errorMessage = 'Failed to create employee: $e';
      notifyListeners();
      return false;
    }
  }

  // Update employee
  Future<bool> updateEmployee(String employeeId, Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firebaseService.updateDocument('employees', employeeId, updates);

      await loadEmployees();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update employee: $e';
      notifyListeners();
      return false;
    }
  }

  // Update employee skills and performance
  Future<bool> updateEmployeeSkills(String employeeId, {
    List<EmployeeSkill>? skills,
    List<String>? specializations,
    List<String>? certifications,
    int? experienceYears,
  }) async {
    final updates = <String, dynamic>{};

    if (skills != null) updates['skills'] = skills.map((skill) => skill.index).toList();
    if (specializations != null) updates['specializations'] = specializations;
    if (certifications != null) updates['certifications'] = certifications;
    if (experienceYears != null) updates['experienceYears'] = experienceYears;

    return await updateEmployee(employeeId, updates);
  }

  // Update employee performance metrics
  Future<bool> updateEmployeePerformance(String employeeId, {
    int? totalOrdersCompleted,
    int? ordersInProgress,
    double? averageRating,
    double? completionRate,
    List<String>? strengths,
    List<String>? areasForImprovement,
    double? totalEarnings,
    List<WorkAssignment>? recentAssignments,
  }) async {
    final updates = <String, dynamic>{};

    if (totalOrdersCompleted != null) updates['totalOrdersCompleted'] = totalOrdersCompleted;
    if (ordersInProgress != null) updates['ordersInProgress'] = ordersInProgress;
    if (averageRating != null) updates['averageRating'] = averageRating;
    if (completionRate != null) updates['completionRate'] = completionRate;
    if (strengths != null) updates['strengths'] = strengths;
    if (areasForImprovement != null) updates['areasForImprovement'] = areasForImprovement;
    if (totalEarnings != null) updates['totalEarnings'] = totalEarnings;
    if (recentAssignments != null) updates['recentAssignments'] = recentAssignments.map((assignment) => assignment.toJson()).toList();

    return await updateEmployee(employeeId, updates);
  }

  // Assign work to employee
  Future<bool> assignWorkToEmployee({
    required String employeeId,
    required String orderId,
    required EmployeeSkill requiredSkill,
    required String taskDescription,
    required DateTime deadline,
    required double estimatedHours,
    required double hourlyRate,
    required double bonusRate,
    required Map<String, dynamic> materials,
    required bool isRemoteWork,
    required String assignedBy,
  }) async {
    try {
      final assignment = WorkAssignment(
        id: '',
        orderId: orderId,
        employeeId: employeeId,
        requiredSkill: requiredSkill,
        taskDescription: taskDescription,
        assignedAt: DateTime.now(),
        status: WorkStatus.notStarted,
        estimatedHours: estimatedHours,
        actualHours: 0.0,
        hourlyRate: hourlyRate,
        bonusRate: bonusRate,
        updates: [],
        materials: materials,
        isRemoteWork: isRemoteWork,
        assignedBy: assignedBy,
        deadline: deadline,
      );

      final assignmentData = assignment.toJson();
      assignmentData.remove('id');

      await _firebaseService.addDocument('work_assignments', assignmentData);

      // Update employee's in-progress orders count
      final employee = _employees.firstWhere((emp) => emp.id == employeeId);
      await updateEmployee(employeeId, {
        'ordersInProgress': employee.ordersInProgress + 1,
        'lastActive': Timestamp.fromDate(DateTime.now()),
      });

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to assign work: $e';
      notifyListeners();
      return false;
    }
  }

  // Get employee's work assignments
  Future<List<WorkAssignment>> getEmployeeAssignments(String employeeId) async {
    try {
      final querySnapshot = await _firebaseService.getCollection('work_assignments');
      return querySnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data != null && data['employeeId'] == employeeId;
          })
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return WorkAssignment.fromJson(data);
          })
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load assignments: $e';
      notifyListeners();
      return [];
    }
  }

  // Update work assignment status
  Future<bool> updateWorkAssignment({
    required String assignmentId,
    WorkStatus? status,
    double? actualHours,
    String? qualityNotes,
    double? qualityRating,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (status != null) {
        updates['status'] = status.index;
        if (status == WorkStatus.completed) {
          updates['completedAt'] = Timestamp.fromDate(DateTime.now());
        }
      }

      if (actualHours != null) updates['actualHours'] = actualHours;
      if (qualityNotes != null) updates['qualityNotes'] = qualityNotes;
      if (qualityRating != null) updates['qualityRating'] = qualityRating;
      if (photoUrl != null) {
        updates['updates'] = FieldValue.arrayUnion([
          WorkUpdate(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            message: 'Progress photo uploaded',
            status: status ?? WorkStatus.inProgress,
            photoUrl: photoUrl,
            updatedBy: 'employee', // Should be actual user ID
          ).toJson()
        ]);
      }

      await _firebaseService.updateDocument('work_assignments', assignmentId, updates);

      // Update employee's performance metrics if assignment is completed
      if (status == WorkStatus.completed && qualityRating != null) {
        final assignment = await _firebaseService.getDocument('work_assignments', assignmentId);
        if (assignment.exists && assignment.data() != null) {
          final data = assignment.data() as Map<String, dynamic>;
          final employeeId = data['employeeId'] as String;
          final employee = await getEmployeeById(employeeId);
          if (employee != null) {
            final newAverageRating = ((employee.averageRating * employee.totalOrdersCompleted) + qualityRating) /
                                    (employee.totalOrdersCompleted + 1);

            await updateEmployeePerformance(employeeId,
              totalOrdersCompleted: employee.totalOrdersCompleted + 1,
              ordersInProgress: employee.ordersInProgress - 1,
              averageRating: newAverageRating,
              totalEarnings: employee.totalEarnings + (actualHours ?? 0) * employee.baseRatePerHour,
            );
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update assignment: $e';
      notifyListeners();
      return false;
    }
  }

  // Deactivate/reactivate employee
  Future<bool> toggleEmployeeStatus(String employeeId, bool isActive, {String? reason}) async {
    // Check if this is the shop owner account (restrict deactivation)
    Employee? employee;
    try {
      employee = _employees.firstWhere((emp) => emp.id == employeeId);
    } catch (e) {
      employee = null;
    }

    if (employee != null && employee.role == UserRole.shopOwner && !isActive) {
      _errorMessage = 'Cannot deactivate shop owner account. Owner access is restricted for security.';
      notifyListeners();
      return false;
    }

    final updates = <String, dynamic>{
      'isActive': isActive,
    };

    if (!isActive && reason != null) {
      updates['deactivationReason'] = reason;
      updates['deactivatedDate'] = Timestamp.fromDate(DateTime.now());
    } else if (isActive) {
      updates['deactivationReason'] = null;
      updates['deactivatedDate'] = null;
    }

    return await updateEmployee(employeeId, updates);
  }

  // Delete employee (with owner restrictions)
  Future<bool> deleteEmployee(String employeeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if this is the shop owner account (restrict deletion)
      Employee? employee;
      try {
        employee = _employees.firstWhere((emp) => emp.id == employeeId);
      } catch (e) {
        employee = null;
      }

      if (employee != null && employee.role == UserRole.shopOwner) {
        _isLoading = false;
        _errorMessage = 'Cannot delete shop owner account. Owner access is restricted for security.';
        notifyListeners();
        return false;
      }

      await _firebaseService.deleteDocument('employees', employeeId);

      // Also delete related work assignments
      final assignments = await getEmployeeAssignments(employeeId);
      for (var assignment in assignments) {
        await _firebaseService.deleteDocument('work_assignments', assignment.id);
      }

      await loadEmployees();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete employee: $e';
      notifyListeners();
      return false;
    }
  }

  // Get employee performance analytics
  Map<String, dynamic> getEmployeeAnalytics(String employeeId) {
    final employee = _employees.firstWhere((emp) => emp.id == employeeId);

    return {
      'totalOrdersCompleted': employee.totalOrdersCompleted,
      'ordersInProgress': employee.ordersInProgress,
      'averageRating': employee.averageRating,
      'completionRate': employee.completionRate,
      'totalEarnings': employee.totalEarnings,
      'skills': employee.skills.length,
      'experienceYears': employee.experienceYears,
      'isActive': employee.isActive,
      'consecutiveDaysWorked': employee.consecutiveDaysWorked,
    };
  }

  // Get workload balancing suggestions
  List<Map<String, dynamic>> getWorkloadBalancingSuggestions() {
    final suggestions = <Map<String, dynamic>>[];

    // Find overloaded employees (more than 3 assignments)
    final overloaded = _employees.where((emp) => emp.ordersInProgress > 3).toList();
    for (var employee in overloaded) {
      suggestions.add({
        'type': 'overload',
        'employee': employee,
        'message': '${employee.displayName} has ${employee.ordersInProgress} assignments',
        'action': 'Consider redistributing some work'
      });
    }

    // Find underutilized employees (no assignments)
    final underutilized = _employees.where((emp) => emp.ordersInProgress == 0 && emp.isActive).toList();
    for (var employee in underutilized) {
      suggestions.add({
        'type': 'underutilized',
        'employee': employee,
        'message': '${employee.displayName} has no current assignments',
        'action': 'Assign new work based on skills and availability'
      });
    }

    return suggestions;
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedAvailabilityFilter = null;
    _selectedSkillFilter = null;
    _activeStatusFilter = null;
    _filteredEmployees = [];
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method for testing - set employees list directly
  void setTestEmployees(List<Employee> employees) {
    _employees = employees;
    _applyFilters();
    notifyListeners();
  }

  // Convert technical errors to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error.toString().contains('permission-denied')) {
      return 'Access denied. Please check your permissions or contact support.';
    } else if (error.toString().contains('unavailable')) {
      return 'Service temporarily unavailable. Please check your internet connection and try again.';
    } else if (error.toString().contains('not-found')) {
      return 'Database collection not found. The employees collection may not exist yet.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (error.toString().contains('Firebase connection')) {
      return 'Unable to connect to database. Please check your internet connection.';
    } else {
      return 'Failed to load employees. Please try again or contact support if the problem persists.';
    }
  }
}


