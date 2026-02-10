import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/models/pick_location_handasah_model.dart';
import 'package:restapi_dart_frog/repositories/pick_location_handasah_repository.dart';
import 'package:restapi_dart_frog/utils/response_helper.dart';

final _repository = PickLocationHandasahRepository();

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await _getAll(context),
    HttpMethod.post => await _create(context),
    _ => ResponseHelper.error(
        message: 'Method not allowed',
        statusCode: HttpStatus.methodNotAllowed,
      ),
  };
}

/// Get all records
Future<Response> _getAll(RequestContext context) async {
  try {
    final records = await _repository.findAll();
    final jsonRecords = records.map((r) => r.toJson()).toList();

    return ResponseHelper.success(
      data: jsonRecords,
      message: 'Retrieved ${records.length} records successfully',
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Failed to retrieve records',
      error: e,
    );
  }
}

/// Create a new record
Future<Response> _create(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final model = PickLocationHandasah.fromJson(body);

    final id = await _repository.create(model);
    final created = await _repository.findById(id);

    return ResponseHelper.created(
      data: created?.toJson(),
      message: 'Record created successfully',
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Failed to create record',
      error: e,
    );
  }
}
