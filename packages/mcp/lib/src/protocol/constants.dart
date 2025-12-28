/// MCP Protocol Constants
/// Based on MCP Specification: https://spec.modelcontextprotocol.io/

/// Current protocol version
const String kMcpProtocolVersion = '2024-11-05';

/// JSON-RPC version
const String kJsonRpcVersion = '2.0';

/// Server information
const String kServerName = 'apidash-mcp';
const String kServerVersion = '0.1.0';

/// MCP Methods
class McpMethods {
  // Lifecycle
  static const String initialize = 'initialize';
  static const String initialized = 'notifications/initialized';
  static const String shutdown = 'shutdown';

  // Tools
  static const String toolsList = 'tools/list';
  static const String toolsCall = 'tools/call';
  static const String toolsListChanged = 'notifications/tools/list_changed';

  // Resources
  static const String resourcesList = 'resources/list';
  static const String resourcesRead = 'resources/read';
  static const String resourcesListChanged =
      'notifications/resources/list_changed';
  static const String resourcesSubscribe = 'resources/subscribe';
  static const String resourcesUnsubscribe = 'resources/unsubscribe';
  static const String resourceTemplatesList = 'resources/templates/list';

  // Prompts
  static const String promptsList = 'prompts/list';
  static const String promptsGet = 'prompts/get';
  static const String promptsListChanged = 'notifications/prompts/list_changed';

  // Logging
  static const String loggingSetLevel = 'logging/setLevel';
  static const String loggingMessage = 'notifications/message';

  // Completion
  static const String completionComplete = 'completion/complete';

  // Ping
  static const String ping = 'ping';

  // Cancelled
  static const String cancelled = 'notifications/cancelled';
  static const String progress = 'notifications/progress';
}

/// MCP Error Codes (JSON-RPC 2.0 + MCP specific)
class McpErrorCodes {
  // JSON-RPC 2.0 standard errors
  static const int parseError = -32700;
  static const int invalidRequest = -32600;
  static const int methodNotFound = -32601;
  static const int invalidParams = -32602;
  static const int internalError = -32603;

  // MCP specific errors
  static const int connectionClosed = -32000;
  static const int requestTimeout = -32001;
}

/// Log levels for MCP logging
enum McpLogLevel {
  debug,
  info,
  notice,
  warning,
  error,
  critical,
  alert,
  emergency,
}
