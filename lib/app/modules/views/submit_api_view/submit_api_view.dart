import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_cubit.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_state.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/modules/views/account_settings_view/widgets/link_email_dialog.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/submit_api_view/widgets/tip_card.dart';

class SubmitApiView extends StatefulWidget {
  const SubmitApiView({super.key});

  @override
  State<SubmitApiView> createState() => _SubmitApiViewState();
}

class _SubmitApiViewState extends State<SubmitApiView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  /// Submitters can't be notified without an identity — offer email-link once.
  Future<void> _maybePromptEmailLink() async {
    if (!mounted) return;
    final authCubit = context.read<AuthCubit>();
    if (!authCubit.isGuestUser) return;
    await LinkEmailDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return BlocListener<SubmitApiCubit, SubmitApiState>(
      listenWhen: (prev, curr) => curr.submitted,
      listener: (context, state) {
        Navigator.of(context).pop();
        _maybePromptEmailLink();
      },
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.tabSubmitApi, style: AppTextStyles.headlineSm),
          backgroundColor: c.surface,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: c.surfaceVariant),
            ),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
              child: Column(
                children: [
                  const TipCard(),
                  const SizedBox(height: AppSpacing.itemGap),
                  _buildTextField(
                    controller: _nameController,
                    label: AppLocalizations.of(context)!.formApiName,
                    validator: _validateName,
                  ),
                  const SizedBox(height: AppSpacing.itemGap),
                  _buildTextField(
                    controller: _linkController,
                    label: AppLocalizations.of(context)!.formApiLink,
                    keyboardType: TextInputType.url,
                    validator: _validateRequiredUrl,
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  BlocBuilder<SubmitApiCubit, SubmitApiState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              state.isSubmitting ? null : () => _submit(context),
                          style: FilledButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s16,
                            ),
                          ),
                          child: state.isSubmitting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: c.onPrimary,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.actionSubmit,
                                  style: AppTextStyles.labelSmUpper.copyWith(
                                    color: c.onPrimary,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await context.read<SubmitApiCubit>().submit(
          name: _nameController.text.trim(),
          link: _linkController.text.trim(),
          l10n: AppLocalizations.of(context)!,
        );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.formFieldRequired;
    }
    if (value.trim().length < 3) {
      return AppLocalizations.of(context)!.formNameTooShort;
    }
    return null;
  }

  String? _validateRequiredUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.formFieldRequired;
    }
    final parsed = Uri.tryParse(value.trim());
    final isValid = parsed != null && parsed.hasScheme && parsed.hasAuthority;
    if (!isValid ||
        !(parsed.scheme.toLowerCase() == 'https' ||
            parsed.scheme.toLowerCase() == 'http')) {
      return AppLocalizations.of(context)!.formInvalidUrl;
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMd,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelSmUpper,
        floatingLabelStyle: AppTextStyles.labelSmUpper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
      ),
      validator: validator,
    );
  }
}
