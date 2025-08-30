# Employee Create Screen Documentation

## Overview
The `employee_create_screen.dart` file contains the comprehensive employee onboarding interface for the AI-Enabled Tailoring Shop Management System. It provides a complete form-based workflow for creating new employee profiles with extensive validation, skill selection, availability configuration, and role-based access control, ensuring thorough data collection for new team members.

## Architecture

### Core Components
- **`EmployeeCreateScreen`**: Main employee creation interface with comprehensive form
- **Advanced Form Validation**: Multi-level validation for all input fields
- **Skill Selection System**: Interactive skill selection with filter chips
- **Availability Configuration**: Flexible work schedule and availability settings
- **Time Picker Integration**: Work hour selection with native time picker
- **Role-Based Access Control**: Shop owner exclusive employee creation
- **Error Handling & Feedback**: Comprehensive error handling and user feedback

### Key Features
- **Complete Employee Profiling**: Personal details, skills, experience, and certifications
- **Flexible Availability**: Multiple work arrangements and scheduling options
- **Skill-Based Assignment**: Comprehensive skill selection for work matching
- **Compensation Setup**: Base rate and performance bonus configuration
- **Remote Work Support**: Location and remote work capability settings
- **Form Persistence**: Maintains form state during validation errors
- **Offline Capability**: Queues employee creation for offline scenarios

## Form Structure

### Basic Information Section
```dart
// Personal Details Collection
_buildTextField(
  controller: _displayNameController,
  label: 'Full Name',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter full name';
    }
    return null;
  },
),

_buildTextField(
  controller: _emailController,
  label: 'Email Address',
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  },
),

_buildTextField(
  controller: _phoneController,
  label: 'Phone Number (optional)',
  keyboardType: TextInputType.phone,
),
```

### Skills and Expertise Section
```dart
// Experience and Skill Assessment
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

_buildTextField(
  controller: _specializationsController,
  label: 'Specializations (comma separated)',
  maxLines: 2,
),

_buildTextField(
  controller: _certificationsController,
  label: 'Certifications (comma separated)',
  maxLines: 2,
),
```

### Availability Configuration
```dart
// Work Schedule and Availability
DropdownButtonFormField<emp.EmployeeAvailability>(
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
)
```

### Work Days Selection
```dart
// Flexible Work Day Selection
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available work days', style: Theme.of(context).textTheme.titleMedium),
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
)
```

### Work Hours Configuration
```dart
// Time Picker Integration
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
)
```

### Remote Work Settings
```dart
// Remote Work Capability
SwitchListTile(
  title: const Text('Can work remotely'),
  value: _canWorkRemotely,
  onChanged: (value) => setState(() => _canWorkRemotely = value),
  tileColor: Theme.of(context).cardColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
),

// Conditional Location Field
if (_canWorkRemotely) ...[
  _buildTextField(
    controller: _locationController,
    label: 'Work Location (optional)',
  ),
]
```

### Compensation Setup
```dart
// Base Rate Configuration
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
)
```

## Skill Selection System

### Interactive Skill Chips
```dart
Widget _buildSkillsSelection() {
  const skills = emp.EmployeeSkill.values;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select skills', style: Theme.of(context).textTheme.titleMedium),
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
```

### Skill Display Names
```dart
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
```

## Availability Options

### Availability Types
```dart
enum EmployeeAvailability {
  fullTime,     // Full Time (8 hours/day)
  partTime,     // Part Time (4 hours/day)
  flexible,     // Flexible Hours
  projectBased, // Project Based
  remote,       // Remote Work
  unavailable,  // Currently Unavailable
}
```

### Availability Display Names
```dart
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
```

## Form Validation

### Multi-Level Validation
```dart
void _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  // Skill Validation
  if (_selectedSkills.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one skill')),
    );
    return;
  }

  // Work Days Validation
  if (_selectedWorkDays.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select at least one work day')),
    );
    return;
  }

  // Form Processing
  setState(() => _isLoading = true);
  // ... form submission logic
}
```

### Custom Text Field Builder
```dart
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  int? maxLines = 1,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Theme.of(context).cardColor,
    ),
    keyboardType: keyboardType,
    maxLines: maxLines,
    validator: validator,
  );
}
```

## Time Picker Integration

### Custom Time Picker Widget
```dart
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
```

## Role-Based Access Control

### Route Protection
```dart
RoleBasedRouteGuard(
  requiredRole: auth.UserRole.shopOwner,
  child: Scaffold(
    // Employee creation interface - shop owner only
  ),
)
```

### Feature-Level Permissions
```dart
// Shop owner exclusive features
- Employee creation and management
- Performance dashboard access
- Compensation setup
- Advanced scheduling configuration
```

## Data Submission

### Employee Creation Process
```dart
final success = await employeeProvider.createEmployee(
  userId: currentUser.uid,
  displayName: _displayNameController.text,
  email: _emailController.text,
  phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
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
  location: _locationController.text.isNotEmpty ? _locationController.text : null,
  baseRatePerHour: double.parse(_hourlyRateController.text),
  performanceBonusRate: double.parse(_hourlyRateController.text) * 0.1,
  paymentTerms: 'Bi-weekly',
);
```

### Success Handling
```dart
if (success && mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Employee created successfully!')),
  );
  Navigator.pop(context); // Return to employee list
}
```

### Error Handling
```dart
catch (e) {
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
```

## Form State Management

### Controller Management
```dart
class _EmployeeCreateScreenState extends State<EmployeeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _specializationsController = TextEditingController();
  final _certificationsController = TextEditingController();
  final _locationController = TextEditingController();

  // State variables
  emp.EmployeeAvailability _availability = emp.EmployeeAvailability.fullTime;
  final List<emp.EmployeeSkill> _selectedSkills = [];
  final List<String> _selectedWorkDays = [];
  emp.TimeOfDay? _startTime;
  emp.TimeOfDay? _endTime;
  bool _canWorkRemotely = false;
  bool _isLoading = false;
}
```

### Resource Cleanup
```dart
@override
void dispose() {
  _displayNameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  _experienceController.dispose();
  _hourlyRateController.dispose();
  _specializationsController.dispose();
  _certificationsController.dispose();
  _locationController.dispose();
  super.dispose();
}
```

## Loading States

### Submit Button with Loading State
```dart
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: _isLoading ? null : _submitForm,
    child: _isLoading
        ? const CircularProgressIndicator()
        : const Text('Create Employee'),
  ),
)
```

### Form Validation States
```dart
// Disable form during submission
onPressed: _isLoading ? null : _submitForm,

// Show loading indicator
child: _isLoading
    ? const CircularProgressIndicator()
    : const Text('Create Employee'),
```

## Navigation Integration

### Successful Creation Navigation
```dart
if (success && mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Employee created successfully!')),
  );
  Navigator.pop(context); // Return to employee list
}
```

### Error State Navigation
```dart
// Stay on form for error correction
// No navigation on error - allows user to fix issues
```

## Business Logic

### Employee Data Structure
```dart
// Complete employee profile creation
Employee(
  userId: currentUser.uid,
  displayName: _displayNameController.text,
  email: _emailController.text,
  phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
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
  location: _locationController.text.isNotEmpty ? _locationController.text : null,
  baseRatePerHour: double.parse(_hourlyRateController.text),
  performanceBonusRate: double.parse(_hourlyRateController.text) * 0.1,
  paymentTerms: 'Bi-weekly',
)
```

### Data Processing
```dart
// Specialization processing
specializations: _specializationsController.text
    .split(',')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList(),

// Certification processing
certifications: _certificationsController.text
    .split(',')
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList(),
```

### Validation Logic
```dart
// Required skill validation
if (_selectedSkills.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select at least one skill')),
  );
  return;
}

// Required work days validation
if (_selectedWorkDays.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select at least one work day')),
  );
  return;
}
```

## Integration Points

### Provider Dependencies
```dart
// Required providers for employee creation
- EmployeeProvider: Core employee data management and CRUD operations
- AuthProvider: User authentication and role verification

// Usage in widget tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => EmployeeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: EmployeeCreateScreen(),
)
```

### Service Dependencies
```dart
// Firebase service integration through providers
- FirebaseService: Data persistence and real-time synchronization
- AuthService: User authentication and role management
- Employee Service: Business logic for employee operations
```

### Navigation Dependencies
```dart
// Screen navigation integration
- EmployeeListScreen: Return destination after creation
- EmployeeDetailScreen: Optional navigation to created employee
- Role-based guards: Access control for employee creation
```

## Security Considerations

### Access Control
```dart
// Shop owner exclusive access
RoleBasedRouteGuard(
  requiredRole: auth.UserRole.shopOwner,
  child: EmployeeCreateScreen(),
)

// Data validation before submission
if (!_formKey.currentState!.validate()) return;

// Authentication verification
final currentUser = authProvider.currentUser;
if (currentUser == null) {
  throw Exception('User not authenticated');
}
```

### Input Validation
```dart
// Email format validation
if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
  return 'Please enter a valid email address';
}

// Numeric validation
final years = int.tryParse(value);
if (years == null || years < 0) {
  return 'Please enter a valid number';
}

// Rate validation
final rate = double.tryParse(value);
if (rate == null || rate <= 0) {
  return 'Please enter a valid rate';
}
```

## Performance Optimization

### Form Efficiency
```dart
// SingleChildScrollView for long forms
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(children: [
    // Form sections...
  ]),
)

// Efficient rebuilds with Consumer
Consumer<EmployeeProvider>(
  builder: (context, employeeProvider, child) {
    // Only rebuilds when employee provider data changes
  },
)
```

### Memory Management
```dart
// Proper controller disposal
@override
void dispose() {
  _displayNameController.dispose();
  _emailController.dispose();
  // ... dispose all controllers
  super.dispose();
}
```

### Validation Optimization
```dart
// Immediate validation feedback
validator: (value) {
  // Synchronous validation for instant feedback
  if (value == null || value.isEmpty) {
    return 'Please enter full name';
  }
  return null;
}
```

## User Experience Features

### Progressive Disclosure
```dart
// Conditional fields based on selections
if (_canWorkRemotely) ...[
  const SizedBox(height: 16),
  _buildTextField(
    controller: _locationController,
    label: 'Work Location (optional)',
  ),
]
```

### Visual Feedback
```dart
// Skill selection with visual feedback
FilterChip(
  label: Text(_getSkillDisplayName(skill)),
  selected: isSelected,
  onSelected: (selected) {
    // Visual feedback through selection state
  },
)

// Form validation with error display
TextFormField(
  validator: (value) {
    // Real-time validation with error messages
  },
)
```

### Loading States
```dart
// Submit button with loading state
ElevatedButton(
  onPressed: _isLoading ? null : _submitForm,
  child: _isLoading
      ? const CircularProgressIndicator()
      : const Text('Create Employee'),
)
```

This comprehensive employee creation screen provides a complete onboarding workflow for new team members, with extensive form validation, skill configuration, availability settings, and role-based access control, ensuring thorough data collection and seamless integration into the tailoring shop management system.