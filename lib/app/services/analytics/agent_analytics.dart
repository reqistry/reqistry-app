import 'dart:async';

import 'package:api_scout/app/services/analytics/posthog_service.dart';

/// Agent Console events. Names are additive: existing events stay untouched.
class AgentAnalytics {
  AgentAnalytics._();

  static void configCopied({required String client}) {
    unawaited(PostHogService.instance.capture(
      'agent_connect_config_copied',
      {'client': client},
    ));
  }

  static void keyCreated() {
    unawaited(PostHogService.instance.capture('agent_key_created', const {}));
  }

  static void keyRevoked() {
    unawaited(PostHogService.instance.capture('agent_key_revoked', const {}));
  }

  /// Task prompt actions only, never the prompt/endpoint content itself.
  static void promptCopied({required String id}) {
    unawaited(PostHogService.instance
        .capture('agent_prompt_copied', {'task': id}));
  }

  static void promptShared({required String id}) {
    unawaited(PostHogService.instance
        .capture('agent_prompt_shared', {'task': id}));
  }

  static void handoffOpened() {
    unawaited(PostHogService.instance
        .capture('api_detail_agent_handoff', const {}));
  }
}
