import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
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
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onAddToProject,
                    icon: const Icon(PhosphorIconsRegular.folderPlus, size: 20),
                    label: Text(
                      projectLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: SizedBox(
                  height: 52,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
