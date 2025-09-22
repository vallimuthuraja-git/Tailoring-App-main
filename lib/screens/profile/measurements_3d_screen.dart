import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer' as developer;
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/common_app_bar_actions.dart';

// Data structure for measurement points
class MeasurementPoint {
  final String name;
  final double
      relativeY; // Relative to container height (0.0 = top, 1.0 = bottom)
  final double startX; // Relative start X (0.0 = left, 1.0 = right)
  final double endX; // Relative end X
  final Color defaultColor;
  final Color selectedColor;

  const MeasurementPoint(
    this.name,
    this.relativeY,
    this.startX,
    this.endX,
    this.defaultColor,
    this.selectedColor,
  );
}

// Predefined measurement points with approximate positions
const List<MeasurementPoint> measurementPoints = [
  MeasurementPoint('chest', 0.55, 0.15, 0.85, Color.fromRGBO(33, 150, 243, 128),
      Color.fromRGBO(33, 150, 243, 255)), // Blue
  MeasurementPoint('waist', 0.65, 0.15, 0.85, Color.fromRGBO(76, 175, 80, 128),
      Color.fromRGBO(76, 175, 80, 255)), // Green
  MeasurementPoint('hip', 0.75, 0.15, 0.85, Color.fromRGBO(255, 152, 0, 128),
      Color.fromRGBO(255, 152, 0, 255)), // Orange
  MeasurementPoint('neck', 0.35, 0.4, 0.6, Color.fromRGBO(156, 39, 176, 128),
      Color.fromRGBO(156, 39, 176, 255)), // Purple
  MeasurementPoint('arms', 0.5, 0.05, 0.25, Color.fromRGBO(244, 67, 54, 128),
      Color.fromRGBO(244, 67, 54, 255)), // Red (left arm)
  MeasurementPoint('inseam', 0.9, 0.45, 0.55, Color.fromRGBO(0, 150, 136, 128),
      Color.fromRGBO(0, 150, 136, 255)), // Teal
];

// Age-adjusted measurement points for children (0-12)
const List<MeasurementPoint> childMeasurementPoints = [
  MeasurementPoint('chest', 0.6, 0.15, 0.85, Color.fromRGBO(33, 150, 243, 128),
      Color.fromRGBO(33, 150, 243, 255)),
  MeasurementPoint('waist', 0.7, 0.15, 0.85, Color.fromRGBO(76, 175, 80, 128),
      Color.fromRGBO(76, 175, 80, 255)),
  MeasurementPoint('hip', 0.8, 0.15, 0.85, Color.fromRGBO(255, 152, 0, 128),
      Color.fromRGBO(255, 152, 0, 255)),
  MeasurementPoint('neck', 0.4, 0.4, 0.6, Color.fromRGBO(156, 39, 176, 128),
      Color.fromRGBO(156, 39, 176, 255)),
  MeasurementPoint('arms', 0.55, 0.05, 0.25, Color.fromRGBO(244, 67, 54, 128),
      Color.fromRGBO(244, 67, 54, 255)),
  MeasurementPoint('inseam', 0.95, 0.45, 0.55, Color.fromRGBO(0, 150, 136, 128),
      Color.fromRGBO(0, 150, 136, 255)),
];

// Age-adjusted measurement points for teens (13-19)
const List<MeasurementPoint> teenMeasurementPoints = [
  MeasurementPoint('chest', 0.58, 0.15, 0.85, Color.fromRGBO(33, 150, 243, 128),
      Color.fromRGBO(33, 150, 243, 255)),
  MeasurementPoint('waist', 0.68, 0.15, 0.85, Color.fromRGBO(76, 175, 80, 128),
      Color.fromRGBO(76, 175, 80, 255)),
  MeasurementPoint('hip', 0.78, 0.15, 0.85, Color.fromRGBO(255, 152, 0, 128),
      Color.fromRGBO(255, 152, 0, 255)),
  MeasurementPoint('neck', 0.38, 0.4, 0.6, Color.fromRGBO(156, 39, 176, 128),
      Color.fromRGBO(156, 39, 176, 255)),
  MeasurementPoint('arms', 0.52, 0.05, 0.25, Color.fromRGBO(244, 67, 54, 128),
      Color.fromRGBO(244, 67, 54, 255)),
  MeasurementPoint('inseam', 0.92, 0.45, 0.55, Color.fromRGBO(0, 150, 136, 128),
      Color.fromRGBO(0, 150, 136, 255)),
];

// Age-adjusted measurement points for seniors (65+)
const List<MeasurementPoint> seniorMeasurementPoints = [
  MeasurementPoint('chest', 0.52, 0.15, 0.85, Color.fromRGBO(33, 150, 243, 128),
      Color.fromRGBO(33, 150, 243, 255)),
  MeasurementPoint('waist', 0.62, 0.15, 0.85, Color.fromRGBO(76, 175, 80, 128),
      Color.fromRGBO(76, 175, 80, 255)),
  MeasurementPoint('hip', 0.72, 0.15, 0.85, Color.fromRGBO(255, 152, 0, 128),
      Color.fromRGBO(255, 152, 0, 255)),
  MeasurementPoint('neck', 0.32, 0.4, 0.6, Color.fromRGBO(156, 39, 176, 128),
      Color.fromRGBO(156, 39, 176, 255)),
  MeasurementPoint('arms', 0.48, 0.05, 0.25, Color.fromRGBO(244, 67, 54, 128),
      Color.fromRGBO(244, 67, 54, 255)),
  MeasurementPoint('inseam', 0.88, 0.45, 0.55, Color.fromRGBO(0, 150, 136, 128),
      Color.fromRGBO(0, 150, 136, 255)),
];

// Function to get responsive camera positions for focusing on measurements
Map<String, cube.Vector3> getResponsiveCameraPositions(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isSmallScreen = screenSize.height < 600;
  double baseZ = isSmallScreen ? 1.0 : 2.0; // Much closer camera position

  return {
    'chest': cube.Vector3(0, 0.1, baseZ),
    'waist': cube.Vector3(0, 0, baseZ),
    'hip': cube.Vector3(0, -0.1, baseZ),
    'neck': cube.Vector3(0, 0.25, baseZ),
    'arms': cube.Vector3(0.5, 0.1, baseZ),
    'inseam': cube.Vector3(0, -0.25, baseZ),
  };
}

// Constants for error handling and debugging
const String _logTag = 'Measurements3DScreen';
const int _maxRetryAttempts = 3;
const Duration _retryDelay = Duration(seconds: 2);

// Debug utility class for comprehensive logging
class _DebugLogger {
  static void log(String message,
      {int level = 700, Object? error, StackTrace? stackTrace}) {
    developer.log(
      '[${DateTime.now().toIso8601String()}] $message',
      name: _logTag,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logState(String component, Map<String, dynamic> state) {
    log('$component State: ${state.toString()}');
  }

  static void logPerformance(String operation, Duration duration) {
    log('$operation completed in ${duration.inMilliseconds}ms');
  }

  static void logAssetInfo(String assetPath, {bool exists = false}) {
    log('Asset $assetPath ${exists ? 'exists' : 'not found'}');
  }
}

// Error tracking system
class _ErrorTracker {
  static final Map<String, List<_TrackedError>> _errors = {};

  static void trackError(String category, String message,
      {Object? error, StackTrace? stackTrace}) {
    final trackedError = _TrackedError(
      timestamp: DateTime.now(),
      category: category,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    if (!_errors.containsKey(category)) {
      _errors[category] = [];
    }
    _errors[category]!.add(trackedError);

    // Keep only last 5 errors per category
    if (_errors[category]!.length > 5) {
      _errors[category]!.removeAt(0);
    }

    _DebugLogger.log('Error tracked [$category]: $message',
        level: 1000, error: error, stackTrace: stackTrace);
  }

  static Map<String, List<_TrackedError>> getAllErrors() {
    return Map.from(_errors);
  }

  static void clearErrors(String category) {
    _errors.remove(category);
  }

  static String getErrorSummary() {
    if (_errors.isEmpty) return 'No errors recorded';

    String summary = 'Error Summary:\n';
    for (final entry in _errors.entries) {
      summary += '${entry.key}: ${entry.value.length} errors\n';
    }
    return summary;
  }
}

class _TrackedError {
  final DateTime timestamp;
  final String category;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  _TrackedError({
    required this.timestamp,
    required this.category,
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() {
    return '[$timestamp] $category: $message${error != null ? ' (Error: $error)' : ''}';
  }
}

// Overlay widget for drawing measurement lines
class MeasurementOverlay extends StatefulWidget {
  final List<MeasurementPoint> points;
  final String? selected;
  final Function(String) onSelect;
  final Function(String) onEdit;

  const MeasurementOverlay({
    super.key,
    required this.points,
    this.selected,
    required this.onSelect,
    required this.onEdit,
  });

  @override
  State<MeasurementOverlay> createState() => _MeasurementOverlayState();
}

class _MeasurementOverlayState extends State<MeasurementOverlay> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: widget.points.map((point) {
            double y = point.relativeY * constraints.maxHeight;
            double startX = point.startX * constraints.maxWidth;
            double endX = point.endX * constraints.maxWidth;
            bool isSelected = widget.selected == point.name;
            Color color = isSelected ? point.selectedColor : point.defaultColor;

            return Positioned(
              left: startX,
              top: y - 2, // Center the line vertically
              child: GestureDetector(
                onTap: () => widget.onSelect(point.name),
                onDoubleTap: () => widget.onEdit(point.name),
                onLongPress: () => widget.onEdit(point.name),
                child: Container(
                  width: endX - startX,
                  height: 4, // Line thickness
                  color: color,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Measurements3DScreen extends StatefulWidget {
  const Measurements3DScreen({super.key});

  @override
  State<Measurements3DScreen> createState() => _Measurements3DScreenState();
}

class _Measurements3DScreenState extends State<Measurements3DScreen> {
  bool _isLoading = false;
  Map<String, Map<String, dynamic>> _measurements = {};
  bool _isInitialized = false;

  // 3D Model state
  cube.Object? _loadedObject;
  bool _isModelLoading = false;
  bool _useFallback = false;
  String? _modelError;
  String? _gender;
  String? _ageGroup;
  int? _age;
  cube.Scene? _scene;

  // Zoom state and constants
  static const double _minZoom = 0.5; // Closest zoom (most zoomed in)
  static const double _maxZoom = 5.0; // Furthest zoom (most zoomed out)
  double _currentZoom = 2.0; // Current zoom level (Z position)

  // Measurement overlay state
  String? selectedMeasurement;

  @override
  void initState() {
    super.initState();
    _DebugLogger.log('Measurements3DScreen initialized');
    _DebugLogger.logState('Initial', {
      'isLoading': _isLoading,
      'isInitialized': _isInitialized,
      'isModelLoading': _isModelLoading,
      'useFallback': _useFallback,
      'gender': _gender,
      'ageGroup': _ageGroup,
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _DebugLogger.log(
          'Post frame callback triggered - starting measurement loading');
      _loadMeasurements();
    });
  }

  Future<void> _loadMeasurements() async {
    final startTime = DateTime.now();
    _DebugLogger.log('Starting measurements loading process');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);

      _DebugLogger.log('Auth provider state', level: 800);
      _DebugLogger.logState('AuthProvider', {
        'hasUserProfile': authProvider.userProfile != null,
        'userId': authProvider.userProfile?.id,
        'isAuthenticated': authProvider.isAuthenticated,
      });

      if (authProvider.userProfile?.id == null) {
        _DebugLogger.log('No user profile ID found - authentication required',
            level: 900);
        _setFallbackDefaults();
        return;
      }

      setState(() => _isLoading = true);
      _DebugLogger.log('Set loading state to true');

      _DebugLogger.log(
          'Loading customer profile for user: ${authProvider.userProfile!.id}');
      await customerProvider.loadCustomerProfile(authProvider.userProfile!.id);
      _DebugLogger.log('Customer profile loaded');

      // Calculate age and age group from user profile with error handling
      final userProfile = authProvider.userProfile!;
      _age = _calculateAge(userProfile.dateOfBirth);
      _ageGroup = _getAgeGroup(_age);

      _DebugLogger.logState('User Demographics', {
        'age': _age,
        'ageGroup': _ageGroup,
        'dateOfBirth': userProfile.dateOfBirth?.toIso8601String(),
      });

      // Ensure gender is loaded with fallback
      _gender = customerProvider.currentCustomer?.gender?.toLowerCase();
      if (_gender == null || (_gender != 'male' && _gender != 'female')) {
        _gender = 'female'; // Default fallback
        _DebugLogger.log('Gender not found or invalid, using default: $_gender',
            level: 800);
      }

      _DebugLogger.logState('Customer Data', {
        'gender': _gender,
        'hasMeasurements':
            customerProvider.currentCustomer?.measurements != null,
        'measurementsCount': // ignore: invalid_null_aware_operator
            (customerProvider.currentCustomer?.measurements.length) ?? 0,
      });

      if (mounted) {
        setState(() {
          _measurements = Map<String, Map<String, dynamic>>.fromEntries(
              (customerProvider.currentCustomer?.measurements ?? {})
                  .entries
                  .map((e) {
            var value = e.value;
            if (value is Map) {
              _DebugLogger.log(
                  'Processing measurement ${e.key} as Map: $value');
              return MapEntry<String, Map<String, dynamic>>(
                  e.key, Map<String, dynamic>.from(value));
            } else {
              double? d =
                  value is double ? value : double.tryParse(value.toString());
              _DebugLogger.log(
                  'Processing measurement ${e.key} as primitive: $value -> $d');
              return MapEntry<String, Map<String, dynamic>>(
                  e.key, {'value': d ?? 0.0, 'unit': 'inches'});
            }
          }));
          _isLoading = false;
          _isInitialized = true;
        });
      }

      _DebugLogger.logPerformance(
          'Measurements Loading', DateTime.now().difference(startTime));
      _DebugLogger.log(
          'Measurements loaded successfully. Gender: $_gender, Age Group: $_ageGroup, Age: $_age');

      // Load 3D model after measurements
      _DebugLogger.log('Initiating 3D model loading');
      await _load3DModel();
    } catch (e, stackTrace) {
      _ErrorTracker.trackError(
          'MeasurementLoading', 'Failed to load measurements',
          error: e, stackTrace: stackTrace);
      _DebugLogger.log('Error loading measurements: $e',
          level: 1000, error: e, stackTrace: stackTrace);
      _setFallbackDefaults();
    }
  }

  void _setFallbackDefaults() {
    if (mounted) {
      setState(() {
        _gender = 'female';
        _ageGroup = 'adult';
        _age = null;
        _measurements = {};
        _isLoading = false;
        _isInitialized = true;
        _useFallback = true;
        _modelError = 'Unable to load user data. Using default settings.';
      });
    }
    developer.log('Fallback defaults set', name: _logTag);
  }

  int? _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String _getAgeGroup(int? age) {
    if (age == null) return 'adult'; // fallback
    if (age <= 12) return 'child';
    if (age <= 19) return 'teen';
    if (age <= 64) return 'adult';
    return 'senior';
  }

  List<MeasurementPoint> get _currentMeasurementPoints {
    switch (_ageGroup) {
      case 'child':
        return childMeasurementPoints;
      case 'teen':
        return teenMeasurementPoints;
      case 'senior':
        return seniorMeasurementPoints;
      default:
        return measurementPoints; // adult
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    if (_isLoading && !_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('3D Measurements'),
          backgroundColor: themeProvider.isDarkMode
              ? DarkAppColors.surface
              : AppColors.surface,
          actions: const [
            CommonAppBarActions(
              showLogout: true,
              showCart: true,
            ),
          ],
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              themeProvider.isDarkMode ? AppColors.primary : AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Measurements'),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _showDebugDialog,
            tooltip: 'Debug Information',
          ),
          const CommonAppBarActions(
            showLogout: true,
            showCart: true,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.isDarkMode
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DarkAppColors.background,
                    DarkAppColors.surface.withValues(alpha: 0.8),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.background,
                  ],
                ),
        ),
        child: SafeArea(
          child: isLargeScreen
              ? Row(
                  children: [
                    // Controls Panel
                    Expanded(
                      flex: 2,
                      child: _buildControlsPanel(themeProvider),
                    ),
                    // 3D Viewport
                    Expanded(
                      flex: 5,
                      child: _build3DViewport(themeProvider),
                    ),
                    // Measurements Panel
                    Expanded(
                      flex: 2,
                      child: _buildMeasurementsPanel(themeProvider),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Controls Panel
                    SizedBox(
                      height: 200,
                      child: _buildControlsPanel(themeProvider),
                    ),
                    // 3D Viewport
                    Expanded(
                      child: _build3DViewport(themeProvider),
                    ),
                    // Measurements Panel
                    SizedBox(
                      height: 300,
                      child: _buildMeasurementsPanel(themeProvider),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildControlsPanel(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onBackground
                      : AppColors.onBackground,
                ),
                const SizedBox(width: 12),
                Text(
                  'Controls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onBackground
                        : AppColors.onBackground,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildControlButton('Rotate', Icons.rotate_right, () {
                  // Rotation is handled by gestures on the Cube widget
                }),
                _buildControlButton('Zoom In', Icons.zoom_in, _zoomIn),
                _buildControlButton('Zoom Out', Icons.zoom_out, _zoomOut),
                _buildControlButton('Pan', Icons.pan_tool, () {
                  // Pan is handled by drag gestures on the Cube widget
                }),
                _buildControlButton('Measure', Icons.straighten, () {
                  // Measurement functionality not implemented yet
                }),
                _buildControlButton('Reset View', Icons.refresh, _resetView),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      String label, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          foregroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackMannequin(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _FallbackMannequinPainter(
          gender: _gender ?? 'female',
          ageGroup: _ageGroup ?? 'adult',
          themeProvider: themeProvider,
        ),
        size: const Size(double.infinity, double.infinity),
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeProvider themeProvider,
      {String? message, IconData? icon, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black54
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color ??
              (themeProvider.isDarkMode
                  ? Colors.white24
                  : Colors.grey.shade300),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16, color: color),
          if (icon != null) const SizedBox(width: 8),
          if (message != null)
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color ??
                    (themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _build3DViewport(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Main 3D view
          if (_modelError != null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show simple 2D mannequin representation as fallback
                Expanded(
                  flex: 3,
                  child: _buildFallbackMannequin(themeProvider),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildStatusIndicator(
                        themeProvider,
                        message: '3D Model Unavailable',
                        icon: Icons.warning,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Showing simplified view. $_modelError',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (mounted) {
                            _DebugLogger.log('User initiated model retry');
                            setState(() {
                              _useFallback = false;
                              _modelError = null;
                            });
                            _load3DModel().then((_) {
                              if (mounted && _scene != null) {
                                _onSceneCreated(_scene!);
                              }
                            }).catchError((error) {
                              if (mounted) {
                                setState(() {
                                  _modelError = 'Retry failed: $error';
                                });
                              }
                            });
                          }
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry Loading'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          else if (_isModelLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  _buildStatusIndicator(
                    themeProvider,
                    message: 'Loading 3D Model...',
                    icon: Icons.hourglass_top,
                    color: AppColors.primary,
                  ),
                ],
              ),
            )
          else
            SizedBox.expand(
              child: cube.Cube(
                onSceneCreated: _onSceneCreated,
              ),
            ),

          // Status overlays
          if (_isModelLoading || _modelError != null || _useFallback)
            Positioned(
              top: 8,
              right: 8,
              child: _buildStatusIndicator(
                themeProvider,
                message: _getStatusMessage(),
                icon: _getStatusIcon(),
                color: _getStatusColor(),
              ),
            ),

          // Measurement overlay (only show when 3D model is loaded)
          if (_scene != null && !_isModelLoading && _modelError == null)
            MeasurementOverlay(
              points: _currentMeasurementPoints,
              selected: selectedMeasurement,
              onSelect: (name) {
                _DebugLogger.log('User selected measurement: $name');
                setState(() => selectedMeasurement = name);
                _focusCamera(name);
              },
              onEdit: _showEditDialog,
            ),

          // Debug overlay (only in debug mode)
          if (_scene != null && !_isModelLoading && _modelError == null)
            Positioned(
              bottom: 8,
              left: 8,
              child: _buildDebugOverlay(themeProvider),
            ),
        ],
      ),
    );
  }

  String _getStatusMessage() {
    if (_modelError != null) return 'Error';
    if (_isModelLoading) return 'Loading';
    if (_useFallback) return 'Fallback Mode';
    if (_scene != null) return '3D Ready';
    return 'Initializing';
  }

  IconData _getStatusIcon() {
    if (_modelError != null) return Icons.error;
    if (_isModelLoading) return Icons.hourglass_top;
    if (_useFallback) return Icons.info;
    if (_scene != null) return Icons.check_circle;
    return Icons.sync;
  }

  Color _getStatusColor() {
    if (_modelError != null) return Colors.red;
    if (_isModelLoading) return Colors.blue;
    if (_useFallback) return Colors.orange;
    if (_scene != null) return Colors.green;
    return Colors.grey;
  }

  Widget _buildDebugOverlay(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black54
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              themeProvider.isDarkMode ? Colors.white24 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Debug Info',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            'Zoom: ${_currentZoom.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            'Model: ${_loadedObject != null ? 'Loaded' : 'None'}',
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            'Selected: ${selectedMeasurement ?? 'None'}',
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsPanel(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.list,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onBackground
                      : AppColors.onBackground,
                ),
                const SizedBox(width: 12),
                Text(
                  'Measurements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onBackground
                        : AppColors.onBackground,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _measurements.length,
              itemBuilder: (context, index) {
                if (index < 0 || index >= _measurements.length) {
                  return const SizedBox.shrink();
                }
                final entry = _measurements.entries.elementAt(index);
                final isSelected = selectedMeasurement == entry.key;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : themeProvider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _formatMeasurementName(entry.key),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : themeProvider.isDarkMode
                                      ? DarkAppColors.onBackground
                                      : AppColors.onBackground,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${entry.value['value']} ${entry.value['unit']}',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSceneCreated(cube.Scene scene) {
    final startTime = DateTime.now();
    _DebugLogger.log('3D scene creation started');

    try {
      _scene = scene;
      _DebugLogger.log('Scene reference stored');

      // Lighting setup
      scene.light.position.setFrom(cube.Vector3(0, 10, 10));
      _DebugLogger.log(
          'Lighting configured at position: ${scene.light.position}');

      // Get screen dimensions for responsive adjustments
      final screenSize = MediaQuery.of(context).size;
      final aspectRatio = screenSize.width / screenSize.height;
      final isSmallScreen = screenSize.height < 600;

      _DebugLogger.logState('Display Context', {
        'screenSize': screenSize.toString(),
        'aspectRatio': aspectRatio,
        'isSmallScreen': isSmallScreen,
        'devicePixelRatio': MediaQuery.of(context).devicePixelRatio,
      });

      // Adjust camera position based on current zoom level
      scene.camera.position.setFrom(cube.Vector3(0, 0, _currentZoom));
      _DebugLogger.log('Camera position set to: ${scene.camera.position}');

      // Adjust field of view for better visibility
      (scene.camera as dynamic).fov = 90.0;
      _DebugLogger.log('Camera FOV set to 90 degrees');

      _DebugLogger.log(
          '3D scene created successfully with responsive settings');
      _DebugLogger.logPerformance(
          'Scene Creation', DateTime.now().difference(startTime));

      // Model loading section
      if (!_useFallback && _gender != null) {
        try {
          final modelPath = _getModelPath();
          _DebugLogger.log('Loading OBJ model into scene: $modelPath');

          _loadedObject = cube.Object(fileName: modelPath);
          _DebugLogger.log('OBJ object created');

          // Apply responsive scaling based on screen size
          double scaleFactor = isSmallScreen ? 3.0 : 4.0;
          _loadedObject!.scale
              .setFrom(cube.Vector3(scaleFactor, scaleFactor, scaleFactor));
          _DebugLogger.log('Model scaling applied: $scaleFactor');

          scene.world.add(_loadedObject!);
          _DebugLogger.log('OBJ model added to scene successfully');

          // Verify model properties
          _DebugLogger.logState('Model Properties', {
            'scale': _loadedObject!.scale.toString(),
            'position': _loadedObject!.position.toString(),
            'rotation': _loadedObject!.rotation.toString(),
          });
        } catch (e, stackTrace) {
          _ErrorTracker.trackError(
              'SceneCreation', 'Failed to add OBJ model to scene',
              error: e, stackTrace: stackTrace);
          _DebugLogger.log('Failed to add OBJ model to scene: $e',
              level: 1000, error: e, stackTrace: stackTrace);
          _setFallbackModel('Failed to add model to scene: $e');
        }
      } else {
        _DebugLogger.log(
            'Using fallback mode - useFallback: $_useFallback, gender: $_gender');
      }
    } catch (e, stackTrace) {
      _ErrorTracker.trackError('SceneCreation', 'Error initializing 3D scene',
          error: e, stackTrace: stackTrace);
      _DebugLogger.log('Error creating 3D scene: $e',
          level: 1000, error: e, stackTrace: stackTrace);
      _setFallbackModel('Error initializing 3D scene: $e');
    }
  }

  String _getModelPath() {
    // Enhanced model path selection based on gender and age group
    String modelFile = 'cube.obj'; // Default fallback

    if (_gender != null && _ageGroup != null) {
      // Try to match specific model files
      if (_gender == 'male') {
        switch (_ageGroup) {
          case 'child':
            modelFile = 'male_child.obj';
            break;
          case 'teen':
            modelFile = 'male_teen.obj';
            break;
          case 'adult':
            modelFile = 'male_adult.obj';
            break;
          case 'senior':
            modelFile = 'male_senior.obj';
            break;
        }
      } else if (_gender == 'female') {
        switch (_ageGroup) {
          case 'child':
            modelFile = 'female_child.obj';
            break;
          case 'teen':
            modelFile = 'female_teen.obj';
            break;
          case 'adult':
            modelFile = 'female_adult.obj';
            break;
          case 'senior':
            modelFile = 'female_senior.obj';
            break;
        }
      }
    }

    final modelPath = 'assets/models/$modelFile';
    _DebugLogger.log(
        'Selected model path: $modelPath (gender: $_gender, ageGroup: $_ageGroup)');
    return modelPath;
  }

  Future<void> _load3DModel() async {
    final startTime = DateTime.now();
    _DebugLogger.log('Starting 3D model loading process');
    _DebugLogger.logState('Model Loading Context', {
      'gender': _gender,
      'ageGroup': _ageGroup,
      'age': _age,
      'screenSize': MediaQuery.of(context).size.toString(),
      'pixelRatio': MediaQuery.of(context).devicePixelRatio,
    });

    if (_gender == null) {
      _DebugLogger.log('Cannot load 3D model: gender is null', level: 800);
      _setFallbackModel('Gender information is required for 3D model loading.');
      return;
    }

    int attempt = 0;
    while (attempt < _maxRetryAttempts) {
      try {
        _DebugLogger.log(
            'Model loading attempt ${attempt + 1}/$_maxRetryAttempts');

        setState(() {
          _isModelLoading = true;
          _modelError = null;
          _useFallback = false;
        });

        final modelPath = _getModelPath();
        _DebugLogger.log('Attempting to load model: $modelPath');

        // Check asset availability first
        try {
          final assetManifest =
              await rootBundle.loadString('AssetManifest.json');
          final assetExists = assetManifest.contains(modelPath);
          _DebugLogger.logAssetInfo(modelPath, exists: assetExists);

          if (!assetExists) {
            throw Exception('Asset not found in manifest');
          }
        } catch (manifestError) {
          _DebugLogger.log('Failed to check asset manifest: $manifestError',
              level: 800);
        }

        // Check if the OBJ file exists by trying to load it
        final modelData = await rootBundle.loadString(modelPath);
        _DebugLogger.log(
            'Model file loaded successfully: $modelData.length characters');

        // If successful, log success and exit
        _DebugLogger.log('Model loaded successfully: $modelPath');
        _DebugLogger.logPerformance(
            '3D Model Loading', DateTime.now().difference(startTime));

        setState(() {
          _isModelLoading = false;
        });
        return;
      } catch (e, stackTrace) {
        attempt++;
        _ErrorTracker.trackError(
            'ModelLoading', 'Model loading attempt $attempt failed',
            error: e, stackTrace: stackTrace);
        _DebugLogger.log('Model loading attempt $attempt failed: $e',
            level: 900, error: e, stackTrace: stackTrace);

        if (attempt < _maxRetryAttempts) {
          _DebugLogger.log('Retrying after ${_retryDelay.inSeconds} seconds');
          await Future.delayed(_retryDelay);
        } else {
          // All attempts failed, use fallback
          final errorMessage =
              'Failed to load 3D model after $attempt attempts: $e';
          _ErrorTracker.trackError(
              'ModelLoading', 'All attempts failed - using fallback');
          _DebugLogger.log(errorMessage, level: 1000);
          _setFallbackModel(errorMessage);
        }
      }
    }
  }

  void _setFallbackModel(String errorMessage) {
    if (mounted) {
      setState(() {
        _useFallback = true;
        _modelError = errorMessage;
        _isModelLoading = false;
      });
    }
    developer.log('Using fallback model: $errorMessage',
        name: _logTag, level: 800);
  }

  void _focusCamera(String name) {
    _DebugLogger.log('Focusing camera on measurement: $name');
    if (_scene != null) {
      final responsivePositions = getResponsiveCameraPositions(context);
      final targetPosition = responsivePositions[name];
      if (targetPosition != null) {
        final newPosition = cube.Vector3(
          targetPosition.x,
          targetPosition.y,
          _currentZoom,
        );
        _scene!.camera.position.setFrom(newPosition);
        _DebugLogger.log('Camera focused to position: $newPosition');
      } else {
        _DebugLogger.log('No responsive position found for measurement: $name',
            level: 800);
      }
    } else {
      _DebugLogger.log('Cannot focus camera - scene is null', level: 800);
    }
  }

  void _zoomIn() {
    _DebugLogger.log('Zoom in requested - current zoom: $_currentZoom');
    if (_scene != null) {
      setState(() {
        _currentZoom = (_currentZoom - 0.5).clamp(_minZoom, _maxZoom);
        _scene!.camera.position.setFrom(cube.Vector3(0, 0, _currentZoom));
        _DebugLogger.log('Zoomed in to: $_currentZoom');
      });
    } else {
      _DebugLogger.log('Cannot zoom in - scene is null', level: 800);
    }
  }

  void _zoomOut() {
    _DebugLogger.log('Zoom out requested - current zoom: $_currentZoom');
    if (_scene != null) {
      setState(() {
        _currentZoom = (_currentZoom + 0.5).clamp(_minZoom, _maxZoom);
        _scene!.camera.position.setFrom(cube.Vector3(0, 0, _currentZoom));
        _DebugLogger.log('Zoomed out to: $_currentZoom');
      });
    } else {
      _DebugLogger.log('Cannot zoom out - scene is null', level: 800);
    }
  }

  void _resetView() {
    _DebugLogger.log('Reset view requested');
    if (_scene != null) {
      final screenSize = MediaQuery.of(context).size;
      final isSmallScreen = screenSize.height < 600;
      double resetZ = isSmallScreen ? 1.0 : 2.0;
      setState(() {
        _currentZoom = resetZ;
        _scene!.camera.position.setFrom(cube.Vector3(0, 0, _currentZoom));
        // Reset FOV
        (_scene!.camera as dynamic).fov = 90.0;
        _DebugLogger.log(
            'View reset - zoom: $_currentZoom, FOV: 90.0, smallScreen: $isSmallScreen');
      });
    } else {
      _DebugLogger.log('Cannot reset view - scene is null', level: 800);
    }
  }

  void _showEditDialog(String name) {
    final current = _measurements[name] ?? {'value': 0.0, 'unit': 'inches'};
    double value = current['value'];
    String unit = current['unit'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit ${_formatMeasurementName(name)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: value.toString(),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Value'),
                validator: (val) {
                  double? d = double.tryParse(val ?? '');
                  if (d == null || d <= 0) return 'Enter positive number';
                  return null;
                },
                onChanged: (val) {
                  double? d = double.tryParse(val);
                  if (d != null) value = d;
                },
              ),
              DropdownButton<String>(
                value: unit,
                items: ['inches', 'cm']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) => setState(() => unit = val!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            TextButton(
                onPressed: () {
                  if (value > 0) {
                    _saveMeasurement(name, value, unit, ctx);
                  }
                },
                child: Text('Save')),
          ],
        ),
      ),
    );
  }

  void _showDebugDialog() {
    final errorSummary = _ErrorTracker.getErrorSummary();
    final allErrors = _ErrorTracker.getAllErrors();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System State:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Gender: $_gender'),
              Text('• Age Group: $_ageGroup'),
              Text('• Age: $_age'),
              Text('• Measurements: ${_measurements.length} loaded'),
              Text('• Model Loading: $_isModelLoading'),
              Text('• Fallback Mode: $_useFallback'),
              Text('• Scene Created: ${_scene != null}'),
              const SizedBox(height: 16),
              Text('Errors:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(errorSummary),
              if (allErrors.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Recent Errors:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...allErrors.entries.expand((entry) {
                  return [
                    Text('${entry.key}:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    ...entry.value.map((error) => Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text('• ${error.message}',
                              style: TextStyle(fontSize: 12)),
                        )),
                  ];
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (final category in _ErrorTracker.getAllErrors().keys) {
                _ErrorTracker.clearErrors(category);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Clear Errors'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMeasurement(String name, double value, String unit,
      BuildContext dialogContext) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userProfile?.id;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('measurements')
          .doc(name)
          .set({
        'value': value,
        'unit': unit,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          _measurements[name] = {'value': value, 'unit': unit};
        });
        // Check if dialog context can pop after state update
        if (Navigator.canPop(dialogContext)) {
          Navigator.pop(
              dialogContext); // ignore: use_build_context_synchronously
        }
      }
    }
  }

  String _formatMeasurementName(String key) {
    if (key.isEmpty) return key;
    final words = key.split(RegExp(r'(?=[A-Z])'));
    final joined = words.join(' ');
    return joined.isEmpty
        ? joined
        : joined[0].toUpperCase() + joined.substring(1);
  }
}

// Custom painter for fallback mannequin representation
class _FallbackMannequinPainter extends CustomPainter {
  final String gender;
  final String ageGroup;
  final ThemeProvider themeProvider;

  const _FallbackMannequinPainter({
    required this.gender,
    required this.ageGroup,
    required this.themeProvider,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeProvider.isDarkMode ? Colors.white70 : Colors.black54
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final scale = size.height / 200; // Scale based on height

    // Head
    canvas.drawCircle(Offset(centerX, 20 * scale), 15 * scale, paint);

    // Body
    final bodyHeight = ageGroup == 'child' ? 60 * scale : 80 * scale;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, 50 * scale),
        width: 30 * scale,
        height: bodyHeight,
      ),
      paint,
    );

    // Arms
    final armLength = gender == 'male' ? 35 * scale : 30 * scale;
    canvas.drawLine(
      Offset(centerX - 15 * scale, 40 * scale),
      Offset(centerX - 15 * scale - armLength, 60 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 15 * scale, 40 * scale),
      Offset(centerX + 15 * scale + armLength, 60 * scale),
      paint,
    );

    // Legs
    final legLength = ageGroup == 'senior' ? 50 * scale : 60 * scale;
    canvas.drawLine(
      Offset(centerX - 10 * scale, 50 * scale + bodyHeight / 2),
      Offset(centerX - 10 * scale, 50 * scale + bodyHeight / 2 + legLength),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 10 * scale, 50 * scale + bodyHeight / 2),
      Offset(centerX + 10 * scale, 50 * scale + bodyHeight / 2 + legLength),
      paint,
    );

    // Add measurement lines if available
    _drawMeasurementLines(canvas, size, paint, scale);
  }

  void _drawMeasurementLines(
      Canvas canvas, Size size, Paint paint, double scale) {
    final linePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Chest line
    canvas.drawLine(
      Offset(size.width * 0.15, 35 * scale),
      Offset(size.width * 0.85, 35 * scale),
      linePaint,
    );

    // Waist line
    canvas.drawLine(
      Offset(size.width * 0.15, 65 * scale),
      Offset(size.width * 0.85, 65 * scale),
      linePaint,
    );

    // Hip line
    canvas.drawLine(
      Offset(size.width * 0.15, 95 * scale),
      Offset(size.width * 0.85, 95 * scale),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_FallbackMannequinPainter oldDelegate) {
    return oldDelegate.gender != gender ||
        oldDelegate.ageGroup != ageGroup ||
        oldDelegate.themeProvider != themeProvider;
  }
}
