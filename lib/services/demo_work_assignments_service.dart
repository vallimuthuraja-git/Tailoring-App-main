import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart' as emp;

class DemoWorkAssignmentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDemoWorkAssignments() async {
    debugPrint('ðŸš€ Creating demo work assignments...');

    // Get all demo employees
    final demoEmployees = await _getDemoEmployees();

    for (final employee in demoEmployees) {
      await _createWorkAssignmentsForEmployee(employee);
    }

    debugPrint('âœ… Demo work assignments created successfully!');
  }

  Future<List<emp.Employee>> _getDemoEmployees() async {
    final employees = <emp.Employee>[];

    final employeeEmails = [
      'employee@demo.com',
      'tailor@demo.com',
      'cutter@demo.com',
      'finisher@demo.com'
    ];

    for (final email in employeeEmails) {
      final employeeDoc = await _firestore
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();

      if (employeeDoc.docs.isNotEmpty) {
        final employee = emp.Employee.fromJson({
          ...employeeDoc.docs.first.data(),
          'id': employeeDoc.docs.first.id,
        });
        employees.add(employee);
      }
    }

    return employees;
  }

  Future<void> _createWorkAssignmentsForEmployee(emp.Employee employee) async {
    final assignments = _generateWorkAssignmentsForEmployee(employee);

    for (final assignment in assignments) {
      final assignmentData = assignment.toJson();
      assignmentData.remove('id'); // Let Firestore generate the ID

      await _firestore.collection('work_assignments').add(assignmentData);
    }

    debugPrint('âœ… Created ${assignments.length} assignments for ${employee.displayName}');
  }

  List<emp.WorkAssignment> _generateWorkAssignmentsForEmployee(emp.Employee employee) {
    final now = DateTime.now();
    final assignments = <emp.WorkAssignment>[];

    // Generate assignments based on employee type and skills
    if (employee.email.contains('employee')) {
      // General Employee - Mixed assignments
      assignments.addAll(_createGeneralEmployeeAssignments(employee, now));
    } else if (employee.email.contains('tailor')) {
      // Master Tailor - Stitching and alterations
      assignments.addAll(_createTailorAssignments(employee, now));
    } else if (employee.email.contains('cutter')) {
      // Cutter - Cutting and pattern making
      assignments.addAll(_createCutterAssignments(employee, now));
    } else if (employee.email.contains('finisher')) {
      // Finisher - Finishing and quality check
      assignments.addAll(_createFinisherAssignments(employee, now));
    }

    return assignments;
  }

  List<emp.WorkAssignment> _createGeneralEmployeeAssignments(emp.Employee employee, DateTime now) {
    return [
      // Not Started - New assignment
      emp.WorkAssignment(
        id: 'general_1_${employee.id}',
        orderId: 'order_001',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.stitching,
        taskDescription: 'Stitch collar and cuffs for business shirt',
        assignedAt: now.subtract(const Duration(hours: 2)),
        deadline: now.add(const Duration(days: 2)),
        status: emp.WorkStatus.notStarted,
        estimatedHours: 3.0,
        actualHours: 0.0,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [],
        materials: {'fabric': 'Cotton blend', 'thread': 'Matching color'},
        isRemoteWork: false,
        location: 'Main Workshop',
        assignedBy: 'Shop Owner',
      ),

      // In Progress - Currently working
      emp.WorkAssignment(
        id: 'general_2_${employee.id}',
        orderId: 'order_002',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.finishing,
        taskDescription: 'Attach buttons and finish hems on dress shirt',
        assignedAt: now.subtract(const Duration(hours: 4)),
        startedAt: now.subtract(const Duration(hours: 3)),
        deadline: now.add(const Duration(days: 1)),
        status: emp.WorkStatus.inProgress,
        estimatedHours: 2.5,
        actualHours: 1.5,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 2)),
            message: 'Started button attachment',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'buttons': 'Pearl white', 'thread': 'White'},
        isRemoteWork: false,
        location: 'Main Workshop',
        assignedBy: 'Shop Owner',
      ),

      // Completed - Finished work
      emp.WorkAssignment(
        id: 'general_3_${employee.id}',
        orderId: 'order_003',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.alterations,
        taskDescription: 'Shorten sleeves on suit jacket',
        assignedAt: now.subtract(const Duration(days: 3)),
        startedAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 1)),
        deadline: now.subtract(const Duration(days: 2)),
        status: emp.WorkStatus.completed,
        estimatedHours: 1.5,
        actualHours: 1.2,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        qualityNotes: 'Excellent work, sleeves perfectly aligned',
        qualityRating: 4.8,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(days: 3)),
            message: 'Started sleeve alteration',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(days: 1)),
            message: 'Completed alteration, quality check passed',
            status: emp.WorkStatus.completed,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'suit_jacket': 'Wool blend'},
        isRemoteWork: false,
        location: 'Main Workshop',
        assignedBy: 'Shop Owner',
      ),

      // Quality Check - Under review
      emp.WorkAssignment(
        id: 'general_4_${employee.id}',
        orderId: 'order_004',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.stitching,
        taskDescription: 'Stitch pocket on blazer',
        assignedAt: now.subtract(const Duration(days: 2)),
        startedAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(hours: 6)),
        deadline: now.add(const Duration(hours: 12)),
        status: emp.WorkStatus.qualityCheck,
        estimatedHours: 1.0,
        actualHours: 0.8,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(days: 2)),
            message: 'Started pocket stitching',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(hours: 6)),
            message: 'Completed stitching, submitted for quality check',
            status: emp.WorkStatus.qualityCheck,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'blazer': 'Navy wool', 'thread': 'Navy'},
        isRemoteWork: false,
        location: 'Main Workshop',
        assignedBy: 'Shop Owner',
      ),
    ];
  }

  List<emp.WorkAssignment> _createTailorAssignments(emp.Employee employee, DateTime now) {
    return [
      // Complex stitching work
      emp.WorkAssignment(
        id: 'tailor_1_${employee.id}',
        orderId: 'order_005',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.stitching,
        taskDescription: 'Hand-stitch lapel and collar on premium suit',
        assignedAt: now.subtract(const Duration(hours: 6)),
        startedAt: now.subtract(const Duration(hours: 5)),
        deadline: now.add(const Duration(days: 3)),
        status: emp.WorkStatus.inProgress,
        estimatedHours: 8.0,
        actualHours: 3.5,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 5)),
            message: 'Started lapel stitching with premium techniques',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'suit': 'Premium wool', 'thread': 'Silk blend'},
        isRemoteWork: false,
        location: 'Premium Workshop',
        assignedBy: 'Shop Owner',
      ),

      // Alterations work
      emp.WorkAssignment(
        id: 'tailor_2_${employee.id}',
        orderId: 'order_006',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.alterations,
        taskDescription: 'Take in wedding gown for perfect fit',
        assignedAt: now.subtract(const Duration(days: 1)),
        startedAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 12)),
        deadline: now.add(const Duration(hours: 12)),
        status: emp.WorkStatus.completed,
        estimatedHours: 4.0,
        actualHours: 3.8,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        qualityNotes: 'Beautiful work on delicate fabric',
        qualityRating: 5.0,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(days: 1)),
            message: 'Started gown alteration with careful measurements',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(hours: 12)),
            message: 'Completed alteration, gown fits perfectly',
            status: emp.WorkStatus.completed,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'wedding_gown': 'Satin with lace', 'pins': 'Fine steel'},
        isRemoteWork: false,
        location: 'Premium Workshop',
        assignedBy: 'Shop Owner',
      ),

      // Embroidery work
      emp.WorkAssignment(
        id: 'tailor_3_${employee.id}',
        orderId: 'order_007',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.embroidery,
        taskDescription: 'Add monogram to suit pocket',
        assignedAt: now.subtract(const Duration(hours: 8)),
        startedAt: now.subtract(const Duration(hours: 7)),
        deadline: now.add(const Duration(days: 1)),
        status: emp.WorkStatus.inProgress,
        estimatedHours: 2.0,
        actualHours: 1.2,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 7)),
            message: 'Started monogram embroidery with gold thread',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'suit': 'Charcoal wool', 'thread': 'Gold metallic'},
        isRemoteWork: false,
        location: 'Premium Workshop',
        assignedBy: 'Shop Owner',
      ),

      // Paused work
      emp.WorkAssignment(
        id: 'tailor_4_${employee.id}',
        orderId: 'order_008',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.stitching,
        taskDescription: 'Repair vintage suit with period-accurate techniques',
        assignedAt: now.subtract(const Duration(days: 4)),
        startedAt: now.subtract(const Duration(days: 4)),
        deadline: now.add(const Duration(days: 2)),
        status: emp.WorkStatus.paused,
        estimatedHours: 12.0,
        actualHours: 6.0,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(days: 4)),
            message: 'Started repair work on vintage suit',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(hours: 18)),
            message: 'Paused work - waiting for special fabric',
            status: emp.WorkStatus.paused,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'vintage_suit': '1950s wool', 'special_thread': 'Period authentic'},
        isRemoteWork: false,
        location: 'Premium Workshop',
        assignedBy: 'Shop Owner',
      ),
    ];
  }

  List<emp.WorkAssignment> _createCutterAssignments(emp.Employee employee, DateTime now) {
    return [
      // Pattern making
      emp.WorkAssignment(
        id: 'cutter_1_${employee.id}',
        orderId: 'order_009',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.patternMaking,
        taskDescription: 'Create pattern for custom dress design',
        assignedAt: now.subtract(const Duration(hours: 12)),
        startedAt: now.subtract(const Duration(hours: 10)),
        deadline: now.add(const Duration(days: 4)),
        status: emp.WorkStatus.inProgress,
        estimatedHours: 6.0,
        actualHours: 4.0,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 10)),
            message: 'Started pattern creation for unique dress design',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'paper': 'Pattern paper', 'measurements': 'Client measurements'},
        isRemoteWork: false,
        location: 'Cutting Room',
        assignedBy: 'Shop Owner',
      ),

      // Fabric cutting
      emp.WorkAssignment(
        id: 'cutter_2_${employee.id}',
        orderId: 'order_010',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.cutting,
        taskDescription: 'Cut fabric for 3-piece suit',
        assignedAt: now.subtract(const Duration(days: 2)),
        startedAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(days: 1)),
        deadline: now.subtract(const Duration(days: 1)),
        status: emp.WorkStatus.completed,
        estimatedHours: 4.0,
        actualHours: 3.5,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        qualityNotes: 'Excellent precision cutting, minimal waste',
        qualityRating: 4.9,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(days: 2)),
            message: 'Started cutting suit pieces with precision',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(days: 1)),
            message: 'Completed all cutting, pieces ready for sewing',
            status: emp.WorkStatus.completed,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'suit_fabric': 'Italian wool', 'lining': 'Silk blend'},
        isRemoteWork: false,
        location: 'Cutting Room',
        assignedBy: 'Shop Owner',
      ),

      // Complex cutting work
      emp.WorkAssignment(
        id: 'cutter_3_${employee.id}',
        orderId: 'order_011',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.cutting,
        taskDescription: 'Cut delicate silk fabric for evening gown',
        assignedAt: now.subtract(const Duration(hours: 16)),
        startedAt: now.subtract(const Duration(hours: 14)),
        deadline: now.add(const Duration(hours: 8)),
        status: emp.WorkStatus.inProgress,
        estimatedHours: 3.0,
        actualHours: 2.2,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 14)),
            message: 'Started cutting delicate silk with special techniques',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'silk_fabric': 'Premium silk', 'special_tools': 'Sharp scissors'},
        isRemoteWork: false,
        location: 'Cutting Room',
        assignedBy: 'Shop Owner',
      ),

      // Quality check after cutting
      emp.WorkAssignment(
        id: 'cutter_4_${employee.id}',
        orderId: 'order_012',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.cutting,
        taskDescription: 'Cut leather pieces for jacket',
        assignedAt: now.subtract(const Duration(hours: 20)),
        startedAt: now.subtract(const Duration(hours: 18)),
        completedAt: now.subtract(const Duration(hours: 16)),
        deadline: now.add(const Duration(hours: 4)),
        status: emp.WorkStatus.qualityCheck,
        estimatedHours: 2.5,
        actualHours: 2.0,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 18)),
            message: 'Started cutting leather with specialized tools',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(hours: 16)),
            message: 'Completed leather cutting, submitted for quality check',
            status: emp.WorkStatus.qualityCheck,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'leather': 'Genuine leather', 'special_tools': 'Leather cutting tools'},
        isRemoteWork: false,
        location: 'Cutting Room',
        assignedBy: 'Shop Owner',
      ),
    ];
  }

  List<emp.WorkAssignment> _createFinisherAssignments(emp.Employee employee, DateTime now) {
    return [
      // Button attachment
      emp.WorkAssignment(
        id: 'finisher_1_${employee.id}',
        orderId: 'order_013',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.finishing,
        taskDescription: 'Attach premium buttons to suit jacket',
        assignedAt: now.subtract(const Duration(hours: 3)),
        startedAt: now.subtract(const Duration(hours: 2)),
        deadline: now.add(const Duration(hours: 12)),
        status: emp.WorkStatus.inProgress,
        estimatedHours: 1.5,
        actualHours: 0.8,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 2)),
            message: 'Started attaching premium horn buttons',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'buttons': 'Horn buttons', 'thread': 'Matching'},
        isRemoteWork: false,
        location: 'Finishing Station',
        assignedBy: 'Shop Owner',
      ),

      // Hemming work
      emp.WorkAssignment(
        id: 'finisher_2_${employee.id}',
        orderId: 'order_014',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.finishing,
        taskDescription: 'Hem trousers with invisible stitches',
        assignedAt: now.subtract(const Duration(days: 1)),
        startedAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(hours: 18)),
        deadline: now.subtract(const Duration(hours: 12)),
        status: emp.WorkStatus.completed,
        estimatedHours: 2.0,
        actualHours: 1.8,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        qualityNotes: 'Perfect invisible hemming, excellent finish',
        qualityRating: 4.7,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(days: 1)),
            message: 'Started invisible hemming on wool trousers',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(hours: 18)),
            message: 'Completed hemming, ready for final inspection',
            status: emp.WorkStatus.completed,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'trousers': 'Wool blend', 'thread': 'Invisible hem thread'},
        isRemoteWork: false,
        location: 'Finishing Station',
        assignedBy: 'Shop Owner',
      ),

      // Quality inspection
      emp.WorkAssignment(
        id: 'finisher_3_${employee.id}',
        orderId: 'order_015',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.qualityCheck,
        taskDescription: 'Quality inspection of completed suit',
        assignedAt: now.subtract(const Duration(hours: 8)),
        startedAt: now.subtract(const Duration(hours: 7)),
        deadline: now.add(const Duration(hours: 16)),
        status: emp.WorkStatus.inProgress,
        estimatedHours: 1.0,
        actualHours: 0.5,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 7)),
            message: 'Started detailed quality inspection of suit',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'suit': 'Complete suit', 'inspection_tools': 'Magnifying glass'},
        isRemoteWork: false,
        location: 'Quality Station',
        assignedBy: 'Shop Owner',
      ),

      // Final touches
      emp.WorkAssignment(
        id: 'finisher_4_${employee.id}',
        orderId: 'order_016',
        employeeId: employee.id,
        requiredSkill: emp.EmployeeSkill.finishing,
        taskDescription: 'Add final touches and packaging',
        assignedAt: now.subtract(const Duration(hours: 24)),
        startedAt: now.subtract(const Duration(hours: 20)),
        completedAt: now.subtract(const Duration(hours: 18)),
        deadline: now.subtract(const Duration(hours: 16)),
        status: emp.WorkStatus.completed,
        estimatedHours: 1.0,
        actualHours: 0.8,
        hourlyRate: employee.baseRatePerHour,
        bonusRate: employee.performanceBonusRate,
        qualityNotes: 'Perfect finishing, excellent presentation',
        qualityRating: 4.8,
        updates: [
          emp.WorkUpdate(
            id: 'update_1',
            timestamp: now.subtract(const Duration(hours: 20)),
            message: 'Started final touches and quality check',
            status: emp.WorkStatus.inProgress,
            updatedBy: employee.displayName,
          ),
          emp.WorkUpdate(
            id: 'update_2',
            timestamp: now.subtract(const Duration(hours: 18)),
            message: 'Completed all finishing work, ready for delivery',
            status: emp.WorkStatus.completed,
            updatedBy: employee.displayName,
          ),
        ],
        materials: {'packaging': 'Premium box', 'tags': 'Branded tags'},
        isRemoteWork: false,
        location: 'Finishing Station',
        assignedBy: 'Shop Owner',
      ),
    ];
  }

  // Get work assignments for a specific employee
  Future<List<emp.WorkAssignment>> getEmployeeWorkAssignments(String employeeId) async {
    final assignmentsQuery = await _firestore
        .collection('work_assignments')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('assignedAt', descending: true)
        .get();

    return assignmentsQuery.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return emp.WorkAssignment.fromJson(data);
    }).toList();
  }

  // Get work assignments by status
  Future<List<emp.WorkAssignment>> getWorkAssignmentsByStatus(emp.WorkStatus status) async {
    final assignmentsQuery = await _firestore
        .collection('work_assignments')
        .where('status', isEqualTo: status.index)
        .orderBy('assignedAt', descending: true)
        .get();

    return assignmentsQuery.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return emp.WorkAssignment.fromJson(data);
    }).toList();
  }

  // Get overdue assignments
  Future<List<emp.WorkAssignment>> getOverdueAssignments() async {
    final assignmentsQuery = await _firestore
        .collection('work_assignments')
        .where('status', isNotEqualTo: emp.WorkStatus.completed.index)
        .get();

    final assignments = assignmentsQuery.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return emp.WorkAssignment.fromJson(data);
    }).toList();

    return assignments.where((assignment) => assignment.isOverdue).toList();
  }

  // Clean up demo assignments
  Future<void> cleanupDemoAssignments() async {
    debugPrint('ðŸ§¹ Cleaning up demo work assignments...');

    final demoOrderIds = [
      'order_001', 'order_002', 'order_003', 'order_004', 'order_005',
      'order_006', 'order_007', 'order_008', 'order_009', 'order_010',
      'order_011', 'order_012', 'order_013', 'order_014', 'order_015', 'order_016'
    ];

    for (final orderId in demoOrderIds) {
      final assignmentsQuery = await _firestore
          .collection('work_assignments')
          .where('orderId', isEqualTo: orderId)
          .get();

      for (final doc in assignmentsQuery.docs) {
        await doc.reference.delete();
      }
    }

    debugPrint('âœ… Demo work assignments cleanup complete!');
  }
}


