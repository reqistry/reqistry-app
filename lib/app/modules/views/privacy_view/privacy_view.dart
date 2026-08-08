import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:api_scout/app/blocs/privacy/privacy_cubit.dart';
import 'package:api_scout/app/modules/views/general/loading/loading_widget.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.settingsPrivacyPolicy,
          style: AppTextStyles.labelSmUpper.copyWith(
            color: c.onSurface,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: c.surfaceVariant),
          ),
        ),
      ),
      body: BlocBuilder<PrivacyCubit, PrivacyState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const LoadingWidget(isSliverChild: false);
          }

          if (state.content.isNotEmpty) {
            return Markdown(
              data: state.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                textScaler: TextScaler.linear(1.25),
              ),
            );
          }

          if (state.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.warningCircle,
                    size: 48,
                    color: c.danger,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    AppLocalizations.of(context)!.settingsSomethingWentWrong,
                    style: AppTextStyles.labelSmUpper.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  FilledButton(
                    onPressed: () {
                      context.read<PrivacyCubit>().loadPrivacyContent(l10n: AppLocalizations.of(context)!);
                    },
                    child: Text(AppLocalizations.of(context)!.actionRetry),
                  ),
                ],
              ),
            );
          }

          return const LoadingWidget(isSliverChild: false);
        },
      ),
    );
  }
}
