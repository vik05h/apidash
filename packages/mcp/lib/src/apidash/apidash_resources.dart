import 'dart:convert';

import '../resources/resources.dart';
import '../protocol/protocol.dart';
import 'apidash_tools.dart';

/// Register APIDash-specific resources with the resource registry
void registerApiDashResources(
    ResourceRegistry registry, ApiDashDataProvider dataProvider) {
  // All Requests Resource
  registry.registerResource(
    uri: 'apidash://requests',
    name: 'All API Requests',
    description: 'List of all saved API requests in APIDash',
    mimeType: 'application/json',
    handler: (uri) async {
      final requests = await dataProvider.getAllRequests();
      final summary = requests.map((r) {
        return {
          'id': r['id'],
          'name': r['name'] ?? 'Untitled',
          'method': r['httpRequestModel']?['method'] ?? 'GET',
          'url': r['httpRequestModel']?['url'] ?? '',
        };
      }).toList();

      return ResourceReadResult(
        contents: [
          ResourceContent.text(
            uri,
            const JsonEncoder.withIndent('  ').convert({
              'count': summary.length,
              'requests': summary,
            }),
            'application/json',
          ),
        ],
      );
    },
  );

  // Environments Resource
  registry.registerResource(
    uri: 'apidash://environments',
    name: 'Environments',
    description: 'All environment configurations',
    mimeType: 'application/json',
    handler: (uri) async {
      final environments = await dataProvider.getEnvironments();
      return ResourceReadResult(
        contents: [
          ResourceContent.text(
            uri,
            const JsonEncoder.withIndent('  ').convert({
              'count': environments.length,
              'environments': environments,
            }),
            'application/json',
          ),
        ],
      );
    },
  );

  // Active Environment Resource
  registry.registerResource(
    uri: 'apidash://environment/active',
    name: 'Active Environment',
    description: 'Currently active environment variables',
    mimeType: 'application/json',
    handler: (uri) async {
      final env = await dataProvider.getActiveEnvironment();
      return ResourceReadResult(
        contents: [
          ResourceContent.text(
            uri,
            const JsonEncoder.withIndent('  ').convert(env ?? {}),
            'application/json',
          ),
        ],
      );
    },
  );

  // Dynamic Request Resource (apidash://request/{id})
  registry.registerDynamicProvider(
    uriPattern: r'^apidash://request/(.+)$',
    name: 'Request Details',
    description: 'Detailed information about a specific request',
    mimeType: 'application/json',
    handler: (uri) async {
      final match = RegExp(r'^apidash://request/(.+)$').firstMatch(uri);
      final requestId = match?.group(1);

      if (requestId == null) {
        return ResourceReadResult(
          contents: [
            ResourceContent.text(uri, 'Invalid request URI', 'text/plain'),
          ],
        );
      }

      final request = await dataProvider.getRequest(requestId);
      if (request == null) {
        return ResourceReadResult(
          contents: [
            ResourceContent.text(
                uri, 'Request not found: $requestId', 'text/plain'),
          ],
        );
      }

      return ResourceReadResult(
        contents: [
          ResourceContent.text(
            uri,
            const JsonEncoder.withIndent('  ').convert(request),
            'application/json',
          ),
        ],
      );
    },
  );
}
