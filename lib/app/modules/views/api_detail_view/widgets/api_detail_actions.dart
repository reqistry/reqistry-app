import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_showcase.dart';
import 'package:api_scout/app/modules/views/main_shell_view/widgets/root_showcase.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ApiDetailActions extends StatelessWidget {
  const ApiDetailActions({
    super.key,
    required this.projectLabel,
    required this.destinationLabel,
    required this.onAddToProject,
    required this.onOpenDestination,
  });

  final String projectLabel;
  final String destinationLabel;
  final VoidCallback onAddToProject;
  final VoidCallback? onOpenDestination;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Material(
      color: c.surface,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s12,
            AppSpacing.s10,
            AppSpacing.s12,
            AppSpacing.s10,
          ),
          decoration:  BoxDecoration(
            border: Border(top: BorderSide(color: c.surfaceVariant)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 360;
              final destinationButton = SizedBox(
                height: 52,
                width: narrow ? double.infinity : null,
                child: OutlinedButton.icon(
                  onPressed: onOpenDestination,
                  icon: const Icon(
                    PhosphorIconsRegular.arrowSquareOut,
                    size: 20,
                  ),
                  label: Text(
                    destinationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
              final projectButton = SizedBox(
                height: 52,
                width: narrow ? double.infinity : null,
                child: RootShowcase.scope(
                  context: context,
                  showcaseKey: ApiDetailShowcase.addToProjectKey,
                  title: AppLocalizations.of(context)!
                      .onboardingSaveProjectTitle,
                  description: AppLocalizations.of(context)!
                      .onboardingSaveProjectDesc,
                  child: ElevatedButton.icon(
                    onPressed: onAddToProject,
                    icon: const Icon(PhosphorIconsRegular.folderPlus,
                        size: 20),
                    label: Text(
                      projectLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
              if (narrow) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    destinationButton,
                    const SizedBox(height: AppSpacing.s8),
                    projectButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: projectButton),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(child: destinationButton),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
