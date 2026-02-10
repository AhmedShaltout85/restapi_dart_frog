// routes/api/locations/[id].dart
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/models/locations_model.dart';
import 'package:restapi_dart_frog/repositories/locations_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  // Handle CORS preflight
  if (context.request.method == HttpMethod.options) {
    return Response(
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*',
      },
    );
  }

  final locationId = int.tryParse(id);
  if (locationId == null) {
    return Response.json(
      headers: {'Access-Control-Allow-Origin': '*'},
      body: {
        'success': false,
        'message': 'Invalid location ID',
      },
      statusCode: 400,
    );
  }

  final repository = LocationsRepository();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGet(locationId, repository);
    case HttpMethod.put:
      return _handlePut(context, locationId, repository);
    case HttpMethod.delete:
      return _handleDelete(locationId, repository);
    default:
      return Response(statusCode: 405, body: 'Method not allowed');
  }
}

Future<Response> _handleGet(int id, LocationsRepository repository) async {
  try {
    final location = await LocationsRepository.findById(id);

    if (location == null) {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': false,
          'message': 'Location not found',
        },
        statusCode: 404,
      );
    }

    return Response.json(
      headers: {'Access-Control-Allow-Origin': '*'},
      body: {
        'success': true,
        'data': location.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  } catch (e) {
    print('Error in GET /api/locations/$id: $e');
    return _errorResponse('Failed to retrieve location', e.toString());
  }
}

Future<Response> _handlePut(
  RequestContext context,
  int id,
  LocationsRepository repository,
) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Get existing location
    final existing = await LocationsRepository.findById(id);
    if (existing == null) {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': false,
          'message': 'Location not found',
        },
        statusCode: 404,
      );
    }

    // Create updated location
    final updatedLocation = Locations(
      id: id,
      address: body['Address'] as String? ?? existing.address,
      latitude: body['Latitude'] as String? ?? existing.latitude,
      longitude: body['Longtiude'] as String? ?? existing.longitude,
      date: body['Date'] as String? ?? existing.date,
      flag: body['Flag'] != null
          ? int.tryParse(body['Flag'].toString())
          : existing.flag,
      gisUrl: body['Gis_Url'] as String? ?? existing.gisUrl,
      handasahName: body['Handasah_Name'] as String? ?? existing.handasahName,
      technicalName:
          body['Technical_Name'] as String? ?? existing.technicalName,
      isFinished: body['Is_Finished'] != null
          ? (body['Is_Finished'] as int)
          : existing.isFinished,
      isApproved: body['Is_Approved'] != null
          ? (body['Is_Approved'] as int)
          : existing.isApproved,
      callerName: body['Caller_Name'] as String? ?? existing.callerName,
      brokenType: body['Broken_Type'] as String? ?? existing.brokenType,
      callerNumber: body['Caller_Number'] as String? ?? existing.callerNumber,
      videoCall: body['Video_Call'] != null
          ? int.tryParse(body['Video_Call'].toString())
          : existing.videoCall,
    );

    // Update in database
    final success = await LocationsRepository.update(id, updatedLocation);

    if (success) {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': true,
          'message': 'Location updated successfully',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': false,
          'message': 'Failed to update location',
        },
        statusCode: 500,
      );
    }
  } catch (e) {
    print('Error in PUT /api/locations/$id: $e');
    return _errorResponse('Failed to update location', e.toString());
  }
}

Future<Response> _handleDelete(int id, LocationsRepository repository) async {
  try {
    final success = await LocationsRepository.delete(id);

    if (success) {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': true,
          'message': 'Location deleted successfully',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': false,
          'message': 'Location not found',
        },
        statusCode: 404,
      );
    }
  } catch (e) {
    print('Error in DELETE /api/locations/$id: $e');
    return _errorResponse('Failed to delete location', e.toString());
  }
}

Response _errorResponse(String message, String error) {
  return Response.json(
    headers: {'Access-Control-Allow-Origin': '*'},
    body: {
      'success': false,
      'message': message,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    },
    statusCode: 500,
  );
}
