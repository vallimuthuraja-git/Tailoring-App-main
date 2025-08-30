import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart' as emp;

enum QualityCheckpointType {
  fabricInspection,    // Initial fabric quality check
  cuttingPrecision,    // Cutting accuracy verification
  stitchingQuality,    // Stitching quality assessment
  fittingCheck,        // Initial fitting verification
  finishingTouches,    // Final quality inspection
  finalApproval        // Final approval before delivery
}

enum QualityStatus {
  pending,      // Awaiting inspection
  passed,       // Passed quality check
  failed,       // Failed quality check
  reworkRequired, // Needs rework
  reworkCompleted, // Rework done, needs recheck
  approved       // Final approval given
}

class QualityIssue {
  final String id;
  final String description;
  final QualityIssueSeverity severity;
  final String? photoUrl;
  final DateTime reportedAt;
  final String reportedBy;
  final String? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNotes;

  const QualityIssue({
    required this.id,
    required this.description,
    required this.severity,
    this.photoUrl,
    required this.reportedAt,
    required this.reportedBy,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNotes,
  });

  factory QualityIssue.fromJson(Map<String, dynamic> json) {
    return QualityIssue(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      severity: QualityIssueSeverity.values[json['severity'] ?? 0],
      photoUrl: json['photoUrl'],
      reportedAt: (json['reportedAt'] as Timestamp).toDate(),
      reportedBy: json['reportedBy'] ?? '',
      resolvedAt: json['resolvedAt'] != null ? (json['resolvedAt'] as Timestamp).toDate().toIso8601String() : null,
      resolvedBy: json['resolvedBy'],
      resolutionNotes: json['resolutionNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'severity': severity.index,
      'photoUrl': photoUrl,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'reportedBy': reportedBy,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(DateTime.parse(resolvedAt!)) : null,
      'resolvedBy': resolvedBy,
      'resolutionNotes': resolutionNotes,
    };
  }
}

enum QualityIssueSeverity {
  minor,     // Cosmetic issue, doesn't affect functionality
  moderate,  // Affects appearance but fixable
  major,     // Significant issue requiring rework
  critical   // Cannot be delivered, needs complete redo
}

class QualityCheckpoint {
  final String id;
  final String orderId;
  final String workAssignmentId;
  final QualityCheckpointType checkpointType;
  final String checkpointName;
  final String description;
  final QualityStatus status;
  final double? score; // 0-10 rating
  final String? inspectorId;
  final String? inspectorName;
  final DateTime? inspectedAt;
  final String? feedback;
  final List<QualityIssue> issues;
  final String? photoUrl; // Checkpoint photo
  final Map<String, dynamic> measurements; // Quality measurements
  final DateTime createdAt;
  final DateTime updatedAt;

  const QualityCheckpoint({
    required this.id,
    required this.orderId,
    required this.workAssignmentId,
    required this.checkpointType,
    required this.checkpointName,
    required this.description,
    required this.status,
    this.score,
    this.inspectorId,
    this.inspectorName,
    this.inspectedAt,
    this.feedback,
    required this.issues,
    this.photoUrl,
    required this.measurements,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QualityCheckpoint.fromJson(Map<String, dynamic> json) {
    return QualityCheckpoint(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      workAssignmentId: json['workAssignmentId'] ?? '',
      checkpointType: QualityCheckpointType.values[json['checkpointType'] ?? 0],
      checkpointName: json['checkpointName'] ?? '',
      description: json['description'] ?? '',
      status: QualityStatus.values[json['status'] ?? 0],
      score: json['score']?.toDouble(),
      inspectorId: json['inspectorId'],
      inspectorName: json['inspectorName'],
      inspectedAt: json['inspectedAt'] != null ? (json['inspectedAt'] as Timestamp).toDate() : null,
      feedback: json['feedback'],
      issues: (json['issues'] as List<dynamic>?)
          ?.map((issue) => QualityIssue.fromJson(issue))
          .toList() ?? [],
      photoUrl: json['photoUrl'],
      measurements: json['measurements'] ?? {},
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'workAssignmentId': workAssignmentId,
      'checkpointType': checkpointType.index,
      'checkpointName': checkpointName,
      'description': description,
      'status': status.index,
      'score': score,
      'inspectorId': inspectorId,
      'inspectorName': inspectorName,
      'inspectedAt': inspectedAt != null ? Timestamp.fromDate(inspectedAt!) : null,
      'feedback': feedback,
      'issues': issues.map((issue) => issue.toJson()).toList(),
      'photoUrl': photoUrl,
      'measurements': measurements,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get hasIssues => issues.isNotEmpty;
  bool get needsRework => status == QualityStatus.reworkRequired;
  bool get isApproved => status == QualityStatus.approved;
  bool get isFailed => status == QualityStatus.failed;

  String get statusText {
    switch (status) {
      case QualityStatus.pending:
        return 'Pending Review';
      case QualityStatus.passed:
        return 'Passed';
      case QualityStatus.failed:
        return 'Failed';
      case QualityStatus.reworkRequired:
        return 'Rework Required';
      case QualityStatus.reworkCompleted:
        return 'Rework Completed';
      case QualityStatus.approved:
        return 'Approved';
    }
  }
}

class QualityControlService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined quality checkpoints for different work types
  final Map<emp.EmployeeSkill, List<QualityCheckpointTemplate>> _checkpointTemplates = {
    emp.EmployeeSkill.cutting: [
      const QualityCheckpointTemplate(
        type: QualityCheckpointType.fabricInspection,
        name: 'Fabric Inspection',
        description: 'Check fabric quality, pattern alignment, and measurements',
        requiredMeasurements: ['length', 'width', 'thickness', 'pattern_alignment'],
      ),
      const QualityCheckpointTemplate(
        type: QualityCheckpointType.cuttingPrecision,
        name: 'Cutting Precision',
        description: 'Verify cutting accuracy against pattern specifications',
        requiredMeasurements: ['accuracy', 'edge_straightness', 'corner_precision'],
      ),
    ],
    emp.EmployeeSkill.stitching: [
      const QualityCheckpointTemplate(
        type: QualityCheckpointType.stitchingQuality,
        name: 'Stitching Quality',
        description: 'Inspect stitch tension, seam allowance, and thread quality',
        requiredMeasurements: ['stitch_tension', 'seam_allowance', 'thread_strength'],
      ),
    ],
    emp.EmployeeSkill.finishing: [
      const QualityCheckpointTemplate(
        type: QualityCheckpointType.finishingTouches,
        name: 'Finishing Quality',
        description: 'Check buttons, hems, and final appearance',
        requiredMeasurements: ['button_alignment', 'hem_straightness', 'overall_finish'],
      ),
      const QualityCheckpointTemplate(
        type: QualityCheckpointType.finalApproval,
        name: 'Final Approval',
        description: 'Final quality assessment before delivery',
        requiredMeasurements: ['overall_quality', 'customer_satisfaction'],
      ),
    ],
  };

  // Create quality checkpoints for a work assignment
  Future<List<String>> createCheckpointsForAssignment({
    required String orderId,
    required String workAssignmentId,
    required emp.EmployeeSkill skill,
  }) async {
    final checkpointIds = <String>[];
    final templates = _checkpointTemplates[skill] ?? [];

    for (final template in templates) {
      final checkpoint = QualityCheckpoint(
        id: '',
        orderId: orderId,
        workAssignmentId: workAssignmentId,
        checkpointType: template.type,
        checkpointName: template.name,
        description: template.description,
        status: QualityStatus.pending,
        issues: [],
        measurements: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final checkpointData = checkpoint.toJson();
      checkpointData.remove('id');

      final docRef = await _firestore.collection('quality_checkpoints').add(checkpointData);
      checkpointIds.add(docRef.id);
    }

    return checkpointIds;
  }

  // Get quality checkpoints for an order
  Future<List<QualityCheckpoint>> getCheckpointsForOrder(String orderId) async {
    final querySnapshot = await _firestore
        .collection('quality_checkpoints')
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return QualityCheckpoint.fromJson(data);
    }).toList();
  }

  // Get quality checkpoints for a work assignment
  Future<List<QualityCheckpoint>> getCheckpointsForAssignment(String workAssignmentId) async {
    final querySnapshot = await _firestore
        .collection('quality_checkpoints')
        .where('workAssignmentId', isEqualTo: workAssignmentId)
        .orderBy('createdAt')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return QualityCheckpoint.fromJson(data);
    }).toList();
  }

  // Submit quality inspection
  Future<bool> submitQualityInspection({
    required String checkpointId,
    required String inspectorId,
    required String inspectorName,
    required QualityStatus status,
    required double score,
    required String feedback,
    required Map<String, dynamic> measurements,
    required List<QualityIssue> issues,
    String? photoUrl,
  }) async {
    try {
      final updateData = {
        'status': status.index,
        'score': score,
        'inspectorId': inspectorId,
        'inspectorName': inspectorName,
        'inspectedAt': Timestamp.fromDate(DateTime.now()),
        'feedback': feedback,
        'measurements': measurements,
        'issues': issues.map((issue) => issue.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      await _firestore.collection('quality_checkpoints').doc(checkpointId).update(updateData);
      return true;
    } catch (e) {
      print('Error submitting quality inspection: $e');
      return false;
    }
  }

  // Add quality issue to checkpoint
  Future<bool> addQualityIssue({
    required String checkpointId,
    required String description,
    required QualityIssueSeverity severity,
    required String reportedBy,
    String? photoUrl,
  }) async {
    try {
      final issue = QualityIssue(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: description,
        severity: severity,
        photoUrl: photoUrl,
        reportedAt: DateTime.now(),
        reportedBy: reportedBy,
      );

      await _firestore.collection('quality_checkpoints').doc(checkpointId).update({
        'issues': FieldValue.arrayUnion([issue.toJson()]),
        'status': QualityStatus.failed.index,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error adding quality issue: $e');
      return false;
    }
  }

  // Resolve quality issue
  Future<bool> resolveQualityIssue({
    required String checkpointId,
    required String issueId,
    required String resolvedBy,
    required String resolutionNotes,
  }) async {
    try {
      // Get current checkpoint data
      final checkpointDoc = await _firestore.collection('quality_checkpoints').doc(checkpointId).get();
      if (!checkpointDoc.exists) return false;

      final data = checkpointDoc.data()!;
      final issues = (data['issues'] as List<dynamic>?)
          ?.map((issue) => QualityIssue.fromJson(issue))
          .toList() ?? [];

      // Find and update the issue
      final updatedIssues = issues.map((issue) {
        if (issue.id == issueId) {
          return QualityIssue(
            id: issue.id,
            description: issue.description,
            severity: issue.severity,
            photoUrl: issue.photoUrl,
            reportedAt: issue.reportedAt,
            reportedBy: issue.reportedBy,
            resolvedAt: DateTime.now().toIso8601String(),
            resolvedBy: resolvedBy,
            resolutionNotes: resolutionNotes,
          );
        }
        return issue;
      }).toList();

      // Check if all issues are resolved
      final allResolved = updatedIssues.every((issue) => issue.resolvedAt != null);
      final newStatus = allResolved ? QualityStatus.reworkCompleted.index : QualityStatus.reworkRequired.index;

      await _firestore.collection('quality_checkpoints').doc(checkpointId).update({
        'issues': updatedIssues.map((issue) => issue.toJson()).toList(),
        'status': newStatus,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error resolving quality issue: $e');
      return false;
    }
  }

  // Get quality statistics for employee
  Future<Map<String, dynamic>> getEmployeeQualityStats(String employeeId) async {
    try {
      // Get all work assignments for employee
      final assignmentsQuery = await _firestore
          .collection('work_assignments')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      final assignmentIds = assignmentsQuery.docs.map((doc) => doc.id).toList();

      if (assignmentIds.isEmpty) {
        return {
          'totalInspections': 0,
          'averageScore': 0.0,
          'passRate': 0.0,
          'reworkRate': 0.0,
          'qualityTrend': [],
        };
      }

      // Get quality checkpoints for these assignments
      final checkpointsQuery = await _firestore
          .collection('quality_checkpoints')
          .where('workAssignmentId', whereIn: assignmentIds)
          .get();

      final checkpoints = checkpointsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QualityCheckpoint.fromJson(data);
      }).toList();

      final completedCheckpoints = checkpoints.where((c) => c.inspectedAt != null).toList();

      if (completedCheckpoints.isEmpty) {
        return {
          'totalInspections': 0,
          'averageScore': 0.0,
          'passRate': 0.0,
          'reworkRate': 0.0,
          'qualityTrend': [],
        };
      }

      // Calculate statistics
      final totalInspections = completedCheckpoints.length;
      final averageScore = completedCheckpoints
          .where((c) => c.score != null)
          .map((c) => c.score!)
          .reduce((a, b) => a + b) / completedCheckpoints.where((c) => c.score != null).length;

      final passedInspections = completedCheckpoints.where((c) => c.status == QualityStatus.passed || c.status == QualityStatus.approved).length;
      final passRate = passedInspections / totalInspections;

      final reworkInspections = completedCheckpoints.where((c) => c.status == QualityStatus.reworkRequired).length;
      final reworkRate = reworkInspections / totalInspections;

      // Monthly quality trend (last 6 months)
      final qualityTrend = await _getQualityTrend(assignmentIds);

      return {
        'totalInspections': totalInspections,
        'averageScore': averageScore,
        'passRate': passRate,
        'reworkRate': reworkRate,
        'qualityTrend': qualityTrend,
        'commonIssues': _getCommonIssues(checkpoints),
      };
    } catch (e) {
      print('Error getting employee quality stats: $e');
      return {
        'totalInspections': 0,
        'averageScore': 0.0,
        'passRate': 0.0,
        'reworkRate': 0.0,
        'qualityTrend': [],
        'commonIssues': [],
      };
    }
  }

  // Get quality trend data
  Future<List<Map<String, dynamic>>> _getQualityTrend(List<String> assignmentIds) async {
    final trend = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final checkpointsQuery = await _firestore
          .collection('quality_checkpoints')
          .where('workAssignmentId', whereIn: assignmentIds)
          .where('inspectedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(month))
          .where('inspectedAt', isLessThan: Timestamp.fromDate(nextMonth))
          .get();

      final monthCheckpoints = checkpointsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QualityCheckpoint.fromJson(data);
      }).toList();

      final completedCheckpoints = monthCheckpoints.where((c) => c.inspectedAt != null).toList();

      if (completedCheckpoints.isNotEmpty) {
        final averageScore = completedCheckpoints
            .where((c) => c.score != null)
            .map((c) => c.score!)
            .reduce((a, b) => a + b) / completedCheckpoints.where((c) => c.score != null).length;

        final passRate = completedCheckpoints.where((c) => c.status == QualityStatus.passed || c.status == QualityStatus.approved).length / completedCheckpoints.length;

        trend.add({
          'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
          'averageScore': averageScore,
          'passRate': passRate,
          'inspectionCount': completedCheckpoints.length,
        });
      } else {
        trend.add({
          'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
          'averageScore': 0.0,
          'passRate': 0.0,
          'inspectionCount': 0,
        });
      }
    }

    return trend;
  }

  // Get common quality issues
  List<Map<String, dynamic>> _getCommonIssues(List<QualityCheckpoint> checkpoints) {
    final issueCount = <String, int>{};

    for (final checkpoint in checkpoints) {
      for (final issue in checkpoint.issues) {
        final key = '${issue.severity}_${issue.description}';
        issueCount[key] = (issueCount[key] ?? 0) + 1;
      }
    }

    return issueCount.entries
        .map((entry) => {
          'issue': entry.key.split('_')[1],
          'severity': entry.key.split('_')[0],
          'count': entry.value,
        })
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  // Get pending quality inspections
  Future<List<QualityCheckpoint>> getPendingInspections() async {
    final querySnapshot = await _firestore
        .collection('quality_checkpoints')
        .where('status', isEqualTo: QualityStatus.pending.index)
        .orderBy('createdAt')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return QualityCheckpoint.fromJson(data);
    }).toList();
  }

  // Get quality checkpoints requiring rework
  Future<List<QualityCheckpoint>> getReworkRequired() async {
    final querySnapshot = await _firestore
        .collection('quality_checkpoints')
        .where('status', isEqualTo: QualityStatus.reworkRequired.index)
        .orderBy('updatedAt')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return QualityCheckpoint.fromJson(data);
    }).toList();
  }

  // Stream quality updates for an order
  Stream<List<QualityCheckpoint>> getQualityUpdatesForOrder(String orderId) {
    return _firestore
        .collection('quality_checkpoints')
        .where('orderId', isEqualTo: orderId)
        .orderBy('updatedAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return QualityCheckpoint.fromJson(data);
          }).toList();
        });
  }
}

class QualityCheckpointTemplate {
  final QualityCheckpointType type;
  final String name;
  final String description;
  final List<String> requiredMeasurements;

  const QualityCheckpointTemplate({
    required this.type,
    required this.name,
    required this.description,
    required this.requiredMeasurements,
  });
}