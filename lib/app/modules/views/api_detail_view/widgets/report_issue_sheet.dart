import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/notice_banner.dart';

class ReportIssueSheet extends StatefulWidget {
  const ReportIssueSheet({super.key, required this.onSubmit});

  final Future<bool> Function(String reason, String note) onSubmit;

  @override
  State<ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<ReportIssueSheet> {
  final _noteController = TextEditingController();
  late String _selected;
  bool _submitting = false;
  late List<String> _reasons;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _reasons = [
      l10n.reportApiUnavailable,
      l10n.reportLinkBroken,
      l10n.reportPricingIncorrect,
      l10n.reportAuthenticationIncorrect,
      l10n.reportDescriptionIncorrect,
      l10n.reportApiDiscontinued,
      l10n.reportOther,
    ];
    _selected = _reasons.first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final note = _noteController.text.trim();
    final saved =
        await widget.onSubmit(_selected, note.isEmpty ? '' : note);
    if (!mounted) return;
    Navigator.of(context).pop(saved);
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
              groupValue: _selected,
              onChanged: (value) => setState(() => _selected = value!),
              child: Column(
                children: [
                  for (final reason in _reasons)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reason),
                      value: reason,
                    ),
                ],
              ),
            ),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.formOptionalNote,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(l10n.actionSubmitReport),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
