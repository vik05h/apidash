import 'dart:convert';
import 'dart:io';

/// Simple test client for APIDash MCP HTTP Server
void main() async {
  const serverUrl = 'http://localhost:22140';

  print('APIDash MCP HTTP Client Test');
  print('============================\n');

  // Test 1: Health check
  print('1. Testing health endpoint...');
  try {
    final healthResponse = await HttpClient()
        .getUrl(Uri.parse('$serverUrl/health'))
        .then((req) => req.close());
    final healthBody = await healthResponse.transform(utf8.decoder).join();
    print('   ✓ Health: $healthBody\n');
  } catch (e) {
    print('   ✗ Failed: $e');
    print('\n   Make sure APIDash is running with MCP Server enabled!\n');
    exit(1);
  }

  // Test 2: Send initialize request
  print('2. Sending initialize request...');
  final initResponse = await sendMessage(serverUrl, {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {"name": "http-test-client", "version": "1.0"},
    },
  });
  print('   Response: ${_prettyJson(initResponse)}\n');

  // Test 3: Send initialized notification
  print('3. Sending initialized notification...');
  await sendMessage(serverUrl, {
    "jsonrpc": "2.0",
    "method": "notifications/initialized",
  });
  print('   ✓ Initialized notification sent\n');

  // Test 4: List tools
  print('4. Listing available tools...');
  final toolsResponse = await sendMessage(serverUrl, {
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
  });
  print('   Response: ${_prettyJson(toolsResponse)}\n');

  // Test 5: List requests
  print('5. Calling list_requests tool...');
  final listResponse = await sendMessage(serverUrl, {
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {"name": "list_requests", "arguments": {}},
  });
  print('   Response: ${_prettyJson(listResponse)}\n');

  // Test 6: Create a new request
  print('6. Creating a new API request...');
  final createResponse = await sendMessage(serverUrl, {
    "jsonrpc": "2.0",
    "id": 4,
    "method": "tools/call",
    "params": {
      "name": "create_request",
      "arguments": {
        "method": "GET",
        "url": "https://api.github.com/users/octocat",
        "name": "Get GitHub User (MCP Created)",
      },
    },
  });
  print('   Response: ${_prettyJson(createResponse)}\n');

  print('============================');
  print('Test complete! Check APIDash UI for the new request.');
}

Future<String> sendMessage(
  String serverUrl,
  Map<String, dynamic> message,
) async {
  final client = HttpClient();
  final request = await client.postUrl(Uri.parse('$serverUrl/mcp'));
  request.headers.contentType = ContentType.json;
  request.write(jsonEncode(message));
  final response = await request.close();
  return await response.transform(utf8.decoder).join();
}

String _prettyJson(String json) {
  try {
    final decoded = jsonDecode(json);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return json;
  }
}
