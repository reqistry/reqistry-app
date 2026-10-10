import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/notice_banner.dart';
import 'package:api_scout/app/data/models/api_report_result.dart';

class ReportIssueSheet extends StatefulWidget {
  const ReportIssueSheet({super.key, required this.onSubmit});

  final Future<ApiReportResult?> Function(String reason, String note) onSubmit;

  @override
  State<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<ReportIssueSheet> {
  final _noteController = TextEditingController();
  String _selectedCode = 'API_UNAVAILABLE';
  bool _submitting = false;
  String? _error;

  static const _codes = [
    'API_UNAVAILABLE',
    'LINK_BROKEN',
    'PRICING_INCORRECT',
    'AUTHENTICATION_INCORRECT',
    'DESCRIPTION_INCORRECT',
    'DISCONTINUED',
    'OTHER',
  ];

  String _labelFor(String code, AppLocalizations l10n) {
    return switch (code) {
      'API_UNAVAILABLE' => l10n.reportApiUnavailable,
      'LINK_BROKEN' => l10n.reportLinkBroken,
      'PRICING_INCORRECT' => l10n.reportPricingIncorrect,
      'AUTHENTICATION_INCORRECT' => l10n.reportAuthenticationIncorrect,
      'DESCRIPTION_INCORRECT' => l10n.reportDescriptionIncorrect,
      'DISCONTINUED' => l10n.reportApiDiscontinued,
      _ => l10n.reportOther,
    };
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final note = _noteController.text.trim();
    final result =
        await widget.onSubmit(_selectedCode, note.isEmpty ? '' : note);
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(result);
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _submitting = false;
      _error = l10n.snackbarRequestFailedMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        0,
        AppSpacing.s16,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.s16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.formWhatIsIncorrect, style: AppTextStyles.labelSmUpper),
            const SizedBox(height: AppSpacing.s8),
            NoticeBanner(l10n.formReportNoticeBanner),
            RadioGroup<String>(
              groupValue: _selectedCode,
              onChanged: (value) => setState(() => _selectedCode = value!),
              child: Column(
                children: [
                  for (final code in _codes)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_labelFor(code, l10n)),
                      value: code,
                    ),
                ],
              ),
            ),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              maxLength: 2000,
              decoration: InputDecoration(
                labelText: l10n.formOptionalNote,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? Semantics(
                        liveRegion: true,
                        label: l10n.stateLoading,
                        child: const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Text(l10n.actionSubmitReport),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
