import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/feature_models.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class CategoryWatchButton extends StatefulWidget {
  final String category;

  const CategoryWatchButton({super.key, required this.category});

  @override
  State<CategoryWatchButton> createState() => _CategoryWatchButtonState();
}

class _CategoryWatchButtonState extends State<CategoryWatchButton> {
  WatchItem? _watch;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CategoryWatchButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) _load();
  }

  Future<void> _load() async {
    try {
      final watches = await RemoteService.getWatchlists();
      if (!mounted) return;
      final category = widget.category.trim().toLowerCase();
      WatchItem? match;
      for (final watch in watches) {
        if (watch.kind == 'category' &&
            watch.value.trim().toLowerCase() == category) {
          match = watch;
          break;
        }
      }
      setState(() {
        _watch = match;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle() async {
    if (_loading || widget.category.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final current = _watch;
      if (current == null) {
        final created = await RemoteService.addWatch(
          kind: 'category',
          value: widget.category,
          l10n: l10n,
        );
        if (!mounted) return;
        setState(() => _watch = created);
        AppSnackBarHelper.show(
          title: l10n.watchAdded,
          message: widget.category,
        );
      } else {
        await RemoteService.removeWatch(current.id);
        if (!mounted) return;
        setState(() => _watch = null);
        AppSnackBarHelper.show(
          title: l10n.snackbarRemovedTitle,
          message: l10n.notifFeedRemovedMessage,
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.stateSomethingWentWrong,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _toggle,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _watch == null
                    ? PhosphorIconsRegular.bellRinging
                    : PhosphorIconsFill.bellRinging,
                size: 18,
              ),
        label: Text(
          _watch == null ? l10n.watchCategoryAction : l10n.watchCategoryActive,
        ),
      ),
    );
  }
}
