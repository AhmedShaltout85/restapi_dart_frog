// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_odbc/dart_odbc.dart';
import 'package:dotenv/dotenv.dart';
import 'package:restapi_dart_frog/database/database_config.dart';

Future<Response> onRequest(RequestContext context) async {
  final env = DotEnv()..load();

  final envVars = <String, String>{};
  env.map.forEach((key, value) {
    if (key.contains('PASSWORD')) {
      envVars[key] = '***MASKED***';
    } else {
      envVars[key] = value;
    }
  });

  try {
    // Test DatabaseConfig
    final config = DatabaseConfig.fromEnvironment();

    // Test direct connection
    print('Attempting direct connection test...');
    final odbc = DartOdbc(config.pathToDriver);

    try {
      odbc.connect(
        dsn: config.odbcDsn,
        username: config.username,
        password: config.password,
      );

      final result = odbc.execute('SELECT 1 as test, @@VERSION as version');
      odbc.disconnect();

      return Response.json(
        body: {
          'status': 'success',
          'database': {
            'connected': true,
            'test_result': result,
            'config': {
              'driver': config.pathToDriver,
              'dsn': config.odbcDsn,
              'host': config.host,
              'port': config.port,
              'database': config.database,
              'username': config.username,
              'password_length': config.password.length,
            },
          },
          'environment_variables': envVars,
        },
      );
    } catch (e, stackTrace) {
      return Response.json(
        body: {
          'status': 'error',
          'database': {
            'connected': false,
            'error': e.toString(),
            'stack_trace': stackTrace.toString(),
            'config': {
              'driver': config.pathToDriver,
              'dsn': config.odbcDsn,
              'host': config.host,
              'port': config.port,
              'database': config.database,
              'username': config.username,
              'password_length': config.password.length,
            },
          },
          'environment_variables': envVars,
        },
        statusCode: 500,
      );
    }
  } catch (e, stackTrace) {
    return Response.json(
      body: {
        'status': 'config_error',
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
        'environment_variables': envVars,
      },
      statusCode: 500,
    );
  }
}
