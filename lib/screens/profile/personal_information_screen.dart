import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/common_app_bar_actions.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _displayNameController.text = authProvider.userProfile?.displayName ?? '';
    _phoneController.text = authProvider.userProfile?.phoneNumber ?? '';
    _emailController.text = authProvider.userProfile?.email ?? '';
    _selectedGender = authProvider.userProfile?.gender;
    _selectedDateOfBirth = authProvider.userProfile?.dateOfBirth;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    if (value.length < 2) {
      return 'Display name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateUserProfile(
      displayName: _displayNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDateOfBirth,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ??
              'Failed to update personal information'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        elevation: 0,
        actions: [
          if (_hasUnsavedChanges())
            TextButton(
              onPressed: !_isLoading ? _saveChanges : null,
              child: const Text('Save'),
            ),
          // Common app bar actions
          const CommonAppBarActions(
            showLogout: true,
            showCart: true,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DarkAppColors.background,
                    DarkAppColors.surface.withValues(alpha: 0.8),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.background,
                  ],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen ? 600 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: themeProvider.isDarkMode
                              ? LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.8),
                                    AppColors.primaryVariant
                                        .withValues(alpha: 0.9),
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryVariant,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Update Your Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Keep your personal information up to date',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Form
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.surface.withValues(alpha: 0.95)
                              : AppColors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themeProvider.isDarkMode
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display Name Field
                              TextFormField(
                                controller: _displayNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Display Name',
                                  prefixIcon: Icon(Icons.person),
                                  hintText: 'Enter your full name',
                                ),
                                validator: _validateDisplayName,
                              ),

                              const SizedBox(height: 20),

                              // Email Field (Read-only for now)
                              TextFormField(
                                controller: _emailController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email),
                                  hintText: 'Email cannot be changed',
                                  helperText: 'Contact support to change email',
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Phone Number Field
                              TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number (Optional)',
                                  prefixIcon: Icon(Icons.phone),
                                  hintText: '+1 234 567 8901',
                                  helperText: 'Used for delivery updates',
                                ),
                                validator: _validatePhone,
                              ),

                              const SizedBox(height: 20),

                              // Gender Selection
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gender',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: ['Male', 'Female', 'Other']
                                        .map((gender) {
                                      final isSelected =
                                          _selectedGender == gender;
                                      return ChoiceChip(
                                        label: Text(gender),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            setState(() {
                                              _selectedGender = gender;
                                            });
                                          }
                                        },
                                        backgroundColor:
                                            themeProvider.isDarkMode
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade100,
                                        selectedColor: themeProvider.isDarkMode
                                            ? AppColors.primary
                                                .withValues(alpha: 0.2)
                                            : AppColors.primary
                                                .withValues(alpha: 0.2),
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? (themeProvider.isDarkMode
                                                  ? AppColors.primary
                                                  : AppColors.primary)
                                              : (themeProvider.isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black87),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Date of Birth Field
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of Birth',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDateOfBirth ??
                                            DateTime.now().subtract(
                                                const Duration(days: 365 * 18)),
                                        firstDate: DateTime.now().subtract(
                                            const Duration(days: 365 * 120)),
                                        lastDate: DateTime.now().subtract(
                                            const Duration(days: 365 * 0)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: themeProvider
                                                      .isDarkMode
                                                  ? ColorScheme.dark(
                                                      primary:
                                                          AppColors.primary,
                                                      onPrimary: Colors.white,
                                                      surface: themeProvider
                                                              .isDarkMode
                                                          ? Colors.grey.shade800
                                                          : Colors.white,
                                                      onSurface: themeProvider
                                                              .isDarkMode
                                                          ? Colors.white70
                                                          : Colors.black87,
                                                    )
                                                  : ColorScheme.light(
                                                      primary:
                                                          AppColors.primary,
                                                      onPrimary: Colors.white,
                                                      surface: Colors.white,
                                                      onSurface: Colors.black87,
                                                    ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null &&
                                          picked != _selectedDateOfBirth) {
                                        setState(() {
                                          _selectedDateOfBirth = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white
                                                  .withValues(alpha: 0.3)
                                              : Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: themeProvider.isDarkMode
                                            ? Colors.grey.shade800
                                                .withValues(alpha: 0.5)
                                            : Colors.grey.shade50,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _selectedDateOfBirth != null
                                                  ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                                  : 'Select your date of birth',
                                              style: TextStyle(
                                                color: _selectedDateOfBirth !=
                                                        null
                                                    ? (themeProvider.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black87)
                                                    : (themeProvider.isDarkMode
                                                        ? Colors.white
                                                            .withValues(
                                                                alpha: 0.5)
                                                        : Colors.grey.shade500),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Role Display
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeProvider.isDarkMode
                                      ? Colors.blueGrey.shade800
                                          .withValues(alpha: 0.3)
                                      : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.badge,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Account Role',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          authProvider.userRole ==
                                                  UserRole.customer
                                              ? 'Customer'
                                              : authProvider.userRole ==
                                                      UserRole.shopOwner
                                                  ? 'Esther (Owner)'
                                                  : 'Employee',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Save Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text(
                                          'Save Changes',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Cancel Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white.withValues(alpha: 0.3)
                                          : Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Privacy Note
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.amber.withValues(alpha: 0.1)
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.privacy_tip,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Privacy Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your personal information is kept private and secure. We use this information only to provide better service and improve your experience.\n\nChanges to your email address require verification for security reasons.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.amber.shade800,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasUnsavedChanges() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentDisplayName = authProvider.userProfile?.displayName ?? '';
    final currentPhone = authProvider.userProfile?.phoneNumber ?? '';
    final currentGender = authProvider.userProfile?.gender;
    final currentDateOfBirth = authProvider.userProfile?.dateOfBirth;

    return currentDisplayName != _displayNameController.text ||
        currentPhone != _phoneController.text ||
        currentGender != _selectedGender ||
        currentDateOfBirth != _selectedDateOfBirth;
  }
}
