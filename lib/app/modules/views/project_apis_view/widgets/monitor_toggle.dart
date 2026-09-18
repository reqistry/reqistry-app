import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// Stack monitor toggle. Toggles a `project` watchlist entry that feeds
/// the daily digest.
class MonitorToggle extends StatefulWidget {
  const MonitorToggle({super.key, required this.projectId});

  final String projectId;

  @override
  State<MonitorToggle> createState() => _MonitorToggleState();
}

class _MonitorToggleState extends State<MonitorToggle> {
  bool? _watching;
  String? _watchId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final watches = await RemoteService.getWatchlists();
      if (!mounted) return;
      String? id;
      for (final watch in watches) {
        if (watch.kind == 'project' && watch.value == widget.projectId) {
          id = watch.id;
          break;
        }
      }
      setState(() {
        _watchId = id;
        _watching = id != null;
      });
    } catch (_) {
      if (mounted) setState(() => _watching = false);
    }
  }

  Future<void> _toggle(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (value) {
        final watch = await RemoteService.addWatch(
          kind: 'project',
          value: widget.projectId,
          l10n: l10n,
        );
        if (!mounted) return;
        setState(() {
          _watchId = watch.id;
          _watching = true;
        });
      } else {
        final id = _watchId;
        if (id != null) await RemoteService.removeWatch(id);
        if (!mounted) return;
        setState(() {
          _watchId = null;
          _watching = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBarHelper.show(
        title: l10n.stateError,
        message: l10n.stateSomethingWentWrong,
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final watching = _watching ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.bellRinging, size: 20, color: c.onSurface),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.monitorTitle,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.monitorSubtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_watching == null || _busy)
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Switch(value: watching, onChanged: _toggle),
        ],
      ),
    );
  }
}
