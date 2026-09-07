import 'package:flutter/material.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

/// Selectable plan tile: square radio, title/subtitle, mono price, optional
/// savings badge. Whole tile is the tap target.
class PlanOptionTile extends StatelessWidget {
  const PlanOptionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.badge,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final String? badge;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: '$title, $price',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: enabled ? 1 : 0.55,
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border.all(
                  color: selected ? c.primary : c.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: selected ? c.primary : Colors.transparent,
                      border: Border.all(
                        color:
                            selected ? c.primary : c.onSurfaceVariant,
                        width: 1,
                      ),
                    ),
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
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (badge != null) ...[
                              const SizedBox(width: AppSpacing.s8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s6,
                                  vertical: AppSpacing.s2,
                                ),
                                color: c.surfaceContainerLow,
                                child: Text(
                                  badge!,
                                  style: AppTextStyles.labelSm,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: c.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Text(
                    price,
                    style: AppTextStyles.withTabular(
                      AppTextStyles.codeMd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
