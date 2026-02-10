import 'dart:io';
import 'package:dart_odbc/dart_odbc.dart';
import 'package:dotenv/dotenv.dart';

void main() async {
  final env = DotEnv()..load();

  print('Testing ODBC Connection...');
  print('==========================');

  final pathToDriver = env['PATH_TO_DRIVER'] ?? '/usr/lib64/libmsodbcsql-18.so';
  final dsn = env['DB_DSN'] ?? 'PickLocationDB';
  final username = env['DB_USERNAME'] ?? 'sa';
  final password = env['DB_PASSWORD'] ?? '';
  final host = env['DB_HOST'] ?? 'localhost';
  final port = env['DB_PORT'] ?? '1433';
  final database = env['DB_NAME'] ?? 'PickLocationDB';

  print('Configuration:');
  print('  Driver: $pathToDriver');
  print('  DSN: $dsn');
  print('  Host: $host');
  print('  Port: $port');
  print('  Database: $database');
  print('  Username: $username');

  // Check if driver file exists
  final driverFile = File(pathToDriver);
  if (await driverFile.exists()) {
    print('✓ Driver file exists at: $pathToDriver');
  } else {
    print('✗ Driver file NOT found at: $pathToDriver');
    print('Available ODBC drivers:');
    await Process.run('odbcinst', ['-j'], runInShell: true).then((result) {
      print(result.stdout);
    });
    exit(1);
  }

  // Test with ODBC command line tools first
  print('\nTesting with ODBC command line tools...');
  print('Running: echo "SELECT 1" | isql -v $dsn $username $password');

  final result = await Process.run(
    'sh',
    ['-c', 'echo "SELECT 1;" | isql -v $dsn $username $password'],
    runInShell: true,
  );

  print('Exit code: ${result.exitCode}');
  print('STDOUT: ${result.stdout}');
  print('STDERR: ${result.stderr}');

  if (result.exitCode == 0) {
    print('\n✓ ODBC connection successful via command line!');
  } else {
    print('\n✗ ODBC connection failed via command line');

    // Try with connection string
    final connectionString = 'DRIVER={ODBC Driver 18 for SQL Server};'
        'SERVER=$host,$port;'
        'DATABASE=$database;'
        'UID=$username;'
        'PWD=$password;'
        'TrustServerCertificate=yes;';

    print('\nTrying with connection string...');
    print('Running: echo "SELECT 1" | isql -v "$connectionString"');

    final result2 = await Process.run(
      'sh',
      ['-c', 'echo "SELECT 1;" | isql -v "$connectionString"'],
      runInShell: true,
    );

    print('Exit code: ${result2.exitCode}');
    print('STDOUT: ${result2.stdout}');
    print('STDERR: ${result2.stderr}');
  }
}
