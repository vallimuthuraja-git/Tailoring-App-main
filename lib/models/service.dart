// Service Model for Tailoring Services
// Supports saree draping, pre-pleat services, and other tailoring services

import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceCategory {
  sareeServices,      // Saree draping, pre-pleat, etc.
  garmentServices,    // Dressmaking, suits, etc.
  alterationServices, // Alterations and repairs
  customDesign,       // Bespoke designs
  consultation,       // Style consultation
  measurements,       // Measurement services
  specialOccasion,    // Wedding, party wear
  corporateWear,      // Business attire
  uniformServices,    // School, work uniforms
  bridalServices,     // Bridal wear and accessories
}

enum ServiceType {
  // Saree Services
  sareeDraping,
  sareePrePleat,
  sareePrePleatOnTheGo,
  sareeBlouseStitching,
  sareeFallsPinning,
  sareeAlteration,

  // Garment Services
  dressmaking,
  suitTailoring,
  shirtMaking,
  trouserTailoring,
  blouseStitching,
  kurtiStitching,

  // Alteration Services
  hemming,
  takingIn,
  lettingOut,
  shortening,
  lengthening,
  zipperRepair,

  // Custom Design
  bespokeDesign,
  patternMaking,
  embroidery,
  beading,
  embellishment,

  // Special Services
  weddingDress,
  bridesmaidDresses,
  promDresses,
  eveningGowns,
  cocktailDresses,

  // Consultation
  styleConsultation,
  colorAnalysis,
  bodyMeasurement,
  fabricSelection,
}

enum ServiceDuration {
  quick,      // 30 minutes - 2 hours
  standard,   // 2-8 hours
  extended,   // 8-24 hours
  project,    // Multiple days
  ongoing,    // Recurring services
}

enum ServiceComplexity {
  simple,     // Basic alterations, simple stitching
  moderate,   // Standard garments, minor alterations
  complex,    // Custom designs, intricate work
  expert,     // Bespoke, high-end craftsmanship
}

class Service {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final ServiceCategory category;
  final ServiceType type;
  final ServiceDuration duration;
  final ServiceComplexity complexity;

  // Pricing
  final double basePrice;
  final double? minPrice;
  final double? maxPrice;
  final String currency;
  final Map<String, double> tierPricing; // Basic, Standard, Premium

  // Service Details
  final List<String> features;
  final List<String> includedItems;
  final List<String> requirements;
  final List<String> preparationTips;
  final Map<String, dynamic> specifications;

  // Customization Options
  final List<ServiceCustomization> customizations;
  final List<String> addOns;
  final Map<String, double> addOnPricing;

  // Business Logic
  final bool isActive;
  final bool requiresMeasurement;
  final bool requiresFitting;
  final int estimatedHours;
  final List<String> requiredSkills;
  final List<String> recommendedFabrics;

  // Media
  final List<String> imageUrls;
  final String? videoUrl;
  final String? iconName;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> additionalInfo;

  // Analytics
  final int popularityScore;
  final double averageRating;
  final int totalBookings;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.category,
    required this.type,
    required this.duration,
    required this.complexity,
    required this.basePrice,
    this.minPrice,
    this.maxPrice,
    this.currency = 'USD',
    this.tierPricing = const {},
    required this.features,
    this.includedItems = const [],
    this.requirements = const [],
    this.preparationTips = const [],
    this.specifications = const {},
    this.customizations = const [],
    this.addOns = const [],
    this.addOnPricing = const {},
    this.isActive = true,
    this.requiresMeasurement = false,
    this.requiresFitting = false,
    this.estimatedHours = 1,
    this.requiredSkills = const [],
    this.recommendedFabrics = const [],
    this.imageUrls = const [],
    this.videoUrl,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
    this.additionalInfo = const {},
    this.popularityScore = 0,
    this.averageRating = 0.0,
    this.totalBookings = 0,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      category: ServiceCategory.values[json['category'] ?? 0],
      type: ServiceType.values[json['type'] ?? 0],
      duration: ServiceDuration.values[json['duration'] ?? 1],
      complexity: ServiceComplexity.values[json['complexity'] ?? 1],
      basePrice: (json['basePrice'] ?? 0.0).toDouble(),
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      currency: json['currency'] ?? 'USD',
      tierPricing: Map<String, double>.from(json['tierPricing'] ?? {}),
      features: List<String>.from(json['features'] ?? []),
      includedItems: List<String>.from(json['includedItems'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      preparationTips: List<String>.from(json['preparationTips'] ?? []),
      specifications: Map<String, dynamic>.from(json['specifications'] ?? {}),
      customizations: (json['customizations'] as List<dynamic>?)
          ?.map((c) => ServiceCustomization.fromJson(c))
          .toList() ?? [],
      addOns: List<String>.from(json['addOns'] ?? []),
      addOnPricing: Map<String, double>.from(json['addOnPricing'] ?? {}),
      isActive: json['isActive'] ?? true,
      requiresMeasurement: json['requiresMeasurement'] ?? false,
      requiresFitting: json['requiresFitting'] ?? false,
      estimatedHours: json['estimatedHours'] ?? 1,
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      recommendedFabrics: List<String>.from(json['recommendedFabrics'] ?? []),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrl: json['videoUrl'],
      iconName: json['iconName'],
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      additionalInfo: Map<String, dynamic>.from(json['additionalInfo'] ?? {}),
      popularityScore: json['popularityScore'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'category': category.index,
      'type': type.index,
      'duration': duration.index,
      'complexity': complexity.index,
      'basePrice': basePrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'currency': currency,
      'tierPricing': tierPricing,
      'features': features,
      'includedItems': includedItems,
      'requirements': requirements,
      'preparationTips': preparationTips,
      'specifications': specifications,
      'customizations': customizations.map((c) => c.toJson()).toList(),
      'addOns': addOns,
      'addOnPricing': addOnPricing,
      'isActive': isActive,
      'requiresMeasurement': requiresMeasurement,
      'requiresFitting': requiresFitting,
      'estimatedHours': estimatedHours,
      'requiredSkills': requiredSkills,
      'recommendedFabrics': recommendedFabrics,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'iconName': iconName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'additionalInfo': additionalInfo,
      'popularityScore': popularityScore,
      'averageRating': averageRating,
      'totalBookings': totalBookings,
    };
  }

  // Helper methods
  String get categoryName {
    switch (category) {
      case ServiceCategory.sareeServices:
        return 'Saree Services';
      case ServiceCategory.garmentServices:
        return 'Garment Services';
      case ServiceCategory.alterationServices:
        return 'Alteration Services';
      case ServiceCategory.customDesign:
        return 'Custom Design';
      case ServiceCategory.consultation:
        return 'Consultation';
      case ServiceCategory.measurements:
        return 'Measurements';
      case ServiceCategory.specialOccasion:
        return 'Special Occasion';
      case ServiceCategory.corporateWear:
        return 'Corporate Wear';
      case ServiceCategory.uniformServices:
        return 'Uniform Services';
      case ServiceCategory.bridalServices:
        return 'Bridal Services';
    }
  }

  String get typeName {
    return type.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim();
  }

  String get durationText {
    switch (duration) {
      case ServiceDuration.quick:
        return '30 min - 2 hours';
      case ServiceDuration.standard:
        return '2 - 8 hours';
      case ServiceDuration.extended:
        return '8 - 24 hours';
      case ServiceDuration.project:
        return 'Multiple days';
      case ServiceDuration.ongoing:
        return 'Ongoing service';
    }
  }

  String get complexityText {
    switch (complexity) {
      case ServiceComplexity.simple:
        return 'Simple';
      case ServiceComplexity.moderate:
        return 'Moderate';
      case ServiceComplexity.complex:
        return 'Complex';
      case ServiceComplexity.expert:
        return 'Expert';
    }
  }

  bool get isPopular => popularityScore > 100;
  bool get isHighlyRated => averageRating >= 4.5;
  bool get isBestseller => totalBookings > 50;

  double get effectivePrice {
    if (tierPricing.isNotEmpty) {
      return tierPricing['Standard'] ?? basePrice;
    }
    return basePrice;
  }

  Service copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    ServiceCategory? category,
    ServiceType? type,
    ServiceDuration? duration,
    ServiceComplexity? complexity,
    double? basePrice,
    double? minPrice,
    double? maxPrice,
    String? currency,
    Map<String, double>? tierPricing,
    List<String>? features,
    List<String>? includedItems,
    List<String>? requirements,
    List<String>? preparationTips,
    Map<String, dynamic>? specifications,
    List<ServiceCustomization>? customizations,
    List<String>? addOns,
    Map<String, double>? addOnPricing,
    bool? isActive,
    bool? requiresMeasurement,
    bool? requiresFitting,
    int? estimatedHours,
    List<String>? requiredSkills,
    List<String>? recommendedFabrics,
    List<String>? imageUrls,
    String? videoUrl,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? additionalInfo,
    int? popularityScore,
    double? averageRating,
    int? totalBookings,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      complexity: complexity ?? this.complexity,
      basePrice: basePrice ?? this.basePrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      currency: currency ?? this.currency,
      tierPricing: tierPricing ?? this.tierPricing,
      features: features ?? this.features,
      includedItems: includedItems ?? this.includedItems,
      requirements: requirements ?? this.requirements,
      preparationTips: preparationTips ?? this.preparationTips,
      specifications: specifications ?? this.specifications,
      customizations: customizations ?? this.customizations,
      addOns: addOns ?? this.addOns,
      addOnPricing: addOnPricing ?? this.addOnPricing,
      isActive: isActive ?? this.isActive,
      requiresMeasurement: requiresMeasurement ?? this.requiresMeasurement,
      requiresFitting: requiresFitting ?? this.requiresFitting,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      recommendedFabrics: recommendedFabrics ?? this.recommendedFabrics,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      popularityScore: popularityScore ?? this.popularityScore,
      averageRating: averageRating ?? this.averageRating,
      totalBookings: totalBookings ?? this.totalBookings,
    );
  }
}

class ServiceCustomization {
  final String id;
  final String name;
  final String type; // 'selection', 'text', 'number', 'boolean'
  final String description;
  final List<String> options; // For selection type
  final String? defaultValue;
  final double additionalPrice;
  final bool isRequired;
  final bool affectsPricing;
  final Map<String, dynamic> validation;

  const ServiceCustomization({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.options = const [],
    this.defaultValue,
    this.additionalPrice = 0.0,
    this.isRequired = false,
    this.affectsPricing = false,
    this.validation = const {},
  });

  factory ServiceCustomization.fromJson(Map<String, dynamic> json) {
    return ServiceCustomization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'text',
      description: json['description'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      defaultValue: json['defaultValue'],
      additionalPrice: (json['additionalPrice'] ?? 0.0).toDouble(),
      isRequired: json['isRequired'] ?? false,
      affectsPricing: json['affectsPricing'] ?? false,
      validation: Map<String, dynamic>.from(json['validation'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'options': options,
      'defaultValue': defaultValue,
      'additionalPrice': additionalPrice,
      'isRequired': isRequired,
      'affectsPricing': affectsPricing,
      'validation': validation,
    };
  }
}

// Predefined Service Templates
class ServiceTemplates {
  static List<Service> get sareeServices => [
    // Saree Draping
    Service(
      id: 'saree_draping_basic',
      name: 'Saree Draping - Basic',
      description: 'Professional saree draping service for traditional wear. Includes basic draping techniques suitable for casual and semi-formal occasions.',
      shortDescription: 'Basic saree draping for everyday wear',
      category: ServiceCategory.sareeServices,
      type: ServiceType.sareeDraping,
      duration: ServiceDuration.quick,
      complexity: ServiceComplexity.simple,
      basePrice: 25.0,
      features: [
        'Traditional draping technique',
        'Basic pleat styling',
        'Blouse adjustment',
        'Safety pins provided',
        'Photo reference guide',
      ],
      requiresMeasurement: false,
      estimatedHours: 1,
      requiredSkills: ['saree_draping'],
      recommendedFabrics: ['cotton', 'silk', 'chiffon'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Pre-pleat Saree Service
    Service(
      id: 'saree_prepleat_standard',
      name: 'Pre-pleat Saree Service',
      description: 'Professional pre-pleating service for sarees. Perfect preparation for weddings, parties, and special occasions. Includes multiple pleat styles and finishing touches.',
      shortDescription: 'Professional saree pre-pleating for special occasions',
      category: ServiceCategory.sareeServices,
      type: ServiceType.sareePrePleat,
      duration: ServiceDuration.standard,
      complexity: ServiceComplexity.moderate,
      basePrice: 75.0,
      minPrice: 50.0,
      maxPrice: 200.0,
      features: [
        'Multiple pleat style options',
        'Professional finishing',
        'Ironing and pressing',
        'Storage recommendations',
        'Care instructions',
        'Emergency repair kit',
      ],
      includedItems: [
        'Professional pleating',
        'Safety pins',
        'Storage bag',
        'Care instructions',
      ],
      requirements: [
        'Clean saree in good condition',
        'No stains or tears',
        'Fabric should be pleat-friendly',
      ],
      preparationTips: [
        'Dry clean saree before pleating',
        'Remove all accessories',
        'Ensure saree is properly ironed',
      ],
      tierPricing: {
        'Basic': 50.0,
        'Standard': 75.0,
        'Premium': 125.0,
        'Deluxe': 200.0,
      },
      requiresMeasurement: true,
      requiresFitting: false,
      estimatedHours: 4,
      requiredSkills: ['saree_pleating', 'finishing'],
      recommendedFabrics: ['silk', 'crepe', 'georgette', 'chiffon'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Pre-pleat on the Go
    Service(
      id: 'saree_prepleat_onthego',
      name: 'Pre-pleat on the Go',
      description: 'Convenient mobile pre-pleating service. Our expert comes to your location for saree pleating. Perfect for busy schedules and last-minute preparations.',
      shortDescription: 'Mobile saree pre-pleating at your location',
      category: ServiceCategory.sareeServices,
      type: ServiceType.sareePrePleatOnTheGo,
      duration: ServiceDuration.extended,
      complexity: ServiceComplexity.moderate,
      basePrice: 150.0,
      features: [
        'Mobile service at your location',
        'Professional pleating expert',
        'All tools and equipment provided',
        'Multiple pleat consultations',
        'Fitting assistance',
        'Follow-up service',
        'Travel fee included',
      ],
      includedItems: [
        'Professional pleating',
        'Travel to your location',
        'All necessary tools',
        'Finishing touches',
        'Care instructions',
      ],
      requirements: [
        'Serviceable location access',
        'Adequate working space',
        'Clean saree ready for pleating',
        'Access to ironing facilities',
      ],
      preparationTips: [
        'Ensure adequate space',
        'Have saree ready and ironed',
        'Clear area for work',
        'Have refreshments available',
      ],
      tierPricing: {
        'Home Visit': 150.0,
        'Event Location': 200.0,
        'Multiple Sarees': 250.0,
      },
      customizations: const [
        ServiceCustomization(
          id: 'travel_distance',
          name: 'Travel Distance',
          type: 'selection',
          description: 'Distance from our location',
          options: ['Within 5km', '5-15km', '15-30km', 'Over 30km'],
          additionalPrice: 25.0,
          affectsPricing: true,
        ),
        ServiceCustomization(
          id: 'urgency',
          name: 'Urgency',
          type: 'selection',
          description: 'How soon do you need the service?',
          options: ['Standard (3-5 days)', 'Express (24-48 hours)', 'Same Day'],
          additionalPrice: 50.0,
          affectsPricing: true,
        ),
      ],
      requiresMeasurement: true,
      requiresFitting: true,
      estimatedHours: 6,
      requiredSkills: ['saree_pleating', 'mobile_service', 'finishing'],
      recommendedFabrics: ['silk', 'crepe', 'georgette', 'chiffon', 'banarasi'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),

    // Saree Blouse Stitching
    Service(
      id: 'saree_blouse_stitching',
      name: 'Saree Blouse Stitching',
      description: 'Expert saree blouse stitching service. Custom-designed blouses to complement your saree perfectly. Includes multiple design consultations and fittings.',
      shortDescription: 'Custom saree blouse stitching and design',
      category: ServiceCategory.sareeServices,
      type: ServiceType.sareeBlouseStitching,
      duration: ServiceDuration.project,
      complexity: ServiceComplexity.complex,
      basePrice: 120.0,
      minPrice: 80.0,
      maxPrice: 500.0,
      features: [
        'Custom design consultation',
        'Multiple fitting sessions',
        'Professional stitching',
        'Quality fabric selection',
        'Perfect fit guarantee',
        'Alteration support',
      ],
      includedItems: [
        'Custom blouse stitching',
        'Multiple fittings',
        'Fabric recommendations',
        'Design consultation',
        'Finishing touches',
      ],
      customizations: const [
        ServiceCustomization(
          id: 'fabric_type',
          name: 'Fabric Type',
          type: 'selection',
          description: 'Choose the fabric for your blouse',
          options: ['Cotton', 'Silk', 'Georgette', 'Net', 'Velvet', 'Brocade'],
          additionalPrice: 30.0,
          affectsPricing: true,
        ),
        ServiceCustomization(
          id: 'neck_design',
          name: 'Neck Design',
          type: 'selection',
          description: 'Choose neckline style',
          options: ['Round Neck', 'V-Neck', 'Boat Neck', 'Sweetheart', 'Scoop Neck', 'Custom'],
          additionalPrice: 15.0,
          affectsPricing: true,
        ),
        ServiceCustomization(
          id: 'sleeve_style',
          name: 'Sleeve Style',
          type: 'selection',
          description: 'Choose sleeve design',
          options: ['Sleeveless', 'Cap Sleeve', 'Short Sleeve', 'Elbow Sleeve', 'Full Sleeve', 'Bell Sleeve'],
          additionalPrice: 20.0,
          affectsPricing: true,
        ),
      ],
      requiresMeasurement: true,
      requiresFitting: true,
      estimatedHours: 24,
      requiredSkills: ['blouse_stitching', 'design', 'fitting'],
      recommendedFabrics: ['cotton', 'silk', 'georgette', 'net'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<Service> get allServices => [
    ...sareeServices,
    // Add more service categories as needed
  ];
}