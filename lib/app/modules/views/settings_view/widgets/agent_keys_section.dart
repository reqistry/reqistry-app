import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/feature_models.dart';
import 'package:api_scout/app/services/analytics/agent_analytics.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Agent API keys. Manage keys inline (create, copy-once, usage, revoke).
class AgentKeysSection extends StatefulWidget {
  const AgentKeysSection({super.key});

  @override
  State<AgentKeysSection> createState() => _AgentKeysSectionState();
}

class _AgentKeysSectionState extends State<AgentKeysSection> {
  Future<List<AgentKeyItem>>? _future;

  @override
  void initState() {
    super.initState();
    _future = RemoteService.getAgentKeys();
  }

  void _reload() {
    setState(() {
      _future = RemoteService.getAgentKeys();
    });
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await AppDialog.showInput(
      context: context,
      title: l10n.agentKeyCreate,
      hintText: l10n.agentKeyNameHint,
      confirmLabel: l10n.actionCreate,
    );
    if (name == null || !mounted) return;
    try {
      final key = await RemoteService.createAgentKey(
        name: name.isEmpty ? null : name,
        l10n: l10n,
      );
      if (!mounted) return;
      AgentAnalytics.keyCreated();
      _reload();
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor:
              AppColors.of(Theme.of(context).brightness).surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text(l10n.agentKeyCreate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.agentKeyOnceWarning,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.of(Theme.of(context).brightness)
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              SelectableText(
                key.key ?? key.prefix,
                style: AppTextStyles.codeMd,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionDone),
            ),
            FilledButton(
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: key.key ?? key.prefix));
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                AppSnackBarHelper.show(
                  title: l10n.agentKeyCopied,
                  message: key.prefix,
                );
              },
              child: Text(MaterialLocalizations.of(context).copyButtonLabel),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.stateSomethingWentWrong,
        isError: true,
      );
    }
  }

  Future<void> _revoke(AgentKeyItem key) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: l10n.agentKeyRevokeTitle,
      message: l10n.agentKeyRevokeMessage,
      confirmLabel: l10n.actionDelete,
      cancelLabel: l10n.actionCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await RemoteService.revokeAgentKey(key.id);
      AgentAnalytics.keyRevoked();
      if (!mounted) return;
      _reload();
    } catch (_) {
      if (!mounted) return;
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.stateSomethingWentWrong,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.agentKeysTitle,
                    style: AppTextStyles.labelSmUpper
                        .copyWith(color: c.onSurface),
                  ),
                ),
                TextButton.icon(
                  onPressed: _create,
                  icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                  label: Text(l10n.agentKeyCreate),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s8),
            FutureBuilder<List<AgentKeyItem>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppLoading(
                    message: l10n.stateLoading,
                    compact: true,
                  );
                }
                if (snapshot.hasError) {
                  return AppErrorState(
                    title: l10n.stateError,
                    message: l10n.stateSomethingWentWrong,
                    onRetry: _reload,
                    compact: true,
                  );
                }
                final keys = snapshot.data ?? const <AgentKeyItem>[];
                if (keys.isEmpty) {
                  return Text(
                    l10n.agentKeysEmpty,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final key in keys)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                        padding:
                            const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: c.surface,
                          border: Border.all(color: c.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    key.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${key.prefix}…',
                                    style: AppTextStyles.codeMd.copyWith(
                                      fontSize: 12,
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    l10n.agentKeyUsageToday(
                                        key.usedToday),
                                    style: AppTextStyles.withTabular(
                                      AppTextStyles.bodySm.copyWith(
                                        color: c.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    key.lastUsedAt == null
                                        ? l10n.agentKeyNeverUsed
                                        : l10n.agentKeyLastUsed(
                                            formatKeyUsageWhen(
                                                key.lastUsedAt!)),
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.actionDelete,
                              constraints: const BoxConstraints.tightFor(
                                width: 48,
                                height: 48,
                              ),
                              onPressed: () => _revoke(key),
                              icon: const Icon(
                                PhosphorIconsRegular.trashSimple,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
      ],
    );
  }
}

/// Timestamp shown for a key's last agent call. Locale-neutral on purpose:
/// no date-format dependency for one line of diagnostics.
@visibleForTesting
String formatKeyUsageWhen(DateTime when) {
  final d = when.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}
