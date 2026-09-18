import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/text_input_route.dart';
import 'package:api_scout/shared/widgets/ui/bottom_sheet_scaffold.dart';

class CreateProjectBottomSheet extends StatefulWidget {
  const CreateProjectBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateProjectBottomSheet(),
    );
  }

  @override
  State<CreateProjectBottomSheet> createState() =>
      _CreateProjectBottomSheetState();
}

class _CreateProjectBottomSheetState extends State<CreateProjectBottomSheet> {
  final _titleController = TextEditingController();
  IconData _selectedIcon = PhosphorIconsRegular.folder;
  bool _submitted = false;
  bool _saving = false;

  static const _projectIconChoices = [
    PhosphorIconsRegular.folder,
    PhosphorIconsRegular.star,
    PhosphorIconsRegular.code,
    PhosphorIconsRegular.cloud,
    PhosphorIconsRegular.lock,
    PhosphorIconsRegular.database,
    PhosphorIconsRegular.globeHemisphereWest,
    PhosphorIconsRegular.envelope,
    PhosphorIconsRegular.chatCircleText,
    PhosphorIconsRegular.camera,
    PhosphorIconsRegular.musicNote,
    PhosphorIconsRegular.videoCamera,
    PhosphorIconsRegular.shoppingCart,
    PhosphorIconsRegular.creditCard,
    PhosphorIconsRegular.bank,
    PhosphorIconsRegular.truck,
    PhosphorIconsRegular.forkKnife,
    PhosphorIconsRegular.gameController,
    PhosphorIconsRegular.airplaneTilt,
    PhosphorIconsRegular.bed,
    PhosphorIconsRegular.wrench,
    PhosphorIconsRegular.graduationCap,
    PhosphorIconsRegular.hospital,
    PhosphorIconsRegular.pawPrint,
    PhosphorIconsRegular.treeEvergreen,
    PhosphorIconsRegular.sun,
    PhosphorIconsRegular.robot,
    PhosphorIconsRegular.currencyBtc,
    PhosphorIconsRegular.chartBar,
    PhosphorIconsRegular.bell,
  ];

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _submitted = true);
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);
    final saved = await context.read<ProjectsCubit>().createProject(
          title,
          icon: _selectedIcon,
          l10n: AppLocalizations.of(context)!,
        );
    if (!mounted) return;
    if (saved) {
      dismissTextInputRoute(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return BottomSheetScaffold(
      title: AppLocalizations.of(context)!.dialogCreateProjectTitle,
      submitLabel: AppLocalizations.of(context)!.actionCreate,
      onSubmit: _submit,
      isSubmitLoading: _saving,
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.formTitle,
                labelStyle: AppTextStyles.labelSmUpper.copyWith(
                  color: _submitted && _titleController.text.isEmpty
                      ? c.danger
                      : c.onSurfaceVariant,
                ),
                errorText: _submitted && _titleController.text.isEmpty
                    ? AppLocalizations.of(context)!.formTitleRequired
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              AppLocalizations.of(context)!.formIcon,
              style: AppTextStyles.labelSmUpper
                  .copyWith(color: c.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              height: 240,
              child: GridView.builder(
                // Fewer columns on narrow phones so each icon cell keeps a
                // 48dp minimum touch target.
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.sizeOf(context).width < 380 ? 5 : 6,
                  mainAxisSpacing: AppSpacing.s8,
                  crossAxisSpacing: AppSpacing.s8,
                ),
                itemCount: _projectIconChoices.length,
                itemBuilder: (context, index) {
                  final icon = _projectIconChoices[index];
                  final isSelected = icon == _selectedIcon;

                  return Semantics(
                    button: true,
                    selected: isSelected,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? c.primary
                                : c.surfaceContainerLow,
                            border: Border.all(
                              color: isSelected
                                  ? c.primary
                                  : c.surfaceVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: 22,
                            color: isSelected ? c.onPrimary : c.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
