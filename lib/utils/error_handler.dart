import 'dart:async';
import 'package:logging/logging.dart';

/// Custom base exception for the app
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message';
}

/// Network-related errors
class NetworkError extends AppException {
  NetworkError(super.message, {super.code, super.originalError});
}

/// Firebase-related errors
class FirebaseError extends AppException {
  FirebaseError(super.message, {super.code, super.originalError});
}

/// Validation errors
class ValidationError extends AppException {
  ValidationError(super.message, {super.code, super.originalError});
}

/// Logger instance for error handling
final Logger _logger = Logger('AppError');

/// Initialize logging for the app
void initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('  StackTrace: ${record.stackTrace}');
    }
  });
}

/// Log an error with optional stack trace
void logError(dynamic error,
    [StackTrace? stackTrace, Level level = Level.SEVERE]) {
  _logger.log(level, 'Error occurred', error, stackTrace);
}

/// Map of error codes to user-friendly messages
const Map<String, String> errorMessages = {
  'network_timeout':
      'Request timed out. Please check your connection and try again.',
  'network_unreachable':
      'Unable to connect to the server. Please check your internet connection.',
  'firebase_auth_invalid_credentials':
      'Invalid email or password. Please try again.',
  'firebase_auth_user_not_found':
      'No account found with this email. Please sign up or check your email.',
  'firebase_auth_email_already_in_use':
      'An account with this email already exists. Please log in instead.',
  'firebase_auth_weak_password':
      'Password is too weak. Please choose a stronger password.',
  'firebase_permission_denied':
      'You do not have permission to perform this action.',
  'firebase_unavailable':
      'Service is temporarily unavailable. Please try again later.',
  'validation_empty_field': 'This field cannot be empty.',
  'validation_invalid_email': 'Please enter a valid email address.',
  'validation_invalid_phone': 'Please enter a valid phone number.',
  'validation_password_mismatch': 'Passwords do not match.',
  'unknown_error': 'An unexpected error occurred. Please try again.',
};

/// Get user-friendly error message from error object or code
String getUserFriendlyErrorMessage(dynamic error) {
  if (error is AppException) {
    return error.message;
  }

  if (error is String && errorMessages.containsKey(error)) {
    return errorMessages[error]!;
  }

  // Handle Firebase Auth exceptions
  if (error.toString().contains('firebase_auth/invalid-credential')) {
    return errorMessages['firebase_auth_invalid_credentials']!;
  }
  if (error.toString().contains('firebase_auth/user-not-found')) {
    return errorMessages['firebase_auth_user_not_found']!;
  }
  if (error.toString().contains('firebase_auth/email-already-in-use')) {
    return errorMessages['firebase_auth_email_already_in_use']!;
  }
  if (error.toString().contains('firebase_auth/weak-password')) {
    return errorMessages['firebase_auth_weak_password']!;
  }

  // Handle network exceptions
  if (error.toString().contains('SocketException') ||
      error.toString().contains('HttpException')) {
    return errorMessages['network_unreachable']!;
  }

  // Default fallback
  return errorMessages['unknown_error']!;
}

/// Retry mechanism for operations with exponential backoff
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
  double backoffFactor = 2.0,
}) async {
  Duration delay = initialDelay;
  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxRetries - 1) rethrow;
      logError('Retry attempt ${attempt + 1} failed: $e', null, Level.WARNING);
      await Future.delayed(delay);
      delay *= backoffFactor;
    }
  }
  throw Exception('Max retries exceeded');
}
