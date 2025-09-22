import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';

class SearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onVoiceSearch;

  const SearchBar({
    super.key,
    required this.onSearch,
    required this.onVoiceSearch,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _isSearching = query.isNotEmpty;
      _showSuggestions = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _updateSuggestions(query);
    } else {
      _suggestions.clear();
    }

    widget.onSearch(query);
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions =
          _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
    });
  }

  void _updateSuggestions(String query) {
    // Mock suggestions - in real implementation, fetch from Firebase
    _suggestions = [
      'Custom suits',
      'Wedding dresses',
      'Shirts',
      'Pants',
      'Traditional wear',
      'Alterations',
    ]
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    widget.onSearch(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final deviceType = ResponsiveUtils.getDeviceTypeFromContext(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      child: Column(
        children: [
          // Search Bar
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface
                          : AppColors.onSurface,
                      fontSize: getResponsiveFontSize(16),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search products, services, or styles...',
                      hintStyle: TextStyle(
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                            : AppColors.onSurface.withValues(alpha: 0.6),
                        fontSize: getResponsiveFontSize(14),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                        size: getResponsiveFontSize(24),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSearching)
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface
                                        .withValues(alpha: 0.7)
                                    : AppColors.onSurface
                                        .withValues(alpha: 0.7),
                                size: getResponsiveFontSize(20),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchFocusNode.unfocus();
                              },
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: themeProvider.isDarkMode
                                  ? DarkAppColors.primary
                                  : AppColors.primary,
                              size: getResponsiveFontSize(24),
                            ),
                            onPressed: widget.onVoiceSearch,
                            tooltip: 'Voice Search',
                          ),
                        ],
                      ),
                      filled: true,
                      fillColor: themeProvider.isDarkMode
                          ? DarkAppColors.surface
                          : AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                              : AppColors.onSurface.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: themeProvider.isDarkMode
                              ? DarkAppColors.primary
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getResponsiveSpacing(context, 20.0),
                        vertical:
                            ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                      ),
                    ),
                    onSubmitted: (query) {
                      _searchFocusNode.unfocus();
                      widget.onSearch(query);
                    },
                  ),
                ),
              );
            },
          ),

          // Suggestions Dropdown
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.1)
                      : AppColors.onSurface.withValues(alpha: 0.1),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: deviceType == DeviceType.mobile ? 200 : 300,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return InkWell(
                    onTap: () => _onSuggestionTap(suggestion),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                        vertical:
                            ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: getResponsiveFontSize(18),
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                                : AppColors.onSurface.withValues(alpha: 0.6),
                          ),
                          SizedBox(
                              width: ResponsiveUtils.getResponsiveSpacing(
                                  context, 12.0)),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? DarkAppColors.onSurface
                                    : AppColors.onSurface,
                                fontSize: getResponsiveFontSize(14),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: getResponsiveFontSize(14),
                            color: themeProvider.isDarkMode
                                ? DarkAppColors.onSurface.withValues(alpha: 0.4)
                                : AppColors.onSurface.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Popular Searches
          if (!_isSearching)
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Searches',
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(14),
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.8)
                          : AppColors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Custom suits',
                      'Wedding dresses',
                      'Shirts',
                      'Traditional wear',
                      'Alterations',
                    ]
                        .map((tag) => ActionChip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(12),
                                  color: themeProvider.isDarkMode
                                      ? DarkAppColors.primary
                                      : AppColors.primary,
                                ),
                              ),
                              backgroundColor: themeProvider.isDarkMode
                                  ? DarkAppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.1),
                              onPressed: () => _onSuggestionTap(tag),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
