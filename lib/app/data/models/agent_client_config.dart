/// Public MCP client metadata from `GET /v1/agent-keys/config`.
///
/// The server is the source of truth for the endpoint so the app never
/// hardcodes a host that could move.
class AgentClientConfig {
  final String mcpUrl;
  final String transport;
  final String agentKeyHeader;
  final bool agentKeyOptional;

  const AgentClientConfig({
    required this.mcpUrl,
    this.transport = 'streamable-http',
    this.agentKeyHeader = 'X-Agent-Key',
    this.agentKeyOptional = true,
  });

  /// Used when the config request fails: matches the server's default.
  static const AgentClientConfig fallback = AgentClientConfig(
    mcpUrl: 'https://mcp.reqistry.dev/mcp',
  );

  factory AgentClientConfig.fromJson(Map<String, dynamic> json) {
    final url = json['mcpUrl']?.toString().trim() ?? '';
    return AgentClientConfig(
      mcpUrl: url.isNotEmpty ? url : fallback.mcpUrl,
      transport: json['transport']?.toString() ?? 'streamable-http',
      agentKeyHeader: json['agentKeyHeader']?.toString() ?? 'X-Agent-Key',
      agentKeyOptional: json['agentKeyOptional'] != false,
    );
  }
}

/// One copyable client configuration. [path] is shown as code, not prose, so it
/// stays verbatim; [code] must be the complete configuration.
class AgentConfigSnippet {
  /// Stable snake_case id for analytics; [client] is the display name.
  final String id;
  final String client;
  final String? path;
  final String code;

  const AgentConfigSnippet({
    required this.id,
    required this.client,
    this.path,
    required this.code,
  });
}

/// Verbatim client setups, kept in step with the published MCP install docs.
List<AgentConfigSnippet> agentConfigSnippets(AgentClientConfig config) {
  final url = config.mcpUrl;
  return [
    AgentConfigSnippet(
      id: 'claude_code',
      client: 'Claude Code',
      code: 'claude mcp add --transport http reqistry $url',
    ),
    AgentConfigSnippet(
      id: 'codex',
      client: 'OpenAI Codex',
      path: '~/.codex/config.toml',
      code: '[mcp_servers.reqistry]\nurl = "$url"',
    ),
    AgentConfigSnippet(
      id: 'opencode',
      client: 'OpenCode',
      path: 'opencode.json',
      code: '{\n'
          '  "\$schema": "https://opencode.ai/config.json",\n'
          '  "mcp": {\n'
          '    "servers": {\n'
          '      "reqistry": {\n'
          '        "type": "remote",\n'
          '        "url": "$url",\n'
          '        "oauth": false\n'
          '      }\n'
          '    }\n'
          '  }\n'
          '}',
    ),
    AgentConfigSnippet(
      id: 'cursor',
      client: 'Cursor',
      path: '.cursor/mcp.json',
      code: '{\n'
          '  "mcpServers": {\n'
          '    "reqistry": {\n'
          '      "type": "http",\n'
          '      "url": "$url"\n'
          '    }\n'
          '  }\n'
          '}',
    ),
    AgentConfigSnippet(
      id: 'windsurf',
      client: 'Windsurf',
      path: '~/.codeium/windsurf/mcp_config.json',
      code: '{\n'
          '  "mcpServers": {\n'
          '    "reqistry": {\n'
          '      "serverUrl": "$url"\n'
          '    }\n'
          '  }\n'
          '}',
    ),
    AgentConfigSnippet(
      id: 'generic',
      client: 'Any MCP client',
      code: '${config.transport} $url\n${config.agentKeyHeader}: <your key>',
    ),
  ];
}
