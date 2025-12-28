import '../tools/tools.dart';

/// Interface for APIDash data access
/// This should be implemented by the APIDash app to provide data to MCP
abstract class ApiDashDataProvider {
  /// Get all request models
  Future<List<Map<String, dynamic>>> getAllRequests();

  /// Get a specific request by ID
  Future<Map<String, dynamic>?> getRequest(String id);

  /// Execute a request by ID and return the response
  Future<Map<String, dynamic>> executeRequest(String id);

  /// Create a new request
  Future<Map<String, dynamic>> createRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
    String? name,
  });

  /// Get environments
  Future<List<Map<String, dynamic>>> getEnvironments();

  /// Get active environment
  Future<Map<String, dynamic>?> getActiveEnvironment();
}

/// Register APIDash-specific tools with the tool registry
void registerApiDashTools(
    ToolRegistry registry, ApiDashDataProvider dataProvider) {
  // List Requests Tool
  registry.registerTool(
    name: 'list_requests',
    description: 'List all saved API requests in APIDash',
    inputSchema: JsonSchemaBuilder.object(
      properties: {
        'limit': JsonSchemaBuilder.integer(
          description: 'Maximum number of requests to return',
          minimum: 1,
          maximum: 100,
        ),
        'filter': JsonSchemaBuilder.string(
          description: 'Filter requests by name or URL (case-insensitive)',
        ),
      },
    ),
    handler: (args) async {
      final limit = args['limit'] as int? ?? 50;
      final filter = args['filter'] as String?;

      var requests = await dataProvider.getAllRequests();

      if (filter != null && filter.isNotEmpty) {
        final lowerFilter = filter.toLowerCase();
        requests = requests.where((r) {
          final name = (r['name'] as String? ?? '').toLowerCase();
          final url =
              (r['httpRequestModel']?['url'] as String? ?? '').toLowerCase();
          return name.contains(lowerFilter) || url.contains(lowerFilter);
        }).toList();
      }

      if (requests.length > limit) {
        requests = requests.take(limit).toList();
      }

      final summary = requests.map((r) {
        return {
          'id': r['id'],
          'name': r['name'] ?? 'Untitled',
          'method': r['httpRequestModel']?['method'] ?? 'GET',
          'url': r['httpRequestModel']?['url'] ?? '',
        };
      }).toList();

      return successResult({
        'count': summary.length,
        'requests': summary,
      });
    },
  );

  // Get Request Tool
  registry.registerTool(
    name: 'get_request',
    description: 'Get detailed information about a specific API request',
    inputSchema: JsonSchemaBuilder.object(
      properties: {
        'request_id': JsonSchemaBuilder.string(
          description: 'The ID of the request to retrieve',
        ),
      },
      required: ['request_id'],
    ),
    handler: (args) async {
      final requestId = args['request_id'] as String?;
      if (requestId == null || requestId.isEmpty) {
        return errorResult('request_id is required');
      }

      final request = await dataProvider.getRequest(requestId);
      if (request == null) {
        return errorResult('Request not found: $requestId');
      }

      return successResult(request);
    },
  );

  // Execute Request Tool
  registry.registerTool(
    name: 'execute_request',
    description:
        'Execute an API request by ID and return the response. Use this to make actual HTTP calls.',
    inputSchema: JsonSchemaBuilder.object(
      properties: {
        'request_id': JsonSchemaBuilder.string(
          description: 'The ID of the request to execute',
        ),
      },
      required: ['request_id'],
    ),
    handler: (args) async {
      final requestId = args['request_id'] as String?;
      if (requestId == null || requestId.isEmpty) {
        return errorResult('request_id is required');
      }

      try {
        final response = await dataProvider.executeRequest(requestId);
        return successResult(response);
      } catch (e) {
        return errorResult('Failed to execute request: $e');
      }
    },
  );

  // Create Request Tool
  registry.registerTool(
    name: 'create_request',
    description: 'Create a new API request in APIDash',
    inputSchema: JsonSchemaBuilder.object(
      properties: {
        'method': JsonSchemaBuilder.string(
          description: 'HTTP method',
          enumValues: [
            'GET',
            'POST',
            'PUT',
            'PATCH',
            'DELETE',
            'HEAD',
            'OPTIONS'
          ],
        ),
        'url': JsonSchemaBuilder.string(
          description: 'The URL for the API request',
        ),
        'name': JsonSchemaBuilder.string(
          description: 'A name for this request',
        ),
        'headers': JsonSchemaBuilder.object(
          properties: {},
          description:
              'HTTP headers as key-value pairs. Example: {"Content-Type": "application/json"}',
        ),
        'body': JsonSchemaBuilder.string(
          description: 'Request body (for POST, PUT, PATCH)',
        ),
      },
      required: ['method', 'url'],
    ),
    handler: (args) async {
      final method = args['method'] as String?;
      final url = args['url'] as String?;

      if (method == null || url == null) {
        return errorResult('method and url are required');
      }

      final headersRaw = args['headers'];
      Map<String, String>? headers;
      if (headersRaw is Map) {
        headers =
            headersRaw.map((k, v) => MapEntry(k.toString(), v.toString()));
      }

      try {
        final result = await dataProvider.createRequest(
          method: method,
          url: url,
          headers: headers,
          body: args['body'] as String?,
          name: args['name'] as String?,
        );
        return successResult(result);
      } catch (e) {
        return errorResult('Failed to create request: $e');
      }
    },
  );

  // Get Environments Tool
  registry.registerTool(
    name: 'list_environments',
    description: 'List all environments in APIDash',
    inputSchema: JsonSchemaBuilder.object(properties: {}),
    handler: (args) async {
      final environments = await dataProvider.getEnvironments();
      return successResult({
        'count': environments.length,
        'environments': environments,
      });
    },
  );

  // Get Active Environment Tool
  registry.registerTool(
    name: 'get_active_environment',
    description: 'Get the currently active environment variables',
    inputSchema: JsonSchemaBuilder.object(properties: {}),
    handler: (args) async {
      final env = await dataProvider.getActiveEnvironment();
      if (env == null) {
        return successResult({'message': 'No active environment'});
      }
      return successResult(env);
    },
  );
}
