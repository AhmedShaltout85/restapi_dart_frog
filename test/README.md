# Redis Cache Service Tests

This directory contains comprehensive tests for the Redis caching system and JWT token management.

## Test Files

### 1. `services/redis_service_test.dart`

Unit tests for the core Redis service:

- ✅ Connection management
- ✅ Basic operations (GET, SET, DELETE)
- ✅ TTL (Time To Live) functionality
- ✅ Pattern-based operations
- ✅ Error handling

### 2. `services/token_cache_service_test.dart`

Unit tests for JWT token caching:

- ✅ Token caching with TTL
- ✅ Token blacklisting (logout)
- ✅ Multi-device session tracking
- ✅ Token validation
- ✅ Cleanup operations

### 3. `integration/logout_integration_test.dart`

Integration tests for logout flow:

- ✅ Complete logout workflow
- ✅ Middleware token blocking
- ✅ Full token lifecycle (login → use → logout → reject)

## Prerequisites

### 1. Start Redis Server

Using Docker Compose:

```bash
docker-compose up -d redis
```

Or use existing Redis instance and update `.env`:

```env
REDIS_HOST=localhost
REDIS_PORT=6379
```

### 2. Install Test Dependencies

The `mocktail` package is required for mocking:

```bash
dart pub add dev:mocktail
```

## Running Tests

### Run All Tests

```bash
dart test
```

### Run Specific Test File

```bash
# Redis service tests
dart test test/services/redis_service_test.dart

# Token cache service tests
dart test test/services/token_cache_service_test.dart

# Integration tests
dart test test/integration/logout_integration_test.dart
```

### Run with Coverage

```bash
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### Run in Verbose Mode

```bash
dart test --reporter=expanded
```

## Test Structure

Each test file follows this pattern:

```dart
setUpAll()      // Connect to Redis (once)
setUp()         // Clean test data (before each test)
test()          // Individual test cases
tearDown()      // Clean up (after each test)
tearDownAll()   // Disconnect from Redis (once)
```

## Test Coverage

### Redis Service Tests

- **Connection Tests**: 3 tests
- **Basic Operations**: 6 tests
- **Pattern Operations**: 2 tests
- **Error Handling**: 1 test
- **Total**: 12 tests

### Token Cache Service Tests

- **Token Caching**: 4 tests
- **Token Blacklisting**: 5 tests
- **Multi-Device Sessions**: 3 tests
- **Token Validation**: 4 tests
- **Cleanup**: 1 test
- **Total**: 17 tests

### Integration Tests

- **Logout Endpoint**: 4 tests
- **Middleware**: 3 tests
- **Token Lifecycle**: 1 test
- **Total**: 8 tests

**Overall: 37 comprehensive tests**

## Expected Output

When all tests pass:

```
00:00 +0: loading test/services/redis_service_test.dart
✅ Connected to Redis for testing
00:01 +12: All tests passed!

00:00 +0: loading test/services/token_cache_service_test.dart
✅ Connected to Redis for TokenCacheService tests
00:02 +17: All tests passed!

00:00 +0: loading test/integration/logout_integration_test.dart
00:01 +8: All tests passed!
```

## Troubleshooting

### Redis Connection Failed

```
⚠️  Warning: Could not connect to Redis. Tests will be skipped.
   Make sure Redis is running: docker-compose up -d redis
```

**Solution**: Start Redis server before running tests.

### Environment Variables Not Loaded

```
Error: .env file not found
```

**Solution**: Ensure `.env` file exists in project root with Redis configuration.

### Tests Timing Out

If tests are slow or timing out:

- Check Redis server health: `docker-compose ps`
- Increase test timeout: `dart test --timeout=30s`

## CI/CD Integration

Add to your CI pipeline (e.g., GitHub Actions):

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      redis:
        image: redis:latest
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1

      - name: Install dependencies
        run: dart pub get

      - name: Run tests
        run: dart test
        env:
          REDIS_HOST: localhost
          REDIS_PORT: 6379
```

## Writing New Tests

When adding new Redis functionality:

1. **Add unit tests** in `test/services/`
2. **Add integration tests** in `test/integration/`
3. **Follow naming convention**: `*_test.dart`
4. **Clean up test data** in `tearDown()` or `tearDownAll()`
5. **Use unique test keys** with prefix `test:*`

Example:

```dart
test('my new feature', () async {
  const testKey = 'test:my_feature';

  // Your test code

  // Cleanup
  await redisService.delete(testKey);
});
```

## Best Practices

✅ **DO**:

- Use unique test keys with clear prefixes
- Clean up test data after each test
- Test both success and failure scenarios
- Use meaningful test descriptions
- Mock external dependencies in integration tests

❌ **DON'T**:

- Use production data in tests
- Leave test data in Redis
- Run tests against production Redis
- Skip cleanup in tearDown
- Use hardcoded values without constants

---

Happy Testing! 🧪✅
