import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:restapi_dart_frog/services/redis_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: HttpStatus.methodNotAllowed,
      body: {'success': false, 'message': 'Method not allowed'},
    );
  }

  try {
    final redisService = context.read<RedisService>();

    // Check Redis connection
    final isConnected = await redisService.ping();

    if (!isConnected) {
      return Response.json(
        statusCode: HttpStatus.serviceUnavailable,
        body: {
          'success': false,
          'message': 'Redis is not connected',
          'status': 'disconnected',
        },
      );
    }

    // Get Redis info
    final info = await redisService.info();

    return Response.json(
      body: {
        'success': true,
        'message': 'Redis is healthy',
        'status': 'connected',
        'info': {
          'connected': true,
          'version': info['redis_version'] ?? 'unknown',
          'uptime_seconds': info['uptime_in_seconds'] ?? '0',
          'connected_clients': info['connected_clients'] ?? '0',
          'used_memory_human': info['used_memory_human'] ?? '0',
        },
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.serviceUnavailable,
      body: {
        'success': false,
        'message': 'Redis health check failed',
        'error': e.toString(),
        'status': 'error',
      },
    );
  }
}
