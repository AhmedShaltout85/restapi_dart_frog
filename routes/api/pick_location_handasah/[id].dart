import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/models/pick_location_handasah_model.dart';
import 'package:restapi_dart_frog/repositories/pick_location_handasah_repository.dart';
import 'package:restapi_dart_frog/utils/response_helper.dart';

final _repository = PickLocationHandasahRepository();

Future<Response> onRequest(RequestContext context, String id) async {
  final recordId = int.tryParse(id);
  if (recordId == null) {
    return ResponseHelper.error(
      message: 'Invalid ID format',
    );
  }

  return switch (context.request.method) {
    HttpMethod.get => await _getById(context, recordId),
    HttpMethod.put => await _update(context, recordId),
    HttpMethod.delete => await _delete(context, recordId),
    _ => ResponseHelper.error(
        message: 'Method not allowed',
        statusCode: HttpStatus.methodNotAllowed,
      ),
  };
}

/// Get record by ID
Future<Response> _getById(RequestContext context, int id) async {
  try {
    final record = await _repository.findById(id);

    if (record == null) {
      return ResponseHelper.notFound(message: 'Record not found');
    }

    return ResponseHelper.success(
      data: record.toJson(),
      message: 'Record retrieved successfully',
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Failed to retrieve record',
      error: e,
    );
  }
}

/// Update record by ID
Future<Response> _update(RequestContext context, int id) async {
  try {
    final exists = await _repository.findById(id);
    if (exists == null) {
      return ResponseHelper.notFound(message: 'Record not found');
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final model = PickLocationHandasah.fromJson(body).copyWith(id: id);

    await _repository.update(id, model);
    final updated = await _repository.findById(id);

    return ResponseHelper.success(
      data: updated?.toJson(),
      message: 'Record updated successfully',
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Failed to update record',
      error: e,
    );
  }
}

/// Delete record by ID
Future<Response> _delete(RequestContext context, int id) async {
  try {
    final exists = await _repository.findById(id);
    if (exists == null) {
      return ResponseHelper.notFound(message: 'Record not found');
    }

    await _repository.delete(id);

    return ResponseHelper.deleted(
      message: 'Record deleted successfully',
    );
  } catch (e) {
    return ResponseHelper.serverError(
      message: 'Failed to delete record',
      error: e,
    );
  }
}
