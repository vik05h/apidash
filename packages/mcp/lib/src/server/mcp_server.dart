import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../protocol/protocol.dart';
import '../transport/transports.dart';
import '../tools/tool_registry.dart';
import '../resources/resource_registry.dart';

/// MCP Server implementation
class McpServer {
  final McpTransport _transport;
  final ToolRegistry _toolRegistry;
  final ResourceRegistry _resourceRegistry;

  StreamSubscription<String>? _subscription;
  bool _initialized = false;
  ClientCapabilities? _clientCapabilities;
  Implementation? _clientInfo;

  McpServer({
    required McpTransport transport,
    ToolRegistry? toolRegistry,
    ResourceRegistry? resourceRegistry,
  }) : _transport = transport,
       _toolRegistry = toolRegistry ?? ToolRegistry(),
       _resourceRegistry = resourceRegistry ?? ResourceRegistry();

  /// Tool registry for registering and managing tools
  ToolRegistry get toolRegistry => _toolRegistry;

  /// Resource registry for registering and managing resources
  ResourceRegistry get resourceRegistry => _resourceRegistry;

  /// Whether the server has been initialized by a client
  bool get isInitialized => _initialized;

  /// Start the MCP server
  Future<void> start() async {
    _subscription = _transport.incoming.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDone,
    );

    _log('info', 'MCP Server started');
  }

  /// Stop the MCP server
  Future<void> stop() async {
    await _subscription?.cancel();
    await _transport.close();
    _log('info', 'MCP Server stopped');
  }

  void _handleMessage(String message) async {
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;

      // Check if it's a request or notification
      if (json.containsKey('method')) {
        if (json.containsKey('id')) {
          // It's a request
          final request = JsonRpcRequest.fromJson(json);
          await _handleRequest(request);
        } else {
          // It's a notification
          final notification = JsonRpcNotification.fromJson(json);
          await _handleNotification(notification);
        }
      }
    } catch (e, stackTrace) {
      _log('error', 'Error handling message: $e\n$stackTrace');
      // Send parse error if we can determine the id
      await _sendError(null, JsonRpcError.parseError(e.toString()));
    }
  }

  Future<void> _handleRequest(JsonRpcRequest request) async {
    try {
      final result = await _routeRequest(request);
      await _sendResponse(
        JsonRpcResponse.success(id: request.id, result: result),
      );
    } on JsonRpcError catch (e) {
      await _sendError(request.id, e);
    } catch (e) {
      await _sendError(request.id, JsonRpcError.internalError(e.toString()));
    }
  }

  Future<dynamic> _routeRequest(JsonRpcRequest request) async {
    switch (request.method) {
      case McpMethods.initialize:
        return await _handleInitialize(request.params);

      case McpMethods.ping:
        return {};

      case McpMethods.toolsList:
        _checkInitialized();
        return _handleToolsList(request.params);

      case McpMethods.toolsCall:
        _checkInitialized();
        return await _handleToolsCall(request.params);

      case McpMethods.resourcesList:
        _checkInitialized();
        return _handleResourcesList(request.params);

      case McpMethods.resourcesRead:
        _checkInitialized();
        return await _handleResourcesRead(request.params);

      case McpMethods.resourceTemplatesList:
        _checkInitialized();
        return _handleResourceTemplatesList(request.params);

      case McpMethods.promptsList:
        _checkInitialized();
        return _handlePromptsList(request.params);

      case McpMethods.promptsGet:
        _checkInitialized();
        return await _handlePromptsGet(request.params);

      case McpMethods.loggingSetLevel:
        _checkInitialized();
        return _handleLoggingSetLevel(request.params);

      default:
        throw JsonRpcError.methodNotFound('Unknown method: ${request.method}');
    }
  }

  Future<void> _handleNotification(JsonRpcNotification notification) async {
    switch (notification.method) {
      case McpMethods.initialized:
        _log('info', 'Client sent initialized notification');
        break;

      case McpMethods.cancelled:
        // Handle cancellation if needed
        _log('info', 'Request cancelled: ${notification.params}');
        break;

      default:
        _log('warning', 'Unknown notification: ${notification.method}');
    }
  }

  Future<Map<String, dynamic>> _handleInitialize(
    Map<String, dynamic>? params,
  ) async {
    if (params == null) {
      throw JsonRpcError.invalidParams('Missing initialize params');
    }

    final initParams = InitializeParams.fromJson(params);
    _clientCapabilities = initParams.capabilities;
    _clientInfo = initParams.clientInfo;
    _initialized = true;

    _log(
      'info',
      'Initialized by ${_clientInfo?.name} v${_clientInfo?.version}',
    );

    final result = InitializeResult(
      protocolVersion: kMcpProtocolVersion,
      capabilities: ServerCapabilities(
        tools: const ToolsCapability(listChanged: true),
        resources: const ResourcesCapability(
          subscribe: false,
          listChanged: true,
        ),
        prompts: const PromptsCapability(listChanged: false),
        logging: const LoggingCapability(),
      ),
      serverInfo: const Implementation(
        name: kServerName,
        version: kServerVersion,
      ),
      instructions:
          'APIDash MCP Server - Interact with API requests and responses',
    );

    return result.toJson();
  }

  Map<String, dynamic> _handleToolsList(Map<String, dynamic>? params) {
    final tools = _toolRegistry.listTools();
    final result = ToolsListResult(tools: tools);
    return result.toJson();
  }

  Future<Map<String, dynamic>> _handleToolsCall(
    Map<String, dynamic>? params,
  ) async {
    if (params == null) {
      throw JsonRpcError.invalidParams('Missing tool call params');
    }

    final callParams = ToolCallParams.fromJson(params);
    final result = await _toolRegistry.callTool(
      callParams.name,
      callParams.arguments ?? {},
    );

    return result.toJson();
  }

  Map<String, dynamic> _handleResourcesList(Map<String, dynamic>? params) {
    final resources = _resourceRegistry.listResources();
    final result = ResourcesListResult(resources: resources);
    return result.toJson();
  }

  Map<String, dynamic> _handleResourceTemplatesList(
    Map<String, dynamic>? params,
  ) {
    // APIDash doesn't use resource templates, return empty list
    return {'resourceTemplates': []};
  }

  Future<Map<String, dynamic>> _handleResourcesRead(
    Map<String, dynamic>? params,
  ) async {
    if (params == null) {
      throw JsonRpcError.invalidParams('Missing resource read params');
    }

    final readParams = ResourceReadParams.fromJson(params);
    final result = await _resourceRegistry.readResource(readParams.uri);
    return result.toJson();
  }

  Map<String, dynamic> _handlePromptsList(Map<String, dynamic>? params) {
    // APIDash doesn't have prompts yet, return empty list
    final result = PromptsListResult(prompts: []);
    return result.toJson();
  }

  Future<Map<String, dynamic>> _handlePromptsGet(
    Map<String, dynamic>? params,
  ) async {
    throw JsonRpcError.invalidParams('No prompts available');
  }

  Map<String, dynamic> _handleLoggingSetLevel(Map<String, dynamic>? params) {
    // Accept the logging level but we just use stderr for logging
    final level = params?['level'] as String? ?? 'info';
    _log('info', 'Logging level set to: $level');
    return {};
  }

  void _checkInitialized() {
    if (!_initialized) {
      throw JsonRpcError(
        code: McpErrorCodes.invalidRequest,
        message: 'Server not initialized',
      );
    }
  }

  Future<void> _sendResponse(JsonRpcResponse response) async {
    final json = jsonEncode(response.toJson());
    await _transport.send(json);
  }

  Future<void> _sendError(dynamic id, JsonRpcError error) async {
    final response = JsonRpcResponse.error(id: id, error: error);
    final json = jsonEncode(response.toJson());
    await _transport.send(json);
  }

  Future<void> _sendNotification(
    String method, [
    Map<String, dynamic>? params,
  ]) async {
    final notification = JsonRpcNotification(method: method, params: params);
    final json = jsonEncode(notification.toJson());
    await _transport.send(json);
  }

  /// Notify clients that the tool list has changed
  Future<void> notifyToolsListChanged() async {
    if (_initialized) {
      await _sendNotification(McpMethods.toolsListChanged);
    }
  }

  /// Notify clients that the resource list has changed
  Future<void> notifyResourcesListChanged() async {
    if (_initialized) {
      await _sendNotification(McpMethods.resourcesListChanged);
    }
  }

  void _handleError(dynamic error) {
    _log('error', 'Transport error: $error');
  }

  void _handleDone() {
    _log('info', 'Transport closed');
  }

  void _log(String level, String message) {
    // Write logs to stderr to avoid corrupting JSON-RPC communication
    stderr.writeln('[$level] $message');
  }
}
