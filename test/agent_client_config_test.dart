import 'dart:convert';

import 'package:api_scout/app/data/models/agent_client_config.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/agent_keys_section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgentClientConfig.fromJson', () {
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
          'claude mcp add --transport http reqistry https://mcp.reqistry.dev/mcp');
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

    test('generic snippet names the transport and key header', () {
      final snippet = agentConfigSnippets(config)
          .firstWhere((s) => s.client == 'Any MCP client');
      expect(snippet.code, contains('streamable-http'));
      expect(snippet.code, contains('X-Agent-Key: <your key>'));
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
}
