# Employee Edit Screen Documentation

## Overview
The `employee_edit_screen.dart` file contains the comprehensive employee profile editing interface for the AI-Enabled Tailoring Shop Management System. It provides a complete form-based workflow for updating employee information, skills, work schedule, compensation, and status with extensive validation and dynamic content management.

## Architecture

### Core Components
- **`EmployeeEditScreen`**: Main employee editing interface with pre-populated data
- **Dynamic Form Management**: Real-time form state updates with validation
- **Skills Selection System**: Interactive skill management with filter chips
- **Specialization Management**: Dynamic addition/removal of employee specializations
- **Certification Handling**: Dynamic certification management system
- **Work Schedule Configuration**: Comprehensive availability and work preference settings
- **Compensation Management**: Base rate and bonus configuration
- **Status Control**: Employee active/inactive status toggle

### Key Features
- **Pre-populated Data**: All existing employee information loaded for editing
- **Real-time Validation**: Immediate feedback on form inputs with comprehensive validation
- **Dynamic Content**: Add/remove specializations and certifications on-the-fly
- **Skills Management**: Visual skill selection with filter chips
- **Schedule Configuration**: Flexible work availability and preference settings
- **Compensation Control**: Base rate and performance bonus management
- **Status Management**: Employee activation/deactivation control
- **Role-Based Access**: Shop owner exclusive editing permissions
- **Form Persistence**: Maintains state during validation errors

## State Management

### Controller Initialization
```dart
class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _experienceController;
  late final TextEditingController _baseRateController;
  late final TextEditingController _bonusRateController;
  late final TextEditingController _locationController;

  late List<EmployeeSkill> _selectedSkills;
  late List<String> _specializations;
  late List<String> _certifications;
  late List<String> _workDays;
  late EmployeeAvailability _availability;
  late bool _canWorkRemotely;
  late bool _isActive;

  bool _isLoading = false;
}
```

### Data Pre-population
```dart
void _initializeControllers() {
  // Text field controllers with existing data
  _displayNameController = TextEditingController(text: widget.employee.displayName);
  _emailController = TextEditingController(text: widget.employee.email);
  _phoneController = TextEditingController(text: widget.employee.phoneNumber ?? '');
  _experienceController = TextEditingController(text: widget.employee.experienceYears.toString());
  _baseRateController = TextEditingController(text: widget.employee.baseRatePerHour.toString());
  _bonusRateController = TextEditingController(text: widget.employee.performanceBonusRate.toString());
  _locationController = TextEditingController(text: widget.employee.location ?? '');

  // List data cloning for independent state management
  _selectedSkills = List.from(widget.employee.skills);
  _specializations = List.from(widget.employee.specializations);
  _certifications = List.from(widget.employee.certifications);
  _workDays = List.from(widget.employee.preferredWorkDays);

  // Primitive data assignment
  _availability = widget.employee.availability;
  _canWorkRemotely = widget.employee.canWorkRemotely;
  _isActive = widget.employee.isActive;
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
  _baseRateController.dispose();
  _bonusRateController.dispose();
  _locationController.dispose();
  super.dispose();
}
```

## Form Sections

### Basic Information Section
```dart
Widget _buildBasicInfoSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Full Name (Required)
        TextFormField(
          controller: _displayNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
          ),
        ),

        // Email (Required)
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        // Phone Number (Optional)
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),

        // Location (Optional)
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
          ),
        ),

        // Years of Experience (Required)
        TextFormField(
          controller: _experienceController,
          decoration: const InputDecoration(
            labelText: 'Years of Experience *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ]),
    ),
  );
}
```

### Skills and Expertise Section
```dart
Widget _buildSkillsSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills Selection (Required)
          Text('Skills *', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EmployeeSkill.values.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill.name),
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

          // Specializations Management
          const SizedBox(height: 20),
          Text('Specializations', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          Wrap(
            spacing: 8,
            children: [
              ..._specializations.map((spec) => Chip(
                label: Text(spec),
                onDeleted: () {
                  setState(() => _specializations.remove(spec));
                },
              )),
              ActionChip(
                label: const Text('+ Add Specialization'),
                onPressed: _addSpecialization,
              ),
            ],
          ),

          // Certifications Management
          const SizedBox(height: 20),
          Text('Certifications', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          Wrap(
            spacing: 8,
            children: [
              ..._certifications.map((cert) => Chip(
                label: Text(cert),
                onDeleted: () {
                  setState(() => _certifications.remove(cert));
                },
              )),
              ActionChip(
                label: const Text('+ Add Certification'),
                onPressed: _addCertification,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

### Work Schedule Section
```dart
Widget _buildScheduleSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Dropdown (Required)
          Text('Availability *', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          DropdownButtonFormField<EmployeeAvailability>(
            initialValue: _availability,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: EmployeeAvailability.values.map((availability) {
              return DropdownMenuItem(
                value: availability,
                child: Text(availability.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _availability = value);
              }
            },
          ),

          // Work Days Selection (Required)
          const SizedBox(height: 20),
          Text('Preferred Work Days *', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )),
          Wrap(
            spacing: 8,
            children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                .map((day) {
              final isSelected = _workDays.contains(day);
              return FilterChip(
                label: Text(day.substring(0, 3)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _workDays.add(day);
                    } else {
                      _workDays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),

          // Remote Work Toggle
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Can Work Remotely'),
            value: _canWorkRemotely,
            onChanged: (value) => setState(() => _canWorkRemotely = value),
            tileColor: Colors.grey[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ],
      ),
    ),
  );
}
```

### Compensation Section
```dart
Widget _buildCompensationSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Base Hourly Rate
        TextFormField(
          controller: _baseRateController,
          decoration: const InputDecoration(
            labelText: 'Base Rate per Hour (USD)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),

        // Performance Bonus Rate
        const SizedBox(height: 16),
        TextFormField(
          controller: _bonusRateController,
          decoration: const InputDecoration(
            labelText: 'Performance Bonus Rate (USD)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ]),
    ),
  );
}
```

### Status Section
```dart
Widget _buildStatusSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: SwitchListTile(
        title: const Text('Active Employee'),
        subtitle: const Text('Employee can receive work assignments'),
        value: _isActive,
        onChanged: (value) => setState(() => _isActive = value),
        tileColor: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
```

## Dynamic Content Management

### Specialization Addition Dialog
```dart
void _addSpecialization() {
  showDialog(
    context: context,
    builder: (context) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text('Add Specialization'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Saree Draping, Alterations',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _specializations.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
```

### Certification Addition Dialog
```dart
void _addCertification() {
  showDialog(
    context: context,
    builder: (context) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text('Add Certification'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g., Advanced Tailoring Certificate',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _certifications.add(controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
```

## Form Validation and Submission

### Pre-submission Validation
```dart
void _saveEmployee() async {
  // Required field validation
  if (_displayNameController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _experienceController.text.isEmpty ||
      _selectedSkills.isEmpty ||
      _workDays.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Form processing logic
    await _processEmployeeUpdate();
  } catch (e) {
    // Error handling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### Data Processing and Update
```dart
final updates = {
  'displayName': _displayNameController.text,
  'email': _emailController.text,
  'phoneNumber': _phoneController.text.isNotEmpty ? _phoneController.text : null,
  'location': _locationController.text.isNotEmpty ? _locationController.text : null,
  'experienceYears': int.tryParse(_experienceController.text) ?? 0,
  'skills': _selectedSkills.map((skill) => skill.index).toList(),
  'specializations': _specializations,
  'certifications': _certifications,
  'availability': _availability.index,
  'preferredWorkDays': _workDays,
  'canWorkRemotely': _canWorkRemotely,
  'baseRatePerHour': double.tryParse(_baseRateController.text) ?? 0.0,
  'performanceBonusRate': double.tryParse(_bonusRateController.text) ?? 0.0,
  'isActive': _isActive,
};

final success = await employeeProvider.updateEmployee(widget.employee.id, updates);
```

### Success Handling
```dart
if (success && mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Employee updated successfully')),
  );
  Navigator.pop(context); // Return to previous screen
}
```

## User Experience Features

### Loading States
```dart
// Save button with loading state
TextButton(
  onPressed: _isLoading ? null : _saveEmployee,
  child: _isLoading
      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
      : const Text('Save', style: TextStyle(color: Colors.white)),
)
```

### Real-time Feedback
```dart
// Skill selection with immediate visual feedback
FilterChip(
  label: Text(skill.name),
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
)
```

### Dynamic Chip Management
```dart
// Removable specialization chips
Chip(
  label: Text(spec),
  onDeleted: () => setState(() => _specializations.remove(spec)),
)

// Add new item chips
ActionChip(
  label: const Text('+ Add Specialization'),
  onPressed: _addSpecialization,
)
```

## Role-Based Access Control

### Route Protection
```dart
RoleBasedRouteGuard(
  requiredRole: auth.UserRole.shopOwner,
  child: Scaffold(
    // Employee editing interface - shop owner only
  ),
)
```

### Feature-Level Permissions
```dart
// All editing features restricted to shop owners
// No conditional rendering needed as route is protected
```

## Error Handling

### Validation Messages
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Please fill all required fields')),
);
```

### Network Error Handling
```dart
try {
  final success = await employeeProvider.updateEmployee(widget.employee.id, updates);
  if (!success) {
    throw Exception('Failed to update employee');
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### Form State Preservation
```dart
// Maintains form state during validation errors
// No data loss on failed submissions
// User can correct errors and retry
```

## Business Logic

### Data Transformation
```dart
// Skills enum to index conversion for storage
'skills': _selectedSkills.map((skill) => skill.index).toList(),

// Availability enum to index conversion
'availability': _availability.index,

// String to numeric conversions with fallbacks
'experienceYears': int.tryParse(_experienceController.text) ?? 0,
'baseRatePerHour': double.tryParse(_baseRateController.text) ?? 0.0,
'performanceBonusRate': double.tryParse(_bonusRateController.text) ?? 0.0,
```

### Validation Rules
```dart
// Required field validation
if (_displayNameController.text.isEmpty ||
    _emailController.text.isEmpty ||
    _experienceController.text.isEmpty ||
    _selectedSkills.isEmpty ||
    _workDays.isEmpty) {
  // Show validation error
}

// Numeric validation with error handling
final experience = int.tryParse(_experienceController.text) ?? 0;
final baseRate = double.tryParse(_baseRateController.text) ?? 0.0;
final bonusRate = double.tryParse(_bonusRateController.text) ?? 0.0;
```

### State Management
```dart
// Independent state management for form fields
late List<EmployeeSkill> _selectedSkills;
late List<String> _specializations;
late List<String> _certifications;
late List<String> _workDays;

// Primitive state variables
late EmployeeAvailability _availability;
late bool _canWorkRemotely;
late bool _isActive;
```

## Integration Points

### Provider Dependencies
```dart
// Required Providers
- EmployeeProvider: Employee data management and update operations
- AuthProvider: User authentication and role verification

// Usage in Widget Tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => EmployeeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: EmployeeEditScreen(employee: employee),
)
```

### Service Dependencies
```dart
// Firebase Services Integration
- FirebaseService: Data persistence and real-time synchronization
- Employee Service: Business logic for employee operations
- Auth Service: User authentication and role management
```

### Navigation Dependencies
```dart
// Screen Navigation Integration
- EmployeeDetailScreen: Return destination after successful edit
- EmployeeListScreen: Alternative return destination
- WorkAssignmentScreen: Optional navigation for work assignments
```

## Security Considerations

### Input Validation
```dart
// Required field validation
if (_displayNameController.text.isEmpty ||
    _emailController.text.isEmpty ||
    _experienceController.text.isEmpty) {
  // Prevent submission with missing required data
}

// Numeric validation
final experience = int.tryParse(_experienceController.text);
if (experience == null || experience < 0) {
  // Prevent invalid numeric inputs
}
```

### Access Control
```dart
// Role-based route protection
RoleBasedRouteGuard(
  requiredRole: auth.UserRole.shopOwner,
  child: EmployeeEditScreen(employee: employee),
)

// User authorization verification
final currentUser = authProvider.currentUser;
if (currentUser == null) {
  // Handle unauthorized access
}
```

### Data Sanitization
```dart
// Text input sanitization
'displayName': _displayNameController.text.trim(),
'email': _emailController.text.trim(),
'phoneNumber': _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,

// List data sanitization
'specializations': _specializations.where((s) => s.trim().isNotEmpty).toList(),
'certifications': _certifications.where((c) => c.trim().isNotEmpty).toList(),
```

## Performance Optimization

### Efficient Rendering
```dart
// Wrap widgets for responsive chip layout
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: EmployeeSkill.values.map((skill) {
    // Efficient chip rendering
  }).toList(),
)

// SingleChildScrollView for long forms
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(children: [
    // Form sections
  ]),
)
```

### Memory Management
```dart
// Proper controller disposal
@override
void dispose() {
  _displayNameController.dispose();
  _emailController.dispose();
  // Dispose all controllers
  super.dispose();
}

// Efficient state updates
setState(() {
  // Only update necessary state variables
  _selectedSkills.add(skill);
});
```

### Validation Optimization
```dart
// Client-side validation before API calls
if (_selectedSkills.isEmpty) {
  // Immediate feedback without network request
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please select at least one skill')),
  );
  return;
}
```

## Best Practices

### User Experience
- **Progressive Disclosure**: Well-organized form sections with clear labels
- **Immediate Feedback**: Real-time validation and selection feedback
- **Dynamic Content**: Add/remove items without page refresh
- **Consistent Styling**: Theme-aware colors and component styling
- **Clear Navigation**: Intuitive save/cancel actions with loading states

### Form Design
- **Logical Grouping**: Related fields grouped in cards
- **Required Field Indicators**: Clear marking of mandatory fields
- **Input Types**: Appropriate keyboard types for different data types
- **Validation Messages**: Clear, actionable error messages
- **Progressive Enhancement**: Optional fields enhance but don't block submission

### Data Management
- **Pre-population**: Existing data loaded for seamless editing
- **Independent State**: Form state independent of original data
- **Data Transformation**: Proper conversion between UI and storage formats
- **Error Recovery**: Graceful handling of update failures

This comprehensive employee edit screen provides a complete, user-friendly interface for updating all aspects of employee profiles, with extensive validation, dynamic content management, and seamless integration with the tailoring shop management system.