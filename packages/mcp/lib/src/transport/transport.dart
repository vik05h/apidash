import 'dart:async';

/// Abstract transport interface for MCP communication
abstract class McpTransport {
  /// Stream of incoming messages (JSON strings)
  Stream<String> get incoming;

  /// Send a message (JSON string)
  Future<void> send(String message);

  /// Close the transport
  Future<void> close();

  /// Whether the transport is connected
  bool get isConnected;
}

/// Callback type for logging
typedef McpLogCallback = void Function(String level, String message);
