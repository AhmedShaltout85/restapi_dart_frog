// ignore_for_file: inference_failure_on_instance_creation

import 'package:dotenv/dotenv.dart';
import 'package:restapi_dart_frog/config/redis_config.dart';
import 'package:restapi_dart_frog/services/redis_service.dart';
import 'package:test/test.dart';

void main() {
  late RedisService redisService;
  late RedisConfig config;

  setUpAll(() async {
    // Load environment variables
    final env = DotEnv()..load();
    config = RedisConfig.fromEnv(env);
    redisService = RedisService(config);

    // Connect to Redis before running tests
    try {
      await redisService.connect();
      print('✅ Connected to Redis for testing');
    } catch (e) {
      print('⚠️  Warning: Could not connect to Redis. Tests will be skipped.');
      print('   Make sure Redis is running: docker-compose up -d redis');
    }
  });

  tearDownAll(() async {
    // Cleanup: Delete all test keys
    await redisService.deletePattern('test:*');
    await redisService.disconnect();
    print('✅ Disconnected from Redis');
  });

  group('RedisService Connection Tests', () {
    test('should connect to Redis successfully', () {
      expect(redisService.isConnected, isTrue);
    });

    test('should ping Redis successfully', () async {
      final result = await redisService.ping();
      expect(result, isTrue);
    });

    test('should get Redis info', () async {
      final info = await redisService.info();
      expect(info, isNotEmpty);
      expect(info.containsKey('redis_version'), isTrue);
    });
  });

  group('RedisService Basic Operations', () {
    test('should set and get a value', () async {
      const key = 'test:simple';
      const value = 'hello_redis';

      final setResult = await redisService.set(key, value);
      expect(setResult, isTrue);

      final getValue = await redisService.get(key);
      expect(getValue, equals(value));

      // Cleanup
      await redisService.delete(key);
    });

    test('should set value with TTL and auto-expire', () async {
      const key = 'test:ttl';
      const value = 'expires_soon';
      const ttl = 2; // 2 seconds

      await redisService.set(key, value, ttl: ttl);

      // Check it exists immediately
      final exists = await redisService.exists(key);
      expect(exists, isTrue);

      // Check TTL
      final remainingTtl = await redisService.ttl(key);
      expect(remainingTtl, greaterThan(0));
      expect(remainingTtl, lessThanOrEqualTo(ttl));

      // Wait for expiration
      await Future.delayed(const Duration(seconds: ttl + 1));

      // Should be gone
      final existsAfter = await redisService.exists(key);
      expect(existsAfter, isFalse);
    });

    test('should delete a key', () async {
      const key = 'test:delete';
      const value = 'to_be_deleted';

      await redisService.set(key, value);
      expect(await redisService.exists(key), isTrue);

      final deleted = await redisService.delete(key);
      expect(deleted, isTrue);
      expect(await redisService.exists(key), isFalse);
    });

    test('should check if key exists', () async {
      const key = 'test:exists';
      const value = 'i_exist';

      // Should not exist initially
      expect(await redisService.exists(key), isFalse);

      // Set value
      await redisService.set(key, value);
      expect(await redisService.exists(key), isTrue);

      // Cleanup
      await redisService.delete(key);
    });

    test('should return null for non-existent key', () async {
      final value = await redisService.get('test:nonexistent');
      expect(value, isNull);
    });
  });

  group('RedisService Pattern Operations', () {
    setUp(() async {
      // Create multiple test keys
      await redisService.set('test:user:1', 'user1');
      await redisService.set('test:user:2', 'user2');
      await redisService.set('test:user:3', 'user3');
      await redisService.set('test:product:1', 'product1');
    });

    tearDown(() async {
      // Clean up all test keys
      await redisService.deletePattern('test:*');
    });

    test('should find keys by pattern', () async {
      final userKeys = await redisService.keys('test:user:*');
      expect(userKeys.length, equals(3));
      expect(userKeys, contains('test:user:1'));
      expect(userKeys, contains('test:user:2'));
      expect(userKeys, contains('test:user:3'));
    });

    test('should delete keys by pattern', () async {
      // Delete all user keys
      final deletedCount = await redisService.deletePattern('test:user:*');
      expect(deletedCount, equals(3));

      // Verify they're gone
      final remainingKeys = await redisService.keys('test:user:*');
      expect(remainingKeys, isEmpty);

      // Product key should still exist
      final productExists = await redisService.exists('test:product:1');
      expect(productExists, isTrue);
    });
  });

  group('RedisService Error Handling', () {
    test('should handle operations on disconnected service gracefully',
        () async {
      final disconnectedService = RedisService(config);

      expect(
        () => disconnectedService.get('test:key'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
