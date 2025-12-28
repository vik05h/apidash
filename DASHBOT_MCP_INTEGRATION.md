# Dashbot MCP Integration

## What's Been Implemented

Dashbot now has access to MCP (Model Context Protocol) tools to manipulate API requests directly!

### Features Added

1. **MCP Tool Service** (`lib/dashbot/services/mcp_tool_service.dart`)
   - Provides MCP tool definitions to AI models
   - Parses tool calls from AI responses  
   - Executes tool calls via HTTP to MCP server

2. **System Prompt Integration**
   - MCP tools are automatically added to the system prompt when MCP server is enabled
   - AI models now know about these tools:
     - `list_requests` - List all API requests
     - `create_request` - Create new API requests
     - `update_request` - Update existing requests
     - `delete_request` - Delete requests
     - `execute_request` - Execute/send requests

3. **Tool Call Execution**
   - ChatViewmodel now detects tool calls in AI responses
   - Automatically executes tools via MCP HTTP endpoint
   - Shows tool execution results in the chat

### How It Works

1. **User asks Dashbot**: "Create a GET request to https://api.github.com/users/octocat"

2. **AI responds with tool call**:
   ```json
   {
     "explanation": "I'll create that request for you",
     "tool_calls": [
       {
         "tool": "create_request",
         "arguments": {
           "method": "GET",
           "url": "https://api.github.com/users/octocat",
           "name": "Get GitHub User"
         }
       }
     ]
   }
   ```

3. **Dashbot executes** the tool via MCP server

4. **Request appears** in APIDash UI instantly!

### Testing

1. **Enable MCP Server** in Settings
2. **Open Dashbot** chat
3. **Try commands like**:
   - "Create a POST request to https://api.example.com/users"
   - "List all my requests"
   - "Execute the GitHub request"
   - "Update request X to use POST method"

### Requirements

- MCP Server must be enabled in Settings (toggle in bottom section)
- AI model must be configured (Settings → AI Model)
- The AI model needs to support tool/function calling format

### Example Prompts

```
"Create 3 GET requests for the GitHub API:
1. Get user octocat
2. Get user repos 
3. Get user followers"
```

```
"List all my requests and then execute the first one"
```

```
"Create a POST request to https://httpbin.org/post with JSON body containing name and email"
```

## Technical Details

### Files Modified

- `lib/dashbot/services/mcp_tool_service.dart` (NEW)
- `lib/dashbot/services/services.dart`
- `lib/dashbot/services/agent/prompt_builder.dart`
- `lib/dashbot/providers/service_providers.dart`
- `lib/dashbot/providers/chat_viewmodel.dart`

### Architecture

```
Dashbot (UI)
    ↓
ChatViewmodel
    ↓
AI Model (with MCP tools in prompt)
    ↓
Tool Call Response
    ↓
McpToolService
    ↓
HTTP Request → MCP Server (localhost:22140)
    ↓
Tool Execution (create_request, etc.)
    ↓
APIDash State Update (via Riverpod)
    ↓
UI Updates Automatically
```

### Next Steps

To fully test this, you need to:
1. Rebuild the app: `flutter run -d windows`
2. Enable MCP Server in Settings
3. Configure an AI model if not already done
4. Open Dashbot and try the example prompts above

The AI model needs to be configured to understand the tool call format. Most modern models (GPT-4, Claude 3.5, etc.) support this natively.
