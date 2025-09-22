import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/theme_constants.dart';
import '../../../utils/responsive_utils.dart';

class NotificationCenter extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(Map<String, dynamic>) onNotificationTap;

  const NotificationCenter({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? DarkAppColors.onBackground
                  : AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          ...notifications.take(2).map((notification) => _NotificationCard(
                notification: notification,
                onTap: () => onNotificationTap(notification),
              )),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
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

    final title = notification['title'] as String?;
    final message = notification['message'] as String?;
    final timestamp = notification['timestamp'] as DateTime?;
    final read = notification['read'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: read
                ? (themeProvider.isDarkMode
                    ? DarkAppColors.surface
                    : AppColors.surface)
                : (themeProvider.isDarkMode
                    ? DarkAppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: read
                  ? (themeProvider.isDarkMode
                      ? DarkAppColors.onSurface.withValues(alpha: 0.2)
                      : AppColors.onSurface.withValues(alpha: 0.2))
                  : (themeProvider.isDarkMode
                      ? DarkAppColors.primary
                      : AppColors.primary),
              width: read ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: read
                      ? (themeProvider.isDarkMode
                          ? DarkAppColors.background
                          : AppColors.background)
                      : (themeProvider.isDarkMode
                          ? DarkAppColors.primary
                          : AppColors.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications,
                  color: read
                      ? (themeProvider.isDarkMode
                          ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                          : AppColors.onSurface.withValues(alpha: 0.7))
                      : Colors.white,
                  size: getResponsiveFontSize(16),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Notification',
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
                      message ?? '',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(12),
                        color: themeProvider.isDarkMode
                            ? DarkAppColors.onSurface.withValues(alpha: 0.7)
                            : AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
      return 'Now';
    }
  }
}
