// lib/repositories/locations_repository.dart
// ignore_for_file: public_member_api_docs

import 'package:restapi_dart_frog/database/database_helper.dart';
import 'package:restapi_dart_frog/models/locations_model.dart';

class LocationsRepository {
  /// Get all locations
  static Future<List<Locations>> findAll() async {
    try {
      final rows = await DatabaseHelper.executeQuery('SELECT * FROM Locations');

      // Debug: print first row to see actual column names
      if (rows.isNotEmpty) {
        print('First row column names: ${rows[0].keys.toList()}');
      }

      return rows.map((row) {
        try {
          return Locations.fromDb(row);
        } catch (e, stackTrace) {
          print('Error converting row to Locations model: $e');
          print('Row data: $row');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error in findAll: $e');
      rethrow;
    }
  }

  /// Get location by ID
  static Future<Locations?> findById(int id) async {
    try {
      final row = await DatabaseHelper.executeSingleQuery(
        'SELECT * FROM Locations WHERE ID = ?',
        params: [id],
      );

      return row != null ? Locations.fromDb(row) : null;
    } catch (e) {
      print('Error in findById: $e');
      rethrow;
    }
  }

  /// Create new location
  static Future<Locations?> create(Locations location) async {
    try {
      // Insert and get the new ID using OUTPUT clause
      final result = await DatabaseHelper.executeQuery(
        '''
INSERT INTO Locations (Address, Latitude, Longitude, Date, Flag, Gis_Url, Handasah_Name, Technical_Name, Is_Finished, Is_Approved, Caller_Name, Broken_Type, Caller_Number, Video_Call) 
           OUTPUT INSERTED.ID
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        params: [
          location.address,
          location.latitude,
          location.longitude,
          location.date,
          location.flag,
          location.gisUrl,
          location.handasahName,
          location.technicalName,
          location.isFinished,
          location.isApproved,
          location.callerName,
          location.brokenType,
          location.callerNumber,
          location.videoCall,
        ],
      );

      if (result.isNotEmpty) {
        // Safe cast for ID since database might return it as string
        int? safeIntCast(dynamic value) {
          if (value == null) return null;
          if (value is int) return value;
          if (value is num) return value.toInt();
          return int.tryParse(value.toString());
        }

        final newId = safeIntCast(result[0]['ID']);
        if (newId == null) {
          print('Failed to get new ID from INSERT result');
          return null;
        }

        // Return the newly created location with the ID
        return Locations(
          id: newId,
          address: location.address,
          latitude: location.latitude,
          longitude: location.longitude,
          date: location.date,
          flag: location.flag,
          gisUrl: location.gisUrl,
          handasahName: location.handasahName,
          technicalName: location.technicalName,
          isFinished: location.isFinished,
          isApproved: location.isApproved,
          callerName: location.callerName,
          brokenType: location.brokenType,
          callerNumber: location.callerNumber,
          videoCall: location.videoCall,
        );
      }
      return null;
    } catch (e) {
      print('Error in create: $e');
      rethrow;
    }
  }

  /// Update location
  static Future<bool> update(int id, Locations location) async {
    try {
      final success = await DatabaseHelper.executeNonQuery(
        'UPDATE Locations SET Address = ?, Latitude = ?, Longitude = ?, Date = ?, Flag = ?, Gis_Url = ?, Handasah_Name = ?, Technical_Name = ?, Is_Finished = ?, Is_Approved = ?, Caller_Name = ?, Broken_Type = ?, Caller_Number = ?, Video_Call = ? WHERE ID = ?',
        params: [
          location.address,
          location.latitude,
          location.longitude,
          location.date,
          location.flag,
          location.gisUrl,
          location.handasahName,
          location.technicalName,
          location.isFinished,
          location.isApproved,
          location.callerName,
          location.brokenType,
          location.callerNumber,
          location.videoCall,
          id,
        ],
      );

      return success > 0;
    } catch (e) {
      print('Error in update: $e');
      return false;
    }
  }

  /// Delete location
  static Future<bool> delete(int id) async {
    try {
      final rowsAffected = await DatabaseHelper.executeNonQuery(
        'DELETE FROM Locations WHERE ID = ?',
        params: [id],
      );

      return rowsAffected > 0;
    } catch (e) {
      print('Error in delete: $e');
      return false;
    }
  }
}
