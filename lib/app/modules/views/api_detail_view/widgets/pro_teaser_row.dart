import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/blocs/paywall/paywall_cubit.dart';
import 'package:api_scout/app/blocs/paywall/paywall_state.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/ship_check_sheet.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Inline Pro teaser. Pro users open the ship-check report for this API;
/// everyone else lands on the paywall. Never blocks surrounding features.
class ProTeaserRow extends StatelessWidget {
  const ProTeaserRow({super.key, required this.apiId, required this.slug});

  final String apiId;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaywallCubit, PaywallState>(
      builder: (context, state) {
        final c = AppColors.of(Theme.of(context).brightness);
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
          ),
          child: Semantics(
            button: true,
            label: '${l10n.badgePro}: ${l10n.proTeaserTitle}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (state.isPro) {
                    ShipCheckSheet.show(
                      context,
                      apiId.trim().isNotEmpty ? apiId.trim() : slug,
                    );
                  } else {
                    context.push(AppRoutes.pro);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border.all(color: c.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.crown,
                        size: 20,
                        color: c.onSurface,
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.proTeaserTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s6,
                                    vertical: AppSpacing.s2,
                                  ),
                                  color: c.surfaceContainerLow,
                                  child: Text(
                                    l10n.stateComingSoon,
                                    style: AppTextStyles.labelSm,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              l10n.proTeaserBody,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySm.copyWith(
                                color: c.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Icon(
                        PhosphorIconsRegular.caretRight,
                        size: 18,
                        color: c.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
