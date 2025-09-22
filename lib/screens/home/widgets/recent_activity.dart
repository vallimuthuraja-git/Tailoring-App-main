import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';

class RecentActivity extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final Function(Map<String, dynamic>) onActivityTap;

  const RecentActivity({
    super.key,
    required this.activities,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode
                      ? DarkAppColors.onBackground
                      : AppColors.onBackground,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all activities
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.primary
                        : AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            _buildEmptyState(context, themeProvider)
          else
            ...activities.take(3).map((activity) => _ActivityCard(
                  activity: activity,
                  onTap: () => onActivityTap(activity),
                )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? DarkAppColors.surface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? DarkAppColors.onSurface.withValues(alpha: 0.2)
              : AppColors.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: themeProvider.isDarkMode
                ? DarkAppColors.onSurface.withValues(alpha: 0.5)
                : AppColors.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface
                  : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your recent orders and reviews will appear here',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                  : AppColors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double getResponsiveFontSize(double baseSize) {
      if (screenWidth >= 1200) return baseSize * 1.1;
      if (screenWidth >= 900) return baseSize * 1.05;
      if (screenWidth >= 600) return baseSize * 0.95;
      return baseSize * 0.9;
    }

    final icon = activity['icon'] as IconData?;
    final title = activity['title'] as String?;
    final subtitle = activity['subtitle'] as String?;
    final timestamp = activity['timestamp'] as DateTime?;
    final color = activity['color'] as Color?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? DarkAppColors.surface
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                  : AppColors.onSurface.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (color ?? Colors.blue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon ?? Icons.notifications,
                  color: color ?? Colors.blue,
                  size: getResponsiveFontSize(20),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Activity',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(14),
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface
                            : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle ?? '',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(12),
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Timestamp
              if (timestamp != null)
                Text(
                  _formatTimeAgo(timestamp),
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(10),
                    color: themeProvider.isDarkMode
                        ? DarkAppColors.onSurface.withValues(alpha: 0.6)
                        : AppColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
