import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BulkOperationsScreen extends StatefulWidget {
  const BulkOperationsScreen({super.key});

  @override
  State<BulkOperationsScreen> createState() => _BulkOperationsScreenState();
}

class _BulkOperationsScreenState extends State<BulkOperationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Available collections for bulk operations
  final List<String> _collections = [
    'customers',
    'products',
    'orders',
    'employees',
    'services',
    'work_assignments',
    'chat_conversations',
    'chat_messages',
    'users',
    'measurements',
    'notifications'
  ];

  String _selectedCollection = 'customers';
  bool _isLoading = false;
  String _operationStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildCollectionSelector(),
          const SizedBox(height: 20),
          _buildBulkOperations(),
          const SizedBox(height: 20),
          _buildDataOperations(),
          const SizedBox(height: 20),
          _buildStatusDisplay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Theme.of(context).primaryColor,
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.settings_applications,
              size: 48,
              color: Colors.white,
            ),
            SizedBox(height: 12),
            Text(
              'Bulk Operations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Perform bulk operations on your database',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Collection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCollection,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _collections.map((collection) {
                return DropdownMenuItem(
                  value: collection,
                  child: Text(_formatCollectionName(collection)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCollection = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkOperations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bulk Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildOperationButton(
              'Clear All Documents',
              'Delete all documents in selected collection',
              Icons.delete_forever,
              Colors.red,
              _clearAllDocuments,
            ),
            const SizedBox(height: 12),
            _buildOperationButton(
              'Deactivate All',
              'Mark all documents as inactive (where applicable)',
              Icons.block,
              Colors.orange,
              _deactivateAllDocuments,
            ),
            const SizedBox(height: 12),
            _buildOperationButton(
              'Update Timestamps',
              'Update all documents with current timestamp',
              Icons.update,
              Colors.blue,
              _updateAllTimestamps,
            ),
            const SizedBox(height: 12),
            _buildOperationButton(
              'Add Default Values',
              'Add default values to documents missing required fields',
              Icons.add_circle,
              Colors.green,
              _addDefaultValues,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataOperations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Operations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 12),
            _buildOperationButton(
              'Backup Collection',
              'Create a backup of the collection',
              Icons.backup,
              Colors.indigo,
              _backupCollection,
            ),
            const SizedBox(height: 12),
            _buildOperationButton(
              'Validate Data',
              'Validate all documents for data integrity',
              Icons.check_circle,
              Colors.teal,
              _validateData,
            ),
            const SizedBox(height: 12),
            _buildOperationButton(
              'Duplicate Collection',
              'Create a copy of the collection with "_backup" suffix',
              Icons.content_copy,
              Colors.amber,
              _duplicateCollection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationButton(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: _isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDisplay() {
    if (_operationStatus.isEmpty) return const SizedBox.shrink();

    return Card(
      color: _operationStatus.contains('Error') ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _operationStatus.contains('Error') ? Icons.error : Icons.check_circle,
              color: _operationStatus.contains('Error') ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _operationStatus,
                style: TextStyle(
                  color: _operationStatus.contains('Error') ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String status) {
    setState(() => _operationStatus = status);
  }

  Future<void> _clearAllDocuments() async {
    final confirmed = await _showConfirmationDialog(
      'Clear All Documents',
      'Are you sure you want to delete ALL documents in the $_selectedCollection collection? This action cannot be undone.',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    _updateStatus('Clearing all documents...');

    try {
      final snapshot = await _firestore.collection(_selectedCollection).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _updateStatus('Successfully cleared ${snapshot.docs.length} documents');
    } catch (e) {
      _updateStatus('Error clearing documents: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deactivateAllDocuments() async {
    final confirmed = await _showConfirmationDialog(
      'Deactivate All Documents',
      'Are you sure you want to mark all documents in $_selectedCollection as inactive?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    _updateStatus('Deactivating all documents...');

    try {
      final snapshot = await _firestore.collection(_selectedCollection).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isActive': false,
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
      _updateStatus('Successfully deactivated ${snapshot.docs.length} documents');
    } catch (e) {
      _updateStatus('Error deactivating documents: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAllTimestamps() async {
    final confirmed = await _showConfirmationDialog(
      'Update Timestamps',
      'Are you sure you want to update the updatedAt field for all documents in $_selectedCollection?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    _updateStatus('Updating timestamps...');

    try {
      final snapshot = await _firestore.collection(_selectedCollection).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
      _updateStatus('Successfully updated timestamps for ${snapshot.docs.length} documents');
    } catch (e) {
      _updateStatus('Error updating timestamps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addDefaultValues() async {
    final confirmed = await _showConfirmationDialog(
      'Add Default Values',
      'Are you sure you want to add default values to documents missing required fields?',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    _updateStatus('Adding default values...');

    try {
      final snapshot = await _firestore.collection(_selectedCollection).get();
      final batch = _firestore.batch();
      int updatedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final updates = <String, dynamic>{};

        // Add default values based on collection type
        switch (_selectedCollection) {
          case 'customers':
            if (!data.containsKey('isActive')) updates['isActive'] = true;
            if (!data.containsKey('loyaltyTier')) updates['loyaltyTier'] = 0;
            if (!data.containsKey('totalSpent')) updates['totalSpent'] = 0.0;
            break;
          case 'products':
            if (!data.containsKey('isActive')) updates['isActive'] = true;
            break;
          case 'employees':
            if (!data.containsKey('isActive')) updates['isActive'] = true;
            if (!data.containsKey('totalOrdersCompleted')) updates['totalOrdersCompleted'] = 0;
            break;
          case 'services':
            if (!data.containsKey('isActive')) updates['isActive'] = true;
            if (!data.containsKey('totalBookings')) updates['totalBookings'] = 0;
            break;
        }

        if (updates.isNotEmpty) {
          updates['updatedAt'] = Timestamp.now();
          batch.update(doc.reference, updates);
          updatedCount++;
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
      }
      _updateStatus('Successfully added default values to $updatedCount documents');
    } catch (e) {
      _updateStatus('Error adding default values: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _backupCollection() async {
    setState(() => _isLoading = true);
    _updateStatus('Creating collection backup...');

    try {
      final snapshot = await _firestore.collection(_selectedCollection).get();
      final batch = _firestore.batch();
      final backupCollection = '${_selectedCollection}_backup_${DateTime.now().millisecondsSinceEpoch}';

      for (final doc in snapshot.docs) {
        final backupRef = _firestore.collection(backupCollection).doc(doc.id);
        batch.set(backupRef, {
          ...doc.data(),
          'backupSource': _selectedCollection,
          'backupDate': Timestamp.now(),
        });
      }

      await batch.commit();
      _updateStatus('Successfully created backup with ${snapshot.docs.length} documents');
    } catch (e) {
      _updateStatus('Error creating backup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _validateData() async {
    setState(() => _isLoading = true);
    _updateStatus('Validating data integrity...');

    try {
      final snapshot = await _firestore.collection(_selectedCollection).get();
      int validCount = 0;
      int invalidCount = 0;
      final issues = <String>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final validationIssues = _validateDocument(data);

        if (validationIssues.isEmpty) {
          validCount++;
        } else {
          invalidCount++;
          issues.addAll(validationIssues.map((issue) => '${doc.id}: $issue'));
        }
      }

      _updateStatus('Validation complete: $validCount valid, $invalidCount invalid documents');

      if (issues.isNotEmpty && issues.length <= 5) {
        _showValidationIssues(issues);
      }
    } catch (e) {
      _updateStatus('Error validating data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _duplicateCollection() async {
    setState(() => _isLoading = true);
    _updateStatus('Duplicating collection...');

    try {
      final snapshot = await _firestore.collection(_selectedCollection).get();
      final batch = _firestore.batch();
      final duplicateCollection = '${_selectedCollection}_copy_${DateTime.now().millisecondsSinceEpoch}';

      for (final doc in snapshot.docs) {
        final duplicateRef = _firestore.collection(duplicateCollection).doc(doc.id);
        batch.set(duplicateRef, {
          ...doc.data(),
          'copiedFrom': _selectedCollection,
          'copyDate': Timestamp.now(),
        });
      }

      await batch.commit();
      _updateStatus('Successfully created duplicate collection with ${snapshot.docs.length} documents');
    } catch (e) {
      _updateStatus('Error duplicating collection: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> _validateDocument(Map<String, dynamic> data) {
    final issues = <String>[];

    // Common validation rules
    if (!data.containsKey('createdAt')) {
      issues.add('Missing createdAt field');
    }
    if (!data.containsKey('updatedAt')) {
      issues.add('Missing updatedAt field');
    }

    // Collection-specific validation
    switch (_selectedCollection) {
      case 'customers':
        if (!data.containsKey('name')) issues.add('Missing name field');
        if (!data.containsKey('email')) issues.add('Missing email field');
        break;
      case 'products':
        if (!data.containsKey('name')) issues.add('Missing name field');
        if (!data.containsKey('basePrice')) issues.add('Missing basePrice field');
        break;
      case 'orders':
        if (!data.containsKey('customerId')) issues.add('Missing customerId field');
        if (!data.containsKey('totalAmount')) issues.add('Missing totalAmount field');
        break;
    }

    return issues;
  }


  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showValidationIssues(List<String> issues) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Issues'),
        content: SizedBox(
          height: 300,
          width: double.maxFinite,
          child: ListView(
            children: issues.map((issue) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('â€¢ $issue'),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatCollectionName(String name) {
    return name.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

