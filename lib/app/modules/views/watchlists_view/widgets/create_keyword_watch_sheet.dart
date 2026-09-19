import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/services/fetch_api/failure.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class CreateKeywordWatchSheet extends StatefulWidget {
  const CreateKeywordWatchSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateKeywordWatchSheet(),
    );
  }

  @override
  State<CreateKeywordWatchSheet> createState() =>
      _CreateKeywordWatchSheetState();
}

class _CreateKeywordWatchSheetState extends State<CreateKeywordWatchSheet> {
  static const _maxWatches = 10;

  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final keyword = _controller.text.trim();
    if (keyword.length < 2 || _busy) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final watches = await RemoteService.getWatchlists(l10n: l10n);
      final duplicate = watches.any(
        (watch) =>
            watch.kind == 'keyword' &&
            watch.value.trim().toLowerCase() == keyword.toLowerCase(),
      );
      if (duplicate) {
        setState(() => _error = l10n.watchAlreadyExists);
        return;
      }
      if (watches.length >= _maxWatches) {
        setState(() => _error = l10n.watchLimitReached);
        return;
      }

      await RemoteService.addWatch(
        kind: 'keyword',
        value: keyword,
        l10n: l10n,
      );
      if (mounted) Navigator.of(context).pop(keyword);
    } on Failure catch (failure) {
      if (!mounted) return;
      final message = failure.content.toLowerCase();
      setState(() {
        _error = message.contains('already watching')
            ? l10n.watchAlreadyExists
            : message.contains('limit reached')
                ? l10n.watchLimitReached
                : l10n.stateSomethingWentWrong;
      });
    } catch (_) {
      if (mounted) setState(() => _error = l10n.stateSomethingWentWrong);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final canSubmit = _controller.text.trim().length >= 2 && !_busy;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: c.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: Container(
                    width: 40,
                    height: 4,
                    color: c.outlineVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.bellRinging,
                      size: 22,
                      color: c.primary,
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: Text(
                        l10n.watchCreateTitle,
                        style: AppTextStyles.headlineSm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  l10n.watchCreateDescription,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: l10n.watchKeywordHint,
                    prefixIcon:
                        const Icon(PhosphorIconsRegular.magnifyingGlass),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: canSubmit ? _submit : null,
                    icon: _busy
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: c.onPrimary,
                            ),
                          )
                        : const Icon(PhosphorIconsRegular.plus, size: 18),
                    label: Text(l10n.watchCreateAction),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
