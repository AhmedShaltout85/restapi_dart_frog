import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/database/database_helper.dart';

Future<Response> onRequest(RequestContext context) async {
  // Handle CORS preflight
  if (context.request.method == HttpMethod.options) {
    return Response(
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*',
      },
    );
  }

  // Only allow GET
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405, body: 'Method not allowed');
  }

  try {
    // Test connection first
    final isConnected = await DatabaseHelper.testConnection();

    if (!isConnected) {
      return Response.json(
        body: {
          'status': 'error',
          'message': 'Database connection test failed',
          'timestamp': DateTime.now().toIso8601String(),
        },
        statusCode: 500,
      );
    }

    // Execute a test query
    final result = await DatabaseHelper.executeQuery(
      'SELECT @@VERSION as version, DB_NAME() as database, CURRENT_TIMESTAMP as timestamp',
    );

    return Response.json(
      body: {
        'status': 'success',
        'message': 'Database connected successfully',
        'data': result,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'error',
        'message': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
