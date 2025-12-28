import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'transport.dart';

/// HTTP transport for MCP communication
/// This allows MCP clients to connect via HTTP while the app is running
/// Uses synchronous request/response pattern - each POST gets its response directly
class HttpTransport implements McpTransport {
  final int port;
  final String host;

  HttpServer? _server;
  final StreamController<String> _incomingController =
      StreamController<String>.broadcast();
  bool _isConnected = false;

  /// Pending response completers keyed by request id
  final Map<String, Completer<String>> _pendingResponses = {};

  /// Current request being handled (for response routing)
  HttpResponse? _currentResponse;

  HttpTransport({this.port = 8080, this.host = 'localhost'});

  /// Start the HTTP server
  Future<void> startServer() async {
    if (_server != null) return;

    _server = await HttpServer.bind(host, port);
    _isConnected = true;

    _server!.listen(_handleRequest);
  }

  void _handleRequest(HttpRequest request) async {
    // Add CORS headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, POST, OPTIONS',
    );
    request.response.headers.add(
      'Access-Control-Allow-Headers',
      'Content-Type',
    );

    if (request.method == 'OPTIONS') {
      request.response.statusCode = 200;
      await request.response.close();
      return;
    }

    final path = request.uri.path;

    switch (path) {
      case '/message':
      case '/mcp':
        await _handleMessage(request);
        break;
      case '/health':
        await _handleHealth(request);
        break;
      default:
        request.response.statusCode = 404;
        request.response.write('Not found');
        await request.response.close();
    }
  }

  /// Handle incoming JSON-RPC messages from clients
  /// Returns the response directly in the HTTP response
  Future<void> _handleMessage(HttpRequest request) async {
    if (request.method != 'POST') {
      request.response.statusCode = 405;
      request.response.write('Method not allowed');
      await request.response.close();
      return;
    }

    try {
      final body = await utf8.decoder.bind(request).join();
      if (body.isEmpty) {
        request.response.statusCode = 400;
        request.response.write('{"error": "Empty body"}');
        await request.response.close();
        return;
      }

      // Parse the request to get the id
      String? requestId;
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        requestId = json['id']?.toString();
      } catch (_) {
        // Might be a batch request or notification
      }

      // Create a completer for the response
      final completer = Completer<String>();
      if (requestId != null) {
        _pendingResponses[requestId] = completer;
      }

      // Store current response for routing
      _currentResponse = request.response;

      // Send to the MCP server for processing
      _incomingController.add(body);

      // Wait for the response with timeout
      String response;
      if (requestId != null) {
        try {
          response = await completer.future.timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                '{"jsonrpc": "2.0", "error": {"code": -32000, "message": "Timeout"}, "id": $requestId}',
          );
        } finally {
          _pendingResponses.remove(requestId);
        }
      } else {
        // For notifications (no id), just acknowledge
        response = '{"status": "received"}';
      }

      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(response);
    } catch (e) {
      request.response.statusCode = 500;
      request.response.write(
        '{"error": "${e.toString().replaceAll('"', '\\"')}"}',
      );
    }

    await request.response.close();
    _currentResponse = null;
  }

  /// Health check endpoint
  Future<void> _handleHealth(HttpRequest request) async {
    request.response.statusCode = 200;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"status": "ok", "server": "apidash-mcp"}');
    await request.response.close();
  }

  @override
  Stream<String> get incoming => _incomingController.stream;

  @override
  Future<void> send(String message) async {
    if (!_isConnected) {
      throw StateError('Transport is not connected');
    }

    // Parse the response to route it to the correct pending request
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      final id = json['id']?.toString();

      if (id != null && _pendingResponses.containsKey(id)) {
        _pendingResponses[id]!.complete(message);
      }
    } catch (_) {
      // Not a valid JSON response, ignore
    }
  }

  @override
  Future<void> close() async {
    _isConnected = false;

    // Complete all pending requests with error
    for (final entry in _pendingResponses.entries) {
      if (!entry.value.isCompleted) {
        entry.value.complete(
          '{"jsonrpc": "2.0", "error": {"code": -32000, "message": "Server shutdown"}, "id": ${entry.key}}',
        );
      }
    }
    _pendingResponses.clear();

    await _server?.close();
    _server = null;
    await _incomingController.close();
  }

  @override
  bool get isConnected => _isConnected;

  /// Get the server URL
  String get serverUrl => 'http://$host:$port';
}
