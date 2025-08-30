// Service Detail Screen with Offline Support
// Shows comprehensive service information with analytics and management

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../services/auth_service.dart' as auth;
import '../../providers/service_provider.dart';
import '../../widgets/role_based_guard.dart';

class ServiceDetailScreen extends StatefulWidget {
  final Service service;

  const ServiceDetailScreen({required this.service, super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late Service _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _loadServiceDetails();
  }

  Future<void> _loadServiceDetails() async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final updatedService = await serviceProvider.getServiceById(_service.id);
    if (updatedService != null && mounted) {
      setState(() {
        _service = updatedService;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleBasedRouteGuard(
      requiredRole: auth.UserRole.shopOwner,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_service.name),
          actions: [
            // Edit button (role-based)
            RoleBasedWidget(
              requiredRole: auth.UserRole.shopOwner,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit screen (to be implemented)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit functionality coming soon')),
                  );
                },
                tooltip: 'Edit Service',
              ),
            ),
            // Toggle active/inactive
            RoleBasedWidget(
              requiredRole: auth.UserRole.shopOwner,
              child: IconButton(
                icon: Icon(
                  _service.isActive ? Icons.visibility : Icons.visibility_off,
                  color: _service.isActive ? Colors.green : Colors.red,
                ),
                onPressed: () => _toggleServiceStatus(),
                tooltip: _service.isActive ? 'Deactivate Service' : 'Activate Service',
              ),
            ),
            // Delete button (role-based)
            RoleBasedWidget(
              requiredRole: auth.UserRole.shopOwner,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _showDeleteConfirmation(),
                tooltip: 'Delete Service',
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Header Card
              _buildServiceHeader(),

              const SizedBox(height: 24),

              // Service Overview
              _buildServiceOverview(),

              const SizedBox(height: 24),

              // Pricing Information
              _buildPricingSection(),

              const SizedBox(height: 24),

              // Service Details
              _buildServiceDetails(),

              const SizedBox(height: 24),

              // Analytics
              _buildAnalyticsSection(),

              const SizedBox(height: 24),

              // Requirements & Preparation
              _buildRequirementsSection(),

              const SizedBox(height: 24),

              // Customizations (if any)
              if (_service.customizations.isNotEmpty) ...[
                _buildCustomizationsSection(),
                const SizedBox(height: 24),
              ],

              // Similar Services
              _buildSimilarServices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Service Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getServiceColor(_service.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getServiceColor(_service.category).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    _getServiceIcon(_service.category),
                    color: _getServiceColor(_service.category),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Service Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _service.shortDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getServiceColor(_service.category).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _service.categoryName,
                              style: TextStyle(
                                color: _getServiceColor(_service.category),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _service.isActive ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _service.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: _service.isActive ? Colors.green[800] : Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Service Images
            if (_service.imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _service.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(_service.imageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Key Stats
            Row(
              children: [
                _buildStatItem(
                  Icons.access_time,
                  _service.durationText,
                  'Duration',
                  Colors.blue,
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  Icons.build,
                  _service.complexityText,
                  'Complexity',
                  Colors.orange,
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  Icons.attach_money,
                  '\$${_service.effectivePrice.toStringAsFixed(0)}',
                  'Starting Price',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Service Overview', icon: Icons.info_outline),
            const SizedBox(height: 16),
            Text(
              _service.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),

            // Service Features
            if (_service.features.isNotEmpty) ...[
              Text(
                'Key Features',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._service.features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Pricing', icon: Icons.attach_money),
            const SizedBox(height: 16),

            // Base Price
            Row(
              children: [
                Text(
                  'Starting from:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '\$${_service.effectivePrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (_service.minPrice != null && _service.maxPrice != null) ...[
              const SizedBox(height: 8),
              Text(
                'Price Range: \$${(_service.minPrice ?? 0).toStringAsFixed(2)} - \$${(_service.maxPrice ?? 0).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tier Pricing (if available)
            if (_service.tierPricing.isNotEmpty) ...[
              Text(
                'Service Tiers',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._service.tierPricing.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Add-ons
            if (_service.addOns.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Available Add-ons',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._service.addOns.asMap().entries.map((entry) {
                final addOn = entry.value;
                final price = _service.addOnPricing[addOn] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(addOn)),
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Service Details', icon: Icons.settings),
            const SizedBox(height: 16),

            // Service Type and Category
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Service Type',
                    _service.typeName,
                    Icons.category,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(
                    'Category',
                    _service.categoryName,
                    Icons.folder,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Duration and Complexity
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Duration',
                    _service.durationText,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailItem(
                    'Complexity',
                    _service.complexityText,
                    Icons.build,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Requirements
            if (_service.requiresMeasurement || _service.requiresFitting) ...[
              _buildDetailItem(
                'Requirements',
                [
                  if (_service.requiresMeasurement) 'Measurement required',
                  if (_service.requiresFitting) 'Fitting session required',
                ].join(', '),
                Icons.assignment,
              ),
              const SizedBox(height: 16),
            ],

            // Estimated Hours
            _buildDetailItem(
              'Estimated Time',
              '${_service.estimatedHours} hours',
              Icons.access_time,
            ),

            const SizedBox(height: 16),

            // Recommended Fabrics
            if (_service.recommendedFabrics.isNotEmpty) ...[
              _buildDetailItem(
                'Recommended Fabrics',
                _service.recommendedFabrics.join(', '),
                Icons.texture,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Analytics', icon: Icons.analytics),
            const SizedBox(height: 16),

            // Key Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Bookings',
                    _service.totalBookings.toString(),
                    Icons.book_online,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Avg Rating',
                    _service.averageRating.toStringAsFixed(1),
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Popularity',
                    _service.popularityScore.toString(),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Revenue',
                    '\$${(_service.effectivePrice * _service.totalBookings).toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Popularity Indicators
            if (_service.isPopular || _service.isHighlyRated || _service.isBestseller) ...[
              Text(
                'Service Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (_service.isPopular)
                    _buildStatusChip('Popular', Colors.blue),
                  if (_service.isHighlyRated)
                    _buildStatusChip('Highly Rated', Colors.amber),
                  if (_service.isBestseller)
                    _buildStatusChip('Bestseller', Colors.green),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRequirementsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Requirements & Preparation', icon: Icons.assignment),
            const SizedBox(height: 16),

            // Requirements
            if (_service.requirements.isNotEmpty) ...[
              Text(
                'Requirements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._service.requirements.map((requirement) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_box, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(requirement)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Preparation Tips
            if (_service.preparationTips.isNotEmpty) ...[
              Text(
                'Preparation Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._service.preparationTips.map((tip) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Customization Options', icon: Icons.tune),
            const SizedBox(height: 16),

            ..._service.customizations.map((customization) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customization.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (customization.isRequired) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Required',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customization.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (customization.additionalPrice > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Additional Cost: \$${customization.additionalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSimilarServices() {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final similarServices = serviceProvider.getRecommendedServices(
      forServiceId: _service.id,
      category: _service.category,
    ).take(3).toList();

    if (similarServices.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Similar Services', icon: Icons.recommend),
            const SizedBox(height: 16),

            ...similarServices.map((service) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
        color: _getServiceColor(service.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getServiceIcon(service.category),
                        color: _getServiceColor(service.category),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$${service.effectivePrice.toStringAsFixed(0)} - ${service.durationText}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailScreen(service: service),
                          ),
                        );
                      },
                      child: const Text('View'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getServiceColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.sareeServices:
        return Colors.pink;
      case ServiceCategory.garmentServices:
        return Colors.blue;
      case ServiceCategory.alterationServices:
        return Colors.green;
      case ServiceCategory.customDesign:
        return Colors.purple;
      case ServiceCategory.consultation:
        return Colors.orange;
      case ServiceCategory.measurements:
        return Colors.teal;
      case ServiceCategory.specialOccasion:
        return Colors.red;
      case ServiceCategory.corporateWear:
        return Colors.indigo;
      case ServiceCategory.uniformServices:
        return Colors.brown;
      case ServiceCategory.bridalServices:
        return Colors.deepPurple;
    }
  }

  IconData _getServiceIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.sareeServices:
        return Icons.woman;
      case ServiceCategory.garmentServices:
        return Icons.checkroom;
      case ServiceCategory.alterationServices:
        return Icons.content_cut;
      case ServiceCategory.customDesign:
        return Icons.design_services;
      case ServiceCategory.consultation:
        return Icons.chat;
      case ServiceCategory.measurements:
        return Icons.straighten;
      case ServiceCategory.specialOccasion:
        return Icons.celebration;
      case ServiceCategory.corporateWear:
        return Icons.business;
      case ServiceCategory.uniformServices:
        return Icons.school;
      case ServiceCategory.bridalServices:
        return Icons.diamond;
    }
  }

  void _toggleServiceStatus() async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final newStatus = !_service.isActive;

    final success = await serviceProvider.updateService(
      _service.id,
      {'isActive': newStatus},
    );

    if (success && mounted) {
      setState(() {
        _service = _service.copyWith(isActive: newStatus);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Service ${newStatus ? 'activated' : 'deactivated'} successfully',
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text(
          'Are you sure you want to delete "${_service.name}"? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteService(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteService() async {
    Navigator.pop(context); // Close dialog

    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleting service...')),
    );

    try {
      final success = await serviceProvider.deleteService(_service.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully')),
        );
        Navigator.pop(context); // Go back to list
      } else {
        throw Exception('Failed to delete service');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
