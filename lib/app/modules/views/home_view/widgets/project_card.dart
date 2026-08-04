import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return GestureDetector(
      onTap: onTap ?? () => context.push(AppRoutes.projectApis, extra: project),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              IconData(
                // ignore: non_const_argument_for_const_parameter
                project.iconCodePoint,
                fontFamily: 'PhosphorRegular',
                fontPackage: 'phosphoricons_flutter',
              ),
              size: 28,
              color: c.primary,
            ),
            const Spacer(),
            Text(
              project.title,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: c.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              '${project.apiCount} ${project.apiCount == 1 ? 'API' : 'APIs'}',
              style: AppTextStyles.labelSmUpper.copyWith(
                color: c.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddProjectCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddProjectCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(
            color: c.surfaceVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: c.outlineVariant,
                  width: 2,
                ),
              ),
              child: Icon(
                PhosphorIconsRegular.plus,
                size: 24,
                color: c.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              'NEW',
              style: AppTextStyles.labelSmUpper.copyWith(
                color: c.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
