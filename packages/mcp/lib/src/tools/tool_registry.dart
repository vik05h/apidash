import '../protocol/protocol.dart';

/// Signature for tool handler functions
typedef ToolHandler = Future<ToolCallResult> Function(
    Map<String, dynamic> arguments);

/// Registry for MCP tools
class ToolRegistry {
  final Map<String, _ToolEntry> _tools = {};

  /// Register a tool
  void registerTool({
    required String name,
    required String description,
    required Map<String, dynamic> inputSchema,
    required ToolHandler handler,
  }) {
    _tools[name] = _ToolEntry(
      tool: McpTool(
        name: name,
        description: description,
        inputSchema: inputSchema,
      ),
      handler: handler,
    );
  }

  /// Unregister a tool
  void unregisterTool(String name) {
    _tools.remove(name);
  }

  /// List all registered tools
  List<McpTool> listTools() {
    return _tools.values.map((e) => e.tool).toList();
  }

  /// Call a tool by name
  Future<ToolCallResult> callTool(
      String name, Map<String, dynamic> arguments) async {
    final entry = _tools[name];
    if (entry == null) {
      return ToolCallResult(
        content: [ToolResultContent.text('Tool not found: $name')],
        isError: true,
      );
    }

    try {
      return await entry.handler(arguments);
    } catch (e) {
      return ToolCallResult(
        content: [ToolResultContent.text('Tool error: $e')],
        isError: true,
      );
    }
  }

  /// Check if a tool exists
  bool hasTool(String name) => _tools.containsKey(name);
}

class _ToolEntry {
  final McpTool tool;
  final ToolHandler handler;

  _ToolEntry({required this.tool, required this.handler});
}
