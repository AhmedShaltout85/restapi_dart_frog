import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';

Future<Response> onRequest(RequestContext context) async {
  final env = DotEnv()..load();

  // Get all environment variables (mask passwords)
  final envVars = <String, String>{};
  env.map.forEach((key, value) {
    if (key.contains('PASSWORD')) {
      envVars[key] = '***MASKED***';
    } else {
      envVars[key] = value ?? 'NULL';
    }
  });

  return Response.json(
    body: {
      'status': 'debug',
      'environment_variables': envVars,
      'server_time': DateTime.now().toIso8601String(),
    },
  );
}
