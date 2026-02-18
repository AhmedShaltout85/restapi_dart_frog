import 'dart:developer';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Service for JWT token generation and validation
class JwtService {
  JwtService({
    required this.secretKey,
    this.expirationHours = 24,
  });

  final String secretKey;
  final int expirationHours;

  /// Generate a JWT token for a user
  String generateToken({
    required int userId,
    required String userName,
    int? role,
  }) {
    try {
      final jwt = JWT(
        {
          'userId': userId,
          'userName': userName,
          if (role != null) 'role': role,
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        issuer: 'dart_frog_api',
      );

      final token = jwt.sign(
        SecretKey(secretKey),
        expiresIn: Duration(hours: expirationHours),
      );

      log('Generated JWT token for user: $userName (ID: $userId)');
      return token;
    } catch (e) {
      log('Error generating JWT token: $e');
      rethrow;
    }
  }

  /// Verify and decode a JWT token
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(secretKey));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      log('JWT token expired');
      return null;
    } on JWTException catch (e) {
      log('JWT verification failed: $e');
      return null;
    } catch (e) {
      log('Unexpected error verifying JWT: $e');
      return null;
    }
  }

  /// Extract user ID from token
  int? extractUserId(String token) {
    final payload = verifyToken(token);
    if (payload == null) return null;

    final userId = payload['userId'];
    if (userId is int) return userId;
    if (userId is num) return userId.toInt();
    if (userId is String) return int.tryParse(userId);
    return null;
  }

  /// Extract user name from token
  String? extractUserName(String token) {
    final payload = verifyToken(token);
    if (payload == null) return null;
    return payload['userName'] as String?;
  }

  /// Extract role from token
  int? extractRole(String token) {
    final payload = verifyToken(token);
    if (payload == null) return null;

    final role = payload['role'];
    if (role is int) return role;
    if (role is num) return role.toInt();
    if (role is String) return int.tryParse(role);
    return null;
  }

  /// Check if token is valid (not expired and properly signed)
  bool isTokenValid(String token) {
    return verifyToken(token) != null;
  }
}
