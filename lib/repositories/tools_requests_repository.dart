// ignore_for_file: public_member_api_docs, cascade_invocations

import 'package:restapi_dart_frog/models/tools_requests_model.dart';
import 'package:restapi_dart_frog/repositories/base_repository.dart';

class ToolsRequestsRepository extends BaseRepository<ToolsRequests> {
  @override
  String get tableName => 'tools_requests';

  @override
  ToolsRequests fromDb(Map<String, dynamic> row) {
    return ToolsRequests.fromDb(row);
  }

  @override
  Map<String, dynamic> toDb(ToolsRequests model) {
    final json = model.toJson();
    json.remove('id');
    return json;
  }
}
