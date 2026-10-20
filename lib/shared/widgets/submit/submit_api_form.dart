import 'package:flutter/material.dart';

import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Shared submit-an-API form fields. Two entry points (the /submit-api screen and
/// the home sheet) render the same fields and validators; only their decoration
/// and submit orchestration differ.
class SubmitApiFields extends StatelessWidget {
  const SubmitApiFields({
    super.key,
    required this.nameController,
    required this.linkController,
    this.autofocusName = false,
    this.useHints = false,
    this.fieldGap = AppSpacing.itemGap,
  });

  final TextEditingController nameController;
  final TextEditingController linkController;
  final bool autofocusName;
  final bool useHints;
  final double fieldGap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _field(
          controller: nameController,
          label: l10n.formApiName,
          autofocus: autofocusName,
          validator: (value) => submitApiNameError(l10n, value),
        ),
        SizedBox(height: fieldGap),
        _field(
          controller: linkController,
          label: l10n.formApiLink,
          keyboardType: TextInputType.url,
          validator: (value) => submitApiLinkError(l10n, value),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool autofocus = false,
    String? Function(String?)? validator,
  }) {
    if (useHints) {
      return TextFormField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: label),
        validator: validator,
      );
    }
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
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

String? submitApiNameError(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) return l10n.formFieldRequired;
  if (value.trim().length < 3) return l10n.formNameTooShort;
  return null;
}

String? submitApiLinkError(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) return l10n.formFieldRequired;
  final parsed = Uri.tryParse(value.trim());
  final isValid = parsed != null && parsed.hasScheme && parsed.hasAuthority;
  if (!isValid ||
      !(parsed.scheme.toLowerCase() == 'https' ||
          parsed.scheme.toLowerCase() == 'http')) {
    return l10n.formInvalidUrl;
  }
  return null;
}
