import '../protocol/protocol.dart';

/// Signature for resource read handler functions
typedef ResourceReadHandler = Future<ResourceReadResult> Function(String uri);

/// Registry for MCP resources
class ResourceRegistry {
  final Map<String, _ResourceEntry> _resources = {};
  final List<_DynamicResourceProvider> _dynamicProviders = [];

  /// Register a static resource
  void registerResource({
    required String uri,
    required String name,
    String? description,
    String? mimeType,
    required ResourceReadHandler handler,
  }) {
    _resources[uri] = _ResourceEntry(
      resource: McpResource(
        uri: uri,
        name: name,
        description: description,
        mimeType: mimeType,
      ),
      handler: handler,
    );
  }

  /// Register a dynamic resource provider for URI pattern matching
  void registerDynamicProvider({
    required String uriPattern,
    required String name,
    String? description,
    String? mimeType,
    required ResourceReadHandler handler,
  }) {
    _dynamicProviders.add(_DynamicResourceProvider(
      uriPattern: RegExp(uriPattern),
      name: name,
      description: description,
      mimeType: mimeType,
      handler: handler,
    ));
  }

  /// Unregister a resource
  void unregisterResource(String uri) {
    _resources.remove(uri);
  }

  /// List all registered resources
  List<McpResource> listResources() {
    return _resources.values.map((e) => e.resource).toList();
  }

  /// Read a resource by URI
  Future<ResourceReadResult> readResource(String uri) async {
    // First check static resources
    final entry = _resources[uri];
    if (entry != null) {
      try {
        return await entry.handler(uri);
      } catch (e) {
        return ResourceReadResult(
          contents: [
            ResourceContent(
              uri: uri,
              text: 'Error reading resource: $e',
              mimeType: 'text/plain',
            ),
          ],
        );
      }
    }

    // Then check dynamic providers
    for (final provider in _dynamicProviders) {
      if (provider.uriPattern.hasMatch(uri)) {
        try {
          return await provider.handler(uri);
        } catch (e) {
          return ResourceReadResult(
            contents: [
              ResourceContent(
                uri: uri,
                text: 'Error reading resource: $e',
                mimeType: 'text/plain',
              ),
            ],
          );
        }
      }
    }

    // Resource not found
    return ResourceReadResult(
      contents: [
        ResourceContent(
          uri: uri,
          text: 'Resource not found: $uri',
          mimeType: 'text/plain',
        ),
      ],
    );
  }

  /// Check if a resource exists
  bool hasResource(String uri) {
    if (_resources.containsKey(uri)) return true;
    return _dynamicProviders.any((p) => p.uriPattern.hasMatch(uri));
  }
}

class _ResourceEntry {
  final McpResource resource;
  final ResourceReadHandler handler;

  _ResourceEntry({required this.resource, required this.handler});
}

class _DynamicResourceProvider {
  final RegExp uriPattern;
  final String name;
  final String? description;
  final String? mimeType;
  final ResourceReadHandler handler;

  _DynamicResourceProvider({
    required this.uriPattern,
    required this.name,
    this.description,
    this.mimeType,
    required this.handler,
  });
}
