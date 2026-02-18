import 'dart:developer' as developer;
import 'package:restapi_dart_frog/services/redis_service.dart';

/// Service for managing JWT token caching and blacklisting in Redis
class TokenCacheService {
  TokenCacheService(this.redis);
  final RedisService redis;

  // Redis key prefixes
  static const String _tokenPrefix = 'auth:token:';
  static const String _blacklistPrefix = 'auth:blacklist:';
  static const String _userTokensPrefix = 'auth:user:';

  /// Cache a valid token for a user
  Future<bool> cacheToken({
    required int userId,
    required String token,
    required int ttlSeconds,
  }) async {
    try {
      final tokenKey = '$_tokenPrefix$token';
      final userTokensKey = '$_userTokensPrefix$userId';

      // Store token with user ID and TTL
      await redis.set(
        tokenKey,
        userId.toString(),
        ttl: ttlSeconds,
      );

      // Add token to user's token set (for multi-device support)
      // Note: This is a simplified version. For production, use Redis SADD
      final userTokens = await redis.get(userTokensKey) ?? '';
      final tokens = <String>[];
      if (userTokens.isNotEmpty) {
        tokens.addAll(userTokens.split(','));
      }
      if (!tokens.contains(token)) {
        tokens.add(token);
        await redis.set(
          userTokensKey,
          tokens.join(','),
          ttl: ttlSeconds,
        );
      }

      developer.log('✅ Token cached for user $userId (TTL: ${ttlSeconds}s)');
      return true;
    } catch (e) {
      developer.log('❌ Error caching token: $e');
      return false;
    }
  }

  /// Blacklist a token (logout)
  Future<bool> blacklistToken(String token, int remainingTtl) async {
    try {
      final blacklistKey = '$_blacklistPrefix$token';

      // Store token in blacklist with remaining TTL
      // This ensures blacklist entry expires when token would have expired
      await redis.set(
        blacklistKey,
        DateTime.now().toIso8601String(),
        ttl: remainingTtl > 0 ? remainingTtl : 86400, // Default 24h if invalid
      );

      // Remove from active tokens
      final tokenKey = '$_tokenPrefix$token';
      await redis.delete(tokenKey);

      developer.log('✅ Token blacklisted');
      return true;
    } catch (e) {
      developer.log('❌ Error blacklisting token: $e');
      return false;
    }
  }

  /// Check if a token is blacklisted
  Future<bool> isTokenBlacklisted(String token) async {
    try {
      final blacklistKey = '$_blacklistPrefix$token';
      return await redis.exists(blacklistKey);
    } catch (e) {
      developer.log('❌ Error checking token blacklist: $e');
      // On error, consider token valid to avoid blocking legitimate users
      return false;
    }
  }

  /// Get all active tokens for a user
  Future<List<String>> getUserTokens(int userId) async {
    try {
      final userTokensKey = '$_userTokensPrefix$userId';
      final userTokens = await redis.get(userTokensKey);

      if (userTokens == null || userTokens.isEmpty) {
        return [];
      }

      return userTokens.split(',');
    } catch (e) {
      developer.log('❌ Error getting user tokens: $e');
      return [];
    }
  }

  /// Revoke all tokens for a user (logout all devices)
  Future<int> revokeAllUserTokens(int userId) async {
    try {
      final tokens = await getUserTokens(userId);
      var revokedCount = 0;

      for (final token in tokens) {
        // Get remaining TTL
        final tokenKey = '$_tokenPrefix$token';
        final ttl = await redis.ttl(tokenKey);

        if (ttl > 0) {
          await blacklistToken(token, ttl);
          revokedCount++;
        }
      }

      // Clear user tokens list
      final userTokensKey = '$_userTokensPrefix$userId';
      await redis.delete(userTokensKey);

      developer.log('✅ Revoked $revokedCount tokens for user $userId');
      return revokedCount;
    } catch (e) {
      developer.log('❌ Error revoking user tokens: $e');
      return 0;
    }
  }

  /// Check if a token exists in cache (is valid and not blacklisted)
  Future<bool> isTokenValid(String token) async {
    try {
      // Check if blacklisted
      if (await isTokenBlacklisted(token)) {
        return false;
      }

      // Check if exists in active tokens
      final tokenKey = '$_tokenPrefix$token';
      return await redis.exists(tokenKey);
    } catch (e) {
      developer.log('❌ Error validating token: $e');
      // On error, rely on JWT validation only
      return true;
    }
  }

  /// Get user ID from cached token
  Future<int?> getUserIdFromToken(String token) async {
    try {
      final tokenKey = '$_tokenPrefix$token';
      final userId = await redis.get(tokenKey);

      if (userId != null) {
        return int.tryParse(userId);
      }
      return null;
    } catch (e) {
      developer.log('❌ Error getting user ID from token: $e');
      return null;
    }
  }

  /// Clean up expired tokens (maintenance task)
  Future<void> cleanupExpiredTokens() async {
    try {
      // Redis automatically removes expired keys, but we can clean up user token lists
      final userKeys = await redis.keys('$_userTokensPrefix*');

      for (final userKey in userKeys) {
        final tokens = await redis.get(userKey);
        if (tokens == null || tokens.isEmpty) {
          await redis.delete(userKey);
        }
      }

      developer.log('✅ Cleaned up expired token references');
    } catch (e) {
      developer.log('❌ Error cleaning up tokens: $e');
    }
  }
}
