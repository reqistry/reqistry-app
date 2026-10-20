import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/data/models/submission.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Personal API submission history (`GET /v1/submissions/mine`).
///
/// One-shot page state via FutureBuilder: newest-first, no pagination UI
/// (backend caps pages at 50; the first page covers realistic use).
class SubmissionsView extends StatefulWidget {
  const SubmissionsView({super.key});

  @override
  State<SubmissionsView> createState() => _SubmissionsViewState();
}

class _SubmissionsViewState extends State<SubmissionsView> {
  late Future<List<SubmissionItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SubmissionItem>> _load() {
    final l10n = AppLocalizations.of(context);
    return RemoteService.getMySubmissions(limit: 50, l10n: l10n);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    // Error UI comes from the FutureBuilder; never let refresh itself throw.
    try {
      await _future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.submissionsTitle, style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<SubmissionItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppLoading(
                message: l10n.stateLoading,
                scrollable: true,
              );
            }
            if (snapshot.hasError) {
              return AppErrorState(
                title: l10n.stateError,
                message: l10n.stateSomethingWentWrong,
                onRetry: _refresh,
                scrollable: true,
              );
            }
            final items = snapshot.data ?? const <SubmissionItem>[];
            if (items.isEmpty) {
              return AppEmptyState(
                title: l10n.submissionsEmptyTitle,
                message: l10n.submissionsEmptyMessage,
                icon: PhosphorIconsRegular.tray,
                actionLabel: l10n.actionSubmit,
                onAction: () => context.push(AppRoutes.submitApi),
                scrollable: true,
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) =>
                  _SubmissionCard(item: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.item});

  final SubmissionItem item;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final slug = item.routableSlug;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.displayTitle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              _StatusBadge(status: item.status),
            ],
          ),
          if ((item.link ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              item.link!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.codeMd.copyWith(color: c.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: AppSpacing.s8),
          if (item.submittedAt != null)
            Text(
              l10n.submissionsSubmittedOn(_shortDate(item.submittedAt!)),
              style: AppTextStyles.withTabular(
                AppTextStyles.bodySm.copyWith(color: c.onSurfaceVariant),
              ),
            ),
          if (item.reviewedAt != null)
            Text(
              l10n.submissionsReviewedOn(_shortDate(item.reviewedAt!)),
              style: AppTextStyles.withTabular(
                AppTextStyles.bodySm.copyWith(color: c.onSurfaceVariant),
              ),
            ),
          if ((item.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s4),
            Text(
              l10n.submissionsRejectionReason(item.rejectionReason!),
              style: AppTextStyles.bodySm.copyWith(color: c.dangerText),
            ),
          ],
          if (slug != null) ...[
            const SizedBox(height: AppSpacing.s8),
            OutlinedButton.icon(
              onPressed: () => context.push(
                AppRoutes.apiDetailPath(slug, source: 'submissions'),
              ),
              icon: const Icon(PhosphorIconsRegular.arrowSquareOut, size: 18),
              label: Text(l10n.submissionsOpenApi),
            ),
          ],
        ],
      ),
    );
  }

  static String _shortDate(DateTime value) =>
      value.toLocal().toString().split(' ').first;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final key = status.toLowerCase();
    final (label, foreground, background) = switch (key) {
      'approved' => (l10n.submissionStatusApproved, c.successText, c.successBg),
      'rejected' => (l10n.submissionStatusRejected, c.dangerText, c.dangerBg),
      'duplicate' => (l10n.submissionStatusDuplicate, c.infoText, c.infoBg),
      'spam' => (l10n.submissionStatusSpam, c.dangerText, c.dangerBg),
      _ => (l10n.submissionStatusPending, c.warningText, c.warningBg),
    };
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s4,
        ),
        color: background,
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSm.copyWith(
            color: foreground,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
