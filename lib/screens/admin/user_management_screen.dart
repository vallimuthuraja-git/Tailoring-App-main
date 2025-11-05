import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/user_role.dart';
import '../../utils/theme_constants.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Load all users from Firestore
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final usersSnapshot = await _firestore.collection('users').get();

      final users = <Map<String, dynamic>>[];
      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();
        users.add({
          'id': doc.id,
          ...userData,
        });
      }

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  /// Add a new user
  Future<void> _addUser() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const UserFormDialog(),
    );

    if (result != null) {
      await _createUser(result);
    }
  }

  /// Create a new user in Firebase Auth and Firestore
  Future<void> _createUser(Map<String, dynamic> userData) async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating user...')),
      );

      // Create user in Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userData['email'],
        password: userData['password'],
      );

      final uid = userCredential.user!.uid;
      await userCredential.user!.updateDisplayName(userData['displayName']);

      // Create user profile in Firestore
      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': userData['email'],
        'displayName': userData['displayName'],
        'role': userData['role'].index,
        'phoneNumber': userData['phoneNumber'] ?? '',
        'isEmailVerified': false,
        'lastLoginAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create role-specific data
      if (userData['role'] == UserRole.employee) {
        await _createEmployeeProfile(uid, userData);
      } else if (userData['role'] == UserRole.customer) {
        await _createCustomerProfile(uid, userData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );

      _loadUsers(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating user: $e')),
      );
    }
  }

  /// Create employee profile
  Future<void> _createEmployeeProfile(
      String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('employees').doc('emp_$userId').set({
      'id': 'emp_$userId',
      'userId': userId,
      'displayName': userData['displayName'],
      'email': userData['email'],
      'phoneNumber': userData['phoneNumber'] ?? '',
      'role': UserRole.employee.index,
      'skills': [],
      'specializations': [],
      'experienceYears': 0,
      'certifications': [],
      'availability': 0, // fullTime
      'preferredWorkDays': [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
      ],
      'preferredStartTime': {'hour': 9, 'minute': 0},
      'preferredEndTime': {'hour': 17, 'minute': 0},
      'canWorkRemotely': false,
      'location': 'Workshop',
      'totalOrdersCompleted': 0,
      'ordersInProgress': 0,
      'averageRating': 0.0,
      'completionRate': 0.0,
      'strengths': [],
      'areasForImprovement': [],
      'baseRatePerHour': 100.0,
      'performanceBonusRate': 15.0,
      'paymentTerms': 'Monthly',
      'totalEarnings': 0.0,
      'recentAssignments': [],
      'consecutiveDaysWorked': 0,
      'isActive': true,
      'joinedDate': FieldValue.serverTimestamp(),
      'additionalInfo': {},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create customer profile
  Future<void> _createCustomerProfile(
      String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('customers').doc(userId).set({
      'id': userId,
      'userId': userId,
      'name': userData['displayName'],
      'email': userData['email'],
      'phone': userData['phoneNumber'] ?? '',
      'address': {
        'street': '',
        'city': '',
        'state': '',
        'country': '',
        'pincode': '',
      },
      'measurements': {},
      'preferences': {},
      'loyaltyTier': 'Bronze',
      'totalSpent': 0.0,
      'orderCount': 0,
      'joinDate': FieldValue.serverTimestamp(),
      'lastOrderDate': null,
      'isActive': true,
      'notes': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Edit an existing user
  Future<void> _editUser(Map<String, dynamic> user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UserFormDialog(user: user),
    );

    if (result != null) {
      try {
        await _firestore.collection('users').doc(user['id']).update({
          'displayName': result['displayName'],
          'phoneNumber': result['phoneNumber'] ?? '',
          'role': result['role'].index,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );

        _loadUsers(); // Refresh the list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }
  }

  /// Delete a user
  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user['displayName']}? This will remove all their data and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete from Auth
        // Note: We can't directly delete users from client side
        // This would need to be handled by a cloud function or direct admin access

        // Delete from Firestore
        await _firestore.collection('users').doc(user['id']).delete();

        // Delete role-specific data
        int roleIndex = user['role'] as int;
        if (roleIndex < 0 || roleIndex >= UserRole.values.length) {
          roleIndex = 0; // Default to customer
        }
        final role = UserRole.values[roleIndex];
        if (role == UserRole.employee) {
          final employeeDocs = await _firestore
              .collection('employees')
              .where('userId', isEqualTo: user['id'])
              .get();
          for (final doc in employeeDocs.docs) {
            await doc.reference.delete();
          }
        } else if (role == UserRole.customer) {
          await _firestore.collection('customers').doc(user['id']).delete();
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );

        _loadUsers(); // Refresh the list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final isShopOwner = authProvider.isShopOwnerOrAdmin;

    // Only shop owners can access this screen
    if (!isShopOwner) {
      return const Scaffold(
        body: Center(
          child: Text('Access denied. Only shop owners can manage users.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildUserList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No users found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first user to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        int roleIndex = user['role'] as int;
        if (roleIndex < 0 || roleIndex >= UserRole.values.length) {
          roleIndex = 0; // Default to customer
        }
        final role = UserRole.values[roleIndex];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(role),
              child: Icon(
                _getRoleIcon(role),
                color: Colors.white,
              ),
            ),
            title: Text(user['displayName'] ?? 'No name'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email'] ?? ''),
                Text(
                  role.displayName,
                  style: TextStyle(
                    color: _getRoleColor(role),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'edit':
                    _editUser(user);
                    break;
                  case 'delete':
                    _deleteUser(user);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit User'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.employee:
        return Icons.work;
      case UserRole.shopOwner:
        return Icons.business;
      default:
        throw UnimplementedError('Unknown role: $role');
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Colors.green;
      case UserRole.employee:
        return Colors.blue;
      case UserRole.shopOwner:
        return Colors.purple;
      default:
        throw UnimplementedError('Unknown role: $role');
    }
  }
}

/// Dialog for adding/editing users
class UserFormDialog extends StatefulWidget {
  final Map<String, dynamic>? user;

  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _displayNameController.text = widget.user!['displayName'] ?? '';
      _emailController.text = widget.user!['email'] ?? '';
      _phoneController.text = widget.user!['phoneNumber'] ?? '';
      int roleIndex = widget.user!['role'] as int;
      if (roleIndex < 0 || roleIndex >= UserRole.values.length) {
        roleIndex = 0; // Default to customer
      }
      _selectedRole = UserRole.values[roleIndex];
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit User' : 'Add New User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Display name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                enabled: !isEditing, // Can't change email when editing
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              if (!isEditing) ...[
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Password is required';
                    }
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ],
              TextFormField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Phone (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const Text('User Role:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<UserRole>(
                      title: const Text('Customer'),
                      value: UserRole.customer,
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<UserRole>(
                      title: const Text('Employee'),
                      value: UserRole.employee,
                      groupValue: _selectedRole,
                      onChanged: (value) =>
                          setState(() => _selectedRole = value!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'displayName': _displayNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'role': _selectedRole,
      });
    }
  }
}
