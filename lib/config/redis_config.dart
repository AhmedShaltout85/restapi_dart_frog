import 'package:dotenv/dotenv.dart';

/// Redis configuration loaded from environment variables
class RedisConfig {
  RedisConfig({
    required this.host,
    required this.port,
    this.password,
    this.database = 0,
  });

  /// Load Redis configuration from environment variables
  factory RedisConfig.fromEnv(DotEnv env) {
    return RedisConfig(
      host: env['REDIS_HOST'] ?? 'localhost',
      port: int.tryParse(env['REDIS_PORT'] ?? '6379') ?? 6379,
      password:
          env['REDIS_PASSWORD']?.isEmpty ?? true ? null : env['REDIS_PASSWORD'],
      database: int.tryParse(env['REDIS_DB'] ?? '0') ?? 0,
    );
  }
  final String host;
  final int port;
  final String? password;
  final int database;

  /// Get connection string for Redis
  String get connectionString {
    final auth = password != null ? ':$password@' : '';
    return 'redis://$auth$host:$port/$database';
  }

  @override
  String toString() {
    return 'RedisConfig(host: $host, port: $port, database: $database, hasPassword: ${password != null})';
  }
}
