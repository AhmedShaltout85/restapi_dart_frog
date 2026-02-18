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
    final loginRequest = LoginRequest.fromJson(body);

    // Validate required fields
    if (loginRequest.userName.isEmpty || loginRequest.password.isEmpty) {
      return ResponseHelper.error(
        message: 'Missing required fields',
        error: 'userName and password are required',
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

    // Attempt login
    final loginResponse = await authService.login(
      userName: loginRequest.userName,
      password: loginRequest.password,
    );

    if (loginResponse == null) {
      return Response(
        statusCode: HttpStatus.unauthorized,
        body:
            '''{"success": false, "message": "Invalid credentials: Username or password is incorrect", "timestamp": "${DateTime.now().toUtc().toIso8601String()}"}''',
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Return success with token
    return ResponseHelper.success(
      data: loginResponse.toJson(),
      message: 'Login successful',
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Login failed',
      error: e,
    );
  }
}
