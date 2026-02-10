// lib/repositories/base_repository.dart
import 'package:restapi_dart_frog/database/database_helper.dart';

/// Base repository class
/// Provides generic CRUD operations for all repositories
abstract class BaseRepository<T> {
  /// Table name in the database
  String get tableName;

  /// Convert database row to model instance
  T fromDb(Map<String, dynamic> row);

  /// Convert model to JSON for database insert/update
  Map<String, dynamic> toDb(T model);

  /// Get all records from table
  Future<List<T>> findAll() async {
    try {
      final rows =
          await DatabaseHelper.executeQuery('SELECT * FROM $tableName');
      return rows.map(fromDb).toList();
    } catch (e) {
      print('Error in findAll for $tableName: $e');
      rethrow;
    }
  }

  /// Get a record by ID
  Future<T?> findById(int id) async {
    try {
      final row = await DatabaseHelper.executeSingleQuery(
        'SELECT * FROM $tableName WHERE ${getIdColumn()} = ?',
        params: [id],
      );
      return row != null ? fromDb(row) : null;
    } catch (e) {
      print('Error in findById for $tableName (id: $id): $e');
      rethrow;
    }
  }

  /// Create a new record
  Future<int> create(T model) async {
    try {
      final data = toDb(model);
      final columns = data.keys.where((k) => k != getIdColumn()).toList();
      final placeholders = List.filled(columns.length, '?').join(', ');
      final columnNames = columns.join(', ');
      final values = columns.map((k) => data[k]).toList();

      await DatabaseHelper.executeNonQuery(
        'INSERT INTO $tableName ($columnNames) VALUES ($placeholders)',
        params: values,
      );

      // Get the last inserted ID
      final result = await DatabaseHelper.executeSingleQuery(
        'SELECT SCOPE_IDENTITY() as id',
      );
      return result?['id'] as int? ?? 0;
    } catch (e) {
      print('Error in create for $tableName: $e');
      rethrow;
    }
  }

  /// Update a record by ID
  Future<bool> update(int id, T model) async {
    try {
      final data = toDb(model);
      final columns = data.keys.where((k) => k != getIdColumn()).toList();
      final setClause = columns.map((k) => '$k = ?').join(', ');
      final values = [...columns.map((k) => data[k]), id];

      final affected = await DatabaseHelper.executeNonQuery(
        'UPDATE $tableName SET $setClause WHERE ${getIdColumn()} = ?',
        params: values,
      );
      return affected > 0;
    } catch (e) {
      print('Error in update for $tableName (id: $id): $e');
      rethrow;
    }
  }

  /// Delete a record by ID
  Future<bool> delete(int id) async {
    try {
      final affected = await DatabaseHelper.executeNonQuery(
        'DELETE FROM $tableName WHERE ${getIdColumn()} = ?',
        params: [id],
      );
      return affected > 0;
    } catch (e) {
      print('Error in delete for $tableName (id: $id): $e');
      rethrow;
    }
  }

  /// Get the ID column name (override if different from 'id')
  String getIdColumn() => 'id';

  /// Get records with pagination
  Future<List<T>> findPaginated(int page, int pageSize) async {
    try {
      final offset = (page - 1) * pageSize;
      final rows = await DatabaseHelper.executeQuery(
        'SELECT * FROM $tableName ORDER BY ${getIdColumn()} '
        'OFFSET $offset ROWS FETCH NEXT $pageSize ROWS ONLY',
      );
      return rows.map(fromDb).toList();
    } catch (e) {
      print('Error in findPaginated for $tableName: $e');
      rethrow;
    }
  }

  /// Get total count of records
  Future<int> count() async {
    try {
      final result = await DatabaseHelper.executeSingleQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );
      return result?['count'] as int? ?? 0;
    } catch (e) {
      print('Error in count for $tableName: $e');
      rethrow;
    }
  }
}
