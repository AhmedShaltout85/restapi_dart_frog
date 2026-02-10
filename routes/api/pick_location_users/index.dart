import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/models/pick_location_users_model.dart';
import 'package:restapi_dart_frog/repositories/pick_location_users_repository.dart';
import 'package:restapi_dart_frog/utils/response_helper.dart';

final _repository = PickLocationUsersRepository();

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

Future<Response> _getAll(RequestContext context) async {
  try {
    final records = await _repository.findAll();
    return ResponseHelper.success(
      data: records.map((r) => r.toJson()).toList(),
      message: 'Retrieved ${records.length} records',
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Failed to retrieve records',
      error: e,
    );
  }
}

Future<Response> _create(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final id = await _repository.create(PickLocationUsers.fromJson(body));
    final created = await _repository.findById(id);
    return ResponseHelper.created(data: created?.toJson());
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Failed to create record',
      error: e,
    );
  }
}
