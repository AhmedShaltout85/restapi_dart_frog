// routes/api/locations/index.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/models/locations_model.dart';
import 'package:restapi_dart_frog/repositories/locations_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.options) {
    return Response(
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*',
      },
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGet();
    case HttpMethod.post:
      return _handlePost(context);
    default:
      return Response(statusCode: 405, body: 'Method not allowed');
  }
}

Future<Response> _handleGet() async {
  try {
    final locations = await LocationsRepository.findAll();

    return Response.json(
      headers: {'Access-Control-Allow-Origin': '*'},
      body: {
        'success': true,
        'data': locations.map((loc) => loc.toJson()).toList(),
        'count': locations.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  } catch (e, stackTrace) {
    print('Error in GET /api/locations: $e');
    print('Stack trace: $stackTrace');

    return Response.json(
      headers: {'Access-Control-Allow-Origin': '*'},
      body: {
        'success': false,
        'message': 'Failed to retrieve locations',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
      statusCode: 500,
    );
  }
}

Future<Response> _handlePost(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;

    // Create location from JSON (uses fromJson which handles camelCase)
    final location = Locations.fromJson(body);

    // Save to database
    final createdLocation = await LocationsRepository.create(location);

    if (createdLocation != null) {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': true,
          'message': 'Location created successfully',
          'data': createdLocation.toJson(),
          'timestamp': DateTime.now().toIso8601String(),
        },
        statusCode: 201,
      );
    } else {
      return Response.json(
        headers: {'Access-Control-Allow-Origin': '*'},
        body: {
          'success': false,
          'message': 'Failed to create location',
          'timestamp': DateTime.now().toIso8601String(),
        },
        statusCode: 500,
      );
    }
  } catch (e, stackTrace) {
    print('Error in POST /api/locations: $e');
    print('Stack trace: $stackTrace');

    return Response.json(
      headers: {'Access-Control-Allow-Origin': '*'},
      body: {
        'success': false,
        'message': 'Failed to create location',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
      statusCode: 500,
    );
  }
}
