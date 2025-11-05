import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

enum EmployeeSkill {
  cutting, // Fabric cutting
  stitching, // Sewing/tailoring
  finishing, // Final touches (buttons, hems, etc.)
  alterations, // Alteration work
  embroidery, // Embroidery work
  qualityCheck, // Quality inspection
  patternMaking // Pattern creation
}

enum EmployeeAvailability {
  fullTime, // 8 hours/day
  partTime, // 4 hours/day
  flexible, // Variable hours
  projectBased, // Per project basis
  remote, // Works from home
  unavailable // Currently not available
}

enum WorkStatus {
  notStarted, // Order assigned but not started
  inProgress, // Currently working on order
  paused, // Work temporarily paused
  completed, // Work finished
  qualityCheck, // Under quality review
  approved, // Quality approved
  rejected // Quality rejected, needs rework
}

class Employee {
  final String id;
  final String userId; // Reference to UserModel
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole?
      role; // ShopOwner for owner, employee for regular staff, null for legacy data

  // Skills and Expertise
  final List<EmployeeSkill> skills;
  final List<String> specializations; // Custom specializations
  final int experienceYears; // Years of experience
  final List<String> certifications; // Any relevant certifications

  // Availability & Work Preferences
  final EmployeeAvailability availability;
  final List<String> preferredWorkDays; // Days available for work
  final TimeOfDay? preferredStartTime;
  final TimeOfDay? preferredEndTime;
  final bool canWorkRemotely;
  final String? location; // Work location if applicable

  // Performance Metrics
  final int totalOrdersCompleted;
  final int ordersInProgress;
  final double averageRating; // Based on quality ratings
  final double completionRate; // Orders completed on time
  final List<String> strengths; // Performance strengths
  final List<String> areasForImprovement;

  // Salary & Compensation
  final double baseRatePerHour; // Base hourly rate
  final double performanceBonusRate; // Additional bonus rate
  final String paymentTerms; // Weekly, bi-weekly, monthly
  final double totalEarnings; // Total earnings to date

  // Work History
  final List<WorkAssignment> recentAssignments;
  final DateTime? lastActive;
  final int consecutiveDaysWorked;

  // Administrative
  final bool isActive; // Employee is currently active
  final DateTime joinedDate;
  final DateTime? deactivatedDate;
  final String? deactivationReason;
  final Map<String, dynamic> additionalInfo;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.role,
    required this.skills,
    required this.specializations,
    required this.experienceYears,
    required this.certifications,
    required this.availability,
    required this.preferredWorkDays,
    this.preferredStartTime,
    this.preferredEndTime,
    required this.canWorkRemotely,
    this.location,
    required this.totalOrdersCompleted,
    required this.ordersInProgress,
    required this.averageRating,
    required this.completionRate,
    required this.strengths,
    required this.areasForImprovement,
    required this.baseRatePerHour,
    required this.performanceBonusRate,
    required this.paymentTerms,
    required this.totalEarnings,
    required this.recentAssignments,
    this.lastActive,
    required this.consecutiveDaysWorked,
    required this.isActive,
    required this.joinedDate,
    this.deactivatedDate,
    this.deactivationReason,
    required this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      role: json['role'] != null &&
              json['role'] is int &&
              json['role'] >= 0 &&
              json['role'] < UserRole.values.length
          ? UserRole.values[json['role']]
          : null,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((skill) => EmployeeSkill.values[skill])
              .toList() ??
          [],
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((spec) => spec.toString())
              .toList() ??
          [],
      experienceYears: json['experienceYears'] ?? 0,
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((cert) => cert.toString())
              .toList() ??
          [],
      availability: EmployeeAvailability.values[json['availability'] ?? 0],
      preferredWorkDays: (json['preferredWorkDays'] as List<dynamic>?)
              ?.map((day) => day.toString())
              .toList() ??
          [],
      preferredStartTime: json['preferredStartTime'] != null
          ? TimeOfDay.fromJson(json['preferredStartTime'])
          : null,
      preferredEndTime: json['preferredEndTime'] != null
          ? TimeOfDay.fromJson(json['preferredEndTime'])
          : null,
      canWorkRemotely: json['canWorkRemotely'] ?? false,
      location: json['location'],
      totalOrdersCompleted: json['totalOrdersCompleted'] ?? 0,
      ordersInProgress: json['ordersInProgress'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((strength) => strength.toString())
              .toList() ??
          [],
      areasForImprovement: (json['areasForImprovement'] as List<dynamic>?)
              ?.map((area) => area.toString())
              .toList() ??
          [],
      baseRatePerHour: (json['baseRatePerHour'] ?? 0.0).toDouble(),
      performanceBonusRate: (json['performanceBonusRate'] ?? 0.0).toDouble(),
      paymentTerms: json['paymentTerms'] ?? 'Monthly',
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
      recentAssignments: (json['recentAssignments'] as List<dynamic>?)
              ?.map((assignment) => WorkAssignment.fromJson(assignment))
              .toList() ??
          [],
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] as Timestamp).toDate()
          : null,
      consecutiveDaysWorked: json['consecutiveDaysWorked'] ?? 0,
      isActive: json['isActive'] ?? true,
      joinedDate: (json['joinedDate'] as Timestamp).toDate(),
      deactivatedDate: json['deactivatedDate'] != null
          ? (json['deactivatedDate'] as Timestamp).toDate()
          : null,
      deactivationReason: json['deactivationReason'],
      additionalInfo: json['additionalInfo'] ?? {},
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role?.index,
      'skills': skills.map((skill) => skill.index).toList(),
      'specializations': specializations,
      'experienceYears': experienceYears,
      'certifications': certifications,
      'availability': availability.index,
      'preferredWorkDays': preferredWorkDays,
      'preferredStartTime': preferredStartTime?.toJson(),
      'preferredEndTime': preferredEndTime?.toJson(),
      'canWorkRemotely': canWorkRemotely,
      'location': location,
      'totalOrdersCompleted': totalOrdersCompleted,
      'ordersInProgress': ordersInProgress,
      'averageRating': averageRating,
      'completionRate': completionRate,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'baseRatePerHour': baseRatePerHour,
      'performanceBonusRate': performanceBonusRate,
      'paymentTerms': paymentTerms,
      'totalEarnings': totalEarnings,
      'recentAssignments':
          recentAssignments.map((assignment) => assignment.toJson()).toList(),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'consecutiveDaysWorked': consecutiveDaysWorked,
      'isActive': isActive,
      'joinedDate': Timestamp.fromDate(joinedDate),
      'deactivatedDate':
          deactivatedDate != null ? Timestamp.fromDate(deactivatedDate!) : null,
      'deactivationReason': deactivationReason,
      'additionalInfo': additionalInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper methods
  bool hasSkill(EmployeeSkill skill) => skills.contains(skill);

  bool isAvailableOnDay(String day) => preferredWorkDays.contains(day);

  double getHourlyRateWithBonus() => baseRatePerHour + performanceBonusRate;

  bool get isCurrentlyAvailable {
    if (!isActive) return false;
    // Add logic to check current availability based on work hours
    return true;
  }

  Employee copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    UserRole? role,
    List<EmployeeSkill>? skills,
    List<String>? specializations,
    int? experienceYears,
    List<String>? certifications,
    EmployeeAvailability? availability,
    List<String>? preferredWorkDays,
    TimeOfDay? preferredStartTime,
    TimeOfDay? preferredEndTime,
    bool? canWorkRemotely,
    String? location,
    int? totalOrdersCompleted,
    int? ordersInProgress,
    double? averageRating,
    double? completionRate,
    List<String>? strengths,
    List<String>? areasForImprovement,
    double? baseRatePerHour,
    double? performanceBonusRate,
    String? paymentTerms,
    double? totalEarnings,
    List<WorkAssignment>? recentAssignments,
    DateTime? lastActive,
    int? consecutiveDaysWorked,
    bool? isActive,
    DateTime? joinedDate,
    DateTime? deactivatedDate,
    String? deactivationReason,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      specializations: specializations ?? this.specializations,
      experienceYears: experienceYears ?? this.experienceYears,
      certifications: certifications ?? this.certifications,
      availability: availability ?? this.availability,
      preferredWorkDays: preferredWorkDays ?? this.preferredWorkDays,
      preferredStartTime: preferredStartTime ?? this.preferredStartTime,
      preferredEndTime: preferredEndTime ?? this.preferredEndTime,
      canWorkRemotely: canWorkRemotely ?? this.canWorkRemotely,
      location: location ?? this.location,
      totalOrdersCompleted: totalOrdersCompleted ?? this.totalOrdersCompleted,
      ordersInProgress: ordersInProgress ?? this.ordersInProgress,
      averageRating: averageRating ?? this.averageRating,
      completionRate: completionRate ?? this.completionRate,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      baseRatePerHour: baseRatePerHour ?? this.baseRatePerHour,
      performanceBonusRate: performanceBonusRate ?? this.performanceBonusRate,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      recentAssignments: recentAssignments ?? this.recentAssignments,
      lastActive: lastActive ?? this.lastActive,
      consecutiveDaysWorked:
          consecutiveDaysWorked ?? this.consecutiveDaysWorked,
      isActive: isActive ?? this.isActive,
      joinedDate: joinedDate ?? this.joinedDate,
      deactivatedDate: deactivatedDate ?? this.deactivatedDate,
      deactivationReason: deactivationReason ?? this.deactivationReason,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkAssignment {
  final String id;
  final String orderId;
  final String employeeId;
  final EmployeeSkill requiredSkill;
  final String taskDescription;
  final DateTime assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? deadline;
  final WorkStatus status;
  final double estimatedHours;
  final double actualHours;
  final double hourlyRate;
  final double bonusRate;
  final String? qualityNotes;
  final double? qualityRating;
  final List<WorkUpdate> updates;
  final Map<String, dynamic> materials; // Materials provided
  final bool isRemoteWork;
  final String? location;
  final String assignedBy; // Shop owner who assigned

  const WorkAssignment({
    required this.id,
    required this.orderId,
    required this.employeeId,
    required this.requiredSkill,
    required this.taskDescription,
    required this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.deadline,
    required this.status,
    required this.estimatedHours,
    required this.actualHours,
    required this.hourlyRate,
    required this.bonusRate,
    this.qualityNotes,
    this.qualityRating,
    required this.updates,
    required this.materials,
    required this.isRemoteWork,
    this.location,
    required this.assignedBy,
  });

  factory WorkAssignment.fromJson(Map<String, dynamic> json) {
    return WorkAssignment(
      id: json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      requiredSkill: EmployeeSkill.values[json['requiredSkill'] ?? 0],
      taskDescription: json['taskDescription'] ?? '',
      assignedAt: (json['assignedAt'] as Timestamp).toDate(),
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
      deadline: json['deadline'] != null
          ? (json['deadline'] as Timestamp).toDate()
          : null,
      status: WorkStatus.values[json['status'] ?? 0],
      estimatedHours: (json['estimatedHours'] ?? 0.0).toDouble(),
      actualHours: (json['actualHours'] ?? 0.0).toDouble(),
      hourlyRate: (json['hourlyRate'] ?? 0.0).toDouble(),
      bonusRate: (json['bonusRate'] ?? 0.0).toDouble(),
      qualityNotes: json['qualityNotes'],
      qualityRating: json['qualityRating']?.toDouble(),
      updates: (json['updates'] as List<dynamic>?)
              ?.map((update) => WorkUpdate.fromJson(update))
              .toList() ??
          [],
      materials: json['materials'] ?? {},
      isRemoteWork: json['isRemoteWork'] ?? false,
      location: json['location'],
      assignedBy: json['assignedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'employeeId': employeeId,
      'requiredSkill': requiredSkill.index,
      'taskDescription': taskDescription,
      'assignedAt': Timestamp.fromDate(assignedAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'status': status.index,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'hourlyRate': hourlyRate,
      'bonusRate': bonusRate,
      'qualityNotes': qualityNotes,
      'qualityRating': qualityRating,
      'updates': updates.map((update) => update.toJson()).toList(),
      'materials': materials,
      'isRemoteWork': isRemoteWork,
      'location': location,
      'assignedBy': assignedBy,
    };
  }

  double get totalEarnings =>
      (actualHours * hourlyRate) + (actualHours * bonusRate);

  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && status != WorkStatus.completed;
  }

  bool get isOnTime {
    if (deadline == null) return true;
    return completedAt?.isBefore(deadline!) ?? false;
  }
}

class WorkUpdate {
  final String id;
  final DateTime timestamp;
  final String message;
  final WorkStatus status;
  final String? photoUrl; // Progress photo
  final double? hoursWorked;
  final String updatedBy;

  const WorkUpdate({
    required this.id,
    required this.timestamp,
    required this.message,
    required this.status,
    this.photoUrl,
    this.hoursWorked,
    required this.updatedBy,
  });

  factory WorkUpdate.fromJson(Map<String, dynamic> json) {
    return WorkUpdate(
      id: json['id'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      message: json['message'] ?? '',
      status: WorkStatus.values[json['status'] ?? 0],
      photoUrl: json['photoUrl'],
      hoursWorked: json['hoursWorked']?.toDouble(),
      updatedBy: json['updatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'message': message,
      'status': status.index,
      'photoUrl': photoUrl,
      'hoursWorked': hoursWorked,
      'updatedBy': updatedBy,
    };
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({
    required this.hour,
    required this.minute,
  });

  factory TimeOfDay.fromJson(Map<String, dynamic> json) {
    return TimeOfDay(
      hour: json['hour'] ?? 9,
      minute: json['minute'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  String formatTime() {
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  bool isBefore(TimeOfDay other) {
    if (hour < other.hour) return true;
    if (hour > other.hour) return false;
    return minute < other.minute;
  }

  bool isAfter(TimeOfDay other) {
    if (hour > other.hour) return true;
    if (hour < other.hour) return false;
    return minute > other.minute;
  }
}
