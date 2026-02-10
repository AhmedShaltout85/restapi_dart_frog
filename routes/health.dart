import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return Response.json(
    body: {
      'status': 'ok',
      'service': 'Dart Frog REST API',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
