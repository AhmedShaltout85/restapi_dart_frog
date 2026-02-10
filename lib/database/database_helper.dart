// lib/database/database_helper.dart
import 'dart:developer';
import 'package:dart_odbc/dart_odbc.dart';
import 'package:restapi_dart_frog/database/database_config.dart';

/// Database helper for executing queries
class DatabaseHelper {
  static DatabaseConfig? _config;

  /// Initialize database helper with configuration
  static void initialize(DatabaseConfig config) {
    _config = config;
    log('DatabaseHelper initialized with config: ${config.database}');
  }

  /// Get a fresh database connection
  static DartOdbc _getConnection() {
    if (_config == null) {
      throw Exception(
        'DatabaseHelper not initialized. Call initialize() first.',
      );
    }

    final config = _config!;
    final odbc = DartOdbc(config.pathToDriver);

    try {
      // Try with DSN first
      odbc.connect(
        dsn: config.odbcDsn,
        username: config.username,
        password: config.password,
      );
      return odbc;
    } catch (e) {
      // If DSN fails, try connection string
      log('DSN connection failed, trying connection string: $e');
      odbc.disconnect();

      final odbc2 = DartOdbc(config.pathToDriver);
      odbc2.connect(
        dsn: config.connectionString,
        username: '',
        password: '',
      );
      return odbc2;
    }
  }

  /// Execute a query and return results
  static Future<List<Map<String, dynamic>>> executeQuery(
    String query, {
    List<dynamic>? params,
  }) async {
    final odbc = _getConnection();

    try {
      final result = odbc.execute(query, params: params);
      return result;
    } catch (e, stackTrace) {
      log('Query failed: $e\n$stackTrace');
      rethrow;
    } finally {
      odbc.disconnect();
    }
  }

  /// Execute a non-query command (INSERT, UPDATE, DELETE)
  static Future<int> executeNonQuery(
    String query, {
    List<dynamic>? params,
  }) async {
    final odbc = _getConnection();

    try {
      // Execute the query
      final result = odbc.execute(query, params: params);

      // For SQL Server, we can use @@ROWCOUNT to get affected rows
      // First, try to get affected rows from the result
      if (result.isNotEmpty) {
        // Check if result contains rowcount
        if (result[0].containsKey('@@ROWCOUNT')) {
          final rowCount = result[0]['@@ROWCOUNT'];
          if (rowCount is int) return rowCount;
          if (rowCount is num) return rowCount.toInt();
        }

        // Check if result contains any numeric value that might be row count
        for (final key in result[0].keys) {
          final value = result[0][key];
          if (value is int && key.toLowerCase().contains('row')) {
            return value;
          }
        }
      }

      // Fallback: Execute separate query to get affected rows
      try {
        final rowCountResult =
            await executeSingleQuery('SELECT @@ROWCOUNT as rowcount');
        if (rowCountResult != null) {
          final rowCount = rowCountResult['rowcount'];
          if (rowCount is int) return rowCount;
          if (rowCount is num) return rowCount.toInt();
        }
      } catch (_) {
        // Ignore and return 0
      }

      return 0;
    } catch (e, stackTrace) {
      log('Non-query failed: $e\n$stackTrace');
      rethrow;
    } finally {
      odbc.disconnect();
    }
  }

  /// Execute a query and return a single result
  static Future<Map<String, dynamic>?> executeSingleQuery(
    String query, {
    List<dynamic>? params,
  }) async {
    final results = await executeQuery(query, params: params);
    return results.isNotEmpty ? results.first : null;
  }

  /// Execute a scalar query (returns a single value)
  static Future<dynamic> executeScalar(
    String query, {
    List<dynamic>? params,
  }) async {
    final result = await executeSingleQuery(query, params: params);
    if (result != null && result.isNotEmpty) {
      return result.values.first;
    }
    return null;
  }

  /// Test database connection
  static Future<bool> testConnection() async {
    try {
      log('Testing database connection...');
      final result = await executeSingleQuery('SELECT 1 as connection_test');

      if (result != null) {
        final testValue = result['connection_test'];
        // Check if value is 1 (as int, string, or any truthy value)
        if (testValue == 1 ||
            testValue == '1' ||
            (testValue is int && testValue == 1) ||
            (testValue is String && testValue == '1')) {
          log('✓ Database connection test successful');
          return true;
        }
      }
      log('✗ Database connection test failed - invalid result: $result');
      return false;
    } catch (e, stackTrace) {
      log('✗ Database connection test failed: $e\n$stackTrace');
      return false;
    }
  }

  /// Get connection information
  static Map<String, dynamic> getConnectionInfo() {
    return {
      'initialized': _config != null,
      'database': _config?.database ?? 'Not configured',
      'host': _config?.host ?? 'Not configured',
      'port': _config?.port ?? 'Not configured',
    };
  }

  /// Execute a stored procedure
  static Future<List<Map<String, dynamic>>> executeStoredProcedure(
    String procedureName, {
    List<dynamic>? params,
  }) async {
    final paramString = params != null && params.isNotEmpty
        ? params.map((_) => '?').join(',')
        : '';
    final query =
        'EXEC $procedureName${paramString.isNotEmpty ? ' $paramString' : ''}';

    return executeQuery(query, params: params);
  }

  /// Check if a table exists
  static Future<bool> tableExists(String tableName) async {
    try {
      final result = await executeSingleQuery(
        'SELECT COUNT(*) as count FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ?',
        params: [tableName],
      );

      return result != null && (result['count'] as int) > 0;
    } catch (_) {
      return false;
    }
  }

  /// Execute a query with pagination
  static Future<List<Map<String, dynamic>>> executePaginatedQuery(
    String query,
    int page,
    int pageSize, {
    List<dynamic>? params,
  }) async {
    final offset = (page - 1) * pageSize;
    final paginatedQuery =
        '$query OFFSET $offset ROWS FETCH NEXT $pageSize ROWS ONLY';

    return executeQuery(paginatedQuery, params: params);
  }

  /// Get total count for a query
  static Future<int> getQueryCount(
    String baseQuery,
    String countColumn, {
    List<dynamic>? params,
  }) async {
    // Extract FROM clause
    final fromIndex = baseQuery.toLowerCase().indexOf('from');
    if (fromIndex == -1) return 0;

    final whereIndex = baseQuery.toLowerCase().indexOf('where');
    final orderByIndex = baseQuery.toLowerCase().indexOf('order by');

    String countQuery;
    if (whereIndex != -1) {
      final whereClause = orderByIndex != -1
          ? baseQuery.substring(whereIndex, orderByIndex)
          : baseQuery.substring(whereIndex);
      countQuery =
          'SELECT COUNT($countColumn) as total FROM ${baseQuery.substring(fromIndex + 4, whereIndex)} $whereClause';
    } else {
      final fromClause = orderByIndex != -1
          ? baseQuery.substring(fromIndex + 4, orderByIndex)
          : baseQuery.substring(fromIndex + 4);
      countQuery = 'SELECT COUNT($countColumn) as total FROM $fromClause';
    }

    final result = await executeSingleQuery(countQuery, params: params);

    if (result != null) {
      final total = result['total'];
      if (total is int) return total;
      if (total is num) return total.toInt();
    }
    return 0;
  }

  /// Execute multiple queries in a transaction
  static Future<void> executeTransaction(
    List<String> queries, {
    List<List<dynamic>>? paramsList,
  }) async {
    final odbc = _getConnection();

    try {
      for (var i = 0; i < queries.length; i++) {
        final params =
            paramsList != null && i < paramsList.length ? paramsList[i] : null;
        odbc.execute(queries[i], params: params);
      }
    } catch (e, stackTrace) {
      log('Transaction failed: $e\n$stackTrace');
      rethrow;
    } finally {
      odbc.disconnect();
    }
  }

  /// Batch insert operation
  static Future<void> batchInsert(
    String tableName,
    List<Map<String, dynamic>> records, {
    List<String>? columns,
  }) async {
    if (records.isEmpty) return;

    // Use provided columns or get from first record
    final columnList = columns ?? records.first.keys.toList();
    final columnString = columnList.join(', ');
    final placeholders = columnList.map((_) => '?').join(', ');

    final odbc = _getConnection();

    try {
      for (final record in records) {
        final values = columnList.map((col) => record[col]).toList();
        odbc.execute(
          'INSERT INTO $tableName ($columnString) VALUES ($placeholders)',
          params: values,
        );
      }
    } catch (e, stackTrace) {
      log('Batch insert failed: $e\n$stackTrace');
      rethrow;
    } finally {
      odbc.disconnect();
    }
  }
}
