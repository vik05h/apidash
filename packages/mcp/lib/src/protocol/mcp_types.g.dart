// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitializeParams _$InitializeParamsFromJson(Map<String, dynamic> json) =>
    InitializeParams(
      protocolVersion: json['protocolVersion'] as String,
      capabilities: ClientCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
      clientInfo: Implementation.fromJson(
        json['clientInfo'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$InitializeParamsToJson(InitializeParams instance) =>
    <String, dynamic>{
      'protocolVersion': instance.protocolVersion,
      'capabilities': instance.capabilities.toJson(),
      'clientInfo': instance.clientInfo.toJson(),
    };

InitializeResult _$InitializeResultFromJson(Map<String, dynamic> json) =>
    InitializeResult(
      protocolVersion: json['protocolVersion'] as String,
      capabilities: ServerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
      serverInfo: Implementation.fromJson(
        json['serverInfo'] as Map<String, dynamic>,
      ),
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$InitializeResultToJson(InitializeResult instance) =>
    <String, dynamic>{
      'protocolVersion': instance.protocolVersion,
      'capabilities': instance.capabilities.toJson(),
      'serverInfo': instance.serverInfo.toJson(),
      'instructions': instance.instructions,
    };

ClientCapabilities _$ClientCapabilitiesFromJson(Map<String, dynamic> json) =>
    ClientCapabilities(
      experimental: json['experimental'] == null
          ? null
          : ExperimentalCapabilities.fromJson(
              json['experimental'] as Map<String, dynamic>,
            ),
      roots: json['roots'] == null
          ? null
          : RootsCapability.fromJson(json['roots'] as Map<String, dynamic>),
      sampling: json['sampling'] == null
          ? null
          : SamplingCapability.fromJson(
              json['sampling'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ClientCapabilitiesToJson(ClientCapabilities instance) =>
    <String, dynamic>{
      'experimental': ?instance.experimental?.toJson(),
      'roots': ?instance.roots?.toJson(),
      'sampling': ?instance.sampling?.toJson(),
    };

ServerCapabilities _$ServerCapabilitiesFromJson(Map<String, dynamic> json) =>
    ServerCapabilities(
      experimental: json['experimental'] == null
          ? null
          : ExperimentalCapabilities.fromJson(
              json['experimental'] as Map<String, dynamic>,
            ),
      logging: json['logging'] == null
          ? null
          : LoggingCapability.fromJson(json['logging'] as Map<String, dynamic>),
      prompts: json['prompts'] == null
          ? null
          : PromptsCapability.fromJson(json['prompts'] as Map<String, dynamic>),
      resources: json['resources'] == null
          ? null
          : ResourcesCapability.fromJson(
              json['resources'] as Map<String, dynamic>,
            ),
      tools: json['tools'] == null
          ? null
          : ToolsCapability.fromJson(json['tools'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ServerCapabilitiesToJson(ServerCapabilities instance) =>
    <String, dynamic>{
      'experimental': ?instance.experimental?.toJson(),
      'logging': ?instance.logging?.toJson(),
      'prompts': ?instance.prompts?.toJson(),
      'resources': ?instance.resources?.toJson(),
      'tools': ?instance.tools?.toJson(),
    };

Implementation _$ImplementationFromJson(Map<String, dynamic> json) =>
    Implementation(
      name: json['name'] as String,
      version: json['version'] as String,
    );

Map<String, dynamic> _$ImplementationToJson(Implementation instance) =>
    <String, dynamic>{'name': instance.name, 'version': instance.version};

ExperimentalCapabilities _$ExperimentalCapabilitiesFromJson(
  Map<String, dynamic> json,
) => ExperimentalCapabilities();

Map<String, dynamic> _$ExperimentalCapabilitiesToJson(
  ExperimentalCapabilities instance,
) => <String, dynamic>{};

RootsCapability _$RootsCapabilityFromJson(Map<String, dynamic> json) =>
    RootsCapability(listChanged: json['listChanged'] as bool?);

Map<String, dynamic> _$RootsCapabilityToJson(RootsCapability instance) =>
    <String, dynamic>{'listChanged': instance.listChanged};

SamplingCapability _$SamplingCapabilityFromJson(Map<String, dynamic> json) =>
    SamplingCapability();

Map<String, dynamic> _$SamplingCapabilityToJson(SamplingCapability instance) =>
    <String, dynamic>{};

LoggingCapability _$LoggingCapabilityFromJson(Map<String, dynamic> json) =>
    LoggingCapability();

Map<String, dynamic> _$LoggingCapabilityToJson(LoggingCapability instance) =>
    <String, dynamic>{};

PromptsCapability _$PromptsCapabilityFromJson(Map<String, dynamic> json) =>
    PromptsCapability(listChanged: json['listChanged'] as bool?);

Map<String, dynamic> _$PromptsCapabilityToJson(PromptsCapability instance) =>
    <String, dynamic>{'listChanged': instance.listChanged};

ResourcesCapability _$ResourcesCapabilityFromJson(Map<String, dynamic> json) =>
    ResourcesCapability(
      subscribe: json['subscribe'] as bool?,
      listChanged: json['listChanged'] as bool?,
    );

Map<String, dynamic> _$ResourcesCapabilityToJson(
  ResourcesCapability instance,
) => <String, dynamic>{
  'subscribe': instance.subscribe,
  'listChanged': instance.listChanged,
};

ToolsCapability _$ToolsCapabilityFromJson(Map<String, dynamic> json) =>
    ToolsCapability(listChanged: json['listChanged'] as bool?);

Map<String, dynamic> _$ToolsCapabilityToJson(ToolsCapability instance) =>
    <String, dynamic>{'listChanged': instance.listChanged};

McpTool _$McpToolFromJson(Map<String, dynamic> json) => McpTool(
  name: json['name'] as String,
  description: json['description'] as String?,
  inputSchema: json['inputSchema'] as Map<String, dynamic>,
);

Map<String, dynamic> _$McpToolToJson(McpTool instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'inputSchema': instance.inputSchema,
};

ToolsListResult _$ToolsListResultFromJson(Map<String, dynamic> json) =>
    ToolsListResult(
      tools: (json['tools'] as List<dynamic>)
          .map((e) => McpTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$ToolsListResultToJson(ToolsListResult instance) =>
    <String, dynamic>{
      'tools': instance.tools.map((e) => e.toJson()).toList(),
      'nextCursor': ?instance.nextCursor,
    };

ToolCallParams _$ToolCallParamsFromJson(Map<String, dynamic> json) =>
    ToolCallParams(
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ToolCallParamsToJson(ToolCallParams instance) =>
    <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

ToolCallResult _$ToolCallResultFromJson(Map<String, dynamic> json) =>
    ToolCallResult(
      content: (json['content'] as List<dynamic>)
          .map((e) => ToolResultContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      isError: json['isError'] as bool?,
    );

Map<String, dynamic> _$ToolCallResultToJson(ToolCallResult instance) =>
    <String, dynamic>{
      'content': instance.content.map((e) => e.toJson()).toList(),
      'isError': instance.isError,
    };

ToolResultContent _$ToolResultContentFromJson(Map<String, dynamic> json) =>
    ToolResultContent(
      type: json['type'] as String,
      text: json['text'] as String?,
      mimeType: json['mimeType'] as String?,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$ToolResultContentToJson(ToolResultContent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
      'mimeType': instance.mimeType,
      'data': instance.data,
    };

McpResource _$McpResourceFromJson(Map<String, dynamic> json) => McpResource(
  uri: json['uri'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  mimeType: json['mimeType'] as String?,
);

Map<String, dynamic> _$McpResourceToJson(McpResource instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'name': instance.name,
      'description': instance.description,
      'mimeType': instance.mimeType,
    };

ResourcesListResult _$ResourcesListResultFromJson(Map<String, dynamic> json) =>
    ResourcesListResult(
      resources: (json['resources'] as List<dynamic>)
          .map((e) => McpResource.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$ResourcesListResultToJson(
  ResourcesListResult instance,
) => <String, dynamic>{
  'resources': instance.resources.map((e) => e.toJson()).toList(),
  'nextCursor': ?instance.nextCursor,
};

ResourceReadParams _$ResourceReadParamsFromJson(Map<String, dynamic> json) =>
    ResourceReadParams(uri: json['uri'] as String);

Map<String, dynamic> _$ResourceReadParamsToJson(ResourceReadParams instance) =>
    <String, dynamic>{'uri': instance.uri};

ResourceReadResult _$ResourceReadResultFromJson(Map<String, dynamic> json) =>
    ResourceReadResult(
      contents: (json['contents'] as List<dynamic>)
          .map((e) => ResourceContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResourceReadResultToJson(ResourceReadResult instance) =>
    <String, dynamic>{
      'contents': instance.contents.map((e) => e.toJson()).toList(),
    };

ResourceContent _$ResourceContentFromJson(Map<String, dynamic> json) =>
    ResourceContent(
      uri: json['uri'] as String,
      mimeType: json['mimeType'] as String?,
      text: json['text'] as String?,
      blob: json['blob'] as String?,
    );

Map<String, dynamic> _$ResourceContentToJson(ResourceContent instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'mimeType': instance.mimeType,
      'text': instance.text,
      'blob': instance.blob,
    };

McpPrompt _$McpPromptFromJson(Map<String, dynamic> json) => McpPrompt(
  name: json['name'] as String,
  description: json['description'] as String?,
  arguments: (json['arguments'] as List<dynamic>?)
      ?.map((e) => PromptArgument.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$McpPromptToJson(McpPrompt instance) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'arguments': instance.arguments?.map((e) => e.toJson()).toList(),
};

PromptArgument _$PromptArgumentFromJson(Map<String, dynamic> json) =>
    PromptArgument(
      name: json['name'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool?,
    );

Map<String, dynamic> _$PromptArgumentToJson(PromptArgument instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'required': instance.required,
    };

PromptsListResult _$PromptsListResultFromJson(Map<String, dynamic> json) =>
    PromptsListResult(
      prompts: (json['prompts'] as List<dynamic>)
          .map((e) => McpPrompt.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

Map<String, dynamic> _$PromptsListResultToJson(PromptsListResult instance) =>
    <String, dynamic>{
      'prompts': instance.prompts.map((e) => e.toJson()).toList(),
      'nextCursor': instance.nextCursor,
    };

PromptGetParams _$PromptGetParamsFromJson(Map<String, dynamic> json) =>
    PromptGetParams(
      name: json['name'] as String,
      arguments: (json['arguments'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$PromptGetParamsToJson(PromptGetParams instance) =>
    <String, dynamic>{'name': instance.name, 'arguments': instance.arguments};

PromptGetResult _$PromptGetResultFromJson(Map<String, dynamic> json) =>
    PromptGetResult(
      description: json['description'] as String?,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => PromptMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PromptGetResultToJson(PromptGetResult instance) =>
    <String, dynamic>{
      'description': instance.description,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

PromptMessage _$PromptMessageFromJson(Map<String, dynamic> json) =>
    PromptMessage(
      role: json['role'] as String,
      content: PromptMessageContent.fromJson(
        json['content'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PromptMessageToJson(PromptMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content.toJson(),
    };

PromptMessageContent _$PromptMessageContentFromJson(
  Map<String, dynamic> json,
) => PromptMessageContent(
  type: json['type'] as String,
  text: json['text'] as String?,
);

Map<String, dynamic> _$PromptMessageContentToJson(
  PromptMessageContent instance,
) => <String, dynamic>{'type': instance.type, 'text': instance.text};
