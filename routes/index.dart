import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return Response.json(
    body: {
      'message': 'Welcome to Dart Frog REST API',
      'endpoints': {
        '/': 'This welcome message',
        '/health': 'Health check',
        '/test/db': 'Test database connection',
      },
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
