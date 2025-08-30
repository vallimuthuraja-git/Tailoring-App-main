import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../services/image_upload_service.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product; // null for new product, existing product for edit

  const ProductEditScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  bool _isActive = true;
  ProductCategory _selectedCategory = ProductCategory.mensWear;
  List<String> _availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  List<String> _availableFabrics = ['Cotton', 'Silk', 'Wool', 'Polyester'];
  Map<String, String> _specifications = {};
  List<String> _customizationOptions = [];
  List<String> _imageUrls = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.basePrice.toString() ?? '');

    if (widget.product != null) {
      _isActive = widget.product!.isActive;
      _selectedCategory = widget.product!.category;
      _availableSizes = List.from(widget.product!.availableSizes);
      _availableFabrics = List.from(widget.product!.availableFabrics);
      _specifications = Map.from(widget.product!.specifications);
      _customizationOptions = List.from(widget.product!.customizationOptions);
      _imageUrls = List.from(widget.product!.imageUrls);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        backgroundColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child: Text(
              'Save',
              style: TextStyle(
                color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information', themeProvider),
              const SizedBox(height: 16),
              _buildNameField(themeProvider),
              const SizedBox(height: 16),
              _buildDescriptionField(themeProvider),
              const SizedBox(height: 16),
              _buildPriceField(themeProvider),
              const SizedBox(height: 16),
              _buildCategoryDropdown(themeProvider),
              const SizedBox(height: 16),
              _buildActiveSwitch(themeProvider),

              const SizedBox(height: 32),

              // Images Section
              _buildSectionHeader('Product Images', themeProvider),
              const SizedBox(height: 16),
              _buildImageGrid(themeProvider),

              const SizedBox(height: 32),

              // Specifications Section
              _buildSectionHeader('Specifications', themeProvider),
              const SizedBox(height: 16),
              _buildSpecificationsList(themeProvider),

              const SizedBox(height: 32),

              // Sizes Section
              _buildSectionHeader('Available Sizes', themeProvider),
              const SizedBox(height: 16),
              _buildSizesList(themeProvider),

              const SizedBox(height: 32),

              // Fabrics Section
              _buildSectionHeader('Available Fabrics', themeProvider),
              const SizedBox(height: 16),
              _buildFabricsList(themeProvider),

              const SizedBox(height: 32),

              // Customization Options Section
              _buildSectionHeader('Customization Options', themeProvider),
              const SizedBox(height: 16),
              _buildCustomizationList(themeProvider),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeProvider themeProvider) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
      ),
    );
  }

  Widget _buildNameField(ThemeProvider themeProvider) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Product Name',
        hintText: 'Enter product name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
        labelStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a product name';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(ThemeProvider themeProvider) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Enter product description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
        labelStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a product description';
        }
        return null;
      },
    );
  }

  Widget _buildPriceField(ThemeProvider themeProvider) {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Base Price (₹)',
        hintText: 'Enter price',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
        labelStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a price';
        }
        final price = double.tryParse(value);
        if (price == null || price <= 0) {
          return 'Please enter a valid price';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown(ThemeProvider themeProvider) {
    return DropdownButtonFormField<ProductCategory>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
        labelStyle: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
      ),
      items: ProductCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(_getCategoryDisplayName(category)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedCategory = value);
        }
      },
    );
  }

  Widget _buildActiveSwitch(ThemeProvider themeProvider) {
    return SwitchListTile(
      title: Text(
        'Active Product',
        style: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        'Make this product visible to customers',
        style: TextStyle(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
        ),
      ),
      value: _isActive,
      onChanged: (value) => setState(() => _isActive = value),
      tileColor: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.2) : AppColors.onSurface.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  Widget _buildImageGrid(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button and count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Product Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? DarkAppColors.onBackground : AppColors.onBackground,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.primary.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_imageUrls.length}/5',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (_imageUrls.length < 5 && !_isLoading)
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Add Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                  foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Loading indicator
        if (_isLoading)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                    : AppColors.onSurface.withValues(alpha: 0.2),
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text(
                  'Uploading image...',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
        else if (_imageUrls.isEmpty)
          // Empty state
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                    : AppColors.onSurface.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: _imageUrls.length < 5 ? _pickImage : null,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                        : AppColors.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add product images',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                          : AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Up to 5 images • Max 10MB each',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                          : AppColors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Image grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _imageUrls.length < 5 ? _imageUrls.length + 1 : _imageUrls.length,
            itemBuilder: (context, index) {
              // Add button for additional images
              if (index == _imageUrls.length && _imageUrls.length < 5) {
                return InkWell(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.surface
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                            : AppColors.onSurface.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 32,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add More',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.primary
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Regular image
              final imageUrl = _imageUrls[index];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                            : AppColors.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.surface
                                : AppColors.background,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stack) {
                          return Container(
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.surface
                                : AppColors.background,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 24,
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                                      : AppColors.onSurface.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Failed to load',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: themeProvider.isDarkMode
                                        ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                                        : AppColors.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Main',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ),
                ],
              );
            },
          ),

        const SizedBox(height: 8),

        // Helper text
        if (_imageUrls.isNotEmpty)
          Text(
            'Tip: First image will be the main product image',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecificationsList(ThemeProvider themeProvider) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addSpecification,
              icon: const Icon(Icons.add),
              label: const Text('Add Specification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.secondary : AppColors.secondary,
                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onSecondary : AppColors.onSecondary,
              ),
            ),
          ],
        ),
        if (_specifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          ..._specifications.entries.map((entry) {
            final index = _specifications.keys.toList().indexOf(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${entry.key}:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface : AppColors.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? DarkAppColors.onSurface.withValues(alpha: 0.7) : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeSpecification(index),
                    icon: Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSizesList(ThemeProvider themeProvider) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addSize,
              icon: const Icon(Icons.add),
              label: const Text('Add Size'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onPrimary : AppColors.onPrimary,
              ),
            ),
          ],
        ),
        if (_availableSizes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _availableSizes.map((size) {
              final index = _availableSizes.indexOf(size);
              return Chip(
                label: Text(size),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeSize(index),
                backgroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: themeProvider.isDarkMode ? DarkAppColors.primary : AppColors.primary,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildFabricsList(ThemeProvider themeProvider) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addFabric,
              icon: const Icon(Icons.add),
              label: const Text('Add Fabric'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? DarkAppColors.secondary : AppColors.secondary,
                foregroundColor: themeProvider.isDarkMode ? DarkAppColors.onSecondary : AppColors.onSecondary,
              ),
            ),
          ],
        ),
        if (_availableFabrics.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _availableFabrics.map((fabric) {
              final index = _availableFabrics.indexOf(fabric);
              return Chip(
                label: Text(fabric),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeFabric(index),
                backgroundColor: themeProvider.isDarkMode
                    ? DarkAppColors.secondary.withValues(alpha: 0.2)
                    : AppColors.secondary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: themeProvider.isDarkMode ? DarkAppColors.secondary : AppColors.secondary,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomizationList(ThemeProvider themeProvider) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addCustomization,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.isDarkMode ? Colors.purple.shade700 : Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (_customizationOptions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _customizationOptions.map((option) {
              final index = _customizationOptions.indexOf(option);
              return Chip(
                label: Text(option),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeCustomization(index),
                backgroundColor: themeProvider.isDarkMode
                    ? Colors.purple.shade900.withValues(alpha: 0.3)
                    : Colors.purple.shade50,
                labelStyle: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.purple.shade300 : Colors.purple.shade700,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _pickImage() async {
    await _showImageSourceDialog();
  }

  Future<void> _pickMultipleImages() async {
    try {
      setState(() => _isLoading = true);

      final images = await ImageUploadService.pickMultipleImages(maxImages: 5 - _imageUrls.length);
      if (images != null && images.isNotEmpty) {
        final uploadedUrls = await ImageUploadService.uploadMultipleImages(images);

        setState(() {
          _imageUrls.addAll(uploadedUrls);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully uploaded ${uploadedUrls.length} image(s)!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading images: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product Images'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                if (mounted) {
                  Navigator.of(context).pop();
                }
                await _pickImageFromSource(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose Multiple Images'),
              subtitle: Text('Add up to ${5 - _imageUrls.length} more images'),
              enabled: _imageUrls.length < 5,
              onTap: () async {
                Navigator.of(context).pop();
                await _pickMultipleImages();
              },
            ),
            if (_imageUrls.length < 5) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImageFromSource(ImageSource.camera);
                },
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      final image = await ImageUploadService.pickImage(source: source);
      if (image != null) {
        // Validate image before upload
        final validationError = await ImageUploadService.validateImage(image);
        if (validationError != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(validationError)),
            );
          }
          return;
        }

        // Upload image
        final imageUrl = await ImageUploadService.uploadImage(image);
        if (imageUrl != null) {
          setState(() {
            _imageUrls.add(imageUrl);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image. Please try again.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _addSpecification() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Specification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Property (e.g., Material)',
                hintText: 'Enter property name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value (e.g., 100% Cotton)',
                hintText: 'Enter property value',
              ),
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
              if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                setState(() {
                  _specifications[keyController.text] = valueController.text;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSpecification(int index) {
    final key = _specifications.keys.elementAt(index);
    setState(() {
      _specifications.remove(key);
    });
  }

  void _addSize() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Size'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Size (e.g., XL)',
            hintText: 'Enter size',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _availableSizes.add(controller.text.toUpperCase());
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSize(int index) {
    setState(() {
      _availableSizes.removeAt(index);
    });
  }

  void _addFabric() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fabric'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Fabric (e.g., Silk)',
            hintText: 'Enter fabric type',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _availableFabrics.add(controller.text);
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeFabric(int index) {
    setState(() {
      _availableFabrics.removeAt(index);
    });
  }

  void _addCustomization() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Customization Option'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Option (e.g., Custom Fit)',
            hintText: 'Enter customization option',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _customizationOptions.add(controller.text);
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeCustomization(int index) {
    setState(() {
      _customizationOptions.removeAt(index);
    });
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        basePrice: double.parse(_priceController.text),
        category: _selectedCategory,
        availableSizes: _availableSizes,
        availableFabrics: _availableFabrics,
        specifications: _specifications,
        customizationOptions: _customizationOptions,
        imageUrls: _imageUrls.isEmpty
            ? ['https://via.placeholder.com/300x300?text=No+Image']
            : _imageUrls,
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.product == null) {
        // Add new product
        await productProvider.addProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
        }
      } else {
        // Update existing product
        await productProvider.updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        }
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getCategoryDisplayName(ProductCategory category) {
    switch (category) {
      case ProductCategory.mensWear:
        return 'Men\'s Wear';
      case ProductCategory.womensWear:
        return 'Women\'s Wear';
      case ProductCategory.kidsWear:
        return 'Kids Wear';
      case ProductCategory.formalWear:
        return 'Formal Wear';
      case ProductCategory.casualWear:
        return 'Casual Wear';
      case ProductCategory.traditionalWear:
        return 'Traditional Wear';
      case ProductCategory.alterations:
        return 'Alterations';
      case ProductCategory.customDesign:
        return 'Custom Design';
    }
  }
}
