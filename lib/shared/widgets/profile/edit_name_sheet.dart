import 'package:flutter/material.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/utils/text_input_route.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class EditNameSheet extends StatefulWidget {
  const EditNameSheet({
    super.key,
    required this.title,
    required this.initialName,
    required this.onSave,
  });

  final String title;
  final String initialName;
  final ValueChanged<String> onSave;

  @override
  State<EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends State<EditNameSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      AppSnackBarHelper.error(
        title: AppLocalizations.of(context)!.snackbarNameRequiredTitle,
        message: AppLocalizations.of(context)!.snackbarNameRequiredMessage,
      );
      return;
    }
    if (name.length > 100) {
      AppSnackBarHelper.error(
        title: AppLocalizations.of(context)!.snackbarNameTooLongTitle,
        message: AppLocalizations.of(context)!.snackbarNameTooLongMessage,
      );
      return;
    }
    dismissTextInputRoute(context);
    widget.onSave(name);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(
            top: BorderSide(color: c.primary, width: 1),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTextStyles.labelSmUpper),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.bodyMd,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.formYourName),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => dismissTextInputRoute(context),
                  child: Text(AppLocalizations.of(context)!.actionCancel),
                ),
                const SizedBox(width: AppSpacing.s8),
                FilledButton(
                  onPressed: _save,
                  child: Text(AppLocalizations.of(context)!.actionSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
