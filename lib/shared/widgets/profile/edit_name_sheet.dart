import 'package:flutter/material.dart';

import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/utils/text_input_route.dart';

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
        title: 'Name required',
        message: 'Enter a name to update your profile.',
      );
      return;
    }
    if (name.length > 100) {
      AppSnackBarHelper.error(
        title: 'Name too long',
        message: 'Use 100 characters or less.',
      );
      return;
    }
    dismissTextInputRoute(context);
    widget.onSave(name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.primary, width: 1),
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
              decoration: const InputDecoration(
                hintText: 'Your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.surfaceVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => dismissTextInputRoute(context),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: AppSpacing.s8),
                FilledButton(
                  onPressed: _save,
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
