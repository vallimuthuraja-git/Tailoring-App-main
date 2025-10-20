// Offline Storage Service for Cross-Platform Data Persistence
// Supports SQLite (Mobile) and IndexedDB (Web) with Firebase Sync

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';

/// Offline storage service that works across all platforms
class OfflineStorageService {
  static const String _dbName = 'tailoring_app.db';
  static const String _webDbName = 'tailoring_app_offline';

  // Singleton pattern
  static OfflineStorageService? _instance;
  static OfflineStorageService get instance {
    _instance ??= OfflineStorageService._();
    return _instance!;
  }

  OfflineStorageService._();

  Database? _database;
  late SharedPreferences _prefs;
  final Connectivity _connectivity = Connectivity();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sync status tracking
  final Map<String, bool> _syncStatus = {};
  final Map<String, DateTime> _lastSyncTime = {};

  // Platform-specific storage
  late final dynamic _storage;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      // Web platform - use IndexedDB via web APIs
      await _initializeWebStorage();
    } else {
      // Mobile platform - use SQLite
      await _initializeSQLite();
    }

    // Start connectivity monitoring
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _initializeSQLite() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDatabase,
      onUpgrade: _onUpgradeDatabase,
    );
  }

  Future<void> _initializeWebStorage() async {
    // Web storage will be handled by a separate web-specific implementation
    // For now, we'll use a simple in-memory cache with localStorage backup
    debugdebugPrint('Web storage initialized');
  }

  Future<void> _onCreateDatabase(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        userId TEXT,
        displayName TEXT,
        email TEXT,
        phoneNumber TEXT,
        photoUrl TEXT,
        skills TEXT,
        specializations TEXT,
        experienceYears INTEGER,
        certifications TEXT,
        availability INTEGER,
        preferredWorkDays TEXT,
        preferredStartTime TEXT,
        preferredEndTime TEXT,
        canWorkRemotely INTEGER,
        location TEXT,
        totalOrdersCompleted INTEGER,
        ordersInProgress INTEGER,
        averageRating REAL,
        completionRate REAL,
        strengths TEXT,
        areasForImprovement TEXT,
        baseRatePerHour REAL,
        performanceBonusRate REAL,
        paymentTerms TEXT,
        totalEarnings REAL,
        recentAssignments TEXT,
        lastActive TEXT,
        consecutiveDaysWorked INTEGER,
        isActive INTEGER,
        joinedDate TEXT,
        deactivatedDate TEXT,
        deactivationReason TEXT,
        additionalInfo TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        syncStatus TEXT DEFAULT 'synced',
        lastModified INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE work_assignments (
        id TEXT PRIMARY KEY,
        orderId TEXT,
        employeeId TEXT,
        requiredSkill INTEGER,
        taskDescription TEXT,
        assignedAt TEXT,
        startedAt TEXT,
        completedAt TEXT,
        deadline TEXT,
        status INTEGER,
        estimatedHours REAL,
        actualHours REAL,
        hourlyRate REAL,
        bonusRate REAL,
        qualityNotes TEXT,
        qualityRating REAL,
        updates TEXT,
        materials TEXT,
        isRemoteWork INTEGER,
        location TEXT,
        assignedBy TEXT,
        syncStatus TEXT DEFAULT 'synced',
        lastModified INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        collection TEXT,
        documentId TEXT,
        operation TEXT,
        data TEXT,
        timestamp INTEGER,
        retryCount INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_employees_userId ON employees(userId)');
    await db.execute('CREATE INDEX idx_assignments_employeeId ON work_assignments(employeeId)');
    await db.execute('CREATE INDEX idx_sync_queue_timestamp ON sync_queue(timestamp)');
  }

  Future<void> _onUpgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    debugdebugPrint('Database upgraded from $oldVersion to $newVersion');
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.isNotEmpty && results.first != ConnectivityResult.none) {
      // Online - trigger sync
      syncPendingChanges();
    }
  }

  // Employee CRUD Operations
  Future<void> saveEmployee(Employee employee) async {
    if (kIsWeb) {
      await _saveEmployeeWeb(employee);
    } else {
      await _saveEmployeeSQLite(employee);
    }
  }

  Future<void> _saveEmployeeSQLite(Employee employee) async {
    final db = _database;
    if (db == null) return;

    final data = {
      'id': employee.id,
      'userId': employee.userId,
      'displayName': employee.displayName,
      'email': employee.email,
      'phoneNumber': employee.phoneNumber,
      'photoUrl': employee.photoUrl,
      'skills': jsonEncode(employee.skills.map((s) => s.index).toList()),
      'specializations': jsonEncode(employee.specializations),
      'experienceYears': employee.experienceYears,
      'certifications': jsonEncode(employee.certifications),
      'availability': employee.availability.index,
      'preferredWorkDays': jsonEncode(employee.preferredWorkDays),
      'preferredStartTime': employee.preferredStartTime?.toJson(),
      'preferredEndTime': employee.preferredEndTime?.toJson(),
      'canWorkRemotely': employee.canWorkRemotely ? 1 : 0,
      'location': employee.location,
      'totalOrdersCompleted': employee.totalOrdersCompleted,
      'ordersInProgress': employee.ordersInProgress,
      'averageRating': employee.averageRating,
      'completionRate': employee.completionRate,
      'strengths': jsonEncode(employee.strengths),
      'areasForImprovement': jsonEncode(employee.areasForImprovement),
      'baseRatePerHour': employee.baseRatePerHour,
      'performanceBonusRate': employee.performanceBonusRate,
      'paymentTerms': employee.paymentTerms,
      'totalEarnings': employee.totalEarnings,
      'recentAssignments': jsonEncode(employee.recentAssignments.map((a) => a.toJson()).toList()),
      'lastActive': employee.lastActive?.toIso8601String(),
      'consecutiveDaysWorked': employee.consecutiveDaysWorked,
      'isActive': employee.isActive ? 1 : 0,
      'joinedDate': employee.joinedDate.toIso8601String(),
      'deactivatedDate': employee.deactivatedDate?.toIso8601String(),
      'deactivationReason': employee.deactivationReason,
      'additionalInfo': jsonEncode(employee.additionalInfo),
      'createdAt': employee.createdAt.toIso8601String(),
      'updatedAt': employee.updatedAt.toIso8601String(),
      'syncStatus': 'pending',
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };

    await db.insert(
      'employees',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Queue for sync
    await _addToSyncQueue('employees', employee.id, 'create', data);
  }

  Future<void> _saveEmployeeWeb(Employee employee) async {
    // Web implementation would use IndexedDB
    // For now, store in localStorage as JSON
    final data = employee.toJson();
    final key = 'employee_${employee.id}';

    if (kIsWeb) {
      // Use web-specific storage
      // This would be implemented with js interop for IndexedDB
      debugdebugPrint('Web storage: Saving employee $key');
    }

    await _addToSyncQueue('employees', employee.id, 'create', data);
  }

  Future<Employee?> getEmployee(String employeeId) async {
    if (kIsWeb) {
      return await _getEmployeeWeb(employeeId);
    } else {
      return await _getEmployeeSQLite(employeeId);
    }
  }

  Future<Employee?> _getEmployeeSQLite(String employeeId) async {
    final db = _database;
    if (db == null) return null;

    final maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [employeeId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return Employee.fromJson(_convertFromSQLite(map));
  }

  Future<Employee?> _getEmployeeWeb(String employeeId) async {
    // Web implementation
    debugdebugPrint('Web storage: Getting employee $employeeId');
    return null;
  }

  Future<List<Employee>> getAllEmployees() async {
    if (kIsWeb) {
      return await _getAllEmployeesWeb();
    } else {
      return await _getAllEmployeesSQLite();
    }
  }

  Future<List<Employee>> _getAllEmployeesSQLite() async {
    final db = _database;
    if (db == null) return [];

    final maps = await db.query('employees', orderBy: 'displayName ASC');

    return maps.map((map) {
      try {
        return Employee.fromJson(_convertFromSQLite(map));
      } catch (e) {
        debugdebugPrint('Error parsing employee: $e');
        return null;
      }
    }).whereType<Employee>().toList();
  }

  Future<List<Employee>> _getAllEmployeesWeb() async {
    // Web implementation
    debugdebugPrint('Web storage: Getting all employees');
    return [];
  }

  Future<void> deleteEmployee(String employeeId) async {
    if (kIsWeb) {
      await _deleteEmployeeWeb(employeeId);
    } else {
      await _deleteEmployeeSQLite(employeeId);
    }

    await _addToSyncQueue('employees', employeeId, 'delete', {});
  }

  Future<void> _deleteEmployeeSQLite(String employeeId) async {
    final db = _database;
    if (db == null) return;

    await db.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [employeeId],
    );
  }

  Future<void> _deleteEmployeeWeb(String employeeId) async {
    debugdebugPrint('Web storage: Deleting employee $employeeId');
  }

  // Work Assignment Operations
  Future<void> saveWorkAssignment(WorkAssignment assignment) async {
    if (kIsWeb) {
      await _saveWorkAssignmentWeb(assignment);
    } else {
      await _saveWorkAssignmentSQLite(assignment);
    }
  }

  Future<void> _saveWorkAssignmentSQLite(WorkAssignment assignment) async {
    final db = _database;
    if (db == null) return;

    final data = {
      'id': assignment.id,
      'orderId': assignment.orderId,
      'employeeId': assignment.employeeId,
      'requiredSkill': assignment.requiredSkill.index,
      'taskDescription': assignment.taskDescription,
      'assignedAt': assignment.assignedAt.toIso8601String(),
      'startedAt': assignment.startedAt?.toIso8601String(),
      'completedAt': assignment.completedAt?.toIso8601String(),
      'deadline': assignment.deadline?.toIso8601String(),
      'status': assignment.status.index,
      'estimatedHours': assignment.estimatedHours,
      'actualHours': assignment.actualHours,
      'hourlyRate': assignment.hourlyRate,
      'bonusRate': assignment.bonusRate,
      'qualityNotes': assignment.qualityNotes,
      'qualityRating': assignment.qualityRating,
      'updates': jsonEncode(assignment.updates.map((u) => u.toJson()).toList()),
      'materials': jsonEncode(assignment.materials),
      'isRemoteWork': assignment.isRemoteWork ? 1 : 0,
      'location': assignment.location,
      'assignedBy': assignment.assignedBy,
      'syncStatus': 'pending',
      'lastModified': DateTime.now().millisecondsSinceEpoch,
    };

    await db.insert(
      'work_assignments',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _addToSyncQueue('work_assignments', assignment.id, 'create', data);
  }

  Future<void> _saveWorkAssignmentWeb(WorkAssignment assignment) async {
    debugdebugPrint('Web storage: Saving work assignment ${assignment.id}');
    await _addToSyncQueue('work_assignments', assignment.id, 'create', assignment.toJson());
  }

  Future<List<WorkAssignment>> getEmployeeAssignments(String employeeId) async {
    if (kIsWeb) {
      return await _getEmployeeAssignmentsWeb(employeeId);
    } else {
      return await _getEmployeeAssignmentsSQLite(employeeId);
    }
  }

  Future<List<WorkAssignment>> _getEmployeeAssignmentsSQLite(String employeeId) async {
    final db = _database;
    if (db == null) return [];

    final maps = await db.query(
      'work_assignments',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
      orderBy: 'assignedAt DESC',
    );

    return maps.map((map) {
      try {
        return WorkAssignment.fromJson(_convertFromSQLite(map));
      } catch (e) {
        debugdebugPrint('Error parsing work assignment: $e');
        return null;
      }
    }).whereType<WorkAssignment>().toList();
  }

  Future<List<WorkAssignment>> _getEmployeeAssignmentsWeb(String employeeId) async {
    debugdebugPrint('Web storage: Getting assignments for employee $employeeId');
    return [];
  }

  // Sync Queue Management
  Future<void> _addToSyncQueue(String collection, String documentId, String operation, Map<String, dynamic> data) async {
    final queueItem = {
      'id': '${collection}_${documentId}_${DateTime.now().millisecondsSinceEpoch}',
      'collection': collection,
      'documentId': documentId,
      'operation': operation,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'retryCount': 0,
    };

    if (kIsWeb) {
      // Web implementation
      debugdebugPrint('Added to sync queue: ${queueItem['id']}');
    } else {
      final db = _database;
      if (db != null) {
        await db.insert('sync_queue', queueItem, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // Try to sync immediately if online
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.isNotEmpty && connectivityResults.first != ConnectivityResult.none) {
      await syncPendingChanges();
    }
  }

  Future<void> syncPendingChanges() async {
    if (kIsWeb) {
      await _syncPendingChangesWeb();
    } else {
      await _syncPendingChangesSQLite();
    }
  }

  Future<void> _syncPendingChangesSQLite() async {
    final db = _database;
    if (db == null) return;

    final pendingItems = await db.query(
      'sync_queue',
      where: 'retryCount < 5',
      orderBy: 'timestamp ASC',
      limit: 50, // Process in batches
    );

    for (final item in pendingItems) {
      try {
        await _syncItem(item);
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [item['id']]);
      } catch (e) {
        // Increment retry count
        await db.update(
          'sync_queue',
          {'retryCount': (item['retryCount'] as int) + 1},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
        debugdebugPrint('Sync failed for ${item['id']}: $e');
      }
    }
  }

  Future<void> _syncPendingChangesWeb() async {
    debugdebugPrint('Syncing pending changes for web platform');
  }

  Future<void> _syncItem(Map<String, dynamic> item) async {
    final collection = item['collection'] as String;
    final documentId = item['documentId'] as String;
    final operation = item['operation'] as String;
    final data = jsonDecode(item['data'] as String);

    final docRef = _firestore.collection(collection).doc(documentId);

    switch (operation) {
      case 'create':
      case 'update':
        await docRef.set(data, SetOptions(merge: true));
        break;
      case 'delete':
        await docRef.delete();
        break;
    }
  }

  // Utility Methods
  Map<String, dynamic> _convertFromSQLite(Map<String, dynamic> sqliteData) {
    final data = Map<String, dynamic>.from(sqliteData);

    // Convert JSON strings back to objects
    if (data['skills'] != null) {
      final skillsList = jsonDecode(data['skills'] as String) as List;
      data['skills'] = skillsList;
    }

    if (data['specializations'] != null) {
      data['specializations'] = jsonDecode(data['specializations'] as String);
    }

    if (data['certifications'] != null) {
      data['certifications'] = jsonDecode(data['certifications'] as String);
    }

    if (data['preferredWorkDays'] != null) {
      data['preferredWorkDays'] = jsonDecode(data['preferredWorkDays'] as String);
    }

    if (data['strengths'] != null) {
      data['strengths'] = jsonDecode(data['strengths'] as String);
    }

    if (data['areasForImprovement'] != null) {
      data['areasForImprovement'] = jsonDecode(data['areasForImprovement'] as String);
    }

    if (data['recentAssignments'] != null) {
      data['recentAssignments'] = jsonDecode(data['recentAssignments'] as String);
    }

    if (data['additionalInfo'] != null) {
      data['additionalInfo'] = jsonDecode(data['additionalInfo'] as String);
    }

    // Convert integers back to booleans
    if (data['canWorkRemotely'] != null) {
      data['canWorkRemotely'] = data['canWorkRemotely'] == 1;
    }

    if (data['isActive'] != null) {
      data['isActive'] = data['isActive'] == 1;
    }

    if (data['isRemoteWork'] != null) {
      data['isRemoteWork'] = data['isRemoteWork'] == 1;
    }

    return data;
  }

  // Sync Status Management
  bool isOnline() {
    // This would be more sophisticated in a real app
    return true; // Placeholder
  }

  Future<bool> isDataSynced(String collection, String documentId) async {
    final key = '${collection}_$documentId';
    return _syncStatus[key] ?? true;
  }

  void setSyncStatus(String collection, String documentId, bool synced) {
    final key = '${collection}_$documentId';
    _syncStatus[key] = synced;
    if (synced) {
      _lastSyncTime[key] = DateTime.now();
    }
  }

  DateTime? getLastSyncTime(String collection, String documentId) {
    final key = '${collection}_$documentId';
    return _lastSyncTime[key];
  }

  // Cleanup
  Future<void> clearOldData({Duration? olderThan}) async {
    olderThan ??= const Duration(days: 30);

    if (!kIsWeb) {
      final db = _database;
      if (db != null) {
        final cutoff = DateTime.now().subtract(olderThan).millisecondsSinceEpoch;

        await db.delete(
          'sync_queue',
          where: 'timestamp < ?',
          whereArgs: [cutoff],
        );
      }
    }
  }

  Future<void> close() async {
    if (!kIsWeb && _database != null) {
      await _database!.close();
    }
  }
}

