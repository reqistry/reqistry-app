import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/utils/text_input_route.dart';
import 'package:api_scout/shared/widgets/submit/submit_api_form.dart';
import 'package:api_scout/shared/widgets/ui/bottom_sheet_scaffold.dart';

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
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final link = _linkController.text.trim();

    setState(() => _isLoading = true);
    try {
      await RemoteService.submitApi(name: name, link: link, l10n: AppLocalizations.of(context)!);
      if (!mounted) return;
      dismissTextInputRoute(context);
      AppSnackBarHelper.success(
        title: AppLocalizations.of(context)!.snackbarSubmittedTitle,
        message: AppLocalizations.of(context)!.snackbarSubmittedMessage(name),
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
      AppSnackBarHelper.error(
        title: AppLocalizations.of(context)!.snackbarSubmissionFailedTitle,
        message: AppLocalizations.of(context)!.snackbarSubmissionFailedMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetScaffold(
      title: AppLocalizations.of(context)!.dialogSubmitAnApiTitle,
      submitLabel: AppLocalizations.of(context)!.actionSubmit,
      isSubmitLoading: _isLoading,
      onSubmit: _submit,
      content: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubmitApiFields(
                nameController: _nameController,
                linkController: _linkController,
                autofocusName: true,
                useHints: true,
                fieldGap: AppSpacing.s12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
