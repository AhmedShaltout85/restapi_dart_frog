import 'dart:developer';
import 'package:bcrypt/bcrypt.dart';
import 'package:restapi_dart_frog/models/auth_models.dart';
import 'package:restapi_dart_frog/models/pick_location_users_model.dart';
import 'package:restapi_dart_frog/repositories/pick_location_users_repository.dart';
import 'package:restapi_dart_frog/services/jwt_service.dart';
import 'package:restapi_dart_frog/services/token_cache_service.dart';

/// Service for authentication business logic
class AuthService {
  AuthService({
    required this.jwtService,
    required this.userRepository,
    required this.tokenCacheService,
  });

  final JwtService jwtService;
  final PickLocationUsersRepository userRepository;
  final TokenCacheService tokenCacheService;

  /// Hash a password using bcrypt
  String hashPassword(String password) {
    try {
      return BCrypt.hashpw(password, BCrypt.gensalt());
    } catch (e) {
      log('Error hashing password: $e');
      rethrow;
    }
  }

  /// Verify a password against a hash
  bool verifyPassword(String password, String hashedPassword) {
    try {
      return BCrypt.checkpw(password, hashedPassword);
    } catch (e) {
      log('Error verifying password: $e');
      return false;
    }
  }

  /// Login user with username and password
  Future<LoginResponse?> login({
    required String userName,
    required String password,
  }) async {
    try {
      // Find user by username
      final user = await userRepository.findByUserName(userName);

      if (user == null) {
        log('Login failed: User not found - $userName');
        return null;
      }

      // Verify password
      if (user.userPassword == null || user.userPassword!.isEmpty) {
        log('Login failed: User has no password set - $userName');
        return null;
      }

      // Check if password is hashed (bcrypt hashes start with $2a$ or $2b$)
      final isPasswordHashed = user.userPassword!.startsWith(r'$2');

      bool passwordValid;
      if (isPasswordHashed) {
        // Verify against bcrypt hash
        passwordValid = verifyPassword(password, user.userPassword!);
      } else {
        // Legacy: plain text password comparison
        // This should be removed after all passwords are migrated to hashed
        log('Warning: User $userName has plain text password. Please migrate to hashed password.');
        passwordValid = password == user.userPassword;

        // Optionally auto-migrate on successful login
        if (passwordValid) {
          log('Auto-migrating password for user: $userName');
          final hashedPassword = hashPassword(password);
          await userRepository.update(
            user.id!,
            user.copyWith(userPassword: hashedPassword),
          );
        }
      }

      if (!passwordValid) {
        log('Login failed: Invalid password - $userName');
        return null;
      }

      // Generate JWT token
      final token = jwtService.generateToken(
        userId: user.id!,
        userName: user.userName!,
        role: user.role,
      );

      // Cache token in Redis
      try {
        await tokenCacheService.cacheToken(
          userId: user.id!,
          token: token,
          ttlSeconds: jwtService.expirationHours * 3600,
        );
      } catch (e) {
        log('Warning: Failed to cache token in Redis: $e');
        // Continue anyway - token is still valid via JWT
      }

      log('Login successful: $userName');

      return LoginResponse(
        token: token,
        userId: user.id!,
        userName: user.userName!,
        role: user.role,
        controlUnit: user.controlUnit,
      );
    } catch (e, stackTrace) {
      log('Login error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Register a new user
  Future<RegisterResponse?> register({
    required String userName,
    required String password,
    int? role,
    String? controlUnit,
    int? technicalId,
  }) async {
    try {
      // Check if username already exists
      final exists = await userRepository.userNameExists(userName);

      if (exists) {
        log('Registration failed: Username already exists - $userName');
        return null;
      }

      // Hash password
      final hashedPassword = hashPassword(password);

      // Create user
      final newUser = PickLocationUsers(
        userName: userName,
        userPassword: hashedPassword,
        role: role,
        controlUnit: controlUnit,
        technicalId: technicalId,
      );

      final userId = await userRepository.create(newUser);

      log('User registered successfully: $userName (ID: $userId)');

      return RegisterResponse(
        message: 'User registered successfully',
        userId: userId,
      );
    } catch (e, stackTrace) {
      log('Registration error: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Validate JWT token
  bool validateToken(String token) {
    return jwtService.isTokenValid(token);
  }

  /// Extract user data from token
  Map<String, dynamic>? getUserFromToken(String token) {
    return jwtService.verifyToken(token);
  }
}
