// ignore_for_file: inference_failure_on_instance_creation

import 'package:dotenv/dotenv.dart';
import 'package:restapi_dart_frog/config/redis_config.dart';
import 'package:restapi_dart_frog/services/redis_service.dart';
import 'package:restapi_dart_frog/services/token_cache_service.dart';
import 'package:test/test.dart';

void main() {
  late RedisService? redisService;
  late TokenCacheService? tokenCacheService;
  late bool redisAvailable;

  setUpAll(() async {
    // Load environment variables
    final env = DotEnv()..load();
    final config = RedisConfig.fromEnv(env);
    redisService = RedisService(config);
    redisAvailable = false;

    // Connect to Redis before running tests
    try {
      await redisService!.connect();
      redisAvailable = redisService!.isConnected;
      if (redisAvailable) {
        tokenCacheService = TokenCacheService(redisService!);
        print('✅  Connected to Redis for tests');
      }
    } catch (e) {
      print('⚠️  Redis not available - tests will be skipped');
      print('   Start Redis with: docker-compose up -d redis');
    }
  });

  tearDownAll(() async {
    if (redisAvailable && redisService != null) {
      await redisService!.deletePattern('auth:*');
      await redisService!.disconnect();
      print('✅ Cleaned up and disconnected from Redis');
    }
  });

  setUp(() async {
    if (redisAvailable && redisService != null) {
      await redisService!.deletePattern('auth:*');
    }
  });

  group('TokenCacheService - Token Caching', () {
    test('should cache a token successfully', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1001;
      const token = 'test_jwt_token_abc123';
      const ttl = 3600; // 1 hour

      final result = await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: ttl,
      );

      expect(result, isTrue);

      // Verify token is cached
      final cachedUserId = await tokenCacheService!.getUserIdFromToken(token);
      expect(cachedUserId, equals(userId));
    });

    test('should cache token with correct TTL', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1002;
      const token = 'test_jwt_token_ttl';
      const ttl = 5; // 5 seconds

      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: ttl,
      );

      // Check TTL is set
      const tokenKey = 'auth:token:$token';
      final remainingTtl = await redisService!.ttl(tokenKey);
      expect(remainingTtl, greaterThan(0));
      expect(remainingTtl, lessThanOrEqualTo(ttl));
    });

    test('should get user ID from cached token', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1003;
      const token = 'test_jwt_token_getuser';

      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: 3600,
      );

      final retrievedUserId =
          await tokenCacheService!.getUserIdFromToken(token);
      expect(retrievedUserId, equals(userId));
    });

    test('should return null for non-existent token', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      final userId = await tokenCacheService!.getUserIdFromToken('nonexistent');
      expect(userId, isNull);
    });
  });

  group('TokenCacheService - Token Blacklisting', () {
    test('should blacklist a token', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const token = 'test_jwt_token_blacklist';
      const ttl = 3600;

      final result = await tokenCacheService!.blacklistToken(token, ttl);
      expect(result, isTrue);

      // Verify it's blacklisted
      final isBlacklisted = await tokenCacheService!.isTokenBlacklisted(token);
      expect(isBlacklisted, isTrue);
    });

    test('should detect blacklisted token', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const token = 'test_jwt_token_check';
      const ttl = 3600;

      // Initially not blacklisted
      expect(await tokenCacheService!.isTokenBlacklisted(token), isFalse);

      // Blacklist it
      await tokenCacheService!.blacklistToken(token, ttl);

      // Now should be blacklisted
      expect(await tokenCacheService!.isTokenBlacklisted(token), isTrue);
    });

    test('should not validate blacklisted token', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1004;
      const token = 'test_jwt_token_invalid';
      const ttl = 3600;

      // Cache the token
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: ttl,
      );

      // Initially valid
      expect(await tokenCacheService!.isTokenValid(token), isTrue);

      // Blacklist it
      await tokenCacheService!.blacklistToken(token, ttl);

      // Now invalid
      expect(await tokenCacheService!.isTokenValid(token), isFalse);
    });

    test('should remove token from cache when blacklisted', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1005;
      const token = 'test_jwt_token_remove';
      const ttl = 3600;

      // Cache the token
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: ttl,
      );

      // Verify it exists
      const tokenKey = 'auth:token:$token';
      expect(await redisService!.exists(tokenKey), isTrue);

      // Blacklist it
      await tokenCacheService!.blacklistToken(token, ttl);

      // Token cache should be removed
      expect(await redisService!.exists(tokenKey), isFalse);

      // But blacklist entry should exist
      const blacklistKey = 'auth:blacklist:$token';
      expect(await redisService!.exists(blacklistKey), isTrue);
    });
  });

  group('TokenCacheService - Multi-Device Sessions', () {
    test('should track multiple tokens for a user', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1006;
      const token1 = 'test_jwt_token_device1';
      const token2 = 'test_jwt_token_device2';
      const ttl = 3600;

      // Cache two tokens for same user
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token1,
        ttlSeconds: ttl,
      );
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token2,
        ttlSeconds: ttl,
      );

      // Get all user tokens
      final tokens = await tokenCacheService!.getUserTokens(userId);
      expect(tokens.length, equals(2));
      expect(tokens, contains(token1));
      expect(tokens, contains(token2));
    });

    test('should revoke all user tokens', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1007;
      const token1 = 'test_jwt_token_revoke1';
      const token2 = 'test_jwt_token_revoke2';
      const token3 = 'test_jwt_token_revoke3';
      const ttl = 3600;

      // Cache three tokens
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token1,
        ttlSeconds: ttl,
      );
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token2,
        ttlSeconds: ttl,
      );
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token3,
        ttlSeconds: ttl,
      );

      // Revoke all
      final revokedCount = await tokenCacheService!.revokeAllUserTokens(userId);
      expect(revokedCount, equals(3));

      // All should be blacklisted
      expect(await tokenCacheService!.isTokenBlacklisted(token1), isTrue);
      expect(await tokenCacheService!.isTokenBlacklisted(token2), isTrue);
      expect(await tokenCacheService!.isTokenBlacklisted(token3), isTrue);
    });

    test('should return empty list for user with no tokens', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 9999;
      final tokens = await tokenCacheService!.getUserTokens(userId);
      expect(tokens, isEmpty);
    });
  });

  group('TokenCacheService - Token Validation', () {
    test('should validate cached non-blacklisted token', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1008;
      const token = 'test_jwt_token_valid';
      const ttl = 3600;

      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: ttl,
      );

      final isValid = await tokenCacheService!.isTokenValid(token);
      expect(isValid, isTrue);
    });

    test('should invalidate non-cached token', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const token = 'test_jwt_token_not_cached';

      final isValid = await tokenCacheService!.isTokenValid(token);
      expect(isValid, isFalse);
    });

    test('full logout flow - cache, validate, blacklist, invalidate', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1009;
      const token = 'test_jwt_token_full_flow';
      const ttl = 3600;

      // Step 1: Login - Cache token
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: ttl,
      );
      expect(await tokenCacheService!.isTokenValid(token), isTrue);
      expect(await tokenCacheService!.isTokenBlacklisted(token), isFalse);

      // Step 2: Logout - Blacklist token
      await tokenCacheService!.blacklistToken(token, ttl);

      // Step 3: Verify token is now invalid
      expect(await tokenCacheService!.isTokenValid(token), isFalse);
      expect(await tokenCacheService!.isTokenBlacklisted(token), isTrue);
    });
  });

  group('TokenCacheService - Cleanup', () {
    test('should clean up expired token references', () async {
      if (!redisAvailable) {
        markTestSkipped('Redis not available');
      }

      const userId = 1010;
      const token = 'test_jwt_token_cleanup';
      const shortTtl = 2; // 2 seconds

      // Cache with short TTL
      await tokenCacheService!.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: shortTtl,
      );

      // Wait for expiration
      await Future.delayed(const Duration(seconds: shortTtl + 1));

      // Run cleanup
      await tokenCacheService!.cleanupExpiredTokens();

      // User token list should be cleaned
      const userTokensKey = 'auth:user:$userId';
      final exists = await redisService!.exists(userTokensKey);
      expect(exists, isFalse);
    });
  });
}
