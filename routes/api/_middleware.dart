import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/middleware/auth_middleware.dart';
import 'package:restapi_dart_frog/services/jwt_service.dart';

/// Apply authentication middleware to all API routes
Handler middleware(Handler handler) {
  return (context) {
    // Get JWT service from parent context
    final jwtService = context.read<JwtService>();

    // Apply authentication middleware
    final authHandler = authMiddleware(jwtService)(handler);

    return authHandler(context);
  };
}
