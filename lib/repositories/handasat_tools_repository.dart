// ignore_for_file: public_member_api_docs, cascade_invocations

import 'package:restapi_dart_frog/models/handasat_tools_model.dart';
import 'package:restapi_dart_frog/repositories/base_repository.dart';

class HandasatToolsRepository extends BaseRepository<HandasatTools> {
  @override
  String get tableName => 'handasat_tools';

  @override
  HandasatTools fromDb(Map<String, dynamic> row) {
    return HandasatTools.fromDb(row);
  }

  @override
  Map<String, dynamic> toDb(HandasatTools model) {
    final json = model.toJson();
    json.remove('id');
    return json;
  }
}
