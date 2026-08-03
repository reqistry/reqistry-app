import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_cubit.dart';
import 'package:api_scout/app/blocs/submit_api/submit_api_state.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmitApiCubit, SubmitApiState>(
      listenWhen: (prev, curr) => curr.submitted,
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
        title: Text('SUBMIT API', style: AppTextStyles.headlineSm),
        backgroundColor: AppColors.surface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: AppColors.surfaceVariant),
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
                const _TipCard(),
                const SizedBox(height: AppSpacing.itemGap),
                _buildTextField(
                  controller: _nameController,
                  label: 'API NAME',
                  validator: _validateName,
                ),
                const SizedBox(height: AppSpacing.itemGap),
                _buildTextField(
                  controller: _linkController,
                  label: 'API LINK (HTTPS://...)',
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
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : Text(
                                'SUBMIT',
                                style: AppTextStyles.labelSmUpper.copyWith(
                                  color: AppColors.onPrimary,
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
        );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateRequiredUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final parsed = Uri.tryParse(value.trim());
    final isValid = parsed != null && parsed.hasScheme && parsed.hasAuthority;
    if (!isValid ||
        !(parsed.scheme.toLowerCase() == 'https' ||
            parsed.scheme.toLowerCase() == 'http')) {
      return 'Enter a valid http(s) URL';
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.danger, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
      ),
      validator: validator,
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.outline),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            PhosphorIconsRegular.info,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Text(
              'Submit an API for review. Provide the API name and URL.',
              style: AppTextStyles.bodyMd,
            ),
          ),
        ],
      ),
    );
  }
}
