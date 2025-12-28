import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'transport.dart';

/// STDIO transport for MCP communication
/// Uses stdin for receiving messages and stdout for sending messages
class StdioTransport implements McpTransport {
  final StreamController<String> _incomingController =
      StreamController<String>.broadcast();

  late final StreamSubscription<String> _stdinSubscription;
  bool _isConnected = false;

  StdioTransport() {
    _initializeStdin();
  }

  void _initializeStdin() {
    _isConnected = true;

    // Read lines from stdin
    _stdinSubscription =
        stdin.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        if (line.isNotEmpty) {
          _incomingController.add(line);
        }
      },
      onError: (error) {
        stderr.writeln('STDIO Transport error: $error');
        _isConnected = false;
      },
      onDone: () {
        _isConnected = false;
        _incomingController.close();
      },
    );
  }

  @override
  Stream<String> get incoming => _incomingController.stream;

  @override
  Future<void> send(String message) async {
    if (!_isConnected) {
      throw StateError('Transport is not connected');
    }
    // Write to stdout followed by newline
    stdout.writeln(message);
    await stdout.flush();
  }

  @override
  Future<void> close() async {
    _isConnected = false;
    await _stdinSubscription.cancel();
    await _incomingController.close();
  }

  @override
  bool get isConnected => _isConnected;
}
