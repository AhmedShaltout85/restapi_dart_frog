import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:restapi_dart_frog/database/database_config.dart';
import 'package:restapi_dart_frog/database/database_helper.dart';
import 'package:restapi_dart_frog/services/jwt_service.dart';
import 'package:restapi_dart_frog/config/redis_config.dart';
import 'package:restapi_dart_frog/services/redis_service.dart';
import 'package:restapi_dart_frog/services/token_cache_service.dart';

/// Middleware to initialize database connection, Redis, and provide services
Handler middleware(Handler handler) {
  return (context) async {
    // Initialize database and Redis on first request
    if (!_initialized) {
      await _initialize();
      _setupCleanup();
    }

    // Provide services to all routes
    final updatedContext = context
        .provide<JwtService>(() => _jwtService!)
        .provide<RedisService>(() => _redisService!)
        .provide<TokenCacheService>(() => _tokenCacheService!);

    // Add CORS headers
    final response = await handler(updatedContext);
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*',
      },
    );
  };
}

bool _initialized = false;
final _cleanupSetup = Completer<void>();
JwtService? _jwtService;
RedisService? _redisService;
TokenCacheService? _tokenCacheService;

Future<void> _initialize() async {
  try {
    // Load database configuration
    final config = DatabaseConfig.fromEnvironment();

    // Initialize database helper
    DatabaseHelper.initialize(config);

    // Test connection
    final dbSuccess = await DatabaseHelper.testConnection();
    if (dbSuccess) {
      log('✅ Database initialized successfully');
      log('  Database: ${config.database}');
      log('  Host: ${config.host}:${config.port}');
      log('  Username: ${config.username}');
    } else {
      log('❌ Database initialization failed');
    }

    // Create JwtService instance
    _jwtService = JwtService(
      secretKey: config.jwtSecret,
      expirationHours: config.jwtExpirationHours,
    );
    log('✅ JWT Service initialized');

    // Initialize Redis
    final env = DotEnv()..load();
    final redisConfig = RedisConfig.fromEnv(env);
    _redisService = RedisService(redisConfig);

    try {
      await _redisService!.connect();
      log('✅ Redis connected successfully');
      log('  Host: ${redisConfig.host}:${redisConfig.port}');
      log('  Database: ${redisConfig.database}');
    } catch (e) {
      log('⚠️  Redis connection failed (continuing without Redis): $e');
      log('  Token blacklisting and caching will be disabled');
      // Continue without Redis - the app will work with JWT validation only
    }

    // Create TokenCacheService
    _tokenCacheService = TokenCacheService(_redisService!);
    log('✅ Token Cache Service initialized');

    _initialized = true;
  } catch (e, stackTrace) {
    log('❌ Failed to initialize services: $e\n$stackTrace');
    exit(1);
  }
}

void _setupCleanup() {
  if (!_cleanupSetup.isCompleted) {
    _cleanupSetup.complete();

    // Handle process termination
    ProcessSignal.sigint.watch().listen((signal) {
      _cleanup();
      exit(0);
    });

    ProcessSignal.sigterm.watch().listen((signal) {
      _cleanup();
      exit(0);
    });
  }
}

Future<void> _cleanup() async {
  if (_initialized) {
    log('Cleaning up...');

    // Disconnect Redis
    if (_redisService != null) {
      await _redisService!.disconnect();
      log('✅ Redis disconnected');
    }

    log('Database connections are closed automatically after each query');
  }
}
