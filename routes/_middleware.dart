import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/database/database_config.dart';
import 'package:restapi_dart_frog/database/database_helper.dart';

/// Middleware to initialize database connection
Handler middleware(Handler handler) {
  return (context) async {
    // Initialize database on first request
    if (!_initialized) {
      _initialize();
      _setupCleanup();
    }

    // Add CORS headers
    final response = await handler(context);
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

void _initialize() {
  try {
    // Load database configuration
    final config = DatabaseConfig.fromEnvironment();

    // Initialize database helper
    DatabaseHelper.initialize(config);

    // Test connection
    DatabaseHelper.testConnection().then((success) {
      if (success) {
        log('✓ Database initialized successfully');
        log('  Database: ${config.database}');
        log('  Host: ${config.host}:${config.port}');
        log('  Username: ${config.username}');
      } else {
        log('✗ Database initialization failed');
      }
    });

    _initialized = true;
  } catch (e) {
    log('✗ Failed to initialize database: $e');
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

void _cleanup() {
  if (_initialized) {
    log('Cleaning up...');
    log('Database connections are closed automatically after each query');
  }
}
