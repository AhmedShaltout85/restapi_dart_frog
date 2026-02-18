import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/models/auth_models.dart';
import 'package:restapi_dart_frog/repositories/pick_location_users_repository.dart';
import 'package:restapi_dart_frog/services/auth_service.dart';
import 'package:restapi_dart_frog/services/jwt_service.dart';
import 'package:restapi_dart_frog/services/token_cache_service.dart';
import 'package:restapi_dart_frog/utils/response_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  // Only accept POST requests
  if (context.request.method != HttpMethod.post) {
    return ResponseHelper.error(
      message: 'Method not allowed',
      statusCode: HttpStatus.methodNotAllowed,
    );
  }

  try {
    // Parse request body
    final body = await context.request.json() as Map<String, dynamic>;
    final registerRequest = RegisterRequest.fromJson(body);

    // Validate required fields
    if (registerRequest.userName.isEmpty || registerRequest.password.isEmpty) {
      return ResponseHelper.error(
        message: 'Missing required fields',
        error: 'userName and password are required',
      );
    }

    // Validate password strength (minimum 6 characters)
    if (registerRequest.password.length < 6) {
      return ResponseHelper.error(
        message: 'Weak password',
        error: 'Password must be at least 6 characters long',
      );
    }

    // Get services from context
    final jwtService = context.read<JwtService>();
    final tokenCacheService = context.read<TokenCacheService>();
    final userRepository = PickLocationUsersRepository();
    final authService = AuthService(
      jwtService: jwtService,
      userRepository: userRepository,
      tokenCacheService: tokenCacheService,
    );

    // Attempt registration
    final registerResponse = await authService.register(
      userName: registerRequest.userName,
      password: registerRequest.password,
      role: registerRequest.role,
      controlUnit: registerRequest.controlUnit,
      technicalId: registerRequest.technicalId,
    );

    if (registerResponse == null) {
      return ResponseHelper.error(
        message: 'Registration failed',
        error: 'Username already exists',
      );
    }

    // Return success
    return ResponseHelper.created(
      data: registerResponse.toJson(),
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Registration failed',
      error: e,
    );
  }
}
