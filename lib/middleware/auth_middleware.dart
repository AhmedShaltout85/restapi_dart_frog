import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/services/jwt_service.dart';
import 'package:restapi_dart_frog/services/token_cache_service.dart';

/// Middleware provider for JWT authentication
Middleware authMiddleware(JwtService jwtService) {
  return (handler) {
    return (context) async {
      final request = context.request;

      // Extract Authorization header
      final authHeader =
          request.headers['authorization'] ?? request.headers['Authorization'];

      if (authHeader == null || authHeader.isEmpty) {
        return Response(
          statusCode: 401,
          body: '''
{
  "success": false,
  "message": "Missing authentication token",
  "error": "Authorization header is required",
  "timestamp": "${DateTime.now().toUtc().toIso8601String()}"
}''',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Extract token from "Bearer <token>" format
      final parts = authHeader.split(' ');
      if (parts.length != 2 || parts[0].toLowerCase() != 'bearer') {
        return Response(
          statusCode: 401,
          body: '''
{
  "success": false,
  "message": "Invalid authorization header format",
  "error": "Use format: Authorization: Bearer <token>",
  "timestamp": "${DateTime.now().toUtc().toIso8601String()}"
}''',
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = parts[1];

      // Check if token is blacklisted (logged out)
      try {
        final tokenCacheService = context.read<TokenCacheService>();
        final isBlacklisted = await tokenCacheService.isTokenBlacklisted(token);

        if (isBlacklisted) {
          return Response(
            statusCode: 401,
            body: '''
{
  "success": false,
  "message": "Token has been revoked",
  "error": "Please login again",
  "timestamp": "${DateTime.now().toUtc().toIso8601String()}"
}''',
            headers: {'Content-Type': 'application/json'},
          );
        }
      } catch (e) {
        // If Redis is down, continue with JWT validation only
        // Log the error but don't block the request
      }

      // Verify token
      final payload = jwtService.verifyToken(token);
      if (payload == null) {
        return Response(
          statusCode: 403,
          body: '''
{
  "success": false,
  "message": "Invalid or expired token",
  "error": "Token verification failed",
  "timestamp": "${DateTime.now().toUtc().toIso8601String()}"
}''',
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Add user info to context
      final updatedContext = context.provide<Map<String, dynamic>>(
        () => {
          'userId': payload['userId'],
          'userName': payload['userName'],
          'role': payload['role'],
        },
      );

      // Continue with the request
      return handler(updatedContext);
    };
  };
}
