import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/utils/text_input_route.dart';
import 'package:api_scout/shared/widgets/ui/bottom_sheet_scaffold.dart';
import 'package:api_scout/shared/widgets/ui/app_input_decoration.dart';

class SubmitApiSheet extends StatefulWidget {
  const SubmitApiSheet({super.key});

  @override
  State<SubmitApiSheet> createState() => _SubmitApiSheetState();
}

class _SubmitApiSheetState extends State<SubmitApiSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final link = _linkController.text.trim();

    setState(() => _isLoading = true);
    try {
      await RemoteService.submitApi(name: name, link: link);
      if (!mounted) return;
      dismissTextInputRoute(context);
      AppSnackBarHelper.success(
        title: 'Submitted',
        message: 'Thanks! We\'ll review "$name" soon.',
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
      AppSnackBarHelper.error(
        title: 'Submission failed',
        message: 'Unable to submit right now. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return BottomSheetScaffold(
      title: 'SUBMIT AN API',
      submitLabel: 'SUBMIT',
      isSubmitLoading: _isLoading,
      onSubmit: _submit,
      content: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                style: AppTextStyles.bodyMd,
                decoration: AppInputDecoration.standard(
                  c: c,
                  hintText: 'API name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              TextFormField(
                controller: _linkController,
                style: AppTextStyles.bodyMd,
                keyboardType: TextInputType.url,
                decoration: AppInputDecoration.standard(
                  c: c,
                  hintText: 'API LINK (HTTPS://...)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  final parsed = Uri.tryParse(value.trim());
                  if (parsed == null ||
                      !parsed.hasScheme ||
                      !parsed.hasAuthority ||
                      !(parsed.scheme.toLowerCase() == 'https' ||
                          parsed.scheme.toLowerCase() == 'http')) {
                    return 'Enter a valid http(s) URL';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
