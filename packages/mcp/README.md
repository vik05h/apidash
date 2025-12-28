# MCP (Model Context Protocol) for APIDash

This package implements the Model Context Protocol (MCP) server for APIDash, enabling Large Language Models (LLMs) to access and interact with API requests defined in APIDash.

## What is MCP?

MCP (Model Context Protocol) is an open standard for connecting AI applications to external systems. It provides a standardized way for LLMs to access:

- **Tools**: Executable functions that AI applications can invoke
- **Resources**: Data sources that provide contextual information
- **Prompts**: Reusable templates for LLM interactions

## Features

This MCP server implementation exposes:

### Tools
- `execute_request` - Execute an API request by ID
- `list_requests` - List all saved API requests
- `get_request` - Get details of a specific request
- `create_request` - Create a new API request
- `get_response` - Get the response of a previous request

### Resources
- `apidash://requests` - All saved API requests
- `apidash://request/{id}` - Specific request details
- `apidash://response/{id}` - Response from a request
- `apidash://environments` - Environment variables

## Usage

### Running as STDIO Server

The MCP server can be started in STDIO mode for integration with AI applications like Claude Desktop:

```bash
dart run mcp:server --stdio
```

### Claude Desktop Configuration

Add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "apidash": {
      "command": "dart",
      "args": ["run", "mcp:server", "--stdio"]
    }
  }
}
```

## Protocol

This implementation follows the [MCP Specification](https://spec.modelcontextprotocol.io/) using JSON-RPC 2.0 for communication.

## License

MIT License - See LICENSE file for details.
