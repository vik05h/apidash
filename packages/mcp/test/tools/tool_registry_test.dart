import 'package:mcp/mcp.dart';
import 'package:test/test.dart';

void main() {
  group('ToolRegistry', () {
    late ToolRegistry registry;

    setUp(() {
      registry = ToolRegistry();
    });

    test('should register and list tools', () {
      registry.registerTool(
        name: 'test_tool',
        description: 'A test tool',
        inputSchema: {
          'type': 'object',
          'properties': {
            'message': {'type': 'string'},
          },
        },
        handler: (args) async {
          return ToolCallResult(
            content: [ToolResultContent.text('Result: ${args['message']}')],
          );
        },
      );

      final tools = registry.listTools();
      expect(tools.length, equals(1));
      expect(tools.first.name, equals('test_tool'));
      expect(tools.first.description, equals('A test tool'));
    });

    test('should call registered tool', () async {
      registry.registerTool(
        name: 'echo',
        description: 'Echo tool',
        inputSchema: {'type': 'object', 'properties': {}},
        handler: (args) async {
          return ToolCallResult(
            content: [ToolResultContent.text('Echo: ${args['text']}')],
          );
        },
      );

      final result = await registry.callTool('echo', {'text': 'Hello'});
      expect(result.isError, isNull);
      expect(result.content.first.text, equals('Echo: Hello'));
    });

    test('should return error for unknown tool', () async {
      final result = await registry.callTool('unknown', {});
      expect(result.isError, isTrue);
      expect(result.content.first.text, contains('Tool not found'));
    });

    test('should unregister tool', () {
      registry.registerTool(
        name: 'temp_tool',
        description: 'Temporary',
        inputSchema: {'type': 'object'},
        handler: (args) async => successResult('ok'),
      );

      expect(registry.hasTool('temp_tool'), isTrue);
      registry.unregisterTool('temp_tool');
      expect(registry.hasTool('temp_tool'), isFalse);
    });
  });

  group('ResourceRegistry', () {
    late ResourceRegistry registry;

    setUp(() {
      registry = ResourceRegistry();
    });

    test('should register and list resources', () {
      registry.registerResource(
        uri: 'test://resource',
        name: 'Test Resource',
        description: 'A test resource',
        mimeType: 'text/plain',
        handler: (uri) async {
          return ResourceReadResult(
            contents: [ResourceContent.text(uri, 'Content', 'text/plain')],
          );
        },
      );

      final resources = registry.listResources();
      expect(resources.length, equals(1));
      expect(resources.first.uri, equals('test://resource'));
    });

    test('should read registered resource', () async {
      registry.registerResource(
        uri: 'test://data',
        name: 'Data',
        handler: (uri) async {
          return ResourceReadResult(
            contents: [ResourceContent.text(uri, 'Test data')],
          );
        },
      );

      final result = await registry.readResource('test://data');
      expect(result.contents.first.text, equals('Test data'));
    });

    test('should support dynamic resource providers', () async {
      registry.registerDynamicProvider(
        uriPattern: r'^test://item/(\d+)$',
        name: 'Item',
        handler: (uri) async {
          final match = RegExp(r'^test://item/(\d+)$').firstMatch(uri);
          final id = match?.group(1);
          return ResourceReadResult(
            contents: [ResourceContent.text(uri, 'Item #$id')],
          );
        },
      );

      final result = await registry.readResource('test://item/42');
      expect(result.contents.first.text, equals('Item #42'));
    });
  });
}
