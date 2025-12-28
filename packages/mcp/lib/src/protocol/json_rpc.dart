import 'package:json_annotation/json_annotation.dart';

part 'json_rpc.g.dart';

/// JSON-RPC 2.0 Request
@JsonSerializable(explicitToJson: true)
class JsonRpcRequest {
  final String jsonrpc;
  final dynamic id;
  final String method;
  final Map<String, dynamic>? params;

  const JsonRpcRequest({
    this.jsonrpc = '2.0',
    required this.id,
    required this.method,
    this.params,
  });

  factory JsonRpcRequest.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcRequestFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRpcRequestToJson(this);

  bool get isNotification => id == null;
}

/// JSON-RPC 2.0 Response
@JsonSerializable(explicitToJson: true)
class JsonRpcResponse {
  final String jsonrpc;
  final dynamic id;
  final dynamic result;
  final JsonRpcError? error;

  const JsonRpcResponse({
    this.jsonrpc = '2.0',
    required this.id,
    this.result,
    this.error,
  });

  factory JsonRpcResponse.success({
    required dynamic id,
    required dynamic result,
  }) {
    return JsonRpcResponse(
      id: id,
      result: result,
    );
  }

  factory JsonRpcResponse.error({
    required dynamic id,
    required JsonRpcError error,
  }) {
    return JsonRpcResponse(
      id: id,
      error: error,
    );
  }

  factory JsonRpcResponse.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcResponseFromJson(json);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'jsonrpc': jsonrpc,
      'id': id,
    };
    if (error != null) {
      json['error'] = error!.toJson();
    } else {
      json['result'] = result;
    }
    return json;
  }

  bool get isError => error != null;
}

/// JSON-RPC 2.0 Error
@JsonSerializable(explicitToJson: true)
class JsonRpcError {
  final int code;
  final String message;
  final dynamic data;

  const JsonRpcError({
    required this.code,
    required this.message,
    this.data,
  });

  factory JsonRpcError.parseError([String? message]) => JsonRpcError(
        code: -32700,
        message: message ?? 'Parse error',
      );

  factory JsonRpcError.invalidRequest([String? message]) => JsonRpcError(
        code: -32600,
        message: message ?? 'Invalid Request',
      );

  factory JsonRpcError.methodNotFound([String? message]) => JsonRpcError(
        code: -32601,
        message: message ?? 'Method not found',
      );

  factory JsonRpcError.invalidParams([String? message]) => JsonRpcError(
        code: -32602,
        message: message ?? 'Invalid params',
      );

  factory JsonRpcError.internalError([String? message]) => JsonRpcError(
        code: -32603,
        message: message ?? 'Internal error',
      );

  factory JsonRpcError.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcErrorFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRpcErrorToJson(this);
}

/// JSON-RPC 2.0 Notification (request without id)
@JsonSerializable(explicitToJson: true)
class JsonRpcNotification {
  final String jsonrpc;
  final String method;
  final Map<String, dynamic>? params;

  const JsonRpcNotification({
    this.jsonrpc = '2.0',
    required this.method,
    this.params,
  });

  factory JsonRpcNotification.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRpcNotificationToJson(this);
}
