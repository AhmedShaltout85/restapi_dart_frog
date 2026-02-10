// lib/database/database_config.dart
// ignore_for_file: public_member_api_docs, missing_whitespace_between_adjacent_strings

import 'package:dotenv/dotenv.dart';

///
class DatabaseConfig {
  ///
  DatabaseConfig({
    required this.pathToDriver,
    required this.odbcDsn,
    required this.username,
    required this.password,
    required this.host,
    required this.database,
    required this.port,
  });

  factory DatabaseConfig.fromEnvironment() {
    final env = DotEnv()..load();

    // Use helper function to ensure no null values
    String getEnv(String key, String defaultValue) {
      final value = env[key];
      if (value == null || value.isEmpty) {
        print('Warning: $key not found in .env, using default: $defaultValue');
        return defaultValue;
      }
      return value;
    }

    return DatabaseConfig(
      pathToDriver: getEnv('PATH_TO_DRIVER', '/usr/lib64/libmsodbcsql-18.so'),
      odbcDsn: getEnv('DB_DSN', 'PickLocationDB'),
      username: getEnv('DB_USERNAME', 'sa'),
      password: getEnv('DB_PASSWORD', 'ahraahabsha@Ao8R'),
      host: getEnv('DB_HOST', 'localhost'),
      database: getEnv('DB_NAME', 'PickLocationDB'),
      port: int.tryParse(getEnv('DB_PORT', '1433')) ?? 1433,
    );
  }
  final String pathToDriver;
  final String odbcDsn;
  final String username;
  final String password;
  final String host;
  final String database;
  final int port;

  // Get connection string
  String get connectionString {
    return 'DRIVER={ODBC Driver 18 for SQL Server};'
        'SERVER=$host,$port;'
        'DATABASE=$database;'
        'UID=$username;'
        'PWD=$password;'
        'TrustServerCertificate=yes;';
  }

  @override
  String toString() {
    return 'DatabaseConfig{'
        'driver: $pathToDriver, '
        'dsn: $odbcDsn, '
        'host: $host, '
        'port: $port, '
        'database: $database, '
        'username: $username'
        '}';
  }
}
