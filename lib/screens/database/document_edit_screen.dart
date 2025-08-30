import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';

class DocumentEditScreen extends StatefulWidget {
  final String collectionName;
  final String displayName;
  final String? documentId;
  final Map<String, dynamic>? documentData;
  final bool readOnly;

  const DocumentEditScreen({
    super.key,
    required this.collectionName,
    required this.displayName,
    this.documentId,
    this.documentData,
    this.readOnly = false,
  });

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _documentData;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _documentData = widget.documentData ?? {};
    _isEditing = widget.documentId == null || !widget.readOnly;
  }

  @override
  Widget build(BuildContext context) {
    final isNewDocument = widget.documentId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewDocument
              ? 'New ${widget.displayName} Document'
              : (widget.readOnly ? 'View Document' : 'Edit Document'),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!widget.readOnly && !isNewDocument)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              tooltip: _isEditing ? 'Save Changes' : 'Edit Document',
              onPressed: _isEditing ? _saveDocument : () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDocumentHeader(),
                  const SizedBox(height: 20),
                  ..._buildFormFields(),
                  const SizedBox(height: 20),
                  if (!widget.readOnly) _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildDocumentHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCollectionIcon(),
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Collection: ${widget.collectionName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (widget.documentId != null) ...[
              const SizedBox(height: 4),
              Text(
                'Document ID: ${widget.documentId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = <Widget>[];

    // Sort fields to show important ones first
    final sortedKeys = _documentData.keys.toList()..sort((a, b) {
      const priorityFields = ['id', 'name', 'title', 'email', 'phone', 'status', 'type'];
      final aPriority = priorityFields.contains(a) ? 1 : 0;
      final bPriority = priorityFields.contains(b) ? 1 : 0;
      return bPriority.compareTo(aPriority);
    });

    for (final key in sortedKeys) {
      if (key == 'id' && widget.documentId != null) {
        // Don't show ID field for existing documents
        continue;
      }

      fields.add(_buildFormField(key, _documentData[key]));
      fields.add(const SizedBox(height: 16));
    }

    // Add button to add new field
    if (_isEditing) {
      fields.add(
        ElevatedButton.icon(
          onPressed: _addNewField,
          icon: const Icon(Icons.add),
          label: const Text('Add Field'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    return fields;
  }

  Widget _buildFormField(String key, dynamic value) {
    final controller = TextEditingController(text: _formatFieldValue(value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_isEditing && key != 'id')
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    onPressed: () => _removeField(key),
                    tooltip: 'Remove field',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter $key value',
                  suffixIcon: _buildFieldTypeIcon(value),
                ),
                maxLines: _getMaxLinesForField(key, value),
                onChanged: (newValue) => _updateFieldValue(key, newValue),
                validator: (value) {
                  if (key == 'id' && value!.isEmpty) {
                    return 'ID is required';
                  }
                  return null;
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatFieldValue(value),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'Type: ${_getFieldType(value)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldTypeIcon(dynamic value) {
    IconData iconData;
    Color color;

    if (value is int || value is double) {
      iconData = Icons.numbers;
      color = Colors.blue;
    } else if (value is bool) {
      iconData = Icons.check_circle;
      color = Colors.green;
    } else if (value is Timestamp) {
      iconData = Icons.schedule;
      color = Colors.orange;
    } else if (value is List) {
      iconData = Icons.list;
      color = Colors.purple;
    } else if (value is Map) {
      iconData = Icons.web;
      color = Colors.teal;
    } else {
      iconData = Icons.text_fields;
      color = Colors.grey;
    }

    return Icon(iconData, color: color, size: 20);
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveDocument,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(widget.documentId == null ? 'Create' : 'Save'),
          ),
        ),
      ],
    );
  }

  void _addNewField() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: 'Field Name',
                hintText: 'Enter field name',
              ),
              onSubmitted: (fieldName) {
                if (fieldName.isNotEmpty && !_documentData.containsKey(fieldName)) {
                  setState(() {
                    _documentData[fieldName] = '';
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final fieldName = (context.findRenderObject() as RenderBox)
                  .toString()
                  .split('\n')[1]; // This is a simplified approach
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeField(String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Field'),
        content: Text('Are you sure you want to remove the field "$key"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _documentData.remove(key);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _updateFieldValue(String key, String newValue) {
    setState(() {
      // Try to parse the value to appropriate type
      if (newValue == 'true') {
        _documentData[key] = true;
      } else if (newValue == 'false') {
        _documentData[key] = false;
      } else if (int.tryParse(newValue) != null) {
        _documentData[key] = int.parse(newValue);
      } else if (double.tryParse(newValue) != null) {
        _documentData[key] = double.parse(newValue);
      } else {
        _documentData[key] = newValue;
      }
    });
  }

  void _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.documentId == null) {
        // Create new document
        final docRef = await _firebaseService.addDocument(widget.collectionName, _documentData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document created successfully with ID: ${docRef.id}')),
        );
      } else {
        // Update existing document
        await _firebaseService.updateDocument(widget.collectionName, widget.documentId!, _documentData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document updated successfully')),
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving document: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  IconData _getCollectionIcon() {
    switch (widget.collectionName) {
      case 'customers':
        return Icons.people;
      case 'products':
        return Icons.inventory;
      case 'orders':
        return Icons.shopping_cart;
      case 'employees':
        return Icons.work;
      case 'services':
        return Icons.build;
      case 'work_assignments':
        return Icons.assignment;
      case 'chat_conversations':
        return Icons.chat;
      case 'chat_messages':
        return Icons.message;
      case 'users':
        return Icons.account_circle;
      case 'measurements':
        return Icons.straighten;
      case 'notifications':
        return Icons.notifications;
      default:
        return Icons.storage;
    }
  }

  String _formatFieldValue(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) return value.toDate().toString();
    if (value is List) return value.join(', ');
    if (value is Map) return '${value.length} fields';
    return value.toString();
  }

  String _getFieldType(dynamic value) {
    if (value == null) return 'null';
    if (value is int) return 'integer';
    if (value is double) return 'number';
    if (value is bool) return 'boolean';
    if (value is String) return 'string';
    if (value is Timestamp) return 'timestamp';
    if (value is List) return 'array';
    if (value is Map) return 'object';
    return 'unknown';
  }

  int _getMaxLinesForField(String key, dynamic value) {
    if (value is List || value is Map || key.toLowerCase().contains('description')) {
      return 5;
    }
    if (value is String && value.length > 50) {
      return 3;
    }
    return 1;
  }
}