// ignore_for_file: public_member_api_docs, cascade_invocations

import 'dart:developer';
import 'package:restapi_dart_frog/database/database_helper.dart';
import 'package:restapi_dart_frog/models/pick_location_users_model.dart';
import 'package:restapi_dart_frog/repositories/base_repository.dart';

class PickLocationUsersRepository extends BaseRepository<PickLocationUsers> {
  @override
  String get tableName => 'pick_location_users';

  @override
  PickLocationUsers fromDb(Map<String, dynamic> row) {
    return PickLocationUsers.fromDb(row);
  }

  @override
  Map<String, dynamic> toDb(PickLocationUsers model) {
    final json = model.toJson();
    json.remove('id');
    return json;
  }

  /// Find user by username (for authentication)
  Future<PickLocationUsers?> findByUserName(String userName) async {
    try {
      final result = await DatabaseHelper.executeSingleQuery(
        'SELECT * FROM $tableName WHERE user_name = ?',
        params: [userName],
      );

      return result != null ? PickLocationUsers.fromDb(result) : null;
    } catch (e) {
      log('Error finding user by username: $e');
      rethrow;
    }
  }

  /// Check if username already exists (for registration)
  Future<bool> userNameExists(String userName) async {
    try {
      final result = await DatabaseHelper.executeSingleQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE user_name = ?',
        params: [userName],
      );

      if (result != null) {
        final count = result['count'];
        if (count is int) return count > 0;
        if (count is num) return count.toInt() > 0;
        if (count is String) {
          final parsed = int.tryParse(count);
          return parsed != null && parsed > 0;
        }
      }
      return false;
    } catch (e) {
      log('Error checking username existence: $e');
      rethrow;
    }
  }
}
