import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/services/jwt_service.dart';
import 'package:restapi_dart_frog/services/token_cache_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // Only accept POST requests
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {
        'success': false,
        'message': 'Method not allowed',
      },
    );
  }

  try {
    // Extract token from Authorization header
    final authHeader = context.request.headers['authorization'] ??
        context.request.headers['Authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'success': false,
          'message': 'Missing or invalid authorization header',
        },
      );
    }

    final token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Get services from context
    final jwtService = context.read<JwtService>();
    final tokenCacheService = context.read<TokenCacheService>();

    // Verify token is valid (not expired)
    final payload = jwtService.verifyToken(token);
    if (payload == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'success': false,
          'message': 'Invalid or expired token',
        },
      );
    }

    // Get remaining TTL from JWT
    final exp = payload['exp'] as int?;
    final remainingTtl = exp != null
        ? exp - (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        : 86400; // Default 24h

    // Blacklist the token
    final blacklisted = await tokenCacheService.blacklistToken(
      token,
      remainingTtl > 0 ? remainingTtl : 1,
    );

    if (!blacklisted) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'success': false,
          'message': 'Failed to logout. Please try again.',
        },
      );
    }

    return Response.json(
      body: {
        'success': true,
        'message': 'Logged out successfully',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Logout failed',
        'error': e.toString(),
      },
    );
  }
}
