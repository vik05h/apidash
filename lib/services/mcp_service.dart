import 'dart:convert';

import 'package:apidash_core/apidash_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp/mcp.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../consts.dart';

/// APIDash data provider implementation using Riverpod
/// This connects the MCP server to the actual APIDash data
class RiverpodApiDashDataProvider implements ApiDashDataProvider {
  final Ref ref;

  RiverpodApiDashDataProvider(this.ref);

  @override
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    final collection = ref.read(collectionStateNotifierProvider);
    if (collection == null) return [];

    return collection.values.map((request) => _requestToJson(request)).toList();
  }

  @override
  Future<Map<String, dynamic>?> getRequest(String id) async {
    final collection = ref.read(collectionStateNotifierProvider);
    if (collection == null) return null;

    final request = collection[id];
    if (request == null) return null;

    return _requestToJson(request);
  }

  @override
  Future<Map<String, dynamic>> executeRequest(String id) async {
    final collection = ref.read(collectionStateNotifierProvider);
    if (collection == null) {
      throw Exception('No collection loaded');
    }

    final request = collection[id];
    if (request == null) {
      throw Exception('Request not found: $id');
    }

    // Get active environment variables
    final envVars = ref.read(availableEnvironmentVariablesStateProvider);
    final activeEnvId = ref.read(activeEnvironmentIdStateProvider);

    // Build substituted request
    final httpRequestModel = request.httpRequestModel;
    if (httpRequestModel == null) {
      throw Exception('Request has no HTTP configuration');
    }

    // Substitute environment variables
    final substitutedRequest = substituteHttpRequestModel(
      httpRequestModel,
      envVars,
      activeEnvId,
    );

    // Execute the request
    final (response, duration, error) = await sendHttpRequest(
      id,
      APIType.rest,
      substitutedRequest,
    );

    if (error != null) {
      // Update UI with error
      ref.read(collectionStateNotifierProvider.notifier).update(
            id: id,
            responseStatus: 0,
            message: error,
            httpResponseModel: null,
          );
      return {
        'error': error,
        'duration': duration?.inMilliseconds,
      };
    }

    // Build response model from the response
    final baseResponseModel = const HttpResponseModel();
    final httpResponseModel =
        baseResponseModel.fromResponse(response: response!);

    // Update UI with response
    final statusCode = response.statusCode;
    ref.read(collectionStateNotifierProvider.notifier).update(
          id: id,
          responseStatus: statusCode,
          message: kResponseCodeReasons[statusCode],
          httpResponseModel: httpResponseModel,
        );

    return {
      'status': statusCode,
      'headers': response.headers,
      'body': response.body,
      'duration': duration?.inMilliseconds,
      'requestId': id,
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
    final notifier = ref.read(collectionStateNotifierProvider.notifier);

    // Parse HTTP method
    HTTPVerb httpMethod;
    try {
      httpMethod = HTTPVerb.values.firstWhere(
        (v) => v.name.toUpperCase() == method.toUpperCase(),
        orElse: () => HTTPVerb.get,
      );
    } catch (_) {
      httpMethod = HTTPVerb.get;
    }

    // Build headers
    List<NameValueModel> headersList = [];
    if (headers != null) {
      headersList = headers.entries
          .map((e) => NameValueModel(name: e.key, value: e.value))
          .toList();
    }

    // Create request model
    final httpRequestModel = HttpRequestModel(
      method: httpMethod,
      url: url,
      headers: headersList.isEmpty ? null : headersList,
      body: body,
      bodyContentType: body != null ? ContentType.json : ContentType.text,
    );

    // Add to collection
    notifier.addRequestModel(httpRequestModel, name: name);

    // Get the newly created request
    final requestSequence = ref.read(requestSequenceProvider);
    final newId = requestSequence.first;
    final newRequest = ref.read(collectionStateNotifierProvider)?[newId];

    if (newRequest == null) {
      throw Exception('Failed to create request');
    }

    return _requestToJson(newRequest);
  }

  @override
  Future<List<Map<String, dynamic>>> getEnvironments() async {
    final environments = ref.read(environmentsStateNotifierProvider);
    if (environments == null) return [];

    return environments.values.map((env) => _environmentToJson(env)).toList();
  }

  @override
  Future<Map<String, dynamic>?> getActiveEnvironment() async {
    final activeEnv = ref.read(activeEnvironmentModelProvider);
    if (activeEnv == null) return null;

    return _environmentToJson(activeEnv);
  }

  Map<String, dynamic> _requestToJson(RequestModel request) {
    final httpRequest = request.httpRequestModel;
    final httpResponse = request.httpResponseModel;

    return {
      'id': request.id,
      'name': request.name,
      'description': request.description,
      'apiType': request.apiType.name,
      'httpRequestModel': httpRequest == null
          ? null
          : {
              'method': httpRequest.method.name.toUpperCase(),
              'url': httpRequest.url,
              'headers': httpRequest.headers
                      ?.map((h) => {'name': h.name, 'value': h.value})
                      .toList() ??
                  [],
              'params': httpRequest.params
                      ?.map((p) => {'name': p.name, 'value': p.value})
                      .toList() ??
                  [],
              'body': httpRequest.body,
              'bodyContentType': httpRequest.bodyContentType?.name,
            },
      'httpResponseModel': httpResponse == null
          ? null
          : {
              'statusCode': httpResponse.statusCode,
              'body': httpResponse.body,
              'headers': httpResponse.headers,
              'contentType': httpResponse.contentType,
              'time': httpResponse.time?.inMilliseconds,
            },
      'responseStatus': request.responseStatus,
      'message': request.message,
    };
  }

  Map<String, dynamic> _environmentToJson(EnvironmentModel env) {
    return {
      'id': env.id,
      'name': env.name,
      'variables': env.values
          .map((v) => {
                'key': v.key,
                'value': v.value,
                'enabled': v.enabled,
                'type': v.type.name,
              })
          .toList(),
      'variablesMap': {
        for (var v in env.values.where((v) => v.enabled)) v.key: v.value,
      },
    };
  }
}

/// Provider for MCP data provider
final mcpDataProviderProvider = Provider<ApiDashDataProvider>((ref) {
  return RiverpodApiDashDataProvider(ref);
});

/// Provider for MCP server instance
final mcpServerProvider = Provider<McpServer?>((ref) {
  // This is just a placeholder - actual server would be created
  // when MCP mode is enabled
  return null;
});
