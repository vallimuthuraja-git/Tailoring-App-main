import 'package:flutter/foundation.dart';

/// Debug utilities for production performance optimization
class DebugUtils {
  /// Log only in debug mode for better production performance
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log with tag only in debug mode
  static void logWithTag(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
    }
  }

  /// Log error only in debug mode
  static void logError(String message, [dynamic error]) {
    if (kDebugMode) {
      debugPrint('âŒ ERROR: $message');
      if (error != null) {
        debugPrint('   Details: $error');
      }
    }
  }

  /// Log success only in debug mode
  static void logSuccess(String message) {
    if (kDebugMode) {
      debugPrint('âœ… SUCCESS: $message');
    }
  }

  /// Log warning only in debug mode
  static void logWarning(String message) {
    if (kDebugMode) {
      debugPrint('âš ï¸ WARNING: $message');
    }
  }

  /// Log info only in debug mode
  static void logInfo(String message) {
    if (kDebugMode) {
      debugPrint('â„¹ï¸ INFO: $message');
    }
  }
}

