// ignore_for_file: public_member_api_docs, cascade_invocations

import 'package:restapi_dart_frog/models/tracking_locations_model.dart';
import 'package:restapi_dart_frog/repositories/base_repository.dart';

class TrackingLocationsRepository extends BaseRepository<TrackingLocations> {
  @override
  String get tableName => 'tracking_locations';

  @override
  TrackingLocations fromDb(Map<String, dynamic> row) {
    return TrackingLocations.fromDb(row);
  }

  @override
  Map<String, dynamic> toDb(TrackingLocations model) {
    final json = model.toJson();
    json.remove('id');
    return json;
  }
}
