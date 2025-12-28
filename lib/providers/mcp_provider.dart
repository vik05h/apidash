import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp/mcp.dart';
import '../services/mcp_service.dart';
import 'providers.dart';

/// Default port for MCP HTTP server
const int kMcpServerPort = 22140;

/// Provider for MCP server state
final mcpServerStateProvider =
    StateNotifierProvider<McpServerNotifier, McpServerState>((ref) {
  return McpServerNotifier(ref);
});

/// MCP Server state
class McpServerState {
  final bool isRunning;
  final String? error;
  final String? serverUrl;
  final int port;

  const McpServerState({
    this.isRunning = false,
    this.error,
    this.serverUrl,
    this.port = kMcpServerPort,
  });

  McpServerState copyWith({
    bool? isRunning,
    String? error,
    String? serverUrl,
    int? port,
  }) {
    return McpServerState(
      isRunning: isRunning ?? this.isRunning,
      error: error,
      serverUrl: serverUrl ?? this.serverUrl,
      port: port ?? this.port,
    );
  }
}

/// Notifier for MCP server
class McpServerNotifier extends StateNotifier<McpServerState> {
  final Ref ref;
  McpServer? _server;
  HttpTransport? _transport;

  McpServerNotifier(this.ref) : super(const McpServerState()) {
    // Listen to settings changes
    ref.listen(settingsProvider, (previous, next) {
      if (next.isMcpServerEnabled && !state.isRunning) {
        startServer();
      } else if (!next.isMcpServerEnabled && state.isRunning) {
        stopServer();
      }
    });

    // Auto-start if already enabled
    final settings = ref.read(settingsProvider);
    if (settings.isMcpServerEnabled) {
      startServer();
    }
  }

  Future<void> startServer() async {
    if (state.isRunning) return;

    try {
      // Use HTTP transport so clients can connect while app is running
      _transport = HttpTransport(port: state.port);
      await _transport!.startServer();

      _server = McpServer(transport: _transport!);

      // Register APIDash tools and resources with REAL data
      final dataProvider = RiverpodApiDashDataProvider(ref);
      registerApiDashTools(_server!.toolRegistry, dataProvider);
      registerApiDashResources(_server!.resourceRegistry, dataProvider);

      await _server!.start();

      state = state.copyWith(
        isRunning: true,
        error: null,
        serverUrl: _transport!.serverUrl,
      );
    } catch (e) {
      state = state.copyWith(isRunning: false, error: e.toString());
    }
  }

  Future<void> stopServer() async {
    if (!state.isRunning) return;

    try {
      await _server?.stop();
      await _transport?.close();
      _server = null;
      _transport = null;
      state = state.copyWith(isRunning: false, error: null, serverUrl: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    stopServer();
    super.dispose();
  }
}
