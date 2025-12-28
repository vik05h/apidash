import 'dart:convert';
import 'dart:io';

void main() async {
  print('Starting server...');
  final process = await Process.start('dart', [
    'bin/server.dart',
    '--stdio',
  ], workingDirectory: 'packages/mcp');

  // Listen to stdout
  process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (line) {
      print('SERVER STDOUT: $line');
    },
  );

  // Listen to stderr
  process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
    (line) {
      print('SERVER STDERR: $line');
    },
  );

  // Send initialize request
  final initRequest = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {"name": "manual-test", "version": "1.0"},
    },
  };

  print('Sending initialize request...');
  process.stdin.writeln(jsonEncode(initRequest));
  await process.stdin.flush();

  // Wait a bit for response
  await Future.delayed(const Duration(seconds: 1));

  // Send initialized notification
  print('Sending initialized notification...');
  process.stdin.writeln(
    jsonEncode({"jsonrpc": "2.0", "method": "notifications/initialized"}),
  );
  await process.stdin.flush();

  // Wait a bit
  await Future.delayed(const Duration(seconds: 2));

  print('Killing server...');
  process.kill();
}
