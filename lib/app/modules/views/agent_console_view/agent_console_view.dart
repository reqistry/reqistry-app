import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/agent_client_config.dart';
import 'package:api_scout/app/modules/views/agent_console_view/widgets/agent_task_card.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/agent_keys_section.dart';
import 'package:api_scout/app/services/analytics/agent_analytics.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Agent Console: try a real task first, then wire a client, then keys.
class AgentConsoleView extends StatefulWidget {
  const AgentConsoleView({super.key, this.configFuture, this.apiSlug});

  /// Injectable for tests; defaults to the live server config request.
  final Future<AgentClientConfig>? configFuture;

  /// Optional API slug carried over from detail, personalizing a task prompt.
  final String? apiSlug;

  @override
  State<AgentConsoleView> createState() => _AgentConsoleViewState();
}

class _AgentConsoleViewState extends State<AgentConsoleView> {
  late final Future<AgentClientConfig> _config;
  String _clientId = 'claude_code';

  @override
  void initState() {
    super.initState();
    _config = widget.configFuture ?? RemoteService.getAgentClientConfig();
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
    final apiSlug = (widget.apiSlug == null || widget.apiSlug!.isEmpty)
        ? null
        : widget.apiSlug;
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
          // Tasks first: value before configuration.
          Text(l10n.agentTasksTitle, style: AppTextStyles.headlineLg),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.agentTasksSubtitle,
            style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.s16),
          AgentTaskCard(
            taskId: 'find',
            title: l10n.agentTaskFindTitle,
            prompt: l10n.agentTaskFindPrompt,
          ),
          const SizedBox(height: AppSpacing.s12),
          AgentTaskCard(
            taskId: 'compare',
            title: l10n.agentTaskCompareTitle,
            prompt: l10n.agentTaskComparePrompt,
          ),
          const SizedBox(height: AppSpacing.s12),
          AgentTaskCard(
            taskId: 'replace',
            title: l10n.agentTaskReplaceTitle,
            prompt: l10n.agentTaskReplacePrompt,
          ),
          if (apiSlug != null) ...[
            const SizedBox(height: AppSpacing.s12),
            AgentTaskCard(
              taskId: 'evaluate',
              title: l10n.agentTaskEvaluateTitle(apiSlug),
              prompt: l10n.agentTaskEvaluatePrompt(apiSlug),
            ),
          ],
          const SizedBox(height: AppSpacing.s32),
          Text(
            l10n.agentConnectTitle,
            style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
          ),
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
              final snippets = agentConfigSnippets(config);
              final selected = snippets.firstWhere(
                (s) => s.id == _clientId,
                orElse: () => snippets.first,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (config.isFallback)
                    Container(
                      key: const ValueKey('agent_config_fallback_notice'),
                      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: c.surface,
                        border: Border.all(color: c.outlineVariant),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(PhosphorIconsRegular.warningCircle,
                              size: 18, color: c.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              l10n.agentConfigFallbackNotice,
                              style: AppTextStyles.bodySm
                                  .copyWith(color: c.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  Text(
                    l10n.agentSetupClientLabel,
                    style: AppTextStyles.labelSmUpper
                        .copyWith(color: c.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      for (final snippet in snippets)
                        _clientChip(
                          c: c,
                          id: snippet.id,
                          label: snippet.client,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  _snippet(c: c, snippet: selected),
                  const SizedBox(height: AppSpacing.s16),
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
          // Keys stay collapsed: a key is for after the first task, and the
          // section is only created — and only fetches — once expanded.
          _KeysSection(
            c: c,
            title: l10n.agentKeysTitle,
            subtitle: l10n.agentKeysAdvancedHint,
            footer: l10n.agentKeysDeviceNotice,
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

  Widget _clientChip({
    required AppColorScheme c,
    required String id,
    required String label,
  }) {
    final selected = id == _clientId;
    return InkWell(
      onTap: () => setState(() => _clientId = id),
      child: Container(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: selected ? c.primary : c.outlineVariant),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySm.copyWith(color: c.onSurface),
        ),
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

/// Collapsible advanced section. [childBuilder] runs only once expanded, so
/// the authed key fetch inside it cannot fire while the section is collapsed.
class _KeysSection extends StatefulWidget {
  const _KeysSection({
    required this.c,
    required this.title,
    required this.subtitle,
    required this.footer,
  });

  final AppColorScheme c;
  final String title;
  final String subtitle;
  final String footer;

  @override
  State<_KeysSection> createState() => _KeysSectionState();
}

class _KeysSectionState extends State<_KeysSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.labelSmUpper
                            .copyWith(color: c.onSurface),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.bodySm
                            .copyWith(color: c.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? PhosphorIconsRegular.caretDown
                      : (rtl
                          ? PhosphorIconsRegular.caretLeft
                          : PhosphorIconsRegular.caretRight),
                  size: 18,
                  color: c.onSurfaceVariant,
                ),
              ],
            ),
            // Build the authed key list only when expanded.
            if (_expanded) ...[
              const SizedBox(height: AppSpacing.s8),
              const AgentKeysSection(showTitle: false),
              const SizedBox(height: AppSpacing.s8),
              Text(
                widget.footer,
                style: AppTextStyles.bodySm
                    .copyWith(color: c.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
