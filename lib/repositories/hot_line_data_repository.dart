// ignore_for_file: public_member_api_docs, cascade_invocations

import 'package:restapi_dart_frog/models/hot_line_data_model.dart';
import 'package:restapi_dart_frog/repositories/base_repository.dart';

class HotLineDataRepository extends BaseRepository<HotLineData> {
  @override
  String get tableName => 'hot_line_data';

  @override
  HotLineData fromDb(Map<String, dynamic> row) {
    return HotLineData.fromDb(row);
  }

  @override
  Map<String, dynamic> toDb(HotLineData model) {
    final json = model.toJson();
    json.remove('id');
    return json;
  }
}
