import 'package:json_annotation/json_annotation.dart';

part 'mcp_types.g.dart';

/// MCP Initialize Request Parameters
@JsonSerializable(explicitToJson: true)
class InitializeParams {
  final String protocolVersion;
  final ClientCapabilities capabilities;
  final Implementation clientInfo;

  const InitializeParams({
    required this.protocolVersion,
    required this.capabilities,
    required this.clientInfo,
  });

  factory InitializeParams.fromJson(Map<String, dynamic> json) =>
      _$InitializeParamsFromJson(json);

  Map<String, dynamic> toJson() => _$InitializeParamsToJson(this);
}

/// MCP Initialize Result
@JsonSerializable(explicitToJson: true)
class InitializeResult {
  final String protocolVersion;
  final ServerCapabilities capabilities;
  final Implementation serverInfo;
  final String? instructions;

  const InitializeResult({
    required this.protocolVersion,
    required this.capabilities,
    required this.serverInfo,
    this.instructions,
  });

  factory InitializeResult.fromJson(Map<String, dynamic> json) =>
      _$InitializeResultFromJson(json);

  Map<String, dynamic> toJson() => _$InitializeResultToJson(this);
}

/// Client capabilities
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ClientCapabilities {
  final ExperimentalCapabilities? experimental;
  final RootsCapability? roots;
  final SamplingCapability? sampling;

  const ClientCapabilities({this.experimental, this.roots, this.sampling});

  factory ClientCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ClientCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$ClientCapabilitiesToJson(this);
}

/// Server capabilities
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ServerCapabilities {
  final ExperimentalCapabilities? experimental;
  final LoggingCapability? logging;
  final PromptsCapability? prompts;
  final ResourcesCapability? resources;
  final ToolsCapability? tools;

  const ServerCapabilities({
    this.experimental,
    this.logging,
    this.prompts,
    this.resources,
    this.tools,
  });

  factory ServerCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ServerCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$ServerCapabilitiesToJson(this);
}

/// Implementation info (client or server)
@JsonSerializable()
class Implementation {
  final String name;
  final String version;

  const Implementation({required this.name, required this.version});

  factory Implementation.fromJson(Map<String, dynamic> json) =>
      _$ImplementationFromJson(json);

  Map<String, dynamic> toJson() => _$ImplementationToJson(this);
}

/// Experimental capabilities placeholder
@JsonSerializable()
class ExperimentalCapabilities {
  const ExperimentalCapabilities();

  factory ExperimentalCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ExperimentalCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$ExperimentalCapabilitiesToJson(this);
}

/// Roots capability
@JsonSerializable()
class RootsCapability {
  final bool? listChanged;

  const RootsCapability({this.listChanged});

  factory RootsCapability.fromJson(Map<String, dynamic> json) =>
      _$RootsCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$RootsCapabilityToJson(this);
}

/// Sampling capability
@JsonSerializable()
class SamplingCapability {
  const SamplingCapability();

  factory SamplingCapability.fromJson(Map<String, dynamic> json) =>
      _$SamplingCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$SamplingCapabilityToJson(this);
}

/// Logging capability
@JsonSerializable()
class LoggingCapability {
  const LoggingCapability();

  factory LoggingCapability.fromJson(Map<String, dynamic> json) =>
      _$LoggingCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$LoggingCapabilityToJson(this);
}

/// Prompts capability
@JsonSerializable()
class PromptsCapability {
  final bool? listChanged;

  const PromptsCapability({this.listChanged});

  factory PromptsCapability.fromJson(Map<String, dynamic> json) =>
      _$PromptsCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$PromptsCapabilityToJson(this);
}

/// Resources capability
@JsonSerializable()
class ResourcesCapability {
  final bool? subscribe;
  final bool? listChanged;

  const ResourcesCapability({this.subscribe, this.listChanged});

  factory ResourcesCapability.fromJson(Map<String, dynamic> json) =>
      _$ResourcesCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$ResourcesCapabilityToJson(this);
}

/// Tools capability
@JsonSerializable()
class ToolsCapability {
  final bool? listChanged;

  const ToolsCapability({this.listChanged});

  factory ToolsCapability.fromJson(Map<String, dynamic> json) =>
      _$ToolsCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$ToolsCapabilityToJson(this);
}

/// MCP Tool definition
@JsonSerializable(explicitToJson: true)
class McpTool {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;

  const McpTool({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  factory McpTool.fromJson(Map<String, dynamic> json) =>
      _$McpToolFromJson(json);

  Map<String, dynamic> toJson() => _$McpToolToJson(this);
}

/// Tools list result
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ToolsListResult {
  final List<McpTool> tools;
  final String? nextCursor;

  const ToolsListResult({required this.tools, this.nextCursor});

  factory ToolsListResult.fromJson(Map<String, dynamic> json) =>
      _$ToolsListResultFromJson(json);

  Map<String, dynamic> toJson() => _$ToolsListResultToJson(this);
}

/// Tool call params
@JsonSerializable()
class ToolCallParams {
  final String name;
  final Map<String, dynamic>? arguments;

  const ToolCallParams({required this.name, this.arguments});

  factory ToolCallParams.fromJson(Map<String, dynamic> json) =>
      _$ToolCallParamsFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallParamsToJson(this);
}

/// Tool call result
@JsonSerializable(explicitToJson: true)
class ToolCallResult {
  final List<ToolResultContent> content;
  final bool? isError;

  const ToolCallResult({required this.content, this.isError});

  factory ToolCallResult.fromJson(Map<String, dynamic> json) =>
      _$ToolCallResultFromJson(json);

  Map<String, dynamic> toJson() => _$ToolCallResultToJson(this);
}

/// Tool result content
@JsonSerializable()
class ToolResultContent {
  final String type;
  final String? text;
  final String? mimeType;
  final String? data;

  const ToolResultContent({
    required this.type,
    this.text,
    this.mimeType,
    this.data,
  });

  factory ToolResultContent.text(String text) =>
      ToolResultContent(type: 'text', text: text);

  factory ToolResultContent.image(String base64Data, String mimeType) =>
      ToolResultContent(type: 'image', data: base64Data, mimeType: mimeType);

  factory ToolResultContent.fromJson(Map<String, dynamic> json) =>
      _$ToolResultContentFromJson(json);

  Map<String, dynamic> toJson() => _$ToolResultContentToJson(this);
}

/// MCP Resource definition
@JsonSerializable()
class McpResource {
  final String uri;
  final String name;
  final String? description;
  final String? mimeType;

  const McpResource({
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
  });

  factory McpResource.fromJson(Map<String, dynamic> json) =>
      _$McpResourceFromJson(json);

  Map<String, dynamic> toJson() => _$McpResourceToJson(this);
}

/// Resources list result
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ResourcesListResult {
  final List<McpResource> resources;
  final String? nextCursor;

  const ResourcesListResult({required this.resources, this.nextCursor});

  factory ResourcesListResult.fromJson(Map<String, dynamic> json) =>
      _$ResourcesListResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResourcesListResultToJson(this);
}

/// Resource read params
@JsonSerializable()
class ResourceReadParams {
  final String uri;

  const ResourceReadParams({required this.uri});

  factory ResourceReadParams.fromJson(Map<String, dynamic> json) =>
      _$ResourceReadParamsFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceReadParamsToJson(this);
}

/// Resource read result
@JsonSerializable(explicitToJson: true)
class ResourceReadResult {
  final List<ResourceContent> contents;

  const ResourceReadResult({required this.contents});

  factory ResourceReadResult.fromJson(Map<String, dynamic> json) =>
      _$ResourceReadResultFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceReadResultToJson(this);
}

/// Resource content
@JsonSerializable()
class ResourceContent {
  final String uri;
  final String? mimeType;
  final String? text;
  final String? blob;

  const ResourceContent({
    required this.uri,
    this.mimeType,
    this.text,
    this.blob,
  });

  factory ResourceContent.text(String uri, String text, [String? mimeType]) =>
      ResourceContent(uri: uri, text: text, mimeType: mimeType ?? 'text/plain');

  factory ResourceContent.fromJson(Map<String, dynamic> json) =>
      _$ResourceContentFromJson(json);

  Map<String, dynamic> toJson() => _$ResourceContentToJson(this);
}

/// MCP Prompt definition
@JsonSerializable(explicitToJson: true)
class McpPrompt {
  final String name;
  final String? description;
  final List<PromptArgument>? arguments;

  const McpPrompt({required this.name, this.description, this.arguments});

  factory McpPrompt.fromJson(Map<String, dynamic> json) =>
      _$McpPromptFromJson(json);

  Map<String, dynamic> toJson() => _$McpPromptToJson(this);
}

/// Prompt argument
@JsonSerializable()
class PromptArgument {
  final String name;
  final String? description;
  final bool? required;

  const PromptArgument({required this.name, this.description, this.required});

  factory PromptArgument.fromJson(Map<String, dynamic> json) =>
      _$PromptArgumentFromJson(json);

  Map<String, dynamic> toJson() => _$PromptArgumentToJson(this);
}

/// Prompts list result
@JsonSerializable(explicitToJson: true)
class PromptsListResult {
  final List<McpPrompt> prompts;
  final String? nextCursor;

  const PromptsListResult({required this.prompts, this.nextCursor});

  factory PromptsListResult.fromJson(Map<String, dynamic> json) =>
      _$PromptsListResultFromJson(json);

  Map<String, dynamic> toJson() => _$PromptsListResultToJson(this);
}

/// Prompt get params
@JsonSerializable()
class PromptGetParams {
  final String name;
  final Map<String, String>? arguments;

  const PromptGetParams({required this.name, this.arguments});

  factory PromptGetParams.fromJson(Map<String, dynamic> json) =>
      _$PromptGetParamsFromJson(json);

  Map<String, dynamic> toJson() => _$PromptGetParamsToJson(this);
}

/// Prompt get result
@JsonSerializable(explicitToJson: true)
class PromptGetResult {
  final String? description;
  final List<PromptMessage> messages;

  const PromptGetResult({this.description, required this.messages});

  factory PromptGetResult.fromJson(Map<String, dynamic> json) =>
      _$PromptGetResultFromJson(json);

  Map<String, dynamic> toJson() => _$PromptGetResultToJson(this);
}

/// Prompt message
@JsonSerializable(explicitToJson: true)
class PromptMessage {
  final String role;
  final PromptMessageContent content;

  const PromptMessage({required this.role, required this.content});

  factory PromptMessage.fromJson(Map<String, dynamic> json) =>
      _$PromptMessageFromJson(json);

  Map<String, dynamic> toJson() => _$PromptMessageToJson(this);
}

/// Prompt message content
@JsonSerializable()
class PromptMessageContent {
  final String type;
  final String? text;

  const PromptMessageContent({required this.type, this.text});

  factory PromptMessageContent.text(String text) =>
      PromptMessageContent(type: 'text', text: text);

  factory PromptMessageContent.fromJson(Map<String, dynamic> json) =>
      _$PromptMessageContentFromJson(json);

  Map<String, dynamic> toJson() => _$PromptMessageContentToJson(this);
}
