// ignore_for_file: public_member_api_docs, cascade_invocations

import 'package:restapi_dart_frog/models/hot_line_status_data_model.dart';
import 'package:restapi_dart_frog/repositories/base_repository.dart';

class HotLineStatusDataRepository extends BaseRepository<HotLineStatusData> {
  @override
  String get tableName => 'hot_line_status_data';

  @override
  HotLineStatusData fromDb(Map<String, dynamic> row) {
    return HotLineStatusData.fromDb(row);
  }

  @override
  Map<String, dynamic> toDb(HotLineStatusData model) {
    final json = model.toJson();
    json.remove('uid');
    return json;
  }

  @override
  String getIdColumn() => 'uid';
}
