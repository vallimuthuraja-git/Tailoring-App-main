import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import 'document_edit_screen.dart';

class CollectionDetailScreen extends StatefulWidget {
  final String collectionName;
  final String displayName;
  final IconData icon;
  final Color color;

  const CollectionDetailScreen({
    super.key,
    required this.collectionName,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Document',
            onPressed: () => _addNewDocument(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Searching for: $_searchQuery',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                      _searchController.clear();
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getCollectionStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                if (documents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No documents in ${widget.displayName}',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _addNewDocument(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Document'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    return _buildDocumentCard(doc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getCollectionStream() {
    Query query = FirebaseFirestore.instance.collection(widget.collectionName);

    if (_searchQuery.isNotEmpty) {
      // For now, we'll do a simple ID search
      // In a real app, you might want to implement full-text search
      query = query.where(FieldPath.documentId, isGreaterThanOrEqualTo: _searchQuery)
                   .where(FieldPath.documentId, isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    return query.snapshots();
  }

  Widget _buildDocumentCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final docId = doc.id;

    // Get the first few fields for preview
    final previewFields = _getPreviewFields(data);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewDocument(doc),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      docId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleDocumentAction(action, doc),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              if (previewFields.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...previewFields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${field['key']}: ${field['value']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
              const SizedBox(height: 8),
              Text(
                'Created: ${_formatTimestamp(data)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getPreviewFields(Map<String, dynamic> data) {
    final previewFields = <Map<String, dynamic>>[];

    // Priority fields to show in preview
    final priorityFields = ['name', 'title', 'email', 'phone', 'status', 'type', 'category'];

    for (final field in priorityFields) {
      if (data.containsKey(field)) {
        previewFields.add({
          'key': field,
          'value': _formatFieldValue(data[field]),
        });
        if (previewFields.length >= 3) break; // Limit to 3 preview fields
      }
    }

    // If no priority fields found, show first few fields
    if (previewFields.isEmpty) {
      int count = 0;
      for (final entry in data.entries) {
        if (count >= 3) break;
        if (entry.key != 'createdAt' && entry.key != 'updatedAt') {
          previewFields.add({
            'key': entry.key,
            'value': _formatFieldValue(entry.value),
          });
          count++;
        }
      }
    }

    return previewFields;
  }

  String _formatFieldValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    if (value is int || value is double) return value.toString();
    if (value is bool) return value.toString();
    if (value is Timestamp) return _formatTimestamp({'createdAt': value});
    if (value is List) return '${value.length} items';
    if (value is Map) return '${value.length} fields';
    return value.toString();
  }

  String _formatTimestamp(Map<String, dynamic> data) {
    final timestamp = data['createdAt'] ?? data['updatedAt'];
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString().split('.')[0];
    }
    return 'Unknown';
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Documents'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _addNewDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(
          collectionName: widget.collectionName,
          displayName: widget.displayName,
          documentId: null, // null means create new document
        ),
      ),
    );
  }

  void _viewDocument(DocumentSnapshot doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(
          collectionName: widget.collectionName,
          displayName: widget.displayName,
          documentId: doc.id,
          documentData: doc.data() as Map<String, dynamic>?,
          readOnly: true,
        ),
      ),
    );
  }

  void _handleDocumentAction(String action, DocumentSnapshot doc) {
    switch (action) {
      case 'view':
        _viewDocument(doc);
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentEditScreen(
              collectionName: widget.collectionName,
              displayName: widget.displayName,
              documentId: doc.id,
              documentData: doc.data() as Map<String, dynamic>?,
            ),
          ),
        );
        break;
      case 'duplicate':
        _duplicateDocument(doc);
        break;
      case 'delete':
        _deleteDocument(doc);
        break;
    }
  }

  void _duplicateDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // Remove metadata fields that shouldn't be duplicated
    data.remove('id');
    data.remove('createdAt');
    data['createdAt'] = Timestamp.now();
    data['updatedAt'] = Timestamp.now();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(
          collectionName: widget.collectionName,
          displayName: widget.displayName,
          documentId: null,
          documentData: data,
        ),
      ),
    );
  }

  void _deleteDocument(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firebaseService.deleteDocument(widget.collectionName, doc.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Document deleted successfully')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting document: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

