import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../models/employee.dart' as emp;

class EmployeeRegistrationScreen extends StatefulWidget {
  const EmployeeRegistrationScreen({super.key});

  @override
  State<EmployeeRegistrationScreen> createState() => _EmployeeRegistrationScreenState();
}

class _EmployeeRegistrationScreenState extends State<EmployeeRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _specializationsController = TextEditingController();
  final _certificationsController = TextEditingController();

  emp.EmployeeAvailability _availability = emp.EmployeeAvailability.fullTime;
  final List<emp.EmployeeSkill> _selectedSkills = [];
  final List<String> _selectedWorkDays = [];
  emp.TimeOfDay? _startTime;
  emp.TimeOfDay? _endTime;
  bool _canWorkRemotely = false;
  String? _location;

  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _specializationsController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Registration'),
      ),
      body: Consumer2<AuthProvider, EmployeeProvider>(
        builder: (context, authProvider, employeeProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  _buildSectionTitle('Basic Information'),
                  _buildTextField(
                    controller: _displayNameController,
                    label: 'Full Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Skills and Expertise
                  _buildSectionTitle('Skills and Expertise'),
                  _buildSkillsSelection(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _specializationsController,
                    label: 'Specializations (comma separated)',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _experienceController,
                    label: 'Years of Experience',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter years of experience';
                      }
                      final years = int.tryParse(value);
                      if (years == null || years < 0) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _certificationsController,
                    label: 'Certifications (comma separated)',
                    maxLines: 2,
                  ),

                  const SizedBox(height: 32),

                  // Availability
                  _buildSectionTitle('Availability'),
                  _buildAvailabilityDropdown(),
                  const SizedBox(height: 16),
                  _buildWorkDaysSelection(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePicker(
                          label: 'Start Time',
                          value: _startTime,
                          onChanged: (time) => setState(() => _startTime = time),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimePicker(
                          label: 'End Time',
                          value: _endTime,
                          onChanged: (time) => setState(() => _endTime = time),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Can work remotely'),
                    value: _canWorkRemotely,
                    onChanged: (value) => setState(() => _canWorkRemotely = value),
                    tileColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (_canWorkRemotely) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      initialValue: _location,
                      label: 'Work Location (optional)',
                      onChanged: (value) => _location = value,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Compensation
                  _buildSectionTitle('Compensation'),
                  _buildTextField(
                    controller: _hourlyRateController,
                    label: 'Base Hourly Rate (USD)',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hourly rate';
                      }
                      final rate = double.tryParse(value);
                      if (rate == null || rate <= 0) {
                        return 'Please enter a valid rate';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Complete Registration'),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildSkillsSelection() {
    const skills = emp.EmployeeSkill.values;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your skills',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: skills.map((skill) {
                final isSelected = _selectedSkills.contains(skill);
                return FilterChip(
                  label: Text(_getSkillDisplayName(skill)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityDropdown() {
    return DropdownButtonFormField<emp.EmployeeAvailability>(
      initialValue: _availability,
      decoration: const InputDecoration(
        labelText: 'Availability',
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: emp.EmployeeAvailability.values.map((availability) {
        return DropdownMenuItem(
          value: availability,
          child: Text(_getAvailabilityDisplayName(availability)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _availability = value);
        }
      },
    );
  }

  Widget _buildWorkDaysSelection() {
    final workDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available work days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: workDays.map((day) {
                final isSelected = _selectedWorkDays.contains(day);
                return FilterChip(
                  label: Text(day.substring(0, 3)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWorkDays.add(day);
                      } else {
                        _selectedWorkDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required emp.TimeOfDay? value,
    required void Function(emp.TimeOfDay?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          onChanged(emp.TimeOfDay(hour: time.hour, minute: time.minute));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? value.formatTime() : label,
                style: TextStyle(
                  color: value != null ? null : Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.access_time),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }

    if (_selectedWorkDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one work day')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

      final currentUser = authProvider.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await employeeProvider.createEmployee(
        userId: currentUser.uid,
        displayName: _displayNameController.text,
        email: currentUser.email ?? '',
        phoneNumber: _phoneController.text,
        skills: _selectedSkills,
        specializations: _specializationsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        experienceYears: int.parse(_experienceController.text),
        certifications: _certificationsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        availability: _availability,
        preferredWorkDays: _selectedWorkDays,
        preferredStartTime: _startTime,
        preferredEndTime: _endTime,
        canWorkRemotely: _canWorkRemotely,
        location: _location,
        baseRatePerHour: double.parse(_hourlyRateController.text),
        performanceBonusRate: double.parse(_hourlyRateController.text) * 0.1, // 10% bonus
        paymentTerms: 'Bi-weekly',
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration completed successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to create employee profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getSkillDisplayName(emp.EmployeeSkill skill) {
    switch (skill) {
      case emp.EmployeeSkill.cutting:
        return 'Fabric Cutting';
      case emp.EmployeeSkill.stitching:
        return 'Stitching';
      case emp.EmployeeSkill.finishing:
        return 'Finishing';
      case emp.EmployeeSkill.alterations:
        return 'Alterations';
      case emp.EmployeeSkill.embroidery:
        return 'Embroidery';
      case emp.EmployeeSkill.qualityCheck:
        return 'Quality Check';
      case emp.EmployeeSkill.patternMaking:
        return 'Pattern Making';
    }
  }

  String _getAvailabilityDisplayName(emp.EmployeeAvailability availability) {
    switch (availability) {
      case emp.EmployeeAvailability.fullTime:
        return 'Full Time (8 hours/day)';
      case emp.EmployeeAvailability.partTime:
        return 'Part Time (4 hours/day)';
      case emp.EmployeeAvailability.flexible:
        return 'Flexible Hours';
      case emp.EmployeeAvailability.projectBased:
        return 'Project Based';
      case emp.EmployeeAvailability.remote:
        return 'Remote Work';
      case emp.EmployeeAvailability.unavailable:
        return 'Currently Unavailable';
    }
  }
}
