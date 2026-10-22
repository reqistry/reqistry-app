import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/services/analytics/agent_analytics.dart';
import 'package:api_scout/app/services/share/share_plus/share_plus.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// One copy-ready prompt for a connected coding agent. Collapsed by default;
/// expanding reveals the selectable prompt plus copy and share actions.
class AgentTaskCard extends StatefulWidget {
  const AgentTaskCard({
    required this.taskId,
    required this.title,
    required this.prompt,
    super.key,
  });

  /// Stable id for analytics; never the prompt content itself.
  final String taskId;
  final String title;
  final String prompt;

  @override
  State<AgentTaskCard> createState() => _AgentTaskCardState();
}

class _AgentTaskCardState extends State<AgentTaskCard> {
  bool _expanded = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.prompt));
    AgentAnalytics.promptCopied(id: widget.taskId);
    if (!mounted) return;
    AppSnackBarHelper.show(
      title: AppLocalizations.of(context)!.agentPromptCopied,
      message: widget.title,
    );
  }

  Future<void> _share() async {
    AgentAnalytics.promptShared(id: widget.taskId);
    await ShareService.instance.shareText(widget.prompt);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.outlineVariant),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: c.onSurface),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? PhosphorIconsRegular.caretDown
                        : PhosphorIconsRegular.caretRight,
                    size: 18,
                    color: c.onSurfaceVariant,
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 150),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                // Keep the collapsed size stable.
                firstChild: const SizedBox(height: AppSpacing.s2),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.s8),
                    SelectableText(
                      widget.prompt,
                      style: AppTextStyles.bodySm.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    _iconButton(
                      tooltip: MaterialLocalizations.of(context)
                          .copyButtonLabel,
                      icon: PhosphorIconsRegular.copy,
                      onTap: _copy,
                    ),
                    _iconButton(
                      tooltip: AppLocalizations.of(context)!.actionShare,
                      icon: PhosphorIconsRegular.shareNetwork,
                      onTap: _share,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required String tooltip,
    required PhosphorIconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
    );
  }
}
