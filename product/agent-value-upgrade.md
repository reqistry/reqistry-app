# Mobile agent value upgrade — 2026-10-22

## Intent and scope
Make Reqistry's evidence-backed catalog useful inside an engineer's coding
workflow. The first impression should be a concrete task, not a configuration
manual. Continue the approved client-upgrade plan without replacing Flutter,
the Cubit/RemoteService architecture, or the flat bordered design system.

Owner authorized autonomous execution. Implement this focused release inline:
1. Home prominently introduces the agent workflow, with a direct route to it.
2. Agent Console offers discovery, comparison and replacement prompts before
   setup. These are instructions for a connected coding agent, not fabricated
   answers, and reference tools actually in the backend registry.
3. Choose one client and show only that client's complete setup. Include
   Claude Code, Codex, OpenCode, Cursor, Antigravity, existing Windsurf and a
   generic endpoint. Copy/share setup and prompts; never run external commands.
4. API detail hands off its actual slug to the agent journey, producing a
   contextual integration prompt (inspect evidence, show unknowns, starter code).
5. Retain key management under optional advanced access. No secret persistence
   or key auto-injection. No claim that copying a config means connected.
6. Review prompts follow established successful saves/projects, with the existing
   three-win, three-day, 90-day-cooldown policy; opening details never prompts.

## Integrity and validation
Validate server-supplied endpoint URLs before displaying executable snippets:
HTTPS only, no credentials/query/fragment, no command injection. Encode JSON
with dart:convert. Report fallback explicitly instead of presenting it as live
configuration. Commands are copy-only and must not overwrite existing config.
One client visible at a time, full code selectable, touch targets >=48dp,
English and Spanish, light/dark and large-text widget checks. No unverified
checkmarks. No raw prompts/keys/config text in analytics.

## Documentation evidence
Checked official docs on 2026-10-22:
- https://code.claude.com/docs/en/mcp — HTTP CLI command.
- https://developers.openai.com/codex/mcp — mcp_servers tables and url.
- https://opencode.ai/docs/mcp-servers/ — current documented direct mcp map
  (existing app's nested mcp.servers is not the current published schema).
- https://cursor.com/docs/context/mcp — mcpServers with url.
- https://antigravity.google/docs/mcp — mcpServers with serverUrl; use the
  client's raw MCP configuration editor rather than assume a global file path.
Appllama MCP unavailable. No claim of reference-screen study or on-device
verification until actually performed. Desktop Flutter is available; no mobile
device/emulator was connected at preflight. Android SDK exists at
/home/gw/tooling/android-sdk (local.properties still points elsewhere).

## Non-goals
No backend changes/deploys, fake in-app chatbot, auto-install, inferred client
connection success, notification growth campaigns, paid ranking, store release,
new art/dependencies, or completion claim for all waves of the original plan.
