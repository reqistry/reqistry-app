# Agent value implementation plan

> Execute inline with test-driven-development and verification-before-completion.

**Spec:** product/agent-value-upgrade.md
**Goal:** task-first agent workflows discoverable from Home and API detail.
**Architecture:** existing services, a presentation-only workflow model and small
widgets; one screen orchestrates config loading, client choice and task choice.

## Tasks
- [ ] Config trust boundary + official client snippets: extend existing
  AgentClientConfig and its test. RED: malicious URL, unsafe scheme/userinfo,
  fallback provenance, nested OpenCode shape, missing Antigravity. GREEN:
  validated HTTPS URLs, safe encoding, current schemas, honest fallback flag.
- [ ] Task-first Agent Console + Home/detail entry: localized prompts backed
  by existing tools; selected-client view, selectable code, copy/share, optional
  collapsed key management; preserve route and additive analytics. Tests for
  client switching, action copy text, contextual slug, retry/fallback, 2x text,
  light/dark. No keys fetched before advanced access expands.
- [ ] Reviews after value only: regression test prohibits detail visits from
  prompting, remove detail-view trigger, retain successful save/project callers,
  correct supplied-clock handling, remove unused legacy review manager.
- [ ] Final: gen-l10n, analyze, full tests, APK debug build (command-local
  Gradle JVM override if needed). Fresh read-only whole-change review, repair
  important issues, recheck. Device/client verification recorded as manual if
  unavailable. Keep changes local; no push/release/deploy.

## Review focus
Untrusted config URLs cannot execute through shell snippets; unavailable config
does not look verified; no key/prompt content in telemetry; 200% text does not
overflow; contextual handoff cannot silently change an API slug.
