import 'package:mcp/mcp.dart';
import 'package:test/test.dart';

void main() {
  group('JsonRpcRequest', () {
    test('should serialize and deserialize correctly', () {
      const request = JsonRpcRequest(
        id: 1,
        method: 'test/method',
        params: {'key': 'value'},
      );

      final json = request.toJson();
      final deserialized = JsonRpcRequest.fromJson(json);

      expect(deserialized.jsonrpc, equals('2.0'));
      expect(deserialized.id, equals(1));
      expect(deserialized.method, equals('test/method'));
      expect(deserialized.params, equals({'key': 'value'}));
    });

    test('should identify notifications', () {
      const notification = JsonRpcRequest(
        id: null,
        method: 'notification',
      );

      expect(notification.isNotification, isTrue);
    });
  });

  group('JsonRpcResponse', () {
    test('should create success response', () {
      final response = JsonRpcResponse.success(
        id: 1,
        result: {'data': 'test'},
      );

      expect(response.isError, isFalse);
      expect(response.result, equals({'data': 'test'}));
    });

    test('should create error response', () {
      final response = JsonRpcResponse.error(
        id: 1,
        error: JsonRpcError.methodNotFound('Unknown method'),
      );

      expect(response.isError, isTrue);
      expect(response.error?.code, equals(-32601));
    });
  });

  group('JsonRpcError', () {
    test('should create standard errors', () {
      expect(JsonRpcError.parseError().code, equals(-32700));
      expect(JsonRpcError.invalidRequest().code, equals(-32600));
      expect(JsonRpcError.methodNotFound().code, equals(-32601));
      expect(JsonRpcError.invalidParams().code, equals(-32602));
      expect(JsonRpcError.internalError().code, equals(-32603));
    });
  });
}
