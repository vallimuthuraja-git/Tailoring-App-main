
// Service Edit Screen - Updated Version
// Reuses ServiceCreateScreen logic with pre-populated fields for editing

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart' as svc;
import '../../services/auth_service.dart' as auth;
import '../../providers/service_provider.dart';
import '../../widgets/role_based_guard.dart';

class ServiceEditScreen extends StatefulWidget {
  final svc.Service service;

  const ServiceEditScreen({required this.service, super.key});

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _estimatedHoursController = TextEditingController();
  final _featuresController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _preparationTipsController = TextEditingController();
  final _fabricsController = TextEditingController();

  svc.ServiceCategory _selectedCategory = svc.ServiceCategory.sareeServices;
  svc.ServiceType _selectedType = svc.ServiceType.sareeDraping;
  svc.ServiceDuration _selectedDuration = svc.ServiceDuration.standard;
  svc.ServiceComplexity _selectedComplexity = svc.ServiceComplexity.moderate;

  bool _requiresMeasurement = false;
  bool _requiresFitting = false;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _features = [];
  final List<String> _requirements = [];
  final List<String> _preparationTips = [];
  final List<String> _recommendedFabrics = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Pre-populate all fields from the existing service
    _nameController.text = widget.service.name;
    _descriptionController.text = widget.service.description;
    _shortDescriptionController.text = widget.service.shortDescription;
    _basePriceController.text = widget.service.basePrice.toStringAsFixed(2);
    _estimatedHoursController.text = widget.service.estimatedHours.toString();

    _selectedCategory = widget.service.category;
    _selectedType = widget.service.type;
    _selectedDuration = widget.service.duration;
    _selectedComplexity = widget.service.complexity;

    _requiresMeasurement = widget.service.requiresMeasurement;
    _requiresFitting = widget.service.requiresFitting;
    _isActive = widget.service.isActive;

    _features.addAll(widget.service.features);
    _requirements.addAll(widget.service.requirements);
    _preparationTips.addAll(widget.service.preparationTips);
    _recommendedFabrics.addAll(widget.service.recommendedFabrics);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _basePriceController.dispose();
    _estimatedHoursController.dispose();
    _featuresController.dispose();
    _requirementsController.dispose();
    _preparationTipsController.dispose();
    _fabricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoleBasedRouteGuard(
      requiredRole: auth.UserRole.shopOwner,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Service'),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                _buildSectionTitle('Basic Information'),
                _buildTextField(
                  controller: _nameController,
                  label: 'Service Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _shortDescriptionController,
                  label: 'Short Description',
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a short description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Detailed Description',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a detailed description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Service Classification
                _buildSectionTitle('Service Classification'),
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                _buildTypeDropdown(),
                const SizedBox(height: 16),
                _buildDurationDropdown(),
                const SizedBox(height: 16),
                _buildComplexityDropdown(),

                const SizedBox(height: 32),

                // Pricing
                _buildSectionTitle('Pricing'),
                _buildTextField(
                  controller: _basePriceController,
                  label: 'Base Price (USD)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter base price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _estimatedHoursController,
                  label: 'Estimated Hours',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter estimated hours';
                    }
                    final hours = int.tryParse(value);
                    if (hours == null || hours <= 0) {
                      return 'Please enter valid hours';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Requirements
                _buildSectionTitle('Service Requirements'),
                SwitchListTile(
                  title: const Text('Requires Measurement'),
                  value: _requiresMeasurement,
                  onChanged: (value) => setState(() => _requiresMeasurement = value),
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Requires Fitting'),
                  value: _requiresFitting,
                  onChanged: (value) => setState(() => _requiresFitting = value),
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Service is Active'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 32),

                // Features
                _buildSectionTitle('Features'),
                _buildDynamicListSection(
                  title: 'Service Features',
                  items: _features,
                  controller: _featuresController,
                  hintText: 'Enter a feature (e.g., Professional draping technique)',
                ),

                const SizedBox(height: 32),

                // Requirements List
                _buildSectionTitle('Requirements & Preparation'),
                _buildDynamicListSection(
                  title: 'Requirements',
                  items: _requirements,
                  controller: _requirementsController,
                  hintText: 'Enter a requirement (e.g., Clean saree in good condition)',
                ),
                const SizedBox(height: 16),
                _buildDynamicListSection(
                  title: 'Preparation Tips',
                  items: _preparationTips,
                  controller: _preparationTipsController,
                  hintText: 'Enter a preparation tip (e.g., Dry clean saree before service)',
                ),

                const SizedBox(height: 32),

                // Recommended Fabrics
                _buildSectionTitle('Recommended Fabrics'),
                _buildDynamicListSection(
                  title: 'Fabric Types',
                  items: _recommendedFabrics,
                  controller: _fabricsController,
                  hintText: 'Enter fabric type (e.g., Silk, Cotton, Georgette)',
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
                        : const Text('Update Service'),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

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

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<svc.ServiceCategory>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Service Category',
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: svc.ServiceCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<svc.ServiceType>(
      initialValue: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Service Type',
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: svc.ServiceType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedType = value);
        }
      },
    );
  }

  Widget _buildDurationDropdown() {
    return DropdownButtonFormField<svc.ServiceDuration>(
      initialValue: _selectedDuration,
      decoration: const InputDecoration(
        labelText: 'Service Duration',
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: svc.ServiceDuration.values.map((duration) {
        return DropdownMenuItem(
          value: duration,
          child: Text(duration.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedDuration = value);
        }
      },
    );
  }

  Widget _buildComplexityDropdown() {
    return DropdownButtonFormField<svc.ServiceComplexity>(
      initialValue: _selectedComplexity,
      decoration: const InputDecoration(
        labelText: 'Service Complexity',
        border: OutlineInputBorder(),
        filled: true,
      ),
      items: svc.ServiceComplexity.values.map((complexity) {
        return DropdownMenuItem(
          value: complexity,
          child: Text(complexity.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedComplexity = value);
        }
      },
    );
  }

  Widget _buildDynamicListSection({
    required String title,
    required List<String> items,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Add new item
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _addItem(items, controller),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addItem(items, controller),
                  child: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // List of items
            if (items.isNotEmpty) ...[
              const Text(
                'Added Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => items.removeAt(index)),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _addItem(List<String> items, TextEditingController controller) {
    final value = controller.text.trim();
    if (value.isNotEmpty && !items.contains(value)) {
      setState(() {
        items.add(value);
        controller.clear();
      });
    }
  }

  void _submitForm() async {
    debugPrint('_submitForm called for service ${widget.service.id}');
    if (!_formKey.currentState!.validate()) {
      debugPrint('_submitForm: validation failed');
      return;
    }

    if (_features.isEmpty) {
      debugPrint('_submitForm: no features, showing snackbar');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one feature')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('_submitForm: preparing updates');
      final updates = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'shortDescription': _shortDescriptionController.text,
        'category': _selectedCategory.index,
        'type': _selectedType.index,
        'duration': _selectedDuration.index,
        'complexity': _selectedComplexity.index,
        'basePrice': double.parse(_basePriceController.text),
        'estimatedHours': int.parse(_estimatedHoursController.text),
        'features': _features,
        'requirements': _requirements,
        'preparationTips': _preparationTips,
        'recommendedFabrics': _recommendedFabrics,
        'isActive': _isActive,
        'requiresMeasurement': _requiresMeasurement,
        'requiresFitting': _requiresFitting,
      };

      debugPrint('_submitForm: updates: $updates');
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final success = await serviceProvider.updateService(widget.service.id, updates);
      debugPrint('_submitForm: updateService result: $success');

      if (success && mounted) {
        debugPrint('_submitForm: service updated successfully, navigating back');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        debugPrint('_submitForm: updateService failed');
        throw Exception('Failed to update service');
      }
    } catch (e) {
      debugPrint('_submitForm: error updating service: $e');
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
}
