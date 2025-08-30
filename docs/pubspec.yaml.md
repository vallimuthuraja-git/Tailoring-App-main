# pubspec.yaml

## Overview
The `pubspec.yaml` file is the project configuration file for the AI-Enabled Tailoring Shop Management System Flutter application. It defines project metadata, dependencies, assets, and build configuration.

## Key Configuration Sections

### Project Metadata
```yaml
name: tailoring_app
description: AI-Enabled Web-Based Tailoring Shop Management System
version: 1.0.0+1
```

### Environment Requirements
```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"
```

## Dependencies

### Core Flutter Dependencies
- **`flutter`**: SDK dependency with material design support
- **`cupertino_icons`**: iOS-style icons for Flutter
- **`intl`**: Internationalization support
- **`http`**: HTTP client for API calls
- **`shared_preferences`**: Local data persistence
- **`image_picker`**: Image selection from gallery/camera
- **`path_provider`**: File system path management

### UI & Theming
- **`flex_color_scheme`**: Advanced color scheme management
  - Related: [`lib/providers/theme_provider.dart`](../lib/providers/theme_provider.md)
  - Related: [`lib/utils/theme_constants.dart`](../lib/utils/theme_constants.md)

### Firebase Integration
- **`firebase_core`**: Core Firebase functionality
- **`firebase_auth`**: User authentication
  - Related: [`lib/services/auth_service.dart`](../lib/services/auth_service.md)
  - Related: [`lib/providers/auth_provider.dart`](../lib/providers/auth_provider.md)
- **`cloud_firestore`**: NoSQL database
  - Related: [`lib/services/firebase_service.dart`](../lib/services/firebase_service.md)

### Platform Integration
- **`connectivity_plus`**: Network connectivity monitoring
- **`device_info_plus`**: Device information detection
  - Related: [`lib/services/device_detection_service.dart`](../lib/services/device_detection_service.md)
- **`sqflite`**: Local SQLite database
  - Related: [`lib/services/offline_storage_service.dart`](../lib/services/offline_storage_service.md)

### State Management
- **`provider`**: State management solution
  - Used in: [`lib/providers/`](../lib/providers/) (all provider files)

### PWA & Web Support
- **`flutter_web_plugins`**: Web platform support

## Development Dependencies
- **`flutter_test`**: Unit testing framework
- **`flutter_lints`**: Code linting rules
- **`integration_test`**: Integration testing
- **`flutter_launcher_icons`**: App icon generation

## Asset Configuration

### Image Assets
```yaml
assets:
  - assets/images/
  - assets/icons/
```

### Font Configuration
```yaml
flutter:
  uses-material-design: true
```

## Integration Points

### Theme System Integration
- **Color Schemes**: [`flex_color_scheme`] enables advanced theming
- **Device Detection**: [`device_info_plus`] supports auto theme detection
- **Theme Constants**: Integrates with [`lib/utils/theme_constants.dart`](../lib/utils/theme_constants.md)

### Authentication Integration
- **Firebase Auth**: Enables secure user authentication
- **Auth Services**: Connects to [`lib/services/auth_service.dart`](../lib/services/auth_service.md)
- **Auth Provider**: Links with [`lib/providers/auth_provider.dart`](../lib/providers/auth_provider.md)

### Data Management Integration
- **Cloud Firestore**: Backend database for all data models
- **Firebase Service**: Connects to [`lib/services/firebase_service.dart`](../lib/services/firebase_service.md)
- **Offline Storage**: Uses [`sqflite`] for local data caching

### Network & Connectivity
- **Connectivity Monitoring**: [`connectivity_plus`] for network state detection
- **Offline Support**: Enables [`lib/services/offline_storage_service.dart`](../lib/services/offline_storage_service.md)

## Build & Deployment Impact

### Web PWA Features
- **PWA Support**: Configured for web deployment
- **Offline Capability**: Service worker support through Flutter
- **Responsive Design**: Cross-platform compatibility

### Platform-Specific Optimizations
- **Mobile Optimization**: iOS and Android specific features
- **Web Optimization**: PWA features and web-specific enhancements
- **Desktop Support**: Windows, macOS, Linux compatibility

## Security Considerations

### Firebase Security
- **Authentication**: Secure user authentication flow
- **Data Security**: Firestore security rules integration
- **API Security**: Secure communication with backend services

### Local Data Security
- **Shared Preferences**: Secure local data storage
- **SQLite Encryption**: Local database security considerations

## Performance Impact

### Bundle Size
- **Minimal Dependencies**: Only essential packages included
- **Tree Shaking**: Unused code automatically removed
- **Asset Optimization**: Efficient asset loading

### Runtime Performance
- **Provider Optimization**: Efficient state management
- **Firebase Optimization**: Efficient data synchronization
- **Image Optimization**: Efficient image handling

## Development Workflow

### Hot Reload Support
- **Development Efficiency**: Fast development iteration
- **State Preservation**: Maintains app state during development
- **Error Handling**: Comprehensive error reporting

### Testing Integration
- **Unit Tests**: [`flutter_test`] framework
- **Integration Tests**: [`integration_test`] for full app testing
- **Code Quality**: [`flutter_lints`] for code standards

## Version Management

### Dependency Versions
- **Pinned Versions**: Specific versions for stability
- **Compatibility**: Ensured compatibility across packages
- **Updates**: Regular dependency updates for security and features

### Flutter SDK Requirements
- **Minimum SDK**: 3.0.0 for modern Flutter features
- **Maximum SDK**: <4.0.0 for stability
- **Flutter Version**: >=3.0.0 for latest features

## Related Files

### Configuration Files
- [`firebase.json`](../firebase.json.md) - Firebase project configuration
- [`analysis_options.yaml`](../analysis_options.yaml.md) - Code analysis rules
- [`web/manifest.json`](../web/manifest.json.md) - PWA manifest

### Core Application Files
- [`lib/main.dart`](../lib/main.dart.md) - Application entry point
- [`lib/firebase_options.dart`](../lib/firebase_options.md) - Firebase configuration

### Service Integration Files
- [`lib/services/firebase_service.dart`](../lib/services/firebase_service.md) - Firebase operations
- [`lib/services/auth_service.dart`](../lib/services/auth_service.md) - Authentication service
- [`lib/services/device_detection_service.dart`](../lib/services/device_detection_service.md) - Device detection

## Benefits

1. **Centralized Configuration**: Single source of truth for project setup
2. **Dependency Management**: Clean package management and updates
3. **Platform Support**: Cross-platform compatibility
4. **Performance Optimization**: Optimized for production deployment
5. **Security Integration**: Built-in security best practices
6. **Developer Experience**: Excellent development workflow support

## Maintenance Notes

### Regular Updates
- **Security Updates**: Regular dependency security updates
- **Feature Updates**: Latest package features and improvements
- **Compatibility**: Ensure compatibility with Flutter SDK updates

### Dependency Analysis
- **Bundle Impact**: Monitor impact on app bundle size
- **Performance Impact**: Track performance implications of updates
- **Compatibility Testing**: Test across all target platforms

---

*This configuration enables the AI-Enabled Tailoring Shop Management System to run efficiently across web, mobile, and desktop platforms with comprehensive theming, authentication, and data management capabilities.*