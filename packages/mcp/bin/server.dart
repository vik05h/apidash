import 'dart:io';

import 'package:mcp/mcp.dart';

/// Example MCP Server runner for APIDash
///
/// This is a standalone server that can be started to provide MCP
/// functionality. In production, this would be integrated with the
/// APIDash app's data layer.
void main(List<String> args) async {
  // Check for STDIO mode
  final useStdio = args.contains('--stdio') || args.contains('-s');

  if (!useStdio) {
    stderr.writeln('APIDash MCP Server');
    stderr.writeln('==================');
    stderr.writeln('');
    stderr.writeln('Usage: dart run mcp:server --stdio');
    stderr.writeln('');
    stderr.writeln('This starts the MCP server in STDIO mode for use with');
    stderr.writeln('AI applications like Claude Desktop.');
    stderr.writeln('');
    stderr.writeln(
        'Configuration for Claude Desktop (claude_desktop_config.json):');
    stderr.writeln('''
{
  "mcpServers": {
    "apidash": {
      "command": "dart",
      "args": ["run", "mcp:server", "--stdio"],
      "cwd": "/path/to/apidash"
    }
  }
}
''');
    exit(1);
  }

  // Create server with STDIO transport
  final transport = StdioTransport();
  final server = McpServer(transport: transport);

  // Register a mock data provider for demonstration
  // In production, this would connect to the actual APIDash data
  final mockProvider = _MockApiDashDataProvider();
  registerApiDashTools(server.toolRegistry, mockProvider);
  registerApiDashResources(server.resourceRegistry, mockProvider);

  // Start server
  await server.start();

  // Keep server running until stdin is closed
  stderr.writeln('[info] APIDash MCP Server started in STDIO mode');
}

/// Mock data provider for demonstration
/// Replace this with actual APIDash data integration
class _MockApiDashDataProvider implements ApiDashDataProvider {
  final List<Map<String, dynamic>> _requests = [
    {
      'id': 'demo-1',
      'name': 'Get Users',
      'httpRequestModel': {
        'method': 'GET',
        'url': 'https://api.example.com/users',
        'headers': [],
      },
    },
    {
      'id': 'demo-2',
      'name': 'Create User',
      'httpRequestModel': {
        'method': 'POST',
        'url': 'https://api.example.com/users',
        'headers': [
          {'name': 'Content-Type', 'value': 'application/json'},
        ],
        'body': '{"name": "John Doe", "email": "john@example.com"}',
      },
    },
  ];

  @override
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    return _requests;
  }

  @override
  Future<Map<String, dynamic>?> getRequest(String id) async {
    try {
      return _requests.firstWhere((r) => r['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> executeRequest(String id) async {
    final request = await getRequest(id);
    if (request == null) {
      throw Exception('Request not found: $id');
    }

    // Mock response - in production this would make actual HTTP calls
    return {
      'status': 200,
      'statusText': 'OK',
      'headers': {'content-type': 'application/json'},
      'body': '{"message": "Mock response for ${request['name']}"}',
      'time': 150,
    };
  }

  @override
  Future<Map<String, dynamic>> createRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    String? name,
  }) async {
    final newId = 'demo-${_requests.length + 1}';
    final newRequest = {
      'id': newId,
      'name': name ?? 'New Request',
      'httpRequestModel': {
        'method': method,
        'url': url,
        'headers': headers?.entries
                .map((e) => {'name': e.key, 'value': e.value})
                .toList() ??
            [],
        if (body != null) 'body': body,
      },
    };
    _requests.add(newRequest);
    return newRequest;
  }

  @override
  Future<List<Map<String, dynamic>>> getEnvironments() async {
    return [
      {
        'id': 'env-1',
        'name': 'Development',
        'variables': [
          {'name': 'BASE_URL', 'value': 'http://localhost:3000'},
          {'name': 'API_KEY', 'value': 'dev-key-123'},
        ],
      },
      {
        'id': 'env-2',
        'name': 'Production',
        'variables': [
          {'name': 'BASE_URL', 'value': 'https://api.example.com'},
          {'name': 'API_KEY', 'value': 'prod-key-456'},
        ],
      },
    ];
  }

  @override
  Future<Map<String, dynamic>?> getActiveEnvironment() async {
    return {
      'id': 'env-1',
      'name': 'Development',
      'variables': {
        'BASE_URL': 'http://localhost:3000',
        'API_KEY': 'dev-key-123',
      },
    };
  }
}
