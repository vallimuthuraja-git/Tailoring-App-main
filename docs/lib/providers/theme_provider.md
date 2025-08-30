# Theme Provider

## Overview
The `ThemeProvider` manages application theming with enhanced auto-detection capabilities. It handles theme mode switching, glassmorphism effects, and automatic theme detection based on device characteristics.

## Key Features

### Auto Theme Detection
- **Smart Defaults**: Automatically detects optimal themes for new users
- **Device Awareness**: Adapts themes based on device type and capabilities
- **System Integration**: Respects system theme preferences
- **User Override**: Allows manual theme selection and preferences

### Theme Modes
- **Light Mode**: Clean, bright interface
- **Dark Mode**: Easy on the eyes, battery-efficient
- **System Mode**: Follows device theme settings
- **Glassy Mode**: Advanced visual effects with blur and transparency

## Key Properties

### Core Properties
- `currentTheme`: Current `ThemeMode` (light, dark, system)
- `isDarkMode`: Boolean indicating dark mode state
- `isGlassyMode`: Boolean for glassmorphism effects
- `isAutoDetectEnabled`: Controls automatic theme detection
- `deviceInfo`: Current device information (if available)

### Computed Properties
- `currentThemeData`: Returns appropriate `ThemeData` based on settings
- `isLightMode`: Inverse of `isDarkMode`
- `currentThemeName`: Human-readable theme description
- `currentThemeIcon`: Appropriate icon for current theme

## Key Methods

### Initialization
```dart
await initializeTheme(); // Load saved preferences
await initializeAutoTheme(context); // Auto-detect device theme
```

### Theme Control
```dart
await toggleTheme(); // Switch between light/dark
await switchToLightMode(); // Force light mode
await switchToDarkMode(); // Force dark mode
await enableGlassyMode(); // Enable advanced effects
await followSystemTheme(); // Follow system settings
```

### Auto-Detection Control
```dart
await setAutoDetectEnabled(true); // Enable auto-detection
ThemeRecommendation? recommendation = await getDeviceThemeRecommendation(context);
```

## Auto-Detection Logic

### New User Experience
1. **First Launch**: Detects device type and system preferences
2. **Smart Recommendation**: Applies optimal theme based on device
3. **Save Preferences**: Stores settings for future launches

### Device-Specific Recommendations
- **Mobile**: Prefers dark mode for battery efficiency
- **iOS**: Enables glassmorphism on supported versions
- **Android**: Adapts to Material You capabilities
- **Desktop**: Respects system theme preferences
- **Web**: Adapts to browser theme settings

### Fallback Behavior
- If auto-detection fails, falls back to system theme
- Graceful degradation ensures app remains usable
- User preferences always take precedence

## Integration with Device Detection

The theme provider integrates closely with `DeviceDetectionService`:

```dart
// Get device information
final deviceInfo = await DeviceDetectionService.instance.getDeviceInfo(context);

// Get theme recommendation
final recommendation = DeviceDetectionService.instance.getThemeRecommendation(deviceInfo);

// Apply recommendation
_currentTheme = recommendation.themeMode;
_isDarkMode = recommendation.isDarkMode;
_isGlassyMode = recommendation.useGlassyMode;
```

## Data Persistence

### Shared Preferences Keys
- `_themeKey`: Stores theme mode ('light', 'dark', 'system', 'glassy')
- `_isDarkKey`: Stores dark mode state
- `_autoDetectKey`: Stores auto-detection preference

### Persistence Behavior
- Settings saved automatically when changed
- Preferences restored on app launch
- Auto-detection settings remembered across sessions

## Usage in Widgets

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          color: themeProvider.isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
          child: Text(
            'Current theme: ${themeProvider.currentThemeName}',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
          ),
        );
      },
    );
  }
}
```

## Benefits

1. **Seamless Experience**: Optimal themes without user configuration
2. **Battery Optimization**: Dark mode on mobile devices
3. **Platform Consistency**: Follows platform design guidelines
4. **User Control**: Manual override capabilities
5. **Performance**: Efficient theme switching with minimal rebuilds
6. **Accessibility**: Respects system accessibility preferences