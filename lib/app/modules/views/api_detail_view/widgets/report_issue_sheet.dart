import 'package:flutter/material.dart';
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
  static const _reasons = [
    'API is unavailable',
    'Link is broken',
    'Pricing is incorrect',
    'Authentication is incorrect',
    'Description is incorrect',
    'API is discontinued',
    'Other',
  ];

  final _noteController = TextEditingController();
  String _selected = _reasons.first;
  bool _submitting = false;

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
            Text('WHAT IS INCORRECT?', style: AppTextStyles.labelSmUpper),
            const SizedBox(height: AppSpacing.s8),
            const NoticeBanner('Reports are sent to Reqistry for review.'),
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
              decoration: const InputDecoration(
                labelText: 'Optional note',
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: const Text('Submit report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
