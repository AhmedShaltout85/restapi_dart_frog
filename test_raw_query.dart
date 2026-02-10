import 'package:restapi_dart_frog/database/database_config.dart';
import 'package:restapi_dart_frog/database/database_helper.dart';

void main() async {
  print('Testing raw query to see actual database response...');
  
  try {
    // Initialize database
    final config = DatabaseConfig.fromEnvironment();
    DatabaseHelper.initialize(config);
    
    // Test connection
    final connected = await DatabaseHelper.testConnection();
    if (!connected) {
      print('✗ Database connection failed');
      return;
    }
    
    print('✓ Database connected');
    
    // Execute raw query
    print('\nExecuting SELECT * FROM Locations...');
    try {
      final result = await DatabaseHelper.executeQuery(
        'SELECT TOP 1 * FROM Locations',
      );
      
      if (result.isEmpty) {
        print('No data returned');
        return;
      }
      
      print('\n=== RAW DATABASE RESPONSE ===');
      print('Type of result: ${result.runtimeType}');
      print('Number of rows: ${result.length}');
      
      final firstRow = result[0];
      print('\nFirst row keys:');
      for (final key in firstRow.keys) {
        print('  "$key" (${key.runtimeType})');
      }
      
      print('\nFirst row values:');
      for (final entry in firstRow.entries) {
        final value = entry.value;
        print('  "${entry.key}": $value (${value.runtimeType})');
      }
      
      // Try to create Locations model
      print('\n=== TRYING TO CREATE MODEL ===');
      try {
        // Create a simple test
        final testRow = {
          'ID': firstRow['ID'],
          'Address': firstRow['Address'],
          'Latitude': firstRow['Latitude'],
          'Longtiude': firstRow['Longtiude'],
          'Date': firstRow['Date'],
          'Flag': firstRow['Flag'],
          'Gis_Url': firstRow['Gis_Url'],
          'Handasah_Name': firstRow['Handasah_Name'],
          'Technical_Name': firstRow['Technical_Name'],
          'Is_Finished': firstRow['Is_Finished'],
          'Is_Approved': firstRow['Is_Approved'],
          'Caller_Name': firstRow['Caller_Name'],
          'Broken_Type': firstRow['Broken_Type'],
          'Caller_Number': firstRow['Caller_Number'],
          'Video_Call': firstRow['Video_Call'],
        };
        
        print('Test row created successfully');
        
        // Now test the fromDb factory
        print('\nTesting Locations.fromDb()...');
        final location = Locations.fromDb(testRow);
        print('Model created successfully!');
        print('Location address: ${location.address}');
        
      } catch (e, stackTrace) {
        print('✗ Failed to create model: $e');
        print('Stack trace: $stackTrace');
      }
      
    } catch (e, stackTrace) {
      print('✗ Query failed: $e');
      print('Stack trace: $stackTrace');
    }
    
  } catch (e) {
    print('✗ Setup failed: $e');
  }
}

// Simple Locations class for testing
class Locations {
  final int? id;
  final String address;
  
  Locations({this.id, required this.address});
  
  factory Locations.fromDb(Map<String, dynamic> row) {
    // Try to get address with various fallbacks
    final address = (row['Address'] ?? '').toString();
    
    return Locations(
      id: row['ID'] as int?,
      address: address,
    );
  }
}
