import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_cached_image.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';

class ApiAlternativesSection extends StatelessWidget {
  const ApiAlternativesSection({
    super.key,
    required this.alternatives,
    required this.isLoading,
    required this.onOpen,
    required this.onSave,
    this.error,
  });

  final List<ApiAlternative> alternatives;
  final bool isLoading;
  final ValueChanged<ApiAlternative> onOpen;
  final ValueChanged<ApiAlternative> onSave;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && alternatives.isEmpty && error == null) {
      return const SizedBox.shrink();
    }
    final c = AppColors.of(Theme.of(context).brightness);
    return DetailSection(
      title: 'SIMILAR APIs',
      child: Column(
        children: [
          if (isLoading && alternatives.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (error != null && alternatives.isEmpty)
            Text(error!, style: AppTextStyles.bodyMd)
          else
            for (final alternative in alternatives)
              Material(
                color: c.surface,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 72,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: c.surfaceVariant),
                    ),
                    child: ClipRect(
                      child: AppCachedImage(
                        imageUrl: alternative.imageUrl,
                        fallback: CategoryImagePlaceholder(
                          name: alternative.name,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    alternative.name,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${alternative.pricing} · ${alternative.authentication}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    onPressed: () => onSave(alternative),
                    tooltip: 'Save ${alternative.name}',
                    constraints:
                        const BoxConstraints.tightFor(width: 48, height: 48),
                    icon: const Icon(PhosphorIconsRegular.bookmarkSimple),
                  ),
                  onTap: () => onOpen(alternative),
                ),
              ),
        ],
      ),
    );
  }
}
