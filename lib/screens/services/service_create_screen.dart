// Service Create Screen with Offline Support
// Form to create new tailoring services with comprehensive customization options

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/service.dart' as svc;
import '../../services/auth_service.dart' as auth;
import '../../services/firebase_storage_service.dart';
import '../../providers/service_provider.dart';
import '../../widgets/role_based_guard.dart';

class ServiceCreateScreen extends StatefulWidget {
  const ServiceCreateScreen({super.key});

  @override
  State<ServiceCreateScreen> createState() => _ServiceCreateScreenState();
}

class _ServiceCreateScreenState extends State<ServiceCreateScreen> {
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

  // Image upload state
  final List<XFile> _selectedImages = [];
  final List<String> _uploadedImageUrls = [];
  bool _isUploadingImages = false;
  double _uploadProgress = 0.0;
  String? _uploadError;

  final List<String> _features = [];
  final List<String> _requirements = [];
  final List<String> _preparationTips = [];
  final List<String> _recommendedFabrics = [];

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
          title: const Text('Create New Service'),
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

                // Service Images
                _buildSectionTitle('Service Images'),
                _buildImageSelectionSection(),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Service'),
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

  Widget _buildImageSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Images (${_selectedImages.length + _uploadedImageUrls.length}/10)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedImages.isNotEmpty || _uploadedImageUrls.isNotEmpty)
                  TextButton(
                    onPressed: _isUploadingImages ? null : _uploadSelectedImages,
                    child: _isUploadingImages
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_selectedImages.isNotEmpty ? 'Upload Images' : 'Upload Status'),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Image picker buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedImages.length >= 10 ? null : _pickImagesFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedImages.length >= 10 ? null : _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Upload progress indicator
            if (_isUploadingImages) ...[
              LinearProgressIndicator(value: _uploadProgress),
              const SizedBox(height: 8),
              Text(
                '${(_uploadProgress * 100).toStringAsFixed(1)}% uploaded',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
            ],

            // Upload error message
            if (_uploadError != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _uploadError = null),
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Selected images thumbnails
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Selected Images:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return _buildImageThumbnail(_selectedImages[index], index, false);
                  },
                ),
              ),
            ],

            // Uploaded images thumbnails
            if (_uploadedImageUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Uploaded Images:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _uploadedImageUrls.length,
                  itemBuilder: (context, index) {
                    return _buildUploadedImageThumbnail(_uploadedImageUrls[index], index);
                  },
                ),
              ),
            ],

            // Info text
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload high-quality images to showcase your service. Maximum 10 images, each under 10MB.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(XFile imageFile, int index, bool isUploaded) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imageFile.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedImageThumbnail(String imageUrl, int index) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
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

  // Image picker methods
  Future<void> _pickImagesFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Limit to maximum 10 images per service
        if (_selectedImages.length + images.length > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 10 images allowed per service')),
            );
          }
          return;
        }

        setState(() {
          _selectedImages.addAll(images);
          _uploadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting images: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        // Check if we've reached the limit
        if (_selectedImages.length >= 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 10 images allowed per service')),
            );
          }
          return;
        }

        setState(() {
          _selectedImages.add(image);
          _uploadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadSelectedImages() async {
    if (_selectedImages.isEmpty) return;

    debugPrint('_uploadSelectedImages called with ${_selectedImages.length} images');
    final serviceId = 'service_${DateTime.now().millisecondsSinceEpoch}';
    final firebaseStorageService = FirebaseStorageService();

    setState(() {
      _isUploadingImages = true;
      _uploadProgress = 0.0;
      _uploadError = null;
      _uploadedImageUrls.clear();
    });

    try {
      debugPrint('_uploadSelectedImages: calling uploadMultipleImages');
      final uploadedUrls = await firebaseStorageService.uploadMultipleImages(
        _selectedImages,
        folder: 'services',
        serviceId: serviceId,
        onProgress: (progress) {
          debugPrint('_uploadSelectedImages: progress $progress');
          setState(() => _uploadProgress = progress);
        },
        onImageComplete: (completed, total) {
          debugPrint('Uploaded $completed of $total images');
        },
      );

      debugPrint('_uploadSelectedImages: uploaded ${uploadedUrls.length} urls: $uploadedUrls');
      setState(() {
        _uploadedImageUrls.addAll(uploadedUrls);
        _selectedImages.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully uploaded ${uploadedUrls.length} images')),
        );
      }
    } catch (e) {
      debugPrint('_uploadSelectedImages: error $e');
      setState(() => _uploadError = e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading images: $e')),
        );
      }
    } finally {
      setState(() => _isUploadingImages = false);
    }
  }

  void _submitForm() async {
    debugPrint('_submitForm called');
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

    // Handle image uploads if there are selected images
    if (_selectedImages.isNotEmpty) {
      debugPrint('_submitForm: handling uploads, ${_selectedImages.length} images');
      try {
        await _uploadSelectedImages();

        // If upload failed, don't proceed
        if (_uploadError != null) {
          debugPrint('_submitForm: upload error: $_uploadError');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload images before creating the service')),
          );
          return;
        }
      } catch (e) {
        debugPrint('_submitForm: upload exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload images: $e')),
        );
        return;
      }
    } else {
      debugPrint('_submitForm: no images to upload');
    }

    debugPrint('_submitForm: image handling done, urls: $_uploadedImageUrls');
    setState(() => _isLoading = true);

    try {
      debugPrint('_submitForm: creating service object');
      final service = svc.Service(
          id: 'service_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text,
          description: _descriptionController.text,
          shortDescription: _shortDescriptionController.text,
          category: _selectedCategory,
          type: _selectedType,
          duration: _selectedDuration,
          complexity: _selectedComplexity,
          basePrice: double.parse(_basePriceController.text),
          features: _features,
          requirements: _requirements,
          preparationTips: _preparationTips,
          recommendedFabrics: _recommendedFabrics,
          isActive: _isActive,
          requiresMeasurement: _requiresMeasurement,
          requiresFitting: _requiresFitting,
          estimatedHours: int.parse(_estimatedHoursController.text),
          imageUrls: _uploadedImageUrls,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

      debugPrint('_submitForm: calling serviceProvider.createService');
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final success = await serviceProvider.createService(service);
      debugPrint('_submitForm: createService result: $success');

      if (success && mounted) {
        debugPrint('_submitForm: service created successfully, navigating back');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service created successfully!')),
        );

        // Reset image upload state
        setState(() {
          _selectedImages.clear();
          _uploadedImageUrls.clear();
          _uploadProgress = 0.0;
          _uploadError = null;
        });

        Navigator.pop(context);
      } else {
        debugPrint('_submitForm: createService failed');
        throw Exception('Failed to create service');
      }
    } catch (e) {
      debugPrint('_submitForm: error creating service: $e');
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