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
}
