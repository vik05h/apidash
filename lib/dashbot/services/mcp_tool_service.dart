import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp/mcp.dart';
import '../../providers/providers.dart';

/// Service to integrate MCP tools with Dashbot
class McpToolService {
  final Ref ref;
  bool _isInitialized = false;

  McpToolService(this.ref);

  /// Ensure MCP session is initialized
  Future<bool> _ensureInitialized() async {
    if (_isInitialized) return true;

    final mcpState = ref.read(mcpServerStateProvider);
    if (!mcpState.isRunning) return false;

    try {
      // Send initialize request
      final initResponse = await _makeRequest({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {
          'protocolVersion': '2024-11-05',
          'capabilities': {},
          'clientInfo': {
            'name': 'dashbot',
            'version': '1.0.0',
          },
        },
      });

      if (initResponse['error'] != null) {
        debugPrint(
            '[McpToolService] Initialization error: ${initResponse['error']}');
        return false;
      }

      // Send initialized notification
      await _makeRequest({
        'jsonrpc': '2.0',
        'method': 'notifications/initialized',
      });

      _isInitialized = true;
      debugPrint('[McpToolService] MCP session initialized');
      return true;
    } catch (e) {
      debugPrint('[McpToolService] Failed to initialize: $e');
      return false;
    }
  }

  /// Make a JSON-RPC request to MCP server
  Future<Map<String, dynamic>> _makeRequest(
      Map<String, dynamic> request) async {
    final uri = Uri.parse('http://localhost:22140/mcp');
    final requestBody = jsonEncode(request);

    final client = HttpClient();
    try {
      final httpRequest = await client.postUrl(uri);
      httpRequest.headers.contentType = ContentType.json;
      httpRequest.write(requestBody);

      final response = await httpRequest.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody) as Map<String, dynamic>;
      }

      return {
        'error': 'HTTP ${response.statusCode}: $responseBody',
      };
    } finally {
      client.close();
    }
  }

  /// Get MCP tool definitions formatted for AI prompt
  String getToolsSystemPrompt() {
    final mcpState = ref.read(mcpServerStateProvider);
    if (!mcpState.isRunning) {
      return '';
    }

    return '''

<mcp_tools>
You have access to the following tools to manage API requests in APIDash:

1. **list_requests** - List all API requests in the collection
   Arguments: none
   Returns: Array of request objects with id, name, method, url, etc.

2. **create_request** - Create a new API request
   Arguments:
   - method (required): HTTP method (GET, POST, PUT, DELETE, PATCH, etc.)
   - url (required): The API endpoint URL
   - name (optional): Descriptive name for the request
   - headers (optional): Object with header key-value pairs
   - body (optional): Request body content
   Returns: Created request object with id

3. **update_request** - Update an existing API request
   Arguments:
   - id (required): Request ID to update
   - method (optional): HTTP method
   - url (optional): API endpoint URL
   - name (optional): Request name
   - headers (optional): Headers object
   - body (optional): Request body
   Returns: Updated request object

4. **delete_request** - Delete an API request
   Arguments:
   - id (required): Request ID to delete
   Returns: Success confirmation

5. **execute_request** - Execute/send an API request
   Arguments:
   - id (required): Request ID to execute
   Returns: Response with status, headers, body, duration

To use a tool, respond with JSON in this exact format:
{
  "explanation": "Brief explanation of what you're doing",
  "tool_calls": [
    {
      "tool": "tool_name",
      "arguments": {
        "arg1": "value1",
        "arg2": "value2"
      }
    }
  ]
}

You can make multiple tool calls in one response. Always provide an explanation before the tool calls.
</mcp_tools>
''';
  }

  /// Parse tool calls from AI response
  List<McpToolCall>? parseToolCalls(String response) {
    try {
      final json = jsonDecode(response) as Map<String, dynamic>;
      if (!json.containsKey('tool_calls')) return null;

      final toolCallsJson = json['tool_calls'] as List;
      return toolCallsJson
          .map((tc) => McpToolCall.fromJson(tc as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[McpToolService] Error parsing tool calls: $e');
      return null;
    }
  }

  /// Execute a tool call via MCP
  Future<Map<String, dynamic>> executeToolCall(McpToolCall toolCall) async {
    final mcpState = ref.read(mcpServerStateProvider);
    if (!mcpState.isRunning) {
      return {
        'error': 'MCP server is not running',
      };
    }

    // Ensure session is initialized
    if (!await _ensureInitialized()) {
      return {
        'error': 'Failed to initialize MCP session',
      };
    }

    try {
      debugPrint('[McpToolService] Executing tool: ${toolCall.tool}');
      debugPrint(
          '[McpToolService] Arguments: ${jsonEncode(toolCall.arguments)}');

      // Make tool call request
      final requestId = DateTime.now().millisecondsSinceEpoch;
      final response = await _makeRequest({
        'jsonrpc': '2.0',
        'id': requestId,
        'method': 'tools/call',
        'params': {
          'name': toolCall.tool,
          'arguments': toolCall.arguments,
        },
      });

      if (response.containsKey('result')) {
        return response['result'] as Map<String, dynamic>;
      } else if (response.containsKey('error')) {
        return {
          'error': response['error'],
        };
      }

      return {
        'error': 'Unexpected response format',
      };
    } catch (e) {
      debugPrint('[McpToolService] Error executing tool: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// Execute multiple tool calls and format results
  Future<String> executeToolCalls(List<McpToolCall> toolCalls) async {
    final results = <Map<String, dynamic>>[];

    for (final toolCall in toolCalls) {
      final result = await executeToolCall(toolCall);
      results.add(result);
    }

    return jsonEncode({
      'tool_results': results,
    });
  }
}

/// Represents a tool call from the AI
class McpToolCall {
  final String tool;
  final Map<String, dynamic> arguments;

  McpToolCall({
    required this.tool,
    required this.arguments,
  });

  factory McpToolCall.fromJson(Map<String, dynamic> json) {
    return McpToolCall(
      tool: json['tool'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
        'tool': tool,
        'arguments': arguments,
      };
}

/// Provider for MCP tool service
final mcpToolServiceProvider = Provider<McpToolService>((ref) {
  return McpToolService(ref);
});
