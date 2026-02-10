// ignore_for_file: public_member_api_docs, cascade_invocations

import 'package:restapi_dart_frog/models/pick_location_handasah_model.dart';
import 'package:restapi_dart_frog/repositories/base_repository.dart';

/// Repository for pick_location_handasah table
class PickLocationHandasahRepository
    extends BaseRepository<PickLocationHandasah> {
  @override
  String get tableName => 'pick_location_handasah';

  @override
  PickLocationHandasah fromDb(Map<String, dynamic> row) {
    return PickLocationHandasah.fromDb(row);
  }

  @override
  Map<String, dynamic> toDb(PickLocationHandasah model) {
    final json = model.toJson();
    json.remove('id'); // Remove id for insert/update
    return json;
  }
}
