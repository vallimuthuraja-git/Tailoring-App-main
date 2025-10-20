import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/theme_constants.dart';
import '../../widgets/common_app_bar_actions.dart';

// Avatar customization data structures
class AvatarCustomization {
  Color skinTone;
  Color hairColor;
  Color eyeColor;
  String hairStyle;
  String topClothing;
  String bottomClothing;
  String shoes;
  Map<String, Color> accessories;

  AvatarCustomization({
    this.skinTone = const Color(0xFFF5DEB3),
    this.hairColor = const Color(0xFF8B4513),
    this.eyeColor = const Color(0xFF4A90E2),
    this.hairStyle = 'short',
    this.topClothing = 'shirt',
    this.bottomClothing = 'pants',
    this.shoes = 'sneakers',
    Map<String, Color>? accessories,
  }) : accessories = accessories ?? {};

  Map<String, dynamic> toJson() {
    return {
      'skinTone': skinTone.toARGB32(),
      'hairColor': hairColor.toARGB32(),
      'eyeColor': eyeColor.toARGB32(),
      'hairStyle': hairStyle,
      'topClothing': topClothing,
      'bottomClothing': bottomClothing,
      'shoes': shoes,
      'accessories':
          accessories.map((key, value) => MapEntry(key, value.toARGB32())),
    };
  }

  factory AvatarCustomization.fromJson(Map<String, dynamic> json) {
    return AvatarCustomization(
      skinTone: Color(json['skinTone'] ?? 0xFFF5DEB3),
      hairColor: Color(json['hairColor'] ?? 0xFF8B4513),
      eyeColor: Color(json['eyeColor'] ?? 0xFF4A90E2),
      hairStyle: json['hairStyle'] ?? 'short',
      topClothing: json['topClothing'] ?? 'shirt',
      bottomClothing: json['bottomClothing'] ?? 'pants',
      shoes: json['shoes'] ?? 'sneakers',
      accessories: (json['accessories'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, Color(value))) ??
          {},
    );
  }
}

// Predefined customization options
class AvatarOptions {
  static const List<Color> skinTones = [
    Color(0xFFF5DEB3), // Light
    Color(0xFFD2B48C), // Medium light
    Color(0xFFBC9867), // Medium
    Color(0xFFA0522D), // Medium dark
    Color(0xFF8B4513), // Dark
  ];

  static const List<Color> hairColors = [
    Color(0xFF1A1A1A), // Black
    Color(0xFF8B4513), // Brown
    Color(0xFFDAA520), // Blonde
    Color(0xFFFF4500), // Red
    Color(0xFFFFFFFF), // White
  ];

  static const List<Color> eyeColors = [
    Color(0xFF4A90E2), // Blue
    Color(0xFF2E8B57), // Green
    Color(0xFF8B4513), // Brown
    Color(0xFF000000), // Black
    Color(0xFF808080), // Gray
  ];

  static const List<String> hairStyles = [
    'short',
    'medium',
    'long',
    'curly',
    'bald'
  ];

  static const List<String> topClothing = [
    'shirt',
    't-shirt',
    'jacket',
    'dress',
    'blouse'
  ];

  static const List<String> bottomClothing = [
    'pants',
    'jeans',
    'shorts',
    'skirt',
    'leggings'
  ];

  static const List<String> shoes = [
    'sneakers',
    'boots',
    'heels',
    'sandals',
    'dress_shoes'
  ];
}

class AvatarCustomizationScreen extends StatefulWidget {
  const AvatarCustomizationScreen({super.key});

  @override
  State<AvatarCustomizationScreen> createState() =>
      _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends State<AvatarCustomizationScreen>
    with TickerProviderStateMixin {
  late AvatarCustomization _customization;
  bool _isLoading = false;
  cube.Object? _avatarObject;
  cube.Scene? _scene;
  String? _modelError;

  // Camera controls
  double _zoom = 3.0;
  static const double _minZoom = 1.5;
  static const double _maxZoom = 8.0;

  // Animation
  AnimationController? _animationController;

  // Selected category for customization
  String _selectedCategory = 'appearance';

  @override
  void initState() {
    super.initState();
    _customization = AvatarCustomization();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _loadAvatarCustomization();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadAvatarCustomization() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userProfile?.id;

    if (userId != null) {
      setState(() => _isLoading = true);
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('avatar')
            .doc('customization')
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _customization = AvatarCustomization.fromJson(data);
        }
      } catch (e) {
        debugdebugPrint('Error loading avatar customization: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveAvatarCustomization() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userProfile?.id;

    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('avatar')
            .doc('customization')
            .set(_customization.toJson());
      } catch (e) {
        debugdebugPrint('Error saving avatar customization: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save avatar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 1200;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Avatar Customization')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Customization'),
        backgroundColor: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAvatarCustomization,
            tooltip: 'Save Avatar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _resetCustomization(),
            tooltip: 'Reset to Default',
          ),
          const CommonAppBarActions(showLogout: true),
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
                    Expanded(
                        flex: 3, child: _buildAvatarViewport(themeProvider)),
                    Expanded(
                        flex: 2,
                        child: _buildCustomizationPanel(themeProvider)),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      height: screenSize.height * 0.4,
                      child: _buildAvatarViewport(themeProvider),
                    ),
                    Expanded(child: _buildCustomizationPanel(themeProvider)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAvatarViewport(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          _build3DViewport(themeProvider),
          _buildViewportControls(themeProvider),
          if (_modelError != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Model Error: $_modelError',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _build3DViewport(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _modelError != null
            ? _buildFallbackAvatar(themeProvider)
            : cube.Cube(
                onSceneCreated: _onSceneCreated,
              ),
      ),
    );
  }

  Widget _buildFallbackAvatar(ThemeProvider themeProvider) {
    return Container(
      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: _customization.skinTone,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: _customization.skinTone.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Head
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: _customization.skinTone,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _customization.eyeColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  // Body
                  Container(
                    width: 40,
                    height: 60,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '3D Model Unavailable',
              style: TextStyle(
                color:
                    themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewportControls(ThemeProvider themeProvider) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildControlButton(
            Icons.rotate_right,
            () => _startRotation(),
            'Rotate',
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            Icons.zoom_in,
            () => _zoomIn(),
            'Zoom In',
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            Icons.zoom_out,
            () => _zoomOut(),
            'Zoom Out',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      IconData icon, VoidCallback onPressed, String tooltip) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCustomizationPanel(ThemeProvider themeProvider) {
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
        children: [
          _buildCategoryTabs(themeProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCategoryContent(themeProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ThemeProvider themeProvider) {
    final categories = ['appearance', 'clothing', 'accessories'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryContent(ThemeProvider themeProvider) {
    switch (_selectedCategory) {
      case 'appearance':
        return _buildAppearancePanel(themeProvider);
      case 'clothing':
        return _buildClothingPanel(themeProvider);
      case 'accessories':
        return _buildAccessoriesPanel(themeProvider);
      default:
        return _buildAppearancePanel(themeProvider);
    }
  }

  Widget _buildAppearancePanel(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Skin Tone', themeProvider),
        _buildColorSelector(
          AvatarOptions.skinTones,
          _customization.skinTone,
          (color) => setState(() => _customization.skinTone = color),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Hair Color', themeProvider),
        _buildColorSelector(
          AvatarOptions.hairColors,
          _customization.hairColor,
          (color) => setState(() => _customization.hairColor = color),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Eye Color', themeProvider),
        _buildColorSelector(
          AvatarOptions.eyeColors,
          _customization.eyeColor,
          (color) => setState(() => _customization.eyeColor = color),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Hair Style', themeProvider),
        _buildOptionSelector(
          AvatarOptions.hairStyles,
          _customization.hairStyle,
          (style) => setState(() => _customization.hairStyle = style),
        ),
      ],
    );
  }

  Widget _buildClothingPanel(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Top', themeProvider),
        _buildOptionSelector(
          AvatarOptions.topClothing,
          _customization.topClothing,
          (top) => setState(() => _customization.topClothing = top),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Bottom', themeProvider),
        _buildOptionSelector(
          AvatarOptions.bottomClothing,
          _customization.bottomClothing,
          (bottom) => setState(() => _customization.bottomClothing = bottom),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Shoes', themeProvider),
        _buildOptionSelector(
          AvatarOptions.shoes,
          _customization.shoes,
          (shoe) => setState(() => _customization.shoes = shoe),
        ),
      ],
    );
  }

  Widget _buildAccessoriesPanel(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Accessories', themeProvider),
        Text(
          'Coming soon! Support for glasses, hats, jewelry, and more.',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: themeProvider.isDarkMode
              ? DarkAppColors.onBackground
              : AppColors.onBackground,
        ),
      ),
    );
  }

  Widget _buildColorSelector(
    List<Color> colors,
    Color selectedColor,
    Function(Color) onColorSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionSelector(
    List<String> options,
    String selectedOption,
    Function(String) onOptionSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selectedOption;
        return GestureDetector(
          onTap: () => onOptionSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              option.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onSceneCreated(cube.Scene scene) {
    _scene = scene;

    // Configure lighting
    scene.light.position.setFrom(cube.Vector3(0, 10, 10));

    // Configure camera
    scene.camera.position.setFrom(cube.Vector3(0, 0, _zoom));

    // Load avatar model
    _loadAvatarModel();
  }

  Future<void> _loadAvatarModel() async {
    try {
      // Use the custom_centered_body.obj as base model
      final modelPath = 'assets/models/custom_centered_body.obj';
      _avatarObject = cube.Object(fileName: modelPath);

      // Scale and position the model
      _avatarObject!.scale.setFrom(cube.Vector3(2.0, 2.0, 2.0));
      _avatarObject!.position.setFrom(cube.Vector3(0, -1, 0));

      // Add to scene
      _scene!.world.add(_avatarObject!);

      // Apply current customization (basic material changes)
      _applyCustomizationToModel();

      setState(() {
        _modelError = null;
      });
    } catch (e) {
      setState(() {
        _modelError = 'Failed to load 3D model: $e';
      });
      debugdebugPrint('Error loading avatar model: $e');
    }
  }

  void _applyCustomizationToModel() {
    if (_avatarObject != null) {
      // This is a simplified implementation
      // In a full implementation, you'd modify materials, textures, etc.
      // For now, we'll just update the visual state
      _updateModelMaterials();
    }
  }

  void _updateModelMaterials() {
    // Placeholder for material/texture updates
    // In a real implementation, this would change colors, textures, etc.
    debugdebugPrint(
        'Updating avatar with customization: ${_customization.toJson()}');
  }

  void _startRotation() {
    if (_animationController != null && !_animationController!.isAnimating) {
      _animationController!.reset();
      _animationController!.forward();
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom = max(_minZoom, _zoom - 0.5);
      if (_scene != null) {
        _scene!.camera.position.setFrom(cube.Vector3(0, 0, _zoom));
      }
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = min(_maxZoom, _zoom + 0.5);
      if (_scene != null) {
        _scene!.camera.position.setFrom(cube.Vector3(0, 0, _zoom));
      }
    });
  }

  void _resetCustomization() {
    setState(() {
      _customization = AvatarCustomization();
      _zoom = 3.0;
      _applyCustomizationToModel();
    });
  }
}


