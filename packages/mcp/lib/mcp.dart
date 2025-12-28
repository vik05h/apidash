/// MCP (Model Context Protocol) support for APIDash
///
/// This library provides MCP server functionality, allowing LLMs to
/// interact with APIDash's API requests through a standardized protocol.
library mcp;

// Protocol types
export 'src/protocol/protocol.dart';

// Transport
export 'src/transport/transports.dart';

// Server
export 'src/server/server.dart';

// Tools
export 'src/tools/tools.dart';

// Resources
export 'src/resources/resources.dart';

// APIDash-specific implementations
export 'src/apidash/apidash.dart';
