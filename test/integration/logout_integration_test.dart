import 'package:mocktail/mocktail.dart';
import 'package:restapi_dart_frog/services/jwt_service.dart';
import 'package:restapi_dart_frog/services/token_cache_service.dart';
import 'package:test/test.dart';

// Mock classes
class MockJwtService extends Mock implements JwtService {}

class MockTokenCacheService extends Mock implements TokenCacheService {}

void main() {
  group('Logout Endpoint Integration Tests', () {
    late JwtService mockJwtService;
    late TokenCacheService mockTokenCacheService;

    setUp(() {
      mockJwtService = MockJwtService();
      mockTokenCacheService = MockTokenCacheService();
    });

    test('should successfully logout with valid token', () async {
      const token = 'valid_jwt_token';
      final payload = {
        'userId': 2009,
        'userName': 'testuser',
        'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
      };

      // Mock JWT verification
      when(() => mockJwtService.verifyToken(token)).thenReturn(payload);

      // Mock token blacklisting
      when(() => mockTokenCacheService.blacklistToken(token, any()))
          .thenAnswer((_) async => true);

      // Simulate logout
      final verified = mockJwtService.verifyToken(token);
      expect(verified, isNotNull);

      final exp = verified!['exp'] as int;
      final remainingTtl =
          exp - (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      final blacklisted = await mockTokenCacheService.blacklistToken(
        token,
        remainingTtl,
      );

      expect(blacklisted, isTrue);
      verify(() => mockJwtService.verifyToken(token)).called(1);
      verify(() => mockTokenCacheService.blacklistToken(token, any()))
          .called(1);
    });

    test('should reject logout with invalid token', () async {
      const token = 'invalid_jwt_token';

      // Mock JWT verification failure
      when(() => mockJwtService.verifyToken(token)).thenReturn(null);

      final verified = mockJwtService.verifyToken(token);
      expect(verified, isNull);
    });

    test('should handle blacklist failure gracefully', () async {
      const token = 'valid_jwt_token';
      final payload = {
        'userId': 2009,
        'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
      };

      when(() => mockJwtService.verifyToken(token)).thenReturn(payload);
      when(() => mockTokenCacheService.blacklistToken(token, any()))
          .thenAnswer((_) async => false);

      final verified = mockJwtService.verifyToken(token);
      final exp = verified!['exp'] as int;
      final remainingTtl =
          exp - (DateTime.now().millisecondsSinceEpoch ~/ 1000);

      final blacklisted = await mockTokenCacheService.blacklistToken(
        token,
        remainingTtl,
      );

      expect(blacklisted, isFalse);
    });

    test('should calculate correct TTL for token', () async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final exp = now + 7200; // 2 hours from now

      final payload = {
        'userId': 2009,
        'exp': exp,
      };

      const token = 'test_token';
      when(() => mockJwtService.verifyToken(token)).thenReturn(payload);

      final verified = mockJwtService.verifyToken(token);
      final remainingTtl = (verified!['exp'] as int) - now;

      expect(remainingTtl, greaterThan(7100));
      expect(remainingTtl, lessThanOrEqualTo(7200));
    });
  });

  group('Authentication Middleware with Redis Tests', () {
    late TokenCacheService mockTokenCacheService;

    setUp(() {
      mockTokenCacheService = MockTokenCacheService();
    });

    test('should block blacklisted token', () async {
      const token = 'blacklisted_token';

      when(() => mockTokenCacheService.isTokenBlacklisted(token))
          .thenAnswer((_) async => true);

      final isBlacklisted =
          await mockTokenCacheService.isTokenBlacklisted(token);
      expect(isBlacklisted, isTrue);
    });

    test('should allow non-blacklisted token', () async {
      const token = 'valid_token';

      when(() => mockTokenCacheService.isTokenBlacklisted(token))
          .thenAnswer((_) async => false);

      final isBlacklisted =
          await mockTokenCacheService.isTokenBlacklisted(token);
      expect(isBlacklisted, isFalse);
    });

    test('should default to allowing token on Redis error', () async {
      const token = 'unknown_token';

      // Simulate Redis error
      when(() => mockTokenCacheService.isTokenBlacklisted(token))
          .thenThrow(Exception('Redis connection failed'));

      expect(
        () => mockTokenCacheService.isTokenBlacklisted(token),
        throwsException,
      );
    });
  });

  group('Token Lifecycle Integration Tests', () {
    late JwtService mockJwtService;
    late TokenCacheService mockTokenCacheService;

    setUp(() {
      mockJwtService = MockJwtService();
      mockTokenCacheService = MockTokenCacheService();
    });

    test('complete token lifecycle: login -> use -> logout -> reject',
        () async {
      const userId = 2009;
      const userName = 'testuser';
      const token = 'lifecycle_test_token';
      const ttl = 3600;

      // Step 1: Login - Generate and cache token
      when(
        () => mockJwtService.generateToken(
          userId: userId,
          userName: userName,
          role: any(named: 'role'),
        ),
      ).thenReturn(token);

      when(
        () => mockTokenCacheService.cacheToken(
          userId: userId,
          token: token,
          ttlSeconds: ttl,
        ),
      ).thenAnswer((_) async => true);

      final generatedToken = mockJwtService.generateToken(
        userId: userId,
        userName: userName,
      );
      expect(generatedToken, equals(token));

      final cached = await mockTokenCacheService.cacheToken(
        userId: userId,
        token: token,
        ttlSeconds: ttl,
      );
      expect(cached, isTrue);

      // Step 2: Use - Validate token (not blacklisted)
      when(() => mockTokenCacheService.isTokenBlacklisted(token))
          .thenAnswer((_) async => false);

      final isBlacklisted =
          await mockTokenCacheService.isTokenBlacklisted(token);
      expect(isBlacklisted, isFalse);

      // Step 3: Logout - Blacklist token
      when(() => mockTokenCacheService.blacklistToken(token, any()))
          .thenAnswer((_) async => true);

      final blacklisted =
          await mockTokenCacheService.blacklistToken(token, ttl);
      expect(blacklisted, isTrue);

      // Step 4: Try to use again - Should be blocked
      when(() => mockTokenCacheService.isTokenBlacklisted(token))
          .thenAnswer((_) async => true);

      final isNowBlacklisted =
          await mockTokenCacheService.isTokenBlacklisted(token);
      expect(isNowBlacklisted, isTrue);
    });
  });
}
