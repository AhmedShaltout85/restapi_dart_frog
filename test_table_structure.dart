import 'package:restapi_dart_frog/database/database_config.dart';
import 'package:restapi_dart_frog/database/database_helper.dart';

void main() async {
  print('Checking Locations table structure...');
  
  try {
    final config = DatabaseConfig.fromEnvironment();
    DatabaseHelper.initialize(config);
    
    // Test connection
    final connected = await DatabaseHelper.testConnection();
    if (!connected) {
      print('✗ Database connection failed');
      return;
    }
    
    print('✓ Database connected');
    
    // Check if table exists
    final tableExists = await DatabaseHelper.tableExists('Locations');
    print('Locations table exists: $tableExists');
    
    if (!tableExists) {
      print('Table does not exist. Available tables:');
      try {
        final tables = await DatabaseHelper.executeQuery('''
          SELECT TABLE_NAME 
          FROM INFORMATION_SCHEMA.TABLES 
          WHERE TABLE_TYPE = 'BASE TABLE'
        ''');
        for (final table in tables) {
          print('  - ${table['TABLE_NAME']}');
        }
      } catch (e) {
        print('Error listing tables: $e');
      }
      return;
    }
    
    // Get table schema
    print('\n=== Locations Table Schema ===');
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
      
      if (schema.isEmpty) {
        print('No columns found in Locations table');
      } else {
        for (final column in schema) {
          print('  ${column['COLUMN_NAME']} (${column['DATA_TYPE']}) - '
                'Nullable: ${column['IS_NULLABLE']}');
        }
      }
    } catch (e) {
      print('Error getting schema: $e');
    }
    
    // Count records
    print('\n=== Record Count ===');
    try {
      final countResult = await DatabaseHelper.executeSingleQuery(
        'SELECT COUNT(*) as count FROM Locations',
      );
      print('Total records: ${countResult?['count'] ?? 0}');
    } catch (e) {
      print('Error counting records: $e');
    }
    
    // Try to insert a test record
    print('\n=== Testing Insert ===');
    try {
      final affected = await DatabaseHelper.executeNonQuery('''
        INSERT INTO Locations (Address) 
        VALUES ('Test Address ' || CAST(NEWID() as NVARCHAR(36)))
      ''');
      print('Insert test - affected rows: $affected');
      
      // Now query it back
      final newRecord = await DatabaseHelper.executeQuery(
        'SELECT TOP 1 * FROM Locations ORDER BY ID DESC',
      );
      
      if (newRecord.isNotEmpty) {
        print('\nNewly inserted record:');
        for (final entry in newRecord[0].entries) {
          print('  ${entry.key}: ${entry.value} (${entry.value.runtimeType})');
        }
      }
    } catch (e, stackTrace) {
      print('Insert test failed: $e');
      print('Stack trace: $stackTrace');
    }
    
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
