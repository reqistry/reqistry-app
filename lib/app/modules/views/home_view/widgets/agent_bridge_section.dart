import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Home section surfacing the agent journey: supported clients followed by
/// a direct route into the Agent Console.
class AgentBridgeSection extends StatelessWidget {
  const AgentBridgeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.agentBridgeTitle,
              style: AppTextStyles.headlineSm.copyWith(color: c.onSurface),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.agentBridgeSubtitle,
              style: AppTextStyles.bodySm.copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.agentConsole),
                icon: const Icon(
                  PhosphorIconsRegular.sparkle,
                  size: 20,
                ),
                label: Text(l10n.agentBridgeCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
