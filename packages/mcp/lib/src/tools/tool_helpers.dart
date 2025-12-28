import 'dart:convert';

import '../protocol/protocol.dart';

/// JSON Schema helper for tool input schemas
class JsonSchemaBuilder {
  /// Create a simple object schema with properties
  static Map<String, dynamic> object({
    required Map<String, Map<String, dynamic>> properties,
    List<String>? required,
    String? description,
  }) {
    return {
      'type': 'object',
      'properties': properties,
      if (required != null) 'required': required,
      if (description != null) 'description': description,
    };
  }

  /// Create a string property
  static Map<String, dynamic> string({
    String? description,
    List<String>? enumValues,
    String? pattern,
  }) {
    return {
      'type': 'string',
      if (description != null) 'description': description,
      if (enumValues != null) 'enum': enumValues,
      if (pattern != null) 'pattern': pattern,
    };
  }

  /// Create a number property
  static Map<String, dynamic> number({
    String? description,
    num? minimum,
    num? maximum,
  }) {
    return {
      'type': 'number',
      if (description != null) 'description': description,
      if (minimum != null) 'minimum': minimum,
      if (maximum != null) 'maximum': maximum,
    };
  }

  /// Create an integer property
  static Map<String, dynamic> integer({
    String? description,
    int? minimum,
    int? maximum,
  }) {
    return {
      'type': 'integer',
      if (description != null) 'description': description,
      if (minimum != null) 'minimum': minimum,
      if (maximum != null) 'maximum': maximum,
    };
  }

  /// Create a boolean property
  static Map<String, dynamic> boolean({String? description}) {
    return {
      'type': 'boolean',
      if (description != null) 'description': description,
    };
  }

  /// Create an array property
  static Map<String, dynamic> array({
    required Map<String, dynamic> items,
    String? description,
  }) {
    return {
      'type': 'array',
      'items': items,
      if (description != null) 'description': description,
    };
  }
}

/// Helper to create success results
ToolCallResult successResult(dynamic data) {
  String text;
  if (data is String) {
    text = data;
  } else if (data is Map || data is List) {
    text = const JsonEncoder.withIndent('  ').convert(data);
  } else {
    text = data.toString();
  }
  return ToolCallResult(
    content: [ToolResultContent.text(text)],
    isError: false,
  );
}

/// Helper to create error results
ToolCallResult errorResult(String message) {
  return ToolCallResult(
    content: [ToolResultContent.text(message)],
    isError: true,
  );
}
