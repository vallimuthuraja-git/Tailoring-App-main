import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/service_provider.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/user_avatar.dart';
import 'service_booking_wizard.dart';

class CustomerServiceDetailScreen extends StatefulWidget {
  final Service service;

  const CustomerServiceDetailScreen({
    super.key,
    required this.service,
  });

  @override
  State<CustomerServiceDetailScreen> createState() =>
      _CustomerServiceDetailScreenState();
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({
    required this.text,
    this.style,
    this.buttonStyle,
    this.maxLines = 4,
    this.expandedText = 'Read more',
    this.collapsedText = 'Show less',
  });

  final String text;
  final TextStyle? style;
  final TextStyle? buttonStyle;
  final int maxLines;
  final String expandedText;
  final String collapsedText;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.centerLeft,
          ),
          child: Text(
            _isExpanded ? widget.collapsedText : widget.expandedText,
            style: widget.buttonStyle,
          ),
        ),
      ],
    );
  }
}

class _CustomerServiceDetailScreenState
    extends State<CustomerServiceDetailScreen> with TickerProviderStateMixin {
  late PageController _imageController;
  int _currentImageIndex = 0;
  late AnimationController _fabAnimationController;

  // State management for customizations
  Map<String, dynamic> selectedCustomizations = {};
  double customizationTotalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimationController.forward();

    // Initialize customizations with defaults
    _initializeCustomizations();
  }

  @override
  void dispose() {
    _imageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _initializeCustomizations() {
    selectedCustomizations = {};
    customizationTotalPrice = 0.0;

    for (final customization in widget.service.customizations) {
      if (customization.defaultValue != null) {
        selectedCustomizations[customization.id] = customization.defaultValue;
        if (customization.affectsPricing) {
          customizationTotalPrice += customization.additionalPrice;
        }
      }
    }
    setState(() {});
  }

  void _updateCustomization(String id, dynamic value) {
    selectedCustomizations[id] = value;
    customizationTotalPrice = 0.0;

    for (final customization in widget.service.customizations) {
      final selectedValue = selectedCustomizations[customization.id];
      if (selectedValue != null && customization.affectsPricing) {
        if (customization.type == 'selection' &&
            customization.options.isNotEmpty) {
          final index = customization.options.indexOf(selectedValue);
          if (index >= 0 && index < customization.options.length) {
            double priceIncrement = customization.additionalPrice * (index + 1);
            customizationTotalPrice += priceIncrement;
          }
        } else {
          customizationTotalPrice += customization.additionalPrice;
        }
      }
    }
    setState(() {});
  }

  bool _validateCustomizations() {
    for (final customization in widget.service.customizations) {
      if (customization.isRequired &&
          selectedCustomizations[customization.id] == null) {
        return false;
      }
      // Additional validation using customization.validation rules
      final selectedValue = selectedCustomizations[customization.id];
      if (selectedValue != null && customization.validation.isNotEmpty) {
        if (customization.validation['min'] != null &&
            (selectedValue is num) &&
            selectedValue < customization.validation['min']) {
          return false;
        }
        if (customization.validation['max'] != null &&
            (selectedValue is num) &&
            selectedValue > customization.validation['max']) {
          return false;
        }
        if (customization.validation['pattern'] != null &&
            (selectedValue is String)) {
          final pattern = RegExp(customization.validation['pattern']);
          if (!pattern.hasMatch(selectedValue)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  Widget _buildCustomizationWidget(ServiceCustomization customization) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final selectedValue = selectedCustomizations[customization.id];

    switch (customization.type) {
      case 'selection':
        if (customization.options.length <= 4) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final option in customization.options)
                RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: selectedValue?.toString(),
                  onChanged: (value) {
                    _updateCustomization(customization.id, value);
                  },
                  activeColor: themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                ),
            ],
          );
        } else {
          return DropdownButtonFormField<String>(
            initialValue: selectedValue?.toString(),
            items: customization.options
                .map((option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _updateCustomization(customization.id, value);
              }
            },
            decoration: InputDecoration(
              labelText: customization.name,
              hintText: customization.description,
              border: const OutlineInputBorder(),
            ),
          );
        }
      case 'boolean':
        return CheckboxListTile(
          title: Text(customization.name),
          subtitle: Text(customization.description),
          value: selectedValue ?? false,
          onChanged: (value) {
            if (value != null) {
              _updateCustomization(customization.id, value);
            }
          },
          activeColor: themeProvider.isDarkMode
              ? DarkAppColors.primary
              : AppColors.primary,
        );
      case 'number':
        return Row(
          children: [
            IconButton(
              onPressed: () {
                final currentValue =
                    (selectedValue ?? customization.defaultValue ?? 0) as int;
                if (currentValue > (customization.validation['min'] ?? 0)) {
                  _updateCustomization(customization.id, currentValue - 1);
                }
              },
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${selectedValue ?? customization.defaultValue ?? 0}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: () {
                final currentValue =
                    (selectedValue ?? customization.defaultValue ?? 0) as int;
                if (currentValue < (customization.validation['max'] ?? 100)) {
                  _updateCustomization(customization.id, currentValue + 1);
                }
              },
              icon: const Icon(Icons.add),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(customization.description)),
          ],
        );
      case 'text':
        return TextFormField(
          initialValue: selectedValue?.toString(),
          onChanged: (value) {
            _updateCustomization(customization.id, value);
          },
          maxLines: 3,
          decoration: InputDecoration(
            labelText: customization.name,
            hintText: customization.description,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (customization.isRequired && (value?.isEmpty ?? true)) {
              return 'This field is required';
            }
            if (value != null && customization.validation['pattern'] != null) {
              final pattern = RegExp(customization.validation['pattern']);
              if (!pattern.hasMatch(value)) {
                return 'Invalid format';
              }
            }
            if (value != null &&
                customization.validation['minLength'] != null &&
                value.length < customization.validation['minLength']) {
              return 'Minimum length: ${customization.validation['minLength']}';
            }
            if (value != null &&
                customization.validation['maxLength'] != null &&
                value.length > customization.validation['maxLength']) {
              return 'Maximum length: ${customization.validation['maxLength']}';
            }
            return null;
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomizationPanel(ThemeProvider themeProvider) {
    if (widget.service.customizations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customize Your Service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.service.customizations.map((customization) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customization.name.isNotEmpty)
                      Text(
                        '${customization.name}${customization.isRequired ? '*' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (customization.description.isNotEmpty)
                      Text(
                        customization.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                              : AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildCustomizationWidget(customization),
                    if (customization.affectsPricing &&
                        customization.additionalPrice > 0)
                      Text(
                        '+${customization.additionalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                        ),
                      ),
                  ],
                ),
              )),
          if (customizationTotalPrice > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Customization Total:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${customizationTotalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
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

  void _toggleWishlist() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to manage favorites')),
      );
      return;
    }

    final success = await wishlistProvider.toggleWishlist(widget.service.id);
    if (success && mounted) {
      final isInWishlist =
          wishlistProvider.isServiceInWishlist(widget.service.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isInWishlist
              ? '${widget.service.name} added to favorites'
              : '${widget.service.name} removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _bookService() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to book services')),
      );
      return;
    }

    // Validate customizations before proceeding
    if (!_validateCustomizations()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all required customizations')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceBookingWizard(
          service: widget.service,
          selectedCustomizations: selectedCustomizations,
          customizationTotalPrice: customizationTotalPrice,
        ),
      ),
    );
  }

  Widget _buildCustomerReviewsSection(
      ThemeProvider themeProvider, ReviewProvider reviewProvider) {
    final summary = reviewProvider.getReviewSummary(widget.service.id);
    final reviews = reviewProvider.getReviewsForService(widget.service.id);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: reviewProvider.isLoading
          ? _buildReviewShimmerLoader(themeProvider)
          : reviews.isEmpty
              ? _buildEmptyReviews(themeProvider)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    const Text(
                      'Reviews & Ratings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Overall Rating Summary
                    Row(
                      children: [
                        // Rating Stars
                        Column(
                          children: [
                            Text(
                              summary?.averageRatingString ?? '0.0',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.primary
                                    : AppColors.primary,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                final rating = summary?.averageRating ?? 0.0;
                                if (index < rating.floor()) {
                                  return const Icon(Icons.star,
                                      size: 16, color: Colors.amber);
                                } else if (index < rating) {
                                  return Icon(Icons.star_half,
                                      size: 16, color: Colors.amber);
                                } else {
                                  return Icon(Icons.star_border,
                                      size: 16, color: Colors.grey[400]!);
                                }
                              }),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${reviews.length} review${reviews.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface
                                        .withValues(alpha: 0.6)
                                    : AppColors.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 24),

                        // Rating Breakdown
                        Expanded(
                          child: Column(
                            children: List.generate(5, (index) {
                              final ratingValue = 5 - index;
                              final count =
                                  summary?.ratingDistribution[ratingValue] ?? 0;
                              final total = reviews.length;
                              final percentage =
                                  total > 0 ? (count / total) * 100 : 0.0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      ratingValue.toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star,
                                        size: 10, color: Colors.amber),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor:
                                            themeProvider.isDarkMode
                                                ? DarkAppColors.onSurface
                                                    .withValues(alpha: 0.1)
                                                : AppColors.onSurface
                                                    .withValues(alpha: 0.1),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.amber),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      count.toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

                    if (reviews.isNotEmpty) ...[
                      const SizedBox(height: 24),

                      // Recent Reviews
                      Row(
                        children: [
                          const Text(
                            'Recent Reviews',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to all reviews page
                            },
                            icon: const Icon(Icons.expand_more, size: 16),
                            label: const Text('View All'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Reviews List
                      ...reviews.take(3).map((review) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.background
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                UserAvatar(
                                  displayName: review.userName.isNotEmpty
                                      ? review.userName
                                      : '?',
                                  imageUrl: null,
                                  radius: 20.0,
                                ),
                                const SizedBox(width: 12),

                                // Review Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              review.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            review.timeAgo,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: themeProvider.isDarkMode
                                                  ? DarkAppColors.onSurface
                                                      .withValues(alpha: 0.6)
                                                  : AppColors.onSurface
                                                      .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(5, (index) {
                                          return Icon(
                                            index < review.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 14,
                                            color: Colors.amber,
                                          );
                                        }),
                                      ),
                                      if (review.title.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          review.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                      if (review.comment.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          review.comment,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: themeProvider.isDarkMode
                                                ? DarkAppColors.onSurface
                                                    .withValues(alpha: 0.8)
                                                : AppColors.onSurface
                                                    .withValues(alpha: 0.8),
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }

  Widget _buildReviewShimmerLoader(ThemeProvider themeProvider) {
    final baseColor =
        themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface;

    return SizedBox(
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyReviews(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.background
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.star_border,
            size: 48,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.3)
                : AppColors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to leave a review for this service',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                  : AppColors.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShopContactInformation(ThemeProvider themeProvider) {
    // Placeholder implementation - will be updated with actual data
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.isDarkMode
                ? DarkAppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            themeProvider.isDarkMode
                ? DarkAppColors.secondary.withValues(alpha: 0.1)
                : AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.primary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: 24,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.primary
                    : AppColors.primary,
              ),
              const SizedBox(width: 12),
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone
          InkWell(
            onTap: () async {
              final Uri url =
                  Uri(scheme: 'tel', path: '+1234567890'); // Placeholder
              await launchUrl(url);
            },
            child: Row(
              children: [
                UserAvatar(
                  displayName: 'Phone',
                  imageUrl: null,
                  radius: 20.0,
                ),
                const SizedBox(width: 16),
                const Text(
                  '+1 (234) 567-8901',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Email
          InkWell(
            onTap: () async {
              final Uri url = Uri(
                  scheme: 'mailto',
                  path: 'contact@tailorapp.com'); // Placeholder
              await launchUrl(url);
            },
            child: Row(
              children: [
                UserAvatar(
                  displayName: 'Email',
                  imageUrl: null,
                  radius: 20.0,
                ),
                const SizedBox(width: 16),
                const Text(
                  'contact@tailorapp.com',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Address
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse(
                  'geo:0,0?q=123 Main St, City, Country'); // Placeholder
              await launchUrl(url);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserAvatar(
                  displayName: 'Address',
                  imageUrl: null,
                  radius: 20.0,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    '123 Main Street\nCity, State 12345\nCountry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Business Hours
          const Text(
            'Business Hours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monday - Friday: 9:00 AM - 7:00 PM',
                  style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              Text('Saturday: 8:00 AM - 5:00 PM',
                  style: TextStyle(fontSize: 14)),
              SizedBox(height: 4),
              Text('Sunday: Closed', style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationShimmerLoader(ThemeProvider themeProvider) {
    final baseColor =
        themeProvider.isDarkMode ? DarkAppColors.surface : AppColors.surface;

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
              3,
              (index) => Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    height: 180,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<ThemeProvider, WishlistProvider, ReviewProvider,
        ServiceProvider>(
      builder: (context, themeProvider, wishlistProvider, reviewProvider,
          serviceProvider, child) {
        final isInWishlist =
            wishlistProvider.isServiceInWishlist(widget.service.id);

        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? DarkAppColors.background
              : AppColors.background,

          // Image Gallery App Bar
          body: CustomScrollView(
            slivers: [
              // Hero Image with Parallax
              _buildImageGallery(themeProvider),

              // Main Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.surface
                        : AppColors.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Title and Rating
                      _buildTitleSection(themeProvider),

                      const SizedBox(height: 16),

                      // Customer Reviews & Ratings Section
                      _buildCustomerReviewsSection(
                          themeProvider, reviewProvider),

                      const SizedBox(height: 24),

                      // Key Service Stats
                      _buildServiceStats(themeProvider),

                      const SizedBox(height: 24),

                      // Pricing Section
                      _buildPricingSection(themeProvider),

                      const SizedBox(height: 24),

                      // Service Customizations
                      _buildCustomizationPanel(themeProvider),

                      const SizedBox(height: 24),

                      // Service Description
                      _buildDescriptionSection(themeProvider),

                      const SizedBox(height: 24),

                      // What's Included
                      if (widget.service.includedItems.isNotEmpty)
                        _buildIncludedItems(themeProvider),

                      const SizedBox(height: 24),

                      // Requirements
                      if (widget.service.requirements.isNotEmpty ||
                          widget.service.requiresMeasurement ||
                          widget.service.requiresFitting)
                        _buildRequirementsSection(themeProvider),

                      const SizedBox(height: 24),

                      // Add-ons Available
                      if (widget.service.addOns.isNotEmpty)
                        _buildAddOnsSection(themeProvider),

                      const SizedBox(height: 24),

                      // Shop/Contact Information Section
                      _buildShopContactInformation(themeProvider),

                      const SizedBox(height: 24),

                      // Service Recommendations Section

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Button for Booking
          floatingActionButton: _buildBookingFab(themeProvider),

          // App Bar with Favorite Button
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : Colors.black87,
                  ),
                  onPressed: _toggleWishlist,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageGallery(ThemeProvider themeProvider) {
    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: false,
      floating: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image Carousel
            widget.service.imageUrls.isNotEmpty
                ? PageView.builder(
                    controller: _imageController,
                    onPageChanged: (index) =>
                        setState(() => _currentImageIndex = index),
                    itemCount: widget.service.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: 'service-gallery-${widget.service.id}-$index',
                        child: Image.network(
                          widget.service.imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                _getServiceIcon(widget.service.category),
                                size: 80,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : Container(
                    color: _getServiceColor(widget.service.category)
                        .withValues(alpha: 0.1),
                    child: Icon(
                      _getServiceIcon(widget.service.category),
                      size: 120,
                      color: _getServiceColor(widget.service.category),
                    ),
                  ),

            // Image Indicators
            if (widget.service.imageUrls.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          widget.service.imageUrls.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: _currentImageIndex == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Service Badge Overlay
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getServiceColor(widget.service.category),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.service.categoryName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Popularity Badge (if popular)
            if (widget.service.isPopular)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Name
        Text(
          widget.service.name,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface
                : AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 4),

        // Service Location/Icon
        Row(
          children: [
            Icon(
              _getServiceIcon(widget.service.category),
              size: 20,
              color: _getServiceColor(widget.service.category),
            ),
            const SizedBox(width: 8),
            Text(
              widget.service.shortDescription,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                    : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Rating
        if (widget.service.averageRating > 0)
          Row(
            children: [
              ...List.generate(5, (index) {
                double rating = widget.service.averageRating;
                if (index < rating.floor()) {
                  return const Icon(Icons.star, size: 18, color: Colors.amber);
                } else if (index < rating) {
                  return Icon(Icons.star_half, size: 18, color: Colors.amber);
                } else {
                  return Icon(Icons.star_border,
                      size: 18, color: Colors.grey[400]!);
                }
              }),
              const SizedBox(width: 8),
              Text(
                '${widget.service.averageRating.toStringAsFixed(1)} (${widget.service.totalBookings} bookings)',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                      : AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildServiceStats(ThemeProvider themeProvider) {
    return Row(
      children: [
        _buildStatItem(
          Icons.access_time,
          widget.service.durationText,
          'Duration',
          Colors.blue,
          themeProvider,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.build,
          widget.service.complexityText,
          'Complexity',
          Colors.orange,
          themeProvider,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          Icons.schedule,
          '${widget.service.estimatedHours}h',
          'Est. Time',
          Colors.green,
          themeProvider,
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color,
      ThemeProvider themeProvider) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface.withValues(alpha: 0.8)
            : AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.1)
              : AppColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Base Price
          Row(
            children: [
              Text(
                'Starting from: ',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                      : AppColors.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const Spacer(),
              Text(
                '\$${widget.service.effectivePrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary,
                ),
              ),
            ],
          ),

          // Tier Pricing (if available)
          if (widget.service.tierPricing.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Service Tiers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.service.tierPricing.entries.map((tier) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.background
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(tier.key)),
                      Text(
                        '\$${tier.value.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 16),

          // Price Range (if available)
          if (widget.service.minPrice != null &&
              widget.service.maxPrice != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.price_check, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Price Range: \$${widget.service.minPrice!.toStringAsFixed(0)} - \$${widget.service.maxPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandableText(
    String text,
    TextStyle? style,
    TextStyle? buttonStyle, {
    int maxLines = 4,
    String expandedText = 'Read more',
    String collapsedText = 'Show less',
  }) {
    return _ExpandableText(
      text: text,
      style: style,
      buttonStyle: buttonStyle,
      maxLines: maxLines,
      expandedText: expandedText,
      collapsedText: collapsedText,
    );
  }

  Widget _buildDescriptionSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildExpandableText(
          widget.service.description,
          TextStyle(
            fontSize: 15,
            height: 1.6,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                : AppColors.onSurface.withValues(alpha: 0.8),
          ),
          TextStyle(
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode
                ? DarkAppColors.primary
                : AppColors.primary,
          ),
          maxLines: 4,
          expandedText: 'Read more',
          collapsedText: 'Show less',
        ),

        // Service Features
        if (widget.service.features.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.service.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                              : AppColors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildIncludedItems(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                "What's Included",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.service.includedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, size: 14, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Requirements & Preparation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Requirements
          ...widget.service.requirements.map((requirement) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, size: 14, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        requirement,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),

          // Special Requirements
          if (widget.service.requiresMeasurement) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.straighten, size: 14, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Measurements required (included in service)',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],

          if (widget.service.requiresFitting) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.accessibility, size: 14, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Fitting session required',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddOnsSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Add-ons',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        ...widget.service.addOns.take(3).map((addOn) {
          final price = widget.service.addOnPricing[addOn] ?? 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.surface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                    : AppColors.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    addOn,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: price > 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    price > 0 ? '+\$${price.toStringAsFixed(0)}' : 'Included',
                    style: TextStyle(
                      color: price > 0 ? Colors.green[700] : Colors.blue[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Show more indicator
        if (widget.service.addOns.length > 3)
          Center(
            child: Text(
              '+${widget.service.addOns.length - 3} more add-ons available',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                    : AppColors.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBookingFab(ThemeProvider themeProvider) {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) => ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticInOut,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: 200,
          child: FloatingActionButton.extended(
            onPressed: _bookService,
            backgroundColor: themeProvider.isDarkMode
                ? DarkAppColors.primary
                : AppColors.primary,
            foregroundColor: themeProvider.isDarkMode
                ? DarkAppColors.onPrimary
                : AppColors.onPrimary,
            elevation: 8,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
            icon: const Icon(Icons.book_online, size: 20),
            label: const Text(
              'Book Service',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
