// ignore_for_file: public_member_api_docs, cascade_invocations

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
}
