import 'dart:async';
import 'dart:developer' as developer;
import 'package:redis/redis.dart';
import 'package:restapi_dart_frog/config/redis_config.dart';

/// Service for managing Redis connections and operations
class RedisService {
  RedisService(this.config);
  final RedisConfig config;
  RedisConnection? _connection;
  Command? _command;
  bool _isConnected = false;

  /// Check if Redis is connected
  bool get isConnected => _isConnected;

  /// Initialize Redis connection
  Future<void> connect() async {
    try {
      developer.log('Connecting to Redis at ${config.host}:${config.port}...');

      _connection = RedisConnection();
      _command = await _connection!.connect(config.host, config.port);

      // Authenticate if password is provided
      if (config.password != null && config.password!.isNotEmpty) {
        await _command!.send_object(['AUTH', config.password!]);
      }

      // Select database
      if (config.database != 0) {
        await _command!.send_object(['SELECT', config.database.toString()]);
      }

      _isConnected = true;
      developer.log('✅ Redis connected successfully');
    } catch (e) {
      _isConnected = false;
      developer.log('❌ Redis connection failed: $e');
      rethrow;
    }
  }

  /// Disconnect from Redis
  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _connection!.close();
        _isConnected = false;
        developer.log('Redis disconnected');
      }
    } catch (e) {
      developer.log('Error disconnecting Redis: $e');
    }
  }

  /// Get value by key
  Future<String?> get(String key) async {
    _ensureConnected();
    try {
      final result = await _command!.send_object(['GET', key]);
      return result?.toString();
    } catch (e) {
      developer.log('Redis GET error: $e');
      return null;
    }
  }

  /// Set key-value with optional TTL (in seconds)
  Future<bool> set(String key, String value, {int? ttl}) async {
    _ensureConnected();
    try {
      if (ttl != null && ttl > 0) {
        // Use SETEX for key with expiration
        await _command!.send_object(['SETEX', key, ttl.toString(), value]);
      } else {
        await _command!.send_object(['SET', key, value]);
      }
      return true;
    } catch (e) {
      developer.log('Redis SET error: $e');
      return false;
    }
  }

  /// Delete key
  Future<bool> delete(String key) async {
    _ensureConnected();
    try {
      final result = await _command!.send_object(['DEL', key]);
      return result == 1;
    } catch (e) {
      developer.log('Redis DEL error: $e');
      return false;
    }
  }

  /// Check if key exists
  Future<bool> exists(String key) async {
    _ensureConnected();
    try {
      final result = await _command!.send_object(['EXISTS', key]);
      return result == 1;
    } catch (e) {
      developer.log('Redis EXISTS error: $e');
      return false;
    }
  }

  /// Get TTL of a key (in seconds, -1 = no expiration, -2 = key doesn't exist)
  Future<int> ttl(String key) async {
    _ensureConnected();
    try {
      final result = await _command!.send_object(['TTL', key]);
      return result as int;
    } catch (e) {
      developer.log('Redis TTL error: $e');
      return -2;
    }
  }

  /// Get all keys matching pattern
  Future<List<String>> keys(String pattern) async {
    _ensureConnected();
    try {
      final result = await _command!.send_object(['KEYS', pattern]);
      if (result is List) {
        return result.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      developer.log('Redis KEYS error: $e');
      return [];
    }
  }

  /// Delete all keys matching pattern
  Future<int> deletePattern(String pattern) async {
    _ensureConnected();
    try {
      final matchingKeys = await keys(pattern);
      if (matchingKeys.isEmpty) return 0;

      final result = await _command!.send_object(['DEL', ...matchingKeys]);
      return result as int;
    } catch (e) {
      developer.log('Redis DELETE PATTERN error: $e');
      return 0;
    }
  }

  /// Ping Redis to check connection
  Future<bool> ping() async {
    try {
      if (!_isConnected || _command == null) return false;
      final result = await _command!.send_object(['PING']);
      return result.toString().toUpperCase() == 'PONG';
    } catch (e) {
      developer.log('Redis PING error: $e');
      return false;
    }
  }

  /// Get Redis info
  Future<Map<String, String>> info() async {
    _ensureConnected();
    try {
      final result = await _command!.send_object(['INFO']);
      final info = <String, String>{};

      if (result != null) {
        final lines = result.toString().split('\n');
        for (final line in lines) {
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length == 2) {
              info[parts[0].trim()] = parts[1].trim();
            }
          }
        }
      }

      return info;
    } catch (e) {
      developer.log('Redis INFO error: $e');
      return {};
    }
  }

  /// Ensure Redis is connected, throw if not
  void _ensureConnected() {
    if (!_isConnected || _command == null) {
      throw Exception('Redis is not connected. Call connect() first.');
    }
  }
}
