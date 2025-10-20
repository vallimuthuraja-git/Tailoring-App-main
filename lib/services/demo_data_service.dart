import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/product_models.dart';
import '../models/customer.dart';
import '../models/order.dart';
import '../models/employee.dart';
import '../models/service.dart';
import '../models/chat.dart';
import '../models/user_role.dart';

class ComprehensiveDemoDataService {
  static final Random _random = Random();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data generation parameters - Excellent coverage for comprehensive demo/testing
  static const int _customerCount = 35;
  static const int _productCount = 28;
  static const int _employeeCount = 18;
  static const int _serviceCount = 22;
  static const int _workAssignmentCount = 35;
  static const int _chatConversationCount = 25;

  /// Main method to populate all demo data
  static Future<void> populateAllDemoData() async {
    debugPrint('🚀 Starting comprehensive demo data population...');

    try {
      // Generate and populate data in order of dependencies
      await _populateCustomers();
      await _populateProducts();
      await _populateEmployees();
      await _populateServices();
      await _populateWorkAssignments();
      await _populateChatConversations();

      debugPrint('✅ Comprehensive demo data population completed!');
      debugPrint('📊 Generated:');
      debugPrint('   - $_customerCount customers');
      debugPrint('   - $_productCount products');
      debugPrint('   - $_employeeCount employees');
      debugPrint('   - $_serviceCount services');
      debugPrint('   - $_workAssignmentCount work assignments');
      debugPrint('   - $_chatConversationCount chat conversations');
      debugPrint('   - Ready for full system testing!');
    } catch (e) {
      debugPrint('❌ Error during demo data population: $e');
      rethrow;
    }
  }

  /// Generate all demo customers (public access to full dataset)
  static List<Customer> getAllDemoCustomers() {
    final customers = _generateCustomers();
    return customers;
  }

  /// Generate customers with all loyalty tiers and diverse profiles
  static Future<void> _populateCustomers() async {
    debugPrint('👥 Generating customers...');

    final customers = _generateCustomers();
    final batch = _firestore.batch();

    for (final customer in customers) {
      final docRef = _firestore.collection('customers').doc(customer.id);
      batch.set(docRef, customer.toJson());
    }

    await batch.commit();
    debugPrint('✅ Generated ${customers.length} customers');
  }

  /// Generate products across all categories
  static Future<void> _populateProducts() async {
    debugPrint('📦 Generating products...');

    final products = _generateProducts();
    final batch = _firestore.batch();

    for (final product in products) {
      final docRef = _firestore.collection('products').doc(product.id);
      batch.set(docRef, product.toJson());
    }

    await batch.commit();
    debugPrint('✅ Generated ${products.length} products');
  }

  /// Generate diverse customer profiles with all loyalty tiers
  static List<Customer> _generateCustomers() {
    final customers = <Customer>[];
    final firstNames = [
      'Rajesh',
      'Priya',
      'Amit',
      'Kavita',
      'Vikram',
      'Anjali',
      'Rahul',
      'Sneha',
      'Arun',
      'Meera',
      'Suresh',
      'Kiran',
      'Deepak',
      'Poonam',
      'Rakesh',
      'Sunita',
      'Manoj',
      'Rekha',
      'Vinay',
      'Geeta'
    ];
    final lastNames = [
      'Kumar',
      'Sharma',
      'Patel',
      'Singh',
      'Gupta',
      'Jain',
      'Agarwal',
      'Verma',
      'Chauhan',
      'Yadav',
      'Shukla',
      'Mishra',
      'Tiwari',
      'Chandra',
      'Bansal',
      'Kapoor',
      'Mehta',
      'Rao',
      'Nair',
      'Pillai'
    ];

    for (int i = 0; i < _customerCount; i++) {
      final firstName = firstNames[_random.nextInt(firstNames.length)];
      final lastName = lastNames[_random.nextInt(lastNames.length)];
      final name = '$firstName $lastName';
      final email =
          '${firstName.toLowerCase()}.${lastName.toLowerCase()}@example.com';
      final phone = '+91 ${_generatePhoneNumber()}';

      // Generate measurements based on gender (assume even index = male, odd = female)
      final isMale = i % 2 == 0;
      final measurements = _generateMeasurements(isMale);

      // Assign loyalty tier based on spending pattern
      final spendingMultiplier = _random.nextDouble() * 2 + 0.5; // 0.5 to 2.5
      final totalSpent =
          (_random.nextDouble() * 50000 + 5000) * spendingMultiplier;
      final loyaltyTier = _getLoyaltyTier(totalSpent);

      final preferences = _generateCustomerPreferences(isMale);

      customers.add(Customer(
        id: 'customer_${i + 1}',
        name: name,
        email: email,
        phone: phone,
        photoUrl:
            'https://via.placeholder.com/100x100?text=${firstName[0]}${lastName[0]}',
        measurements: measurements,
        preferences: preferences,
        createdAt:
            DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        updatedAt: DateTime.now(),
        totalSpent: totalSpent,
        loyaltyTier: loyaltyTier,
        isActive: _random.nextDouble() > 0.1, // 90% active
      ));
    }

    return customers;
  }

  /// Generate products across all categories
  static List<Product> _generateProducts() {
    final products = <Product>[];
    final productTemplates = _getProductTemplates();

    for (int i = 0; i < _productCount; i++) {
      final template =
          productTemplates[_random.nextInt(productTemplates.length)];
      final category = template['category'] as ProductCategory;

      products.add(Product(
        id: 'product_${i + 1}',
        name: '${template['name']} ${i + 1}',
        description: template['description'] as String,
        category: category,
        basePrice: (template['basePrice'] as double) *
            (0.8 + _random.nextDouble() * 0.4), // ±20% variation
        imageUrls: [
          'https://via.placeholder.com/300x300?text=${template['name'].toString().replaceAll(' ', '+')}'
        ],
        specifications: _generateProductSpecifications(category),
        availableSizes: _generateAvailableSizes(category),
        availableFabrics: _generateAvailableFabrics(category),
        customizationOptions: _generateCustomizationOptions(category),
        isActive: _random.nextDouble() > 0.1, // 90% active
        createdAt:
            DateTime.now().subtract(Duration(days: _random.nextInt(180))),
        updatedAt: DateTime.now(),
      ));
    }

    return products;
  }

  static Map<String, dynamic> _generateMeasurements(bool isMale) {
    if (isMale) {
      return {
        'chest': 38.0 + _random.nextDouble() * 8.0, // 38-46
        'waist': 32.0 + _random.nextDouble() * 8.0, // 32-40
        'shoulder': 17.0 + _random.nextDouble() * 3.0, // 17-20
        'length': 28.0 + _random.nextDouble() * 4.0, // 28-32
        'inseam': 32.0 + _random.nextDouble() * 4.0, // 32-36
      };
    } else {
      return {
        'bust': 34.0 + _random.nextDouble() * 8.0, // 34-42
        'waist': 26.0 + _random.nextDouble() * 8.0, // 26-34
        'hips': 36.0 + _random.nextDouble() * 8.0, // 36-44
        'shoulder': 14.0 + _random.nextDouble() * 2.0, // 14-16
        'length': 40.0 + _random.nextDouble() * 8.0, // 40-48
      };
    }
  }

  static LoyaltyTier _getLoyaltyTier(double totalSpent) {
    if (totalSpent >= 100000) return LoyaltyTier.platinum;
    if (totalSpent >= 50000) return LoyaltyTier.gold;
    if (totalSpent >= 25000) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  static List<String> _generateCustomerPreferences(bool isMale) {
    final preferences = <String>[];
    final fabricPrefs = ['Cotton', 'Silk', 'Wool', 'Linen', 'Synthetic'];
    final colorPrefs = [
      'Dark Colors',
      'Light Colors',
      'Bright Colors',
      'Pastel Colors',
      'Neutral Colors'
    ];
    final stylePrefs = isMale
        ? ['Formal Wear', 'Business Casual', 'Casual Wear', 'Traditional Wear']
        : ['Traditional Wear', 'Western Wear', 'Designer Wear', 'Casual Wear'];

    preferences.add(fabricPrefs[_random.nextInt(fabricPrefs.length)]);
    preferences.add(colorPrefs[_random.nextInt(colorPrefs.length)]);
    preferences.add(stylePrefs[_random.nextInt(stylePrefs.length)]);

    return preferences;
  }

  static List<Map<String, dynamic>> _getProductTemplates() {
    return [
      {
        'name': 'Business Suit',
        'description':
            'Professional business suit perfect for corporate environments',
        'category': ProductCategory.mensWear,
        'basePrice': 25000.0,
      },
      {
        'name': 'Wedding Lehenga',
        'description':
            'Elegant wedding lehenga with intricate embroidery and traditional design',
        'category': ProductCategory.womensWear,
        'basePrice': 45000.0,
      },
      {
        'name': 'Cotton Shirt',
        'description':
            'Comfortable cotton shirt ideal for casual and formal wear',
        'category': ProductCategory.mensWear,
        'basePrice': 3000.0,
      },
      {
        'name': 'Designer Dress',
        'description':
            'Stylish designer dress for special occasions and parties',
        'category': ProductCategory.womensWear,
        'basePrice': 15000.0,
      },
      {
        'name': 'School Uniform',
        'description': 'Durable school uniform set with comfortable fabric',
        'category': ProductCategory.kidsWear,
        'basePrice': 2500.0,
      },
      {
        'name': 'Traditional Sherwani',
        'description':
            'Elegant traditional sherwani for weddings and festivals',
        'category': ProductCategory.traditionalWear,
        'basePrice': 35000.0,
      },
      {
        'name': 'Corporate Blazer',
        'description': 'Professional blazer for business and formal occasions',
        'category': ProductCategory.formalWear,
        'basePrice': 18000.0,
      },
      {
        'name': 'Casual T-Shirt',
        'description': 'Comfortable casual t-shirt for everyday wear',
        'category': ProductCategory.casualWear,
        'basePrice': 1200.0,
      },
      {
        'name': 'Suit Alteration',
        'description': 'Professional suit alteration and fitting service',
        'category': ProductCategory.alterations,
        'basePrice': 2500.0,
      },
      {
        'name': 'Custom Design',
        'description': 'Bespoke custom design service for unique garments',
        'category': ProductCategory.customDesign,
        'basePrice': 50000.0,
      },
    ];
  }

  static Map<String, dynamic> _generateProductSpecifications(
      ProductCategory category) {
    final specs = <String, dynamic>{};

    switch (category) {
      case ProductCategory.mensWear:
        specs.addAll({
          'Fit': 'Regular/Slim/Tailored',
          'Fabric': 'Cotton/Wool/Polyester',
          'Care': 'Dry Clean/Machine Wash',
          'Origin': 'Made in India',
        });
        break;
      case ProductCategory.womensWear:
        specs.addAll({
          'Size': 'XS-XXL',
          'Fabric': 'Cotton/Silk/Georgette',
          'Care': 'Hand Wash/Dry Clean',
          'Design': 'Printed/Embroidered/Plain',
        });
        break;
      case ProductCategory.kidsWear:
        specs.addAll({
          'Age Group': '5-15 years',
          'Fabric': 'Cotton Blend',
          'Care': 'Machine Wash',
          'Features': 'Comfortable, Durable',
        });
        break;
      default:
        specs.addAll({
          'Fabric': 'Various',
          'Care': 'Dry Clean',
          'Delivery': '7-21 days',
        });
    }

    return specs;
  }

  /// Generate employees with all skill combinations and diverse profiles
  static Future<void> _populateEmployees() async {
    debugPrint('👷 Generating employees...');

    final employees = _generateEmployees();
    final batch = _firestore.batch();

    for (final employee in employees) {
      final docRef = _firestore.collection('employees').doc(employee.id);
      batch.set(docRef, employee.toJson());
    }

    await batch.commit();
    debugPrint('✅ Generated ${employees.length} employees');
  }

  /// Generate diverse employee profiles with all skill combinations
  static List<Employee> _generateEmployees() {
    final employees = <Employee>[];
    final firstNames = [
      'Rajesh',
      'Priya',
      'Amit',
      'Kavita',
      'Vikram',
      'Anjali',
      'Rahul',
      'Sneha',
      'Arun',
      'Meera',
      'Suresh',
      'Kiran',
      'Deepak',
      'Poonam',
      'Rakesh',
      'Sunita',
      'Manoj',
      'Rekha',
      'Vinay',
      'Geeta'
    ];
    final lastNames = [
      'Kumar',
      'Sharma',
      'Patel',
      'Singh',
      'Gupta',
      'Jain',
      'Agarwal',
      'Verma',
      'Chauhan',
      'Yadav',
      'Shukla',
      'Mishra',
      'Tiwari',
      'Chandra',
      'Bansal',
      'Kapoor',
      'Mehta',
      'Rao',
      'Nair',
      'Pillai'
    ];

    // Add shop owner as first employee
    employees.add(_createShopOwnerEmployee());

    // Generate remaining regular employees (17 more to reach 18 total)
    for (int i = 0; i < _employeeCount - 1; i++) {
      final firstName = firstNames[_random.nextInt(firstNames.length)];
      final lastName = lastNames[_random.nextInt(lastNames.length)];
      final name = '$firstName $lastName';
      final email =
          '${firstName.toLowerCase()}.${lastName.toLowerCase()}@tailoring.com';

      // Generate diverse skill combinations
      final skills = _generateEmployeeSkills(i);
      final specializations = _generateSpecializations(skills);
      final experienceYears = _random.nextInt(15) + 1; // 1-15 years

      // Generate availability and work preferences
      final availability =
          EmployeeAvailability.values[i % EmployeeAvailability.values.length];
      final preferredWorkDays = _generateWorkDays(availability);
      final workHours = _generateWorkHours(availability);

      // Generate performance metrics
      final totalOrdersCompleted = _random.nextInt(200) + 10;
      final ordersInProgress = _random.nextInt(5);
      final averageRating = 3.5 + _random.nextDouble() * 1.5; // 3.5-5.0
      final completionRate = 0.85 + _random.nextDouble() * 0.15; // 85-100%

      // Generate salary information
      final baseRate = _calculateBaseRate(skills, experienceYears);
      final performanceBonusRate =
          baseRate * 0.1 * (_random.nextDouble() + 0.5);

      employees.add(Employee(
        id: 'employee_${i + 1}',
        userId: 'user_employee_${i + 1}',
        displayName: name,
        email: email,
        phoneNumber: '+91 ${_generatePhoneNumber()}',
        photoUrl:
            'https://via.placeholder.com/100x100?text=${firstName[0]}${lastName[0]}',
        skills: skills,
        specializations: specializations,
        experienceYears: experienceYears,
        certifications: _generateCertifications(skills, experienceYears),
        availability: availability,
        preferredWorkDays: preferredWorkDays,
        preferredStartTime: workHours['start'],
        preferredEndTime: workHours['end'],
        canWorkRemotely: availability == EmployeeAvailability.remote ||
            _random.nextDouble() > 0.7,
        location: _generateWorkLocation(availability),
        totalOrdersCompleted: totalOrdersCompleted,
        ordersInProgress: ordersInProgress,
        averageRating: averageRating,
        completionRate: completionRate,
        strengths: _generateStrengths(skills),
        areasForImprovement: _generateAreasForImprovement(),
        baseRatePerHour: baseRate,
        performanceBonusRate: performanceBonusRate,
        paymentTerms: _random.nextBool() ? 'Weekly' : 'Monthly',
        totalEarnings: (totalOrdersCompleted * baseRate * 8) +
            (_random.nextDouble() * 50000),
        recentAssignments: [], // Will be populated with work assignments later
        lastActive:
            DateTime.now().subtract(Duration(hours: _random.nextInt(48))),
        consecutiveDaysWorked: _random.nextInt(30) + 1,
        isActive: _random.nextDouble() > 0.1, // 90% active
        joinedDate: DateTime.now().subtract(
            Duration(days: _random.nextInt(730))), // Up to 2 years ago
        additionalInfo: _generateAdditionalEmployeeInfo(),
        createdAt:
            DateTime.now().subtract(Duration(days: _random.nextInt(730))),
        updatedAt: DateTime.now(),
      ));
    }

    return employees;
  }

  static List<EmployeeSkill> _generateEmployeeSkills(int index) {
    const allSkills = EmployeeSkill.values;
    final skillCount = _random.nextInt(4) + 2; // 2-5 skills per employee

    // Ensure we cover all skills across different employees
    final startIndex = (index * 2) % allSkills.length;
    final skills = <EmployeeSkill>[];

    for (int i = 0; i < skillCount; i++) {
      final skillIndex = (startIndex + i) % allSkills.length;
      skills.add(allSkills[skillIndex]);
    }

    return skills.toSet().toList(); // Remove duplicates
  }

  static List<String> _generateSpecializations(List<EmployeeSkill> skills) {
    final specializations = <String>[];
    final specializationOptions = {
      EmployeeSkill.cutting: [
        'Precision Cutting',
        'Fabric Optimization',
        'Pattern Cutting'
      ],
      EmployeeSkill.stitching: [
        'Hand Stitching',
        'Machine Sewing',
        'Complex Stitches'
      ],
      EmployeeSkill.finishing: [
        'Button Attachment',
        'Hemming',
        'Final Touches'
      ],
      EmployeeSkill.alterations: [
        'Size Modifications',
        'Style Changes',
        'Fit Adjustments'
      ],
      EmployeeSkill.embroidery: [
        'Machine Embroidery',
        'Hand Embroidery',
        'Custom Designs'
      ],
      EmployeeSkill.qualityCheck: [
        'Quality Assurance',
        'Final Inspection',
        'Standards Compliance'
      ],
      EmployeeSkill.patternMaking: [
        'Custom Patterns',
        'Size Grading',
        'Technical Drawing'
      ],
    };

    for (final skill in skills) {
      final skillSpecializations = specializationOptions[skill]!;
      final specializationCount =
          _random.nextInt(2) + 1; // 1-2 specializations per skill

      for (int i = 0; i < specializationCount; i++) {
        specializations.add(
            skillSpecializations[_random.nextInt(skillSpecializations.length)]);
      }
    }

    return specializations.toSet().toList(); // Remove duplicates
  }

  static List<String> _generateCertifications(
      List<EmployeeSkill> skills, int experienceYears) {
    final certifications = <String>[];
    final possibleCertifications = [
      'Certified Tailor',
      'Fashion Design Diploma',
      'Sewing Machine Specialist',
      'Quality Assurance Certification',
      'Embroidery Professional',
      'Pattern Making Expert',
      'Alteration Specialist',
      'Textile Technology Certification',
      'Fashion Merchandising'
    ];

    final certificationCount = experienceYears > 5
        ? _random.nextInt(3) + 1
        : _random.nextInt(2); // 0-3 certifications

    for (int i = 0; i < certificationCount; i++) {
      certifications.add(possibleCertifications[
          _random.nextInt(possibleCertifications.length)]);
    }

    return certifications.toSet().toList(); // Remove duplicates
  }

  static List<String> _generateWorkDays(EmployeeAvailability availability) {
    final allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    switch (availability) {
      case EmployeeAvailability.fullTime:
        return allDays;
      case EmployeeAvailability.partTime:
        return allDays.take(_random.nextInt(3) + 3).toList(); // 3-5 days
      case EmployeeAvailability.flexible:
        return allDays.take(_random.nextInt(4) + 3).toList(); // 3-6 days
      case EmployeeAvailability.projectBased:
        return allDays.take(_random.nextInt(4) + 2).toList(); // 2-5 days
      case EmployeeAvailability.remote:
        return allDays.take(_random.nextInt(3) + 4).toList(); // 4-6 days
      case EmployeeAvailability.unavailable:
        return [];
    }
  }

  static Map<String, TimeOfDay?> _generateWorkHours(
      EmployeeAvailability availability) {
    final startHour = 9 + _random.nextInt(3); // 9-11 AM
    final endHour = 17 + _random.nextInt(4); // 5-8 PM

    switch (availability) {
      case EmployeeAvailability.fullTime:
        return {
          'start': TimeOfDay(hour: startHour, minute: 0),
          'end': TimeOfDay(hour: endHour, minute: 0),
        };
      case EmployeeAvailability.partTime:
        return {
          'start': TimeOfDay(hour: startHour, minute: 0),
          'end': TimeOfDay(hour: startHour + 4, minute: 0),
        };
      case EmployeeAvailability.flexible:
        return {
          'start': TimeOfDay(hour: startHour, minute: 0),
          'end': TimeOfDay(hour: endHour, minute: 0),
        };
      case EmployeeAvailability.projectBased:
        return {
          'start': null,
          'end': null,
        };
      case EmployeeAvailability.remote:
        return {
          'start': TimeOfDay(hour: startHour, minute: 0),
          'end': TimeOfDay(hour: endHour, minute: 0),
        };
      case EmployeeAvailability.unavailable:
        return {
          'start': null,
          'end': null,
        };
    }
  }

  static String? _generateWorkLocation(EmployeeAvailability availability) {
    final locations = [
      'Main Shop',
      'Branch Office',
      'Home Office',
      'Client Location'
    ];

    if (availability == EmployeeAvailability.remote) {
      return locations[_random.nextInt(locations.length)];
    } else if (availability == EmployeeAvailability.unavailable) {
      return null;
    } else {
      return _random.nextBool()
          ? locations[0]
          : locations[1]; // Main shop or branch
    }
  }

  static double _calculateBaseRate(
      List<EmployeeSkill> skills, int experienceYears) {
    const baseRatePerSkill = 50.0;
    const experienceBonus = 10.0;

    final skillBonus = skills.length * baseRatePerSkill;
    final experienceBonusAmount = experienceYears * experienceBonus;

    return 100.0 +
        skillBonus +
        experienceBonusAmount +
        (_random.nextDouble() * 50); // Base 100-150 + bonuses
  }

  static List<String> _generateStrengths(List<EmployeeSkill> skills) {
    final possibleStrengths = [
      'Attention to Detail',
      'Speed and Efficiency',
      'Creative Problem Solving',
      'Customer Service',
      'Quality Focus',
      'Technical Expertise',
      'Adaptability',
      'Team Collaboration',
      'Time Management',
      'Precision Work'
    ];

    final strengthCount = _random.nextInt(3) + 2; // 2-4 strengths
    final strengths = <String>[];

    for (int i = 0; i < strengthCount; i++) {
      strengths
          .add(possibleStrengths[_random.nextInt(possibleStrengths.length)]);
    }

    return strengths.toSet().toList(); // Remove duplicates
  }

  static List<String> _generateAreasForImprovement() {
    final possibleAreas = [
      'Technology Adoption',
      'Advanced Techniques',
      'Speed Optimization',
      'Client Communication',
      'Documentation',
      'Process Standardization'
    ];

    final areaCount = _random.nextInt(2) + 1; // 1-2 areas for improvement
    final areas = <String>[];

    for (int i = 0; i < areaCount; i++) {
      areas.add(possibleAreas[_random.nextInt(possibleAreas.length)]);
    }

    return areas;
  }

  /// Generate services with all types and complexities
  static Future<void> _populateServices() async {
    debugPrint('🏷️ Generating services...');

    final services = _generateServices();
    final batch = _firestore.batch();

    for (final service in services) {
      final docRef = _firestore.collection('services').doc(service.id);
      batch.set(docRef, service.toJson());
    }

    await batch.commit();
    debugPrint('✅ Generated ${services.length} services');
  }

  /// Generate diverse services across all categories and types
  static List<Service> _generateServices() {
    final services = <Service>[];

    // Get all predefined templates first
    services.addAll(ServiceTemplates.sareeServices);

    // Generate additional services to reach target count
    final additionalServiceCount = _serviceCount - services.length;

    for (int i = services.length;
        i < services.length + additionalServiceCount;
        i++) {
      final category =
          ServiceCategory.values[i % ServiceCategory.values.length];
      final serviceTemplate = _getServiceTemplateForCategory(category, i);

      services.add(Service(
        id: serviceTemplate['id'] as String,
        name: serviceTemplate['name'] as String,
        description: serviceTemplate['description'] as String,
        shortDescription: serviceTemplate['shortDescription'] as String,
        category: category,
        type: serviceTemplate['type'] as ServiceType,
        duration: serviceTemplate['duration'] as ServiceDuration,
        complexity: serviceTemplate['complexity'] as ServiceComplexity,
        basePrice: serviceTemplate['basePrice'] as double,
        minPrice: serviceTemplate['minPrice'] as double?,
        maxPrice: serviceTemplate['maxPrice'] as double?,
        tierPricing:
            serviceTemplate['tierPricing'] as Map<String, double>? ?? {},
        features: serviceTemplate['features'] as List<String>,
        includedItems: serviceTemplate['includedItems'] as List<String>? ?? [],
        requirements: serviceTemplate['requirements'] as List<String>? ?? [],
        preparationTips:
            serviceTemplate['preparationTips'] as List<String>? ?? [],
        specifications:
            serviceTemplate['specifications'] as Map<String, dynamic>? ?? {},
        customizations:
            serviceTemplate['customizations'] as List<ServiceCustomization>? ??
                [],
        addOns: serviceTemplate['addOns'] as List<String>? ?? [],
        addOnPricing:
            serviceTemplate['addOnPricing'] as Map<String, double>? ?? {},
        isActive: _random.nextDouble() > 0.1, // 90% active
        requiresMeasurement:
            serviceTemplate['requiresMeasurement'] as bool? ?? false,
        requiresFitting: serviceTemplate['requiresFitting'] as bool? ?? false,
        estimatedHours: serviceTemplate['estimatedHours'] as int? ?? 1,
        requiredSkills:
            serviceTemplate['requiredSkills'] as List<String>? ?? [],
        recommendedFabrics:
            serviceTemplate['recommendedFabrics'] as List<String>? ?? [],
        imageUrls: _generateServiceImageUrls(serviceTemplate['name'] as String),
        iconName: _getServiceIconName(category),
        createdAt:
            DateTime.now().subtract(Duration(days: _random.nextInt(180))),
        updatedAt: DateTime.now(),
        additionalInfo: _generateAdditionalServiceInfo(),
        popularityScore: _random.nextInt(500) + 10,
        averageRating: 3.5 + _random.nextDouble() * 1.5, // 3.5-5.0
        totalBookings: _random.nextInt(200) + 5,
      ));
    }

    return services;
  }

  static Map<String, dynamic> _getServiceTemplateForCategory(
      ServiceCategory category, int index) {
    final templates = _getServiceTemplatesByCategory()[category]!;
    return templates[index % templates.length];
  }

  static Map<ServiceCategory, List<Map<String, dynamic>>>
      _getServiceTemplatesByCategory() {
    return {
      ServiceCategory.sareeServices: [
        {
          'id': 'saree_falls_pinning_${_random.nextInt(1000)}',
          'name': 'Saree Falls Pinning',
          'description':
              'Professional saree falls pinning service to secure saree pleats perfectly. Includes multiple pinning techniques and safety measures.',
          'shortDescription': 'Professional saree falls pinning',
          'type': ServiceType.sareeFallsPinning,
          'duration': ServiceDuration.quick,
          'complexity': ServiceComplexity.simple,
          'basePrice': 15.0,
          'features': [
            'Secure pinning',
            'Multiple techniques',
            'Safety pins included',
            'Quick service'
          ],
          'requiresMeasurement': false,
          'estimatedHours': 1,
          'requiredSkills': ['saree_handling', 'pinning'],
          'recommendedFabrics': ['silk', 'chiffon', 'georgette'],
        },
        {
          'id': 'saree_alteration_${_random.nextInt(1000)}',
          'name': 'Saree Alteration Service',
          'description':
              'Complete saree alteration service including length adjustment, width modification, and style changes.',
          'shortDescription': 'Complete saree alteration service',
          'type': ServiceType.sareeAlteration,
          'duration': ServiceDuration.standard,
          'complexity': ServiceComplexity.moderate,
          'basePrice': 45.0,
          'minPrice': 30.0,
          'maxPrice': 120.0,
          'features': [
            'Length adjustment',
            'Width modification',
            'Hem stitching',
            'Style alterations'
          ],
          'requiresMeasurement': true,
          'estimatedHours': 3,
          'requiredSkills': ['alteration', 'hemming', 'stitching'],
          'recommendedFabrics': ['cotton', 'silk', 'synthetic'],
        },
      ],
      ServiceCategory.garmentServices: [
        {
          'id': 'dressmaking_custom_${_random.nextInt(1000)}',
          'name': 'Custom Dress Making',
          'description':
              'Bespoke dress creation service with custom design, fabric selection, and multiple fittings.',
          'shortDescription': 'Custom dress creation service',
          'type': ServiceType.dressmaking,
          'duration': ServiceDuration.project,
          'complexity': ServiceComplexity.complex,
          'basePrice': 300.0,
          'minPrice': 200.0,
          'maxPrice': 800.0,
          'tierPricing': {
            'Basic': 200.0,
            'Standard': 300.0,
            'Premium': 500.0,
            'Luxury': 800.0
          },
          'features': [
            'Custom design',
            'Fabric selection',
            'Multiple fittings',
            'Alterations included'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 40,
          'requiredSkills': ['dressmaking', 'design', 'fitting'],
          'recommendedFabrics': ['cotton', 'silk', 'chiffon', 'lace'],
          'customizations': [
            const ServiceCustomization(
              id: 'dress_style',
              name: 'Dress Style',
              type: 'selection',
              description: 'Choose your preferred dress style',
              options: ['A-line', 'Sheath', 'Empire', 'Mermaid', 'Ballgown'],
              additionalPrice: 50.0,
              affectsPricing: true,
            ),
          ],
        },
        {
          'id': 'suit_tailoring_${_random.nextInt(1000)}',
          'name': 'Custom Suit Tailoring',
          'description':
              'Professional suit tailoring service with custom measurements, fabric selection, and expert craftsmanship.',
          'shortDescription': 'Professional suit tailoring',
          'type': ServiceType.suitTailoring,
          'duration': ServiceDuration.project,
          'complexity': ServiceComplexity.expert,
          'basePrice': 500.0,
          'minPrice': 350.0,
          'maxPrice': 1500.0,
          'features': [
            'Custom measurements',
            'Fabric consultation',
            'Expert tailoring',
            'Multiple fittings'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 60,
          'requiredSkills': ['suit_tailoring', 'measurements', 'finishing'],
          'recommendedFabrics': ['wool', 'cotton', 'linen', 'blends'],
        },
        {
          'id': 'shirt_making_${_random.nextInt(1000)}',
          'name': 'Custom Shirt Making',
          'description':
              'Custom shirt creation with personalized fit, fabric choice, and style customization.',
          'shortDescription': 'Custom shirt creation service',
          'type': ServiceType.shirtMaking,
          'duration': ServiceDuration.extended,
          'complexity': ServiceComplexity.moderate,
          'basePrice': 120.0,
          'minPrice': 80.0,
          'maxPrice': 300.0,
          'features': [
            'Custom fit',
            'Fabric selection',
            'Collar options',
            'Cuff styles'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 16,
          'requiredSkills': ['shirt_making', 'collar_styles', 'fitting'],
          'recommendedFabrics': ['cotton', 'linen', 'silk'],
        },
      ],
      ServiceCategory.alterationServices: [
        {
          'id': 'hemming_service_${_random.nextInt(1000)}',
          'name': 'Professional Hemming Service',
          'description':
              'Expert hemming service for pants, skirts, dresses, and curtains. Includes different hemming techniques and finishes.',
          'shortDescription': 'Expert hemming service',
          'type': ServiceType.hemming,
          'duration': ServiceDuration.quick,
          'complexity': ServiceComplexity.simple,
          'basePrice': 25.0,
          'minPrice': 15.0,
          'maxPrice': 75.0,
          'features': [
            'Professional hemming',
            'Multiple techniques',
            'Invisible stitches',
            'Quick turnaround'
          ],
          'requiresMeasurement': false,
          'estimatedHours': 2,
          'requiredSkills': ['hemming', 'finishing'],
          'recommendedFabrics': ['cotton', 'wool', 'synthetic'],
        },
        {
          'id': 'taking_in_${_random.nextInt(1000)}',
          'name': 'Taking In/Letting Out Service',
          'description':
              'Professional taking in and letting out service for perfect fit adjustments.',
          'shortDescription': 'Size adjustment service',
          'type': ServiceType.takingIn,
          'duration': ServiceDuration.standard,
          'complexity': ServiceComplexity.moderate,
          'basePrice': 40.0,
          'minPrice': 25.0,
          'maxPrice': 100.0,
          'features': [
            'Size adjustment',
            'Seam ripping',
            'Re-stitching',
            'Fit guarantee'
          ],
          'requiresMeasurement': true,
          'estimatedHours': 4,
          'requiredSkills': ['alteration', 'sewing', 'fitting'],
          'recommendedFabrics': ['cotton', 'wool', 'blends'],
        },
      ],
      ServiceCategory.customDesign: [
        {
          'id': 'bespoke_design_${_random.nextInt(1000)}',
          'name': 'Bespoke Design Service',
          'description':
              'Complete bespoke design service including concept development, fabric selection, and custom creation.',
          'shortDescription': 'Complete bespoke design service',
          'type': ServiceType.bespokeDesign,
          'duration': ServiceDuration.project,
          'complexity': ServiceComplexity.expert,
          'basePrice': 800.0,
          'minPrice': 500.0,
          'maxPrice': 2500.0,
          'features': [
            'Concept development',
            'Design sketches',
            'Fabric selection',
            'Custom creation',
            'Multiple fittings'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 80,
          'requiredSkills': ['design', 'pattern_making', 'tailoring'],
          'recommendedFabrics': ['premium_fabrics'],
          'customizations': [
            const ServiceCustomization(
              id: 'design_complexity',
              name: 'Design Complexity',
              type: 'selection',
              description: 'Choose design complexity level',
              options: ['Simple', 'Moderate', 'Complex', 'Ultra-Complex'],
              additionalPrice: 200.0,
              affectsPricing: true,
            ),
          ],
        },
      ],
      ServiceCategory.consultation: [
        {
          'id': 'style_consultation_${_random.nextInt(1000)}',
          'name': 'Style Consultation',
          'description':
              'Professional style consultation to help you choose the perfect outfit for any occasion.',
          'shortDescription': 'Professional style consultation',
          'type': ServiceType.styleConsultation,
          'duration': ServiceDuration.quick,
          'complexity': ServiceComplexity.simple,
          'basePrice': 75.0,
          'features': [
            'Personal style assessment',
            'Color analysis',
            'Body type analysis',
            'Occasion planning',
            'Shopping recommendations'
          ],
          'requiresMeasurement': false,
          'estimatedHours': 2,
          'requiredSkills': ['style_consultation', 'color_theory'],
        },
      ],
      ServiceCategory.specialOccasion: [
        {
          'id': 'wedding_dress_${_random.nextInt(1000)}',
          'name': 'Wedding Dress Creation',
          'description':
              'Complete wedding dress creation service with custom design, premium fabrics, and expert craftsmanship.',
          'shortDescription': 'Complete wedding dress creation',
          'type': ServiceType.weddingDress,
          'duration': ServiceDuration.project,
          'complexity': ServiceComplexity.expert,
          'basePrice': 1200.0,
          'minPrice': 800.0,
          'maxPrice': 3500.0,
          'features': [
            'Custom design',
            'Premium fabrics',
            'Multiple fittings',
            'Alterations included',
            'Rush service available'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 120,
          'requiredSkills': [
            'wedding_dress_design',
            'bridal_tailoring',
            'premium_finishing'
          ],
          'recommendedFabrics': ['silk', 'satin', 'lace', 'organza'],
        },
      ],
      ServiceCategory.corporateWear: [
        {
          'id': 'corporate_suit_${_random.nextInt(1000)}',
          'name': 'Corporate Suit Service',
          'description':
              'Professional corporate suit creation with business attire standards and quality materials.',
          'shortDescription': 'Professional corporate suit creation',
          'type': ServiceType.suitTailoring,
          'duration': ServiceDuration.project,
          'complexity': ServiceComplexity.complex,
          'basePrice': 450.0,
          'minPrice': 300.0,
          'maxPrice': 1200.0,
          'features': [
            'Business standards',
            'Quality materials',
            'Professional fit',
            'Multiple fittings'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 50,
          'requiredSkills': ['corporate_tailoring', 'business_attire'],
          'recommendedFabrics': ['wool', 'cotton', 'blends'],
        },
      ],
      ServiceCategory.uniformServices: [
        {
          'id': 'school_uniform_${_random.nextInt(1000)}',
          'name': 'School Uniform Service',
          'description':
              'Complete school uniform service including custom sizing, durable materials, and school compliance.',
          'shortDescription': 'Complete school uniform service',
          'type': ServiceType.suitTailoring,
          'duration': ServiceDuration.extended,
          'complexity': ServiceComplexity.moderate,
          'basePrice': 180.0,
          'minPrice': 120.0,
          'maxPrice': 400.0,
          'features': [
            'Custom sizing',
            'Durable materials',
            'School compliance',
            'Bulk orders'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 24,
          'requiredSkills': ['uniform_tailoring', 'bulk_production'],
          'recommendedFabrics': ['cotton', 'polyester', 'blends'],
        },
      ],
      ServiceCategory.bridalServices: [
        {
          'id': 'bridal_gown_${_random.nextInt(1000)}',
          'name': 'Bridal Gown Creation',
          'description':
              'Exquisite bridal gown creation with premium materials, intricate detailing, and perfect fit.',
          'shortDescription': 'Exquisite bridal gown creation',
          'type': ServiceType.weddingDress,
          'duration': ServiceDuration.project,
          'complexity': ServiceComplexity.expert,
          'basePrice': 1500.0,
          'minPrice': 1000.0,
          'maxPrice': 4000.0,
          'features': [
            'Premium materials',
            'Intricate detailing',
            'Perfect fit',
            'Alterations included'
          ],
          'requiresMeasurement': true,
          'requiresFitting': true,
          'estimatedHours': 140,
          'requiredSkills': [
            'bridal_design',
            'premium_tailoring',
            'intricate_work'
          ],
          'recommendedFabrics': ['silk', 'satin', 'lace', 'organza', 'velvet'],
        },
      ],
      ServiceCategory.measurements: [
        {
          'id': 'body_measurement_${_random.nextInt(1000)}',
          'name': 'Professional Body Measurement',
          'description':
              'Comprehensive body measurement service for accurate tailoring and perfect fit.',
          'shortDescription': 'Professional body measurement service',
          'type': ServiceType.bodyMeasurement,
          'duration': ServiceDuration.quick,
          'complexity': ServiceComplexity.simple,
          'basePrice': 35.0,
          'features': [
            'Comprehensive measurements',
            'Digital recording',
            'Measurement chart',
            'Fit recommendations'
          ],
          'requiresMeasurement': false,
          'estimatedHours': 1,
          'requiredSkills': ['measurements', 'body_analysis'],
        },
      ],
    };
  }

  static List<String> _generateServiceImageUrls(String serviceName) {
    final baseName = serviceName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^\w_]'), '');
    return [
      'https://via.placeholder.com/400x300?text=${baseName}_1',
      'https://via.placeholder.com/400x300?text=${baseName}_2',
    ];
  }

  static String? _getServiceIconName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.sareeServices:
        return 'saree';
      case ServiceCategory.garmentServices:
        return 'dress';
      case ServiceCategory.alterationServices:
        return 'scissors';
      case ServiceCategory.customDesign:
        return 'design';
      case ServiceCategory.consultation:
        return 'consultation';
      case ServiceCategory.measurements:
        return 'measuring_tape';
      case ServiceCategory.specialOccasion:
        return 'special_occasion';
      case ServiceCategory.corporateWear:
        return 'corporate';
      case ServiceCategory.uniformServices:
        return 'uniform';
      case ServiceCategory.bridalServices:
        return 'bridal';
    }
  }

  static Map<String, dynamic> _generateAdditionalServiceInfo() {
    final info = <String, dynamic>{};

    if (_random.nextBool()) {
      info['warranty_period'] = '${_random.nextInt(12) + 1} months';
    }

    if (_random.nextBool()) {
      info['rush_service_available'] = _random.nextBool();
    }

    if (_random.nextBool()) {
      info['bulk_discount_available'] = _random.nextBool();
    }

    if (_random.nextBool()) {
      info['home_service_available'] = _random.nextBool();
    }

    return info;
  }

  static String _generatePhoneNumber() {
    // Generate a valid 10-digit Indian phone number
    final areaCode = _random.nextInt(900) + 100; // 100-999
    final firstPart = _random.nextInt(900) + 100; // 100-999
    final secondPart = _random.nextInt(9000) + 1000; // 1000-9999

    return '$areaCode$firstPart$secondPart';
  }

  static Map<String, dynamic> _generateAdditionalEmployeeInfo() {
    final info = <String, dynamic>{};

    if (_random.nextBool()) {
      info['emergencyContact'] = '+91 ${_generatePhoneNumber()}';
    }

    if (_random.nextBool()) {
      info['preferredPaymentMethod'] =
          _random.nextBool() ? 'Bank Transfer' : 'Cash';
    }

    if (_random.nextBool()) {
      info['languages'] = ['English', 'Hindi', 'Marathi', 'Gujarati', 'Punjabi']
          .take(_random.nextInt(3) + 1)
          .toList();
    }

    return info;
  }

  /// Generate work assignments linking employees to orders
  static Future<void> _populateWorkAssignments() async {
    print('📋 Generating work assignments...');

    final workAssignments = _generateWorkAssignments();
    final batch = _firestore.batch();

    for (final assignment in workAssignments) {
      final docRef =
          _firestore.collection('work_assignments').doc(assignment.id);
      batch.set(docRef, assignment.toJson());
    }

    await batch.commit();
    print('✅ Generated ${workAssignments.length} work assignments');
  }

  /// Generate diverse work assignments linking employees to orders
  static List<WorkAssignment> _generateWorkAssignments() {
    final assignments = List<WorkAssignment>.empty(growable: true);
    final orders = _generateOrders();
    final employees = _generateEmployees();

    // Create work assignments for each order
    for (int i = 0; i < _workAssignmentCount && i < orders.length; i++) {
      final order = orders[i];
      final assignedEmployee = _findSuitableEmployeeForOrder(employees, order);

      if (assignedEmployee != null) {
        final requiredSkill = _determineRequiredSkillForOrder(order);
        final assignment = WorkAssignment(
          id: 'work_assignment_${i + 1}',
          orderId: order.id,
          employeeId: assignedEmployee.id,
          requiredSkill: requiredSkill,
          taskDescription: _generateTaskDescription(order, requiredSkill),
          assignedAt:
              DateTime.now().subtract(Duration(days: _random.nextInt(30))),
          status: _getRandomWorkStatus(),
          estimatedHours: _calculateEstimatedHours(order, requiredSkill),
          actualHours: 0.0,
          hourlyRate: assignedEmployee.baseRatePerHour,
          bonusRate: assignedEmployee.performanceBonusRate,
          deadline: DateTime.now()
              .add(Duration(days: _random.nextInt(21) + 7)), // 7-28 days
          materials: _generateMaterialsForAssignment(order),
          isRemoteWork: assignedEmployee.canWorkRemotely && _random.nextBool(),
          assignedBy: 'shop_owner',
          updates: [], // Will be populated separately if needed
        );

        assignments.add(assignment);
      }
    }

    return assignments;
  }

  static Employee? _findSuitableEmployeeForOrder(
      List<Employee> employees, Order order) {
    // Find employees with skills matching the order requirements
    final suitableEmployees = employees.where((employee) {
      // Check if employee has required skills for the order items
      return order.items
          .any((item) => _doesEmployeeHaveRequiredSkills(employee, item));
    }).toList();

    if (suitableEmployees.isEmpty) {
      // If no perfect match, pick a random employee
      return employees.isNotEmpty
          ? employees[_random.nextInt(employees.length)]
          : null;
    }

    return suitableEmployees[_random.nextInt(suitableEmployees.length)];
  }

  static bool _doesEmployeeHaveRequiredSkills(
      Employee employee, OrderItem item) {
    // Simple skill matching based on item category and description
    final itemCategory = item.category.toLowerCase();
    final itemName = item.productName.toLowerCase();

    return employee.skills.any((skill) {
      final skillName = skill.toString().split('.').last.toLowerCase();
      return itemCategory.contains(skillName) ||
          itemName.contains(skillName) ||
          _isSkillApplicable(skill, itemCategory);
    });
  }

  static bool _isSkillApplicable(EmployeeSkill skill, String category) {
    const skillCategoryMap = {
      EmployeeSkill.cutting: ['shirt', 'suit', 'dress', 'blouse'],
      EmployeeSkill.stitching: ['shirt', 'suit', 'dress', 'blouse', 'kurti'],
      EmployeeSkill.finishing: ['shirt', 'suit', 'dress', 'blouse'],
      EmployeeSkill.alterations: ['alterations', 'repair'],
      EmployeeSkill.embroidery: ['lehenga', 'dress', 'blouse'],
      EmployeeSkill.qualityCheck: ['all'],
      EmployeeSkill.patternMaking: ['custom', 'bespoke'],
    };

    final applicableCategories = skillCategoryMap[skill] ?? [];
    return applicableCategories.contains('all') ||
        applicableCategories.any((cat) => category.contains(cat));
  }

  static Employee _createShopOwnerEmployee() {
    return Employee(
      id: 'employee_owner',
      userId: 'user_owner',
      displayName: 'Esther',
      email: 'shop@demo.com',
      phoneNumber: '+91-9876543210',
      photoUrl: 'https://via.placeholder.com/100x100?text=Owner',
      role: UserRole.shopOwner,
      skills: [EmployeeSkill.qualityCheck, EmployeeSkill.alterations],
      specializations: [
        'Shop Management',
        'Quality Assurance',
        'Customer Service',
        'Business Operations'
      ],
      experienceYears: 15,
      certifications: ['Certified Business Owner', 'Fashion Retail Management'],
      availability: EmployeeAvailability.fullTime,
      preferredWorkDays: [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
      ],
      preferredStartTime: TimeOfDay(hour: 8, minute: 0),
      preferredEndTime: TimeOfDay(hour: 20, minute: 0),
      canWorkRemotely: true,
      location: 'Main Shop',
      totalOrdersCompleted: 500,
      ordersInProgress: 2,
      averageRating: 4.8,
      completionRate: 0.95,
      strengths: [
        'Leadership',
        'Customer Relations',
        'Quality Control',
        'Business Management'
      ],
      areasForImprovement: [],
      baseRatePerHour: 200.0,
      performanceBonusRate: 50.0,
      paymentTerms: 'Monthly',
      totalEarnings: 500000.0,
      recentAssignments: [],
      consecutiveDaysWorked: 365,
      isActive: true,
      joinedDate:
          DateTime.now().subtract(const Duration(days: 1825)), // 5 years ago
      additionalInfo: {
        'position': 'Shop Owner',
        'responsibilities': [
          'Shop Management',
          'Customer Relations',
          'Employee Supervision',
          'Quality Assurance'
        ],
      },
      createdAt: DateTime.now().subtract(const Duration(days: 1825)),
      updatedAt: DateTime.now(),
    );
  }

  static EmployeeSkill _determineRequiredSkillForOrder(Order order) {
    // Determine primary skill based on order items
    const skills = EmployeeSkill.values;

    for (final item in order.items) {
      final itemName = item.productName.toLowerCase();
      final itemCategory = item.category.toLowerCase();

      if (itemName.contains('suit') || itemCategory.contains('suit')) {
        return EmployeeSkill.stitching;
      } else if (itemName.contains('shirt') || itemCategory.contains('shirt')) {
        return EmployeeSkill.cutting;
      } else if (itemName.contains('dress') || itemCategory.contains('dress')) {
        return EmployeeSkill.stitching;
      } else if (itemName.contains('alteration') ||
          itemCategory.contains('alteration')) {
        return EmployeeSkill.alterations;
      } else if (itemName.contains('lehenga') ||
          itemCategory.contains('lehenga')) {
        return EmployeeSkill.embroidery;
      }
    }

    return skills[_random.nextInt(skills.length)];
  }

  static String _generateTaskDescription(Order order, EmployeeSkill skill) {
    final skillName = skill.toString().split('.').last;
    final itemNames = order.items.map((item) => item.productName).join(', ');

    return 'Perform $skillName work on $itemNames for order #${order.id}';
  }

  static WorkStatus _getRandomWorkStatus() {
    const statuses = WorkStatus.values;
    return statuses[_random.nextInt(statuses.length)];
  }

  static double _calculateEstimatedHours(Order order, EmployeeSkill skill) {
    const baseHoursPerSkill = {
      EmployeeSkill.cutting: 4.0,
      EmployeeSkill.stitching: 8.0,
      EmployeeSkill.finishing: 2.0,
      EmployeeSkill.alterations: 3.0,
      EmployeeSkill.embroidery: 6.0,
      EmployeeSkill.qualityCheck: 1.0,
      EmployeeSkill.patternMaking: 5.0,
    };

    final baseHours = baseHoursPerSkill[skill] ?? 4.0;
    return baseHours + (_random.nextDouble() * 4.0); // Add 0-4 hours variation
  }

  static Map<String, dynamic> _generateMaterialsForAssignment(Order order) {
    final materials = <String, dynamic>{};

    for (final item in order.items) {
      materials['fabric_${item.productId}'] = {
        'type': 'fabric',
        'quantity': '1 ${item.productName}',
        'provided': _random.nextBool(),
      };

      if (_random.nextBool()) {
        materials['thread_${item.productId}'] = {
          'type': 'thread',
          'quantity': '1 spool',
          'provided': true,
        };
      }

      if (_random.nextBool()) {
        materials['buttons_${item.productId}'] = {
          'type': 'buttons',
          'quantity': '4-6 pieces',
          'provided': _random.nextBool(),
        };
      }
    }

    return materials;
  }

  /// Generate chat conversations for customer support
  static Future<void> _populateChatConversations() async {
    print('💬 Generating chat conversations...');

    final conversations = _generateChatConversations();
    final batch = _firestore.batch();

    for (final conversation in conversations) {
      final docRef =
          _firestore.collection('chat_conversations').doc(conversation.id);
      batch.set(docRef, conversation.toJson());
    }

    await batch.commit();
    print('✅ Generated ${conversations.length} chat conversations');

    // Generate messages for each conversation
    await _populateChatMessages(conversations);
  }

  /// Generate diverse chat conversations for customer support
  static List<ChatConversation> _generateChatConversations() {
    final conversations = List<ChatConversation>.empty(growable: true);
    final customers =
        _generateCustomers().take(_chatConversationCount).toList();

    for (int i = 0; i < _chatConversationCount && i < customers.length; i++) {
      final customer = customers[i];
      final conversation = ChatConversation(
        id: 'conversation_${i + 1}',
        userId: customer.id,
        userName: customer.displayName,
        lastMessage: _generateRandomMessage(),
        lastMessageTime: DateTime.now().subtract(
            Duration(minutes: _random.nextInt(1440))), // Last 24 hours
        unreadCount: _random.nextInt(5),
        isActive: _random.nextDouble() > 0.2, // 80% active
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        updatedAt:
            DateTime.now().subtract(Duration(minutes: _random.nextInt(1440))),
      );

      conversations.add(conversation);
    }

    return conversations;
  }

  /// Generate chat messages for conversations
  static Future<void> _populateChatMessages(
      List<ChatConversation> conversations) async {
    final batch = _firestore.batch();

    for (final conversation in conversations) {
      final messageCount =
          _random.nextInt(10) + 5; // 5-15 messages per conversation

      for (int i = 0; i < messageCount; i++) {
        final message = ChatMessage(
          id: 'message_${conversation.id}_${i + 1}',
          conversationId: conversation.id,
          senderId: i % 2 == 0 ? conversation.userId : 'bot_assistant',
          senderType: i % 2 == 0 ? SenderType.user : SenderType.bot,
          content: _generateMessageContent(i % 2 == 0, conversation.userName),
          messageType: _getRandomMessageType(),
          metadata: _generateMessageMetadata(),
          timestamp: conversation.createdAt
              .add(Duration(minutes: i * 15 + _random.nextInt(30))),
          isRead: i <
              messageCount -
                  _random.nextInt(3), // Last few messages might be unread
        );

        final docRef = _firestore.collection('chat_messages').doc(message.id);
        batch.set(docRef, message.toJson());
      }
    }

    await batch.commit();
    print('✅ Generated chat messages for all conversations');
  }

  static String _generateRandomMessage() {
    const messages = [
      'Hello! How can I help you today?',
      'I need help with my order',
      'What are your working hours?',
      'Can you provide a price quote?',
      'How long does it take to complete an order?',
      'I have a question about measurements',
      'Thank you for your assistance!',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  static String _generateMessageContent(bool isUser, String userName) {
    if (isUser) {
      const userMessages = [
        'Hello! I need help with a suit order',
        'What are your prices for shirt stitching?',
        'How long does it take to alter a dress?',
        'I need measurement guidance for a suit',
        'Can you help me choose fabric for a lehenga?',
        'I want to know about your delivery options',
        'Thank you for the quick response!',
        'I have a question about payment methods',
      ];
      return userMessages[_random.nextInt(userMessages.length)];
    } else {
      const botMessages = [
        'Hello! I\'d be happy to help you with your tailoring needs.',
        'Our shirt stitching starts from ₹1,299. Would you like to see our catalog?',
        'Dress alteration takes 3-5 business days. Express service is available.',
        'I can send you our detailed measurement guide. Would you like that?',
        'We have a wide variety of fabrics. What type of garment are you looking for?',
        'We offer free delivery within the city. Express delivery is ₹199 extra.',
        'You\'re welcome! Is there anything else I can assist you with?',
        'We accept cash, card, UPI, and bank transfers. Which is convenient for you?',
      ];
      return botMessages[_random.nextInt(botMessages.length)];
    }
  }

  static MessageType _getRandomMessageType() {
    const types = [
      MessageType.text,
      MessageType.text,
      MessageType.text,
      MessageType.orderStatus
    ];
    return types[_random.nextInt(types.length)];
  }

  static Map<String, dynamic>? _generateMessageMetadata() {
    if (_random.nextDouble() > 0.7) {
      // 30% chance of having metadata
      return {
        'intent': tailoringChatbotIntents[
                _random.nextInt(tailoringChatbotIntents.length)]
            .intent,
        'confidence': 0.8 + _random.nextDouble() * 0.2,
      };
    }
    return null;
  }

  static List<Order> _generateOrders() {
    // Generate some basic orders for work assignments
    final orders = List<Order>.empty(growable: true);
    final customers = _generateCustomers().take(10).toList();
    final products = _generateProducts().take(15).toList();

    for (int i = 0; i < 20; i++) {
      final customer = customers[i % customers.length];
      final productCount = _random.nextInt(3) + 1;
      final items = <OrderItem>[];

      for (int j = 0; j < productCount; j++) {
        final product = products[(i + j) % products.length];
        items.add(OrderItem(
          id: 'item_${i}_$j',
          productId: product.id,
          productName: product.name,
          category: product.category.toString(),
          price: product.basePrice,
          quantity: 1,
          customizations: {},
        ));
      }

      final totalAmount = items.fold(0.0, (total, item) => total + item.price);

      orders.add(Order(
        id: 'work_order_${i + 1}',
        customerId: customer.id,
        items: items,
        status: OrderStatus.values[i % OrderStatus.values.length],
        paymentStatus: i % 2 == 0 ? PaymentStatus.paid : PaymentStatus.pending,
        totalAmount: totalAmount,
        advanceAmount: totalAmount * 0.5,
        remainingAmount: totalAmount * 0.5,
        orderDate: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        measurements: customer.measurements,
        orderImages: [],
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        updatedAt: DateTime.now(),
      ));
    }

    return orders;
  }

  static List<String> _generateAvailableSizes(ProductCategory category) {
    switch (category) {
      case ProductCategory.mensWear:
        return ['38', '39', '40', '41', '42', '43', '44', '46', '48'];
      case ProductCategory.womensWear:
        return ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
      case ProductCategory.kidsWear:
        return ['5-6Y', '7-8Y', '9-10Y', '11-12Y', '13-14Y', '15-16Y'];
      default:
        return ['Standard Size'];
    }
  }

  static List<String> _generateAvailableFabrics(ProductCategory category) {
    switch (category) {
      case ProductCategory.mensWear:
        return ['Cotton', 'Wool', 'Polyester', 'Cotton Blend', 'Linen'];
      case ProductCategory.womensWear:
        return ['Cotton', 'Silk', 'Georgette', 'Chiffon', 'Satin', 'Velvet'];
      case ProductCategory.traditionalWear:
        return ['Silk', 'Brocade', 'Velvet', 'Heavy Silk'];
      default:
        return ['Cotton', 'Polyester', 'Blend'];
    }
  }

  static List<String> _generateCustomizationOptions(ProductCategory category) {
    switch (category) {
      case ProductCategory.mensWear:
        return ['Collar Style', 'Cuff Style', 'Pocket Options', 'Monogramming'];
      case ProductCategory.womensWear:
        return [
          'Length Adjustment',
          'Sleeve Style',
          'Neck Design',
          'Color Choice'
        ];
      case ProductCategory.customDesign:
        return [
          'Design Consultation',
          'Fabric Selection',
          'Style Customization',
          'Accessories'
        ];
      default:
        return ['Size Adjustment', 'Color Choice', 'Style Modification'];
    }
  }

  /// Legacy methods for backward compatibility
  static List<Product> getDemoProducts() {
    final products = _generateProducts();
    return products.take(5).toList();
  }

  static List<Customer> getDemoCustomers() {
    final customers = _generateCustomers();
    return customers.take(3).toList();
  }

  static List<Employee> getDemoEmployees() {
    final employees = _generateEmployees();
    return employees.take(5).toList();
  }

  static List<Order> getDemoOrders() {
    // Generate some basic demo orders for demonstration
    final orders = <Order>[];
    final customers = _generateCustomers().take(5).toList();
    final products = _generateProducts().take(10).toList();

    for (int i = 0; i < 5; i++) {
      final customer = customers[i];
      final product = products[i % products.length];

      orders.add(Order(
        id: 'demo_order_${i + 1}',
        customerId: customer.id,
        items: [
          OrderItem(
            id: 'item_${i + 1}',
            productId: product.id,
            productName: product.name,
            category: product.category.toString(),
            price: product.basePrice,
            quantity: 1,
            customizations: {},
          ),
        ],
        status: OrderStatus.values[i % OrderStatus.values.length],
        paymentStatus: i % 2 == 0 ? PaymentStatus.paid : PaymentStatus.pending,
        totalAmount: product.basePrice,
        advanceAmount: product.basePrice * 0.5,
        remainingAmount: product.basePrice * 0.5,
        orderDate: DateTime.now().subtract(Duration(days: i)),
        measurements: customer.measurements,
        orderImages: [],
        createdAt: DateTime.now().subtract(Duration(days: i)),
        updatedAt: DateTime.now().subtract(Duration(days: i)),
      ));
    }

    return orders;
  }

  static Map<String, dynamic> getOrderStatistics() {
    return {
      'totalOrders': 0,
      'completedOrders': 0,
      'inProgressOrders': 0,
      'totalRevenue': 0.0,
      'pendingPayments': 0.0,
      'averageOrderValue': 0.0,
      'completionRate': 0.0,
      'thisMonthOrders': 0,
      'thisMonthRevenue': 0.0,
    };
  }
}
