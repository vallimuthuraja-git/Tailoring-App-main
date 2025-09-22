import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_models.dart';
import '../../providers/product_provider.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;

  bool _isActive = true;
  bool _isPopular = false;
  bool _isNewArrival = false;
  bool _isOnSale = false;
  List<String> _imageUrls = [];
  List<String> _availableSizes = [];
  List<String> _availableFabrics = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.basePrice.toString() ?? '');
    _stockController = TextEditingController(
        text: widget.product?.stockCount.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.product?.categoryName ?? '');
    _brandController = TextEditingController(text: widget.product?.brand ?? '');

    if (widget.product != null) {
      _isActive = widget.product!.isActive;
      _isPopular = widget.product!.isPopular;
      _isNewArrival = widget.product!.isNewArrival;
      _isOnSale = widget.product!.isOnSale;
      _imageUrls = List.from(widget.product!.imageUrls);
      _availableSizes = List.from(widget.product!.availableSizes);
      _availableFabrics = List.from(widget.product!.availableFabrics);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text(
                'Basic Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value!) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Count',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter stock count';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Status Options
              Text(
                'Status',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),

              SwitchListTile(
                title: const Text('Popular'),
                value: _isPopular,
                onChanged: (value) => setState(() => _isPopular = value),
              ),

              SwitchListTile(
                title: const Text('New Arrival'),
                value: _isNewArrival,
                onChanged: (value) => setState(() => _isNewArrival = value),
              ),

              SwitchListTile(
                title: const Text('On Sale'),
                value: _isOnSale,
                onChanged: (value) => setState(() => _isOnSale = value),
              ),

              const SizedBox(height: 24),

              // Image URLs
              Text(
                'Image URLs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              ..._imageUrls.map((url) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: url,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final index = _imageUrls.indexOf(url);
                              _imageUrls[index] = value;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              setState(() => _imageUrls.remove(url)),
                        ),
                      ],
                    ),
                  )),

              ElevatedButton.icon(
                onPressed: () => setState(() => _imageUrls.add('')),
                icon: const Icon(Icons.add),
                label: const Text('Add Image URL'),
              ),

              const SizedBox(height: 24),

              // Available Sizes
              Text(
                'Available Sizes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                children: [
                  ..._availableSizes.map((size) => Chip(
                        label: Text(size),
                        onDeleted: () =>
                            setState(() => _availableSizes.remove(size)),
                      )),
                  ActionChip(
                    label: const Text('Add Size'),
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            const _AddItemDialog(title: 'Add Size'),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() => _availableSizes.add(result));
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Available Fabrics
              Text(
                'Available Fabrics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                children: [
                  ..._availableFabrics.map((fabric) => Chip(
                        label: Text(fabric),
                        onDeleted: () =>
                            setState(() => _availableFabrics.remove(fabric)),
                      )),
                  ActionChip(
                    label: const Text('Add Fabric'),
                    onPressed: () async {
                      final result = await showDialog<String>(
                        context: context,
                        builder: (context) =>
                            const _AddItemDialog(title: 'Add Fabric'),
                      );
                      if (result != null && result.isNotEmpty) {
                        setState(() => _availableFabrics.add(result));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      basePrice: double.parse(_priceController.text),
      originalPrice: widget.product?.originalPrice,
      discountPercentage: widget.product?.discountPercentage,
      category: ProductCategory.values.firstWhere(
        (cat) => cat.name == _categoryController.text,
        orElse: () => ProductCategory.mensWear,
      ),
      brand: _brandController.text,
      imageUrls: _imageUrls.where((url) => url.isNotEmpty).toList(),
      specifications: {},
      availableSizes: _availableSizes,
      availableFabrics: _availableFabrics,
      customizationOptions: [],
      stockCount: int.parse(_stockController.text),
      soldCount: widget.product?.soldCount ?? 0,
      rating: widget.product?.rating ??
          ProductRating(averageRating: 0, reviewCount: 0, recentReviews: []),
      isActive: _isActive,
      isPopular: _isPopular,
      isNewArrival: _isNewArrival,
      isOnSale: _isOnSale,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    if (widget.product == null) {
      productProvider.addProduct(product);
    } else {
      productProvider.updateProduct(product);
    }

    Navigator.of(context).pop();
  }
}

class _AddItemDialog extends StatefulWidget {
  final String title;

  const _AddItemDialog({required this.title});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter ${widget.title.toLowerCase()}',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
