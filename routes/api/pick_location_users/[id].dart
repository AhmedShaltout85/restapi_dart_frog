import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/models/pick_location_users_model.dart';
import 'package:restapi_dart_frog/repositories/pick_location_users_repository.dart';
import 'package:restapi_dart_frog/utils/response_helper.dart';

final _repository = PickLocationUsersRepository();

Future<Response> onRequest(RequestContext context, String id) async {
  final recordId = int.tryParse(id);
  if (recordId == null) return ResponseHelper.error(message: 'Invalid ID');

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

Future<Response> _getById(RequestContext context, int id) async {
  try {
    final record = await _repository.findById(id);
    if (record == null) return ResponseHelper.notFound();
    return ResponseHelper.success(data: record.toJson());
  } catch (e) {
    return ResponseHelper.serverError(error: e);
  }
}

Future<Response> _update(RequestContext context, int id) async {
  try {
    if (await _repository.findById(id) == null)
      return ResponseHelper.notFound();
    final body = await context.request.json() as Map<String, dynamic>;
    await _repository.update(
      id,
      PickLocationUsers.fromJson(body).copyWith(id: id),
    );
    final updated = await _repository.findById(id);
    return ResponseHelper.success(
      data: updated?.toJson(),
      message: 'Updated successfully',
    );
  } catch (e) {
    return ResponseHelper.serverError(error: e);
  }
}

Future<Response> _delete(RequestContext context, int id) async {
  try {
    if (await _repository.findById(id) == null)
      return ResponseHelper.notFound();
    await _repository.delete(id);
    return ResponseHelper.deleted();
  } catch (e) {
    return ResponseHelper.serverError(error: e);
  }
}
