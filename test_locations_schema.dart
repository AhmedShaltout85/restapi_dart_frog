import 'dart:developer';
import 'package:restapi_dart_frog/database/database_config.dart';
import 'package:restapi_dart_frog/database/database_helper.dart';

void main() async {
  log('Diagnosing Locations table schema...');

  try {
    // Initialize database
    final config = DatabaseConfig.fromEnvironment();
    DatabaseHelper.initialize(config);

    // Test connection
    final connected = await DatabaseHelper.testConnection();
    if (!connected) {
      log('✗ Database connection failed');
      return;
    }

    log('✓ Database connected');

    // Check if Locations table exists
    final tableExists = await DatabaseHelper.tableExists('Locations');
    if (!tableExists) {
      log('✗ Locations table does not exist');
      return;
    }

    log('✓ Locations table exists');

    // Get table schema
    log('\nGetting table schema...');
    try {
      final schema = await DatabaseHelper.executeQuery('''
        SELECT 
          COLUMN_NAME,
          DATA_TYPE,
          IS_NULLABLE,
          COLUMN_DEFAULT
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = 'Locations'
        ORDER BY ORDINAL_POSITION
      ''');

      log('Table schema:');
      for (final column in schema) {
        log('  ${column['COLUMN_NAME']} (${column['DATA_TYPE']}) - '
            'Nullable: ${column['IS_NULLABLE']} - '
            'Default: ${column['COLUMN_DEFAULT']}');
      }
    } catch (e) {
      log('✗ Failed to get schema: $e');
    }

    // Get sample data
    log('\nGetting sample data...');
    try {
      final sample = await DatabaseHelper.executeQuery(
        'SELECT TOP 3 * FROM Locations ORDER BY ID DESC',
      );

      if (sample.isNotEmpty) {
        log('Sample data (first ${sample.length} rows):');
        for (final row in sample) {
          log('  Row:');
          for (final entry in row.entries) {
            log('    ${entry.key}: ${entry.value} (${entry.value.runtimeType})');
          }
        }
      } else {
        log('No data found in Locations table');
      }
    } catch (e) {
      log('✗ Failed to get sample data: $e');
    }

    // Test basic query
    log('\nTesting basic query...');
    try {
      final result = await DatabaseHelper.executeQuery(
        'SELECT COUNT(*) as count FROM Locations',
      );
      log('Total records: ${result[0]['count']}');
    } catch (e) {
      log('✗ Basic query failed: $e');
    }
  } catch (e) {
    log('✗ Setup failed: $e');
  }
}
