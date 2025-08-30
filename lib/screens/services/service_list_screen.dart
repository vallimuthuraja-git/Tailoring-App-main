// Service List Screen with Offline Support
// Displays all tailoring services with filtering, search, and analytics

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../services/auth_service.dart' as auth;
import '../../providers/service_provider.dart';
import '../../widgets/role_based_guard.dart';
import 'service_detail_screen.dart';
import 'service_create_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  ServiceCategory? _selectedCategoryFilter;
  ServiceType? _selectedTypeFilter;
  bool? _activeStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    await serviceProvider.loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return RoleBasedRouteGuard(
      requiredRole: auth.UserRole.shopOwner,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Service Management'),
          toolbarHeight: kToolbarHeight + 5,
          actions: [
            // Offline sync indicator
            Consumer<ServiceProvider>(
              builder: (context, provider, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: Icon(
                      Icons.sync,
                      color: provider.isLoading ? Colors.orange : Colors.green,
                    ),
                    onPressed: provider.isLoading ? null : _loadServices,
                    tooltip: 'Sync with server',
                  ),
                );
              },
            ),
            // Add service button (role-based)
            RoleBasedWidget(
              requiredRole: auth.UserRole.shopOwner,
              child: IconButton(
                icon: const Icon(Icons.add_business),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ServiceCreateScreen(),
                    ),
                  );
                },
                tooltip: 'Add Service',
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Section
            _buildSearchAndFilters(),

            // Service Stats Overview
            _buildStatsOverview(),

            // Service List
            Expanded(
              child: Consumer<ServiceProvider>(
                builder: (context, serviceProvider, child) {
                  if (serviceProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (serviceProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading services',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            serviceProvider.errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadServices,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final services = serviceProvider.services;

                  if (services.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business_center, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No services found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first service to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _buildServiceCard(service);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: RoleBasedWidget(
          requiredRole: auth.UserRole.shopOwner,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceCreateScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_business),
            label: const Text('Add Service'),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onChanged: (value) {
              final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
              serviceProvider.searchServices(value);
            },
          ),
          const SizedBox(height: 12),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category Filter
                _buildFilterChip(
                  label: 'Category',
                  value: _selectedCategoryFilter?.name ?? 'All',
                  onTap: () => _showCategoryFilterDialog(),
                ),
                const SizedBox(width: 8),

                // Type Filter
                _buildFilterChip(
                  label: 'Type',
                  value: _selectedTypeFilter?.name ?? 'All',
                  onTap: () => _showTypeFilterDialog(),
                ),
                const SizedBox(width: 8),

                // Status Filter
                _buildFilterChip(
                  label: 'Status',
                  value: _activeStatusFilter == null ? 'All' :
                         _activeStatusFilter! ? 'Active' : 'Inactive',
                  onTap: () => _showStatusFilterDialog(),
                ),

                const SizedBox(width: 8),

                // Clear Filters
                ActionChip(
                  label: const Text('Clear'),
                  onPressed: _clearFilters,
                  avatar: const Icon(Icons.clear, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildStatChip(
                '${serviceProvider.services.length}',
                'Total Services',
                Icons.business,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                '${serviceProvider.activeServices.length}',
                'Active',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                '\$${serviceProvider.totalRevenue.toStringAsFixed(0)}',
                'Revenue',
                Icons.attach_money,
                Colors.amber,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                '${serviceProvider.totalBookings}',
                'Bookings',
                Icons.book_online,
                Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required String value, required VoidCallback onTap}) {
    return FilterChip(
      label: Text('$label: $value'),
      selected: false,
      onSelected: (_) => onTap(),
      avatar: Icon(
        label == 'Category' ? Icons.category :
        label == 'Type' ? Icons.build :
        Icons.toggle_on,
        size: 16,
      ),
    );
  }

  Widget _buildServiceCard(Service service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailScreen(service: service),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Service Icon/Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getServiceColor(service.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getServiceColor(service.category).withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      _getServiceIcon(service.category),
                      color: _getServiceColor(service.category),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Service Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          service.shortDescription,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getServiceColor(service.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                service.categoryName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getServiceColor(service.category),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: service.isActive ? Colors.green[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                service.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: service.isActive ? Colors.green[800] : Colors.red[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price and Rating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${service.effectivePrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            service.averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Service Features
              if (service.features.isNotEmpty) ...[
                Text(
                  'Key Features:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: service.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (service.features.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${service.features.length - 3} more features',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 8),

              // Service Stats
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        service.durationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(Icons.build, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        service.complexityText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (service.isPopular) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Popular',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
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

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ServiceCategory.values.map((category) {
            return ListTile(
              title: Text(category.name),
              leading: Icon(
                category == _selectedCategoryFilter ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _selectedCategoryFilter = category;
                });
                final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
                serviceProvider.filterByCategory(category);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategoryFilter = null;
              });
              final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
              serviceProvider.filterByCategory(null);
              Navigator.pop(context);
            },
            child: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }

  void _showTypeFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ServiceType.values.map((type) {
              return ListTile(
                title: Text(type.name),
                leading: Icon(
                  type == _selectedTypeFilter ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                ),
                onTap: () {
                  setState(() {
                    _selectedTypeFilter = type;
                  });
                  final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
                  serviceProvider.filterByType(type);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTypeFilter = null;
              });
              final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
              serviceProvider.filterByType(null);
              Navigator.pop(context);
            },
            child: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Icon(
                _activeStatusFilter == null ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _activeStatusFilter = null;
                });
                final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
                serviceProvider.filterByActiveStatus(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Active'),
              leading: Icon(
                _activeStatusFilter == true ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _activeStatusFilter = true;
                });
                final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
                serviceProvider.filterByActiveStatus(true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Inactive'),
              leading: Icon(
                _activeStatusFilter == false ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              ),
              onTap: () {
                setState(() {
                  _activeStatusFilter = false;
                });
                final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
                serviceProvider.filterByActiveStatus(false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryFilter = null;
      _selectedTypeFilter = null;
      _activeStatusFilter = null;
    });

    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    serviceProvider.searchServices('');
    serviceProvider.filterByCategory(null);
    serviceProvider.filterByType(null);
    serviceProvider.filterByActiveStatus(null);
  }
}