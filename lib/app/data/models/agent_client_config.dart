import 'package:flutter/foundation.dart';

/// Public MCP client metadata from `GET /v1/agent-keys/config`.
///
/// The server is the source of truth for the endpoint so the app never
/// hardcodes a host that could move.
class AgentClientConfig {
  final String mcpUrl;
  final String transport;
  final String agentKeyHeader;
  final bool agentKeyOptional;

  /// True when the documented default endpoint is shown instead of a
  /// server-provided one, so the UI can state that honestly.
  final bool isFallback;

  const AgentClientConfig({
    required this.mcpUrl,
    this.transport = 'streamable-http',
    this.agentKeyHeader = 'X-Agent-Key',
    this.agentKeyOptional = true,
    this.isFallback = false,
  });

  /// Used when the config request fails: matches the server's default.
  static const AgentClientConfig fallback = AgentClientConfig(
    mcpUrl: 'https://mcp.reqistry.dev/mcp',
    transport: 'streamable-http',
    agentKeyHeader: 'X-Agent-Key',
    agentKeyOptional: true,
    isFallback: true,
  );

  /// Trust boundary: the URL is embedded verbatim into shell commands and
  /// JSON the user is told to paste into agent clients, so anything that is
  /// not a plain https endpoint falls back to the documented default.
  @visibleForTesting
  static bool isSafeEndpoint(String url) {
    // Shell metacharacters and whitespace can never appear in the clean URLs
    // the server sends; their presence means an untrusted or malformed value.
    const dangerous = [r'$', '`', "'", '"', ' ', '\n', '\r', '\t', '@'];
    if (dangerous.any(url.contains)) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        uri.query.trim().isEmpty &&
        uri.fragment.trim().isEmpty;
  }

  factory AgentClientConfig.fromJson(Map<String, dynamic> json) {
    final url = json['mcpUrl']?.toString().trim() ?? '';
    final safe = isSafeEndpoint(url);
    return AgentClientConfig(
      mcpUrl: safe ? url : fallback.mcpUrl,
      transport: json['transport']?.toString() ?? 'streamable-http',
      agentKeyHeader: json['agentKeyHeader']?.toString() ?? 'X-Agent-Key',
      agentKeyOptional: json['agentKeyOptional'] != false,
      isFallback: !safe,
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
      code: "claude mcp add --transport http reqistry '$url'",
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
          '    "reqistry": {\n'
          '      "type": "remote",\n'
          '      "url": "$url"\n'
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
      id: 'antigravity',
      client: 'Google Antigravity',
      code: '{\n'
          '  "mcpServers": {\n'
          '    "reqistry": {\n'
          '      "serverUrl": "$url"\n'
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
      code: url,
    ),
  ];
}
