import 'package:restapi_dart_frog/database/database_config.dart';
import 'package:restapi_dart_frog/database/database_helper.dart';

void main() async {
  print('Simple test - checking column names...');
  
  try {
    final config = DatabaseConfig.fromEnvironment();
    DatabaseHelper.initialize(config);
    
    // Get one row to see column names
    final result = await DatabaseHelper.executeQuery(
      'SELECT TOP 1 * FROM Locations',
    );
    
    if (result.isEmpty) {
      print('No data in Locations table');
      return;
    }
    
    final row = result[0];
    print('\nColumn names in the database:');
    for (final key in row.keys) {
      print('  "$key"');
    }
    
    // Try to access each column
    print('\nTrying to access each column:');
    for (final key in row.keys) {
      try {
        final value = row[key];
        print('  "$key": $value (type: ${value.runtimeType})');
      } catch (e) {
        print('  "$key": ERROR - $e');
      }
    }
    
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}
