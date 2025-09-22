import 'package:flutter/foundation.dart';

/// Debug utilities for production performance optimization
class DebugUtils {
  /// Log only in debug mode for better production performance
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  /// Log with tag only in debug mode
  static void logWithTag(String tag, String message) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

  /// Log error only in debug mode
  static void logError(String message, [dynamic error]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('   Details: $error');
      }
    }
  }

  /// Log success only in debug mode
  static void logSuccess(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }

  /// Log warning only in debug mode
  static void logWarning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  /// Log info only in debug mode
  static void logInfo(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }
}
