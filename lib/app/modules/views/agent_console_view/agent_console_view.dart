import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/agent_client_config.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/agent_keys_section.dart';
import 'package:api_scout/app/services/analytics/agent_analytics.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Agent Console: wire an MCP client to Reqistry, manage keys, verify it works.
class AgentConsoleView extends StatefulWidget {
  const AgentConsoleView({super.key});

  @override
  State<AgentConsoleView> createState() => _AgentConsoleViewState();
}

class _AgentConsoleViewState extends State<AgentConsoleView> {
  late final Future<AgentClientConfig> _config;

  @override
  void initState() {
    super.initState();
    _config = RemoteService.getAgentClientConfig();
  }

  Future<void> _copy(String value, String label, String client) async {
    await Clipboard.setData(ClipboardData(text: value));
    AgentAnalytics.configCopied(client: client);
    if (!mounted) return;
    AppSnackBarHelper.show(
      title: AppLocalizations.of(context)!.agentConfigCopied,
      message: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.agentConsoleTitle, style: AppTextStyles.headlineSm),
        centerTitle: false,
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: SizedBox(height: 1, child: ColoredBox(color: c.surfaceVariant)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16, AppSpacing.s24, AppSpacing.s16, AppSpacing.s32),
        children: [
          Text(l10n.agentConnectTitle, style: AppTextStyles.headlineLg),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.agentConnectSubtitle,
            style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.s16),
          FutureBuilder<AgentClientConfig>(
            future: _config,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLoading(message: l10n.stateLoading, compact: true);
              }
              // The service already falls back, so this is belt and braces.
              final config = snapshot.data ?? AgentClientConfig.fallback;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _valueRow(
                    c: c,
                    label: l10n.agentEndpointLabel,
                    value: config.mcpUrl,
                    client: 'endpoint',
                  ),
                  _valueRow(
                    c: c,
                    label: l10n.agentTransportLabel,
                    value: config.transport,
                    client: 'transport',
                  ),
                  if (config.agentKeyOptional)
                    _valueRow(
                      c: c,
                      label: l10n.agentKeyHeaderLabel,
                      value: config.agentKeyHeader,
                      client: 'key_header',
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  for (final snippet in agentConfigSnippets(config)) ...[
                    _snippet(c: c, snippet: snippet),
                    const SizedBox(height: AppSpacing.s16),
                  ],
                  Text(
                    l10n.agentRestartHint,
                    style: AppTextStyles.bodySm.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.s32),
          const AgentKeysSection(),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.agentKeysDeviceNotice,
            style: AppTextStyles.bodySm.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.s32),
          Text(
            l10n.agentVerifyTitle,
            style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
          ),
          const SizedBox(height: AppSpacing.s8),
          _checkLine(c: c, text: l10n.agentVerifyAsk),
          const SizedBox(height: AppSpacing.s4),
          _checkLine(c: c, text: l10n.agentVerifyExpect),
        ],
      ),
    );
  }

  Widget _valueRow({
    required AppColorScheme c,
    required String label,
    required String value,
    required String client,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmUpper
                      .copyWith(color: c.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.s2),
                SelectableText(value, style: AppTextStyles.codeMd),
              ],
            ),
          ),
          _copyButton(
            onTap: () => _copy(value, label, client),
            tooltip: label,
          ),
        ],
      ),
    );
  }

  Widget _snippet({
    required AppColorScheme c,
    required AgentConfigSnippet snippet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    snippet.client,
                    style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
                  ),
                  if (snippet.path != null)
                    Text(
                      snippet.path!,
                      style: AppTextStyles.codeMd.copyWith(
                        fontSize: 12,
                        color: c.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            _copyButton(
              onTap: () => _copy(snippet.code, snippet.client, snippet.id),
              tooltip:
                  '${MaterialLocalizations.of(context).copyButtonLabel} — ${snippet.client}',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s12),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.outlineVariant),
          ),
          child: SelectableText(snippet.code, style: AppTextStyles.codeMd),
        ),
      ],
    );
  }

  Widget _checkLine({required AppColorScheme c, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(PhosphorIconsRegular.checkCircle, size: 18, color: c.primary),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _copyButton({required VoidCallback onTap, required String tooltip}) {
    return IconButton(
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      onPressed: onTap,
      icon: const Icon(PhosphorIconsRegular.copy, size: 18),
    );
  }
}
