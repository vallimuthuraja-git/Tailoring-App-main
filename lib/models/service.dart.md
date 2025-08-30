# Service Model Documentation

## Overview
The `service.dart` file contains the comprehensive service model for the AI-Enabled Tailoring Shop Management System. It defines the structure for various tailoring services, including saree services, garment services, alterations, and custom designs. The model supports complex pricing, customization options, and detailed service specifications.

## Architecture

### Core Classes
- **`Service`**: Main service model with comprehensive properties
- **`ServiceCustomization`**: Defines customization options for services
- **`ServiceTemplates`**: Predefined service templates for common offerings

### Enums
- **`ServiceCategory`**: Service categorization (saree, garments, alterations, etc.)
- **`ServiceType`**: Specific service types within each category
- **`ServiceDuration`**: Time duration categories for services
- **`ServiceComplexity`**: Complexity levels affecting pricing and requirements

## Service Model Properties

### Basic Information
- **`id`**: Unique identifier for the service
- **`name`**: Display name of the service
- **`description`**: Detailed service description
- **`shortDescription`**: Brief description for listings

### Classification
- **`category`**: Service category (saree, garments, etc.)
- **`type`**: Specific service type within the category
- **`duration`**: Time duration category
- **`complexity`**: Complexity level affecting pricing

### Pricing Structure
- **`basePrice`**: Standard service price
- **`minPrice`/`maxPrice`**: Price range for variable services
- **`currency`**: Currency code (default: USD)
- **`tierPricing`**: Multiple pricing tiers (Basic, Standard, Premium)

### Service Details
- **`features`**: List of service features
- **`includedItems`**: What's included in the service
- **`requirements`**: Customer requirements for the service
- **`preparationTips`**: Preparation instructions for customers
- **`specifications`**: Technical specifications map

### Customization & Add-ons
- **`customizations`**: List of `ServiceCustomization` objects
- **`addOns`**: Additional service options
- **`addOnPricing`**: Pricing for add-on services

### Business Logic
- **`isActive`**: Service availability status
- **`requiresMeasurement`**: Whether measurement is needed
- **`requiresFitting`**: Whether fitting session is required
- **`estimatedHours`**: Time estimation for service completion
- **`requiredSkills`**: Skills needed to perform the service
- **`recommendedFabrics`**: Suitable fabric types

### Media & Assets
- **`imageUrls`**: Service image URLs
- **`videoUrl`**: Instructional or promotional video
- **`iconName`**: Icon identifier for UI display

### Metadata & Analytics
- **`createdAt`/`updatedAt`**: Timestamp tracking
- **`additionalInfo`**: Flexible additional data
- **`popularityScore`**: Service popularity metric
- **`averageRating`**: Customer rating average
- **`totalBookings`**: Total booking count

## Service Customization Model

### Properties
- **`id`**: Unique customization identifier
- **`name`**: Display name for the customization
- **`type`**: Input type ('selection', 'text', 'number', 'boolean')
- **`description`**: Explanation of the customization
- **`options`**: Available choices for selection type
- **`defaultValue`**: Pre-selected value
- **`additionalPrice`**: Extra cost for this customization
- **`isRequired`**: Whether customization is mandatory
- **`affectsPricing`**: Whether this affects total price
- **`validation`**: Validation rules map

## Enums Documentation

### ServiceCategory
```dart
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
```

### ServiceType
Comprehensive list including:
- **Saree Services**: draping, pre-pleat, blouse stitching, alterations
- **Garment Services**: dressmaking, suits, shirts, trousers, blouses, kurtis
- **Alteration Services**: hemming, taking in, zipper repair
- **Custom Design**: bespoke design, pattern making, embroidery
- **Special Services**: wedding dresses, bridesmaid dresses, prom dresses

### ServiceDuration
```dart
enum ServiceDuration {
  quick,      // 30 minutes - 2 hours
  standard,   // 2-8 hours
  extended,   // 8-24 hours
  project,    // Multiple days
  ongoing,    // Recurring services
}
```

### ServiceComplexity
```dart
enum ServiceComplexity {
  simple,     // Basic alterations, simple stitching
  moderate,   // Standard garments, minor alterations
  complex,    // Custom designs, intricate work
  expert,     // Bespoke, high-end craftsmanship
}
```

## Key Methods

### Helper Methods
- **`categoryName`**: Returns human-readable category name
- **`typeName`**: Converts enum to readable string
- **`durationText`**: Returns duration description
- **`complexityText`**: Returns complexity description

### Computed Properties
- **`isPopular`**: Returns true if popularity score > 100
- **`isHighlyRated`**: Returns true if rating >= 4.5
- **`isBestseller`**: Returns true if bookings > 50
- **`effectivePrice`**: Calculates actual price based on tier pricing

### Data Methods
- **`fromJson()`**: Factory constructor for Firestore deserialization
- **`toJson()`**: Converts to Firestore-compatible format
- **`copyWith()`**: Creates modified copy of service

## Service Templates

### Predefined Services
The `ServiceTemplates` class provides pre-configured services:

#### Saree Services
1. **Basic Saree Draping**: $25, 1 hour, simple complexity
2. **Standard Pre-pleat**: $75, 4 hours, moderate complexity
3. **Mobile Pre-pleat**: $150, 6 hours, travel included
4. **Blouse Stitching**: $120, 24 hours, custom design

### Service Features
- **Pricing Tiers**: Basic, Standard, Premium, Deluxe options
- **Customization Options**: Fabric type, neck design, sleeve style
- **Detailed Requirements**: Preparation and service requirements
- **Skill Requirements**: Specific skills needed for each service

## Firebase Integration

### Serialization
- **Timestamp Handling**: Proper conversion between Dart DateTime and Firestore Timestamp
- **Enum Storage**: Enums stored as indices for efficient storage
- **Nested Objects**: Customizations and specifications properly serialized

### Data Structure
```json
{
  "id": "service_id",
  "name": "Service Name",
  "category": 0,
  "type": 0,
  "basePrice": 75.0,
  "tierPricing": {"Standard": 75.0, "Premium": 125.0},
  "features": ["Feature 1", "Feature 2"],
  "customizations": [...],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

## Usage Examples

### Creating a Service
```dart
final service = Service(
  id: 'custom_saree_draping',
  name: 'Custom Saree Draping',
  description: 'Professional saree draping service',
  shortDescription: 'Expert saree draping',
  category: ServiceCategory.sareeServices,
  type: ServiceType.sareeDraping,
  duration: ServiceDuration.quick,
  complexity: ServiceComplexity.simple,
  basePrice: 30.0,
  features: ['Traditional draping', 'Blouse adjustment'],
  requiresMeasurement: false,
  estimatedHours: 1,
  requiredSkills: ['saree_draping'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Using Service Templates
```dart
final sareeServices = ServiceTemplates.sareeServices;
final allServices = ServiceTemplates.allServices;
```

### Firebase Operations
```dart
// Save to Firestore
await FirebaseFirestore.instance
    .collection('services')
    .doc(service.id)
    .set(service.toJson());

// Load from Firestore
final doc = await FirebaseFirestore.instance
    .collection('services')
    .doc(serviceId)
    .get();

final service = Service.fromJson(doc.data()!);
```

## Integration Points

### Related Components
- **Service Provider**: Manages service data and state
- **Service List Screen**: Displays available services
- **Order Management**: Uses service data for bookings
- **Employee Management**: Assigns services based on skills

### Dependencies
- **Firebase Firestore**: Data persistence and real-time updates
- **Cloud Firestore**: Timestamp handling
- **Flutter Framework**: Enum and serialization support

## Security Considerations

### Data Validation
- Input validation for all customization fields
- Price range validation to prevent negative values
- Required field validation for critical service data

### Access Control
- Service availability based on user roles
- Employee skill validation for service assignment
- Price visibility based on customer type

## Performance Optimization

### Data Loading
- Lazy loading of service images and media
- Pagination for large service catalogs
- Caching of frequently accessed services

### Search and Filtering
- Category-based filtering for quick access
- Price range filtering for budget-conscious customers
- Popularity and rating-based sorting

## Future Enhancements

### Potential Features
- **AI-Powered Recommendations**: Service suggestions based on customer history
- **Dynamic Pricing**: Real-time price adjustments based on demand
- **Service Bundles**: Package deals combining multiple services
- **Virtual Consultations**: Video-based service consultations
- **Quality Assurance**: Automated quality checks and ratings

This comprehensive service model provides a solid foundation for managing the complex requirements of a tailoring business, supporting everything from simple alterations to complex custom designs with professional-grade features and customization options.