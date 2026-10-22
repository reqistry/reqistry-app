import 'dart:convert';

import 'package:api_scout/app/data/models/agent_client_config.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/agent_keys_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentClientConfig.fromJson', () {
    test('rejects unsafe endpoints and exposes fallback provenance', () {
      for (final url in [
        'http://mcp.example.com/mcp',
        'https://user:secret@mcp.example.com/mcp',
        'https://mcp.example.com/mcp?key=secret',
        'https://mcp.example.com/mcp#fragment',
        'https://mcp.example.com/\$(whoami)',
        "https://mcp.example.com/'command'",
        'javascript:alert(1)',
      ]) {
        final config = AgentClientConfig.fromJson({'mcpUrl': url});
        expect(config.mcpUrl, AgentClientConfig.fallback.mcpUrl, reason: url);
        expect(config.isFallback, isTrue, reason: url);
      }
      expect(AgentClientConfig.fallback.isFallback, isTrue);
      expect(AgentClientConfig.fromJson({
        'mcpUrl': 'https://mcp.example.com/mcp',
      }).isFallback, isFalse);
    });
    test('reads the published server metadata', () {
      final config = AgentClientConfig.fromJson({
        'mcpUrl': 'https://staging-mcp.reqistry.dev/mcp',
        'transport': 'streamable-http',
        'agentKeyHeader': 'X-Agent-Key',
        'agentKeyOptional': false,
      });
      expect(config.mcpUrl, 'https://staging-mcp.reqistry.dev/mcp');
      expect(config.transport, 'streamable-http');
      expect(config.agentKeyHeader, 'X-Agent-Key');
      expect(config.agentKeyOptional, isFalse);
    });

    test('falls back on empty or unusable payloads', () {
      expect(AgentClientConfig.fromJson(const {}).mcpUrl,
          AgentClientConfig.fallback.mcpUrl);
      expect(AgentClientConfig.fromJson(const {'mcpUrl': '  '}).mcpUrl,
          AgentClientConfig.fallback.mcpUrl);
      expect(AgentClientConfig.fromJson(const {}).agentKeyOptional, isTrue);
    });
  });

  group('agentConfigSnippets', () {
    const config = AgentClientConfig(mcpUrl: 'https://mcp.reqistry.dev/mcp');

    test('Claude Code command is shown verbatim', () {
      final snippet = agentConfigSnippets(config)
          .firstWhere((s) => s.client == 'Claude Code');
      expect(snippet.code,
          "claude mcp add --transport http reqistry 'https://mcp.reqistry.dev/mcp'");
    });

    test('every JSON snippet stays valid JSON and carries the endpoint', () {
      for (final snippet in agentConfigSnippets(config)) {
        if (!snippet.code.startsWith('{')) continue;
        final decoded = jsonDecode(snippet.code) as Map<String, dynamic>;
        expect(decoded.toString(), contains(config.mcpUrl),
            reason: '${snippet.client} must show the configured endpoint');
      }
    });

    test('Codex snippet is TOML for the documented path', () {
      final snippet = agentConfigSnippets(config)
          .firstWhere((s) => s.client == 'OpenAI Codex');
      expect(snippet.path, '~/.codex/config.toml');
      expect(snippet.code,
          '[mcp_servers.reqistry]\nurl = "https://mcp.reqistry.dev/mcp"');
    });

    test('generic setup is an endpoint, not a fake mandatory secret', () {
      final snippet = agentConfigSnippets(config)
          .firstWhere((s) => s.client == 'Any MCP client');
      expect(snippet.code, config.mcpUrl);
      expect(snippet.code, isNot(contains('<your key>')));
    });

    test('OpenCode uses the published direct mcp map', () {
      final snippet = agentConfigSnippets(config)
          .firstWhere((s) => s.id == 'opencode');
      final decoded = jsonDecode(snippet.code) as Map<String, dynamic>;
      expect(decoded['mcp']['reqistry']['url'], config.mcpUrl);
      expect(decoded['mcp'].containsKey('servers'), isFalse);
    });

    test('Antigravity uses serverUrl in its MCP settings', () {
      final snippet = agentConfigSnippets(config)
          .firstWhere((s) => s.id == 'antigravity');
      expect(jsonDecode(snippet.code)['mcpServers']['reqistry']['serverUrl'],
          config.mcpUrl);
    });

    test('snippet ids are unique snake_case analytics props', () {
      final ids = agentConfigSnippets(config).map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final id in ids) {
        expect(RegExp(r'^[a-z]+(_[a-z]+)*$').hasMatch(id), isTrue, reason: id);
      }
    });

    test('a moved endpoint flows into every client snippet', () {
      const moved = AgentClientConfig(mcpUrl: 'https://staging.reqistry.dev/mcp');
      for (final snippet in agentConfigSnippets(moved)) {
        expect(snippet.code, contains('https://staging.reqistry.dev/mcp'));
      }
    });
  });

  group('formatKeyUsageWhen', () {
    test('formats a timestamp for the key usage line', () {
      expect(formatKeyUsageWhen(DateTime(2026, 3, 7, 9, 5)), '2026-03-07 09:05');
    });
  });

  test('untrusted header/transport fall back to the documented defaults', () {
    final config = AgentClientConfig.fromJson({
      'mcpUrl': 'https://mcp.example.com/mcp',
      'agentKeyHeader': 'X-Agent-Key" });evil',
      'transport': r'a $(boom) b',
    });
    expect(config.agentKeyHeader, 'X-Agent-Key');
    expect(config.transport, 'streamable-http');
  });
}
