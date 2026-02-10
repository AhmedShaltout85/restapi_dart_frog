import 'package:dart_frog/dart_frog.dart';

/// Response helper utilities
class ResponseHelper {
  /// Create a successful response
  static Response success({
    required dynamic data,
    String message = 'Success',
    int statusCode = 200,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        'data': data,
      },
    );
  }

  /// Create an error response
  static Response error({
    required String message,
    int statusCode = 400,
    dynamic errors,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'message': message,
        if (errors != null) 'errors': errors,
      },
    );
  }

  /// Create a not found response
  static Response notFound({String message = 'Resource not found'}) {
    return error(message: message, statusCode: 404);
  }

  /// Create a created response
  static Response created({
    required dynamic data,
    String message = 'Resource created successfully',
  }) {
    return success(data: data, message: message, statusCode: 201);
  }

  /// Create a deleted response
  static Response deleted({String message = 'Resource deleted successfully'}) {
    return success(data: null, message: message);
  }

  /// Create a server error response
  static Response serverError({
    String message = 'Internal server error',
    dynamic error,
  }) {
    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'message': message,
        if (error != null) 'error': error.toString(),
      },
    );
  }

  /// Create a validation error response
  static Response validationError({
    required String message,
    dynamic errors,
  }) {
    return error(
      message: message,
      statusCode: 422,
      errors: errors,
    );
  }
}
