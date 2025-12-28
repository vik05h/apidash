# MCP (Model Context Protocol) Integration

## Overview

APIDash now includes support for the Model Context Protocol (MCP), allowing AI assistants like Claude Desktop, Cline, and other MCP-compatible clients to interact with your API collections programmatically.

## What is MCP?

Model Context Protocol is an open standard that enables AI applications to securely access context from your tools and data sources. With MCP support in APIDash, AI assistants can:

- **List all your API requests** in your collection
- **Execute API requests** and get real-time responses
- **Create new requests** programmatically
- **Access environment variables** and configurations
- **Read request details** including headers, body, and parameters

## Enabling MCP Server

### In APIDash Desktop App

1. Open **Settings** (gear icon in the sidebar)
2. Find the **MCP Server** toggle switch
3. Enable it to start the MCP server
4. The server will run at `http://localhost:22140`
5. The server URL will be displayed in the settings

**The MCP server runs alongside APIDash and uses your real API collection data!**

### Server Endpoints

When enabled, the MCP server provides:

- `http://localhost:22140/health` - Health check
- `http://localhost:22140/message` - Send JSON-RPC messages (POST)
- `http://localhost:22140/sse` - Server-Sent Events for responses

## Testing the MCP Server

### Quick Test with curl

```bash
# Check if server is running
curl http://localhost:22140/health

# Send an initialize request
curl -X POST http://localhost:22140/message \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'
```

### Using the Test Script

```bash
cd packages/mcp
dart test/http_client_test.dart
```

## Using APIDash with Claude Desktop

### Setup Instructions

1. **Enable MCP Server** in APIDash Settings (see above)

2. **Configure Claude Desktop:**

   Edit your Claude Desktop configuration file:
   
   - **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`
   - **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Linux:** `~/.config/Claude/claude_desktop_config.json`

3. **Add APIDash Server:**

   ```json
   {
     "mcpServers": {
       "apidash": {
         "command": "dart",
         "args": ["run", "mcp:server", "--stdio"],
         "cwd": "/path/to/your/apidash/workspace"
       }
     }
   }
   ```

   Replace `/path/to/your/apidash/workspace` with your actual APIDash project directory.

4. **Restart Claude Desktop** to apply the changes.

### Verifying the Connection

1. Open Claude Desktop
2. Look for a small 🔌 icon or "MCP" indicator
3. Click on it to see available MCP servers
4. You should see "apidash-mcp v0.1.0" listed
5. Click to view available tools and resources

## Available MCP Tools

Once connected, AI assistants can use these tools:

### 1. `apidash_list_requests`
Lists all API requests in your collection.

**Example prompt:** "Show me all my API requests"

### 2. `apidash_get_request`
Retrieves details of a specific request by ID.

**Parameters:**
- `requestId` (string): The ID of the request

**Example prompt:** "Show me the details of request demo-1"

### 3. `apidash_execute_request`
Executes an API request and returns the response.

**Parameters:**
- `requestId` (string): The ID of the request to execute

**Example prompt:** "Execute the Get Users request"

### 4. `apidash_create_request`
Creates a new API request in your collection.

**Parameters:**
- `method` (string): HTTP method (GET, POST, PUT, DELETE, etc.)
- `url` (string): The request URL
- `headers` (object, optional): Key-value pairs of headers
- `body` (string, optional): Request body
- `name` (string, optional): Name for the request

**Example prompt:** "Create a POST request to https://api.example.com/users with a JSON body"

### 5. `apidash_list_environments`
Lists all configured environments.

**Example prompt:** "What environments do I have configured?"

### 6. `apidash_get_active_environment`
Returns the currently active environment with its variables.

**Example prompt:** "What is my active environment?"

## Available MCP Resources

Resources provide read-only access to your API collection:

- `apidash://requests/{id}` - Access any request by its ID
- `apidash://environments` - View all environments
- `apidash://environment/active` - View active environment

## Use Cases

### 1. Quick API Testing
**Prompt:** "Execute my login request and check if the status is 200"

### 2. Batch Operations
**Prompt:** "Execute all my GET requests and summarize the responses"

### 3. API Documentation
**Prompt:** "Generate documentation for all my API endpoints"

### 4. Request Creation
**Prompt:** "Create a new POST request to /api/products with these fields: name, price, category"

### 5. Environment Switching
**Prompt:** "List my environments and tell me which one is active"

## Standalone MCP Server

For advanced users or CI/CD integration, you can run the APIDash MCP server standalone:

```bash
cd /path/to/apidash
dart packages/mcp/bin/server.dart --stdio
```

This is useful for:
- Automation scripts
- Testing MCP functionality
- Integration with other MCP clients
- CI/CD pipelines

## Troubleshooting

### Claude Desktop doesn't show APIDash
1. Check the configuration file path is correct
2. Verify the `cwd` points to your APIDash directory
3. Restart Claude Desktop completely
4. Check Claude Desktop logs for errors

### "Connection Error" in MCP Inspector
1. Ensure the server is running (toggle enabled in Settings)
2. Try restarting APIDash
3. Check terminal/console for error messages

### Commands not working
1. Verify APIDash has your API collection loaded
2. Check that requests have valid IDs
3. Ensure environment variables are configured if required

## Security Note

The MCP server runs locally and only provides access to your APIDash collection data. No data is sent to external servers. Communication between Claude Desktop (or other MCP clients) and APIDash happens entirely on your local machine via STDIO.

## Learn More

- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Claude Desktop MCP Documentation](https://docs.anthropic.com/claude/docs/mcp)
- [APIDash GitHub Repository](https://github.com/foss42/apidash)
