/// Validation utilities
class Validators {
  /// Validate required field
  static String? required(dynamic value, String fieldName) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email format
  static String? email(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '$fieldName must be a valid email address';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) return null;

    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, String fieldName) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }

  /// Validate integer
  static String? isInt(dynamic value, String fieldName) {
    if (value == null) return null;

    if (value is! int) {
      if (value is String) {
        if (int.tryParse(value) == null) {
          return '$fieldName must be a valid integer';
        }
      } else {
        return '$fieldName must be a valid integer';
      }
    }
    return null;
  }

  /// Validate double/float
  static String? isDouble(dynamic value, String fieldName) {
    if (value == null) return null;

    if (value is! double && value is! int) {
      if (value is String) {
        if (double.tryParse(value) == null) {
          return '$fieldName must be a valid number';
        }
      } else {
        return '$fieldName must be a valid number';
      }
    }
    return null;
  }

  /// Validate multiple validators
  static Map<String, String> validateAll(
    Map<String, List<String? Function()>> validationRules,
  ) {
    final errors = <String, String>{};

    validationRules.forEach((field, validators) {
      for (final validator in validators) {
        final error = validator();
        if (error != null) {
          errors[field] = error;
          break;
        }
      }
    });

    return errors;
  }
}
