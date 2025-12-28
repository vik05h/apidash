// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_rpc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonRpcRequest _$JsonRpcRequestFromJson(Map<String, dynamic> json) =>
    JsonRpcRequest(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      id: json['id'],
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$JsonRpcRequestToJson(JsonRpcRequest instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'method': instance.method,
      'params': instance.params,
    };

JsonRpcResponse _$JsonRpcResponseFromJson(Map<String, dynamic> json) =>
    JsonRpcResponse(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      id: json['id'],
      result: json['result'],
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JsonRpcResponseToJson(JsonRpcResponse instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'result': instance.result,
      'error': instance.error?.toJson(),
    };

JsonRpcError _$JsonRpcErrorFromJson(Map<String, dynamic> json) => JsonRpcError(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: json['data'],
);

Map<String, dynamic> _$JsonRpcErrorToJson(JsonRpcError instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

JsonRpcNotification _$JsonRpcNotificationFromJson(Map<String, dynamic> json) =>
    JsonRpcNotification(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$JsonRpcNotificationToJson(
  JsonRpcNotification instance,
) => <String, dynamic>{
  'jsonrpc': instance.jsonrpc,
  'method': instance.method,
  'params': instance.params,
};
