import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/modules/views/intelligence_view/widgets/api_picker_sheet.dart';
import 'package:api_scout/app/modules/views/intelligence_view/widgets/change_feed_section.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart' show AppRoutes;
import 'package:api_scout/l10n/app_localizations.dart';

/// Intelligence tab: real API comparison and registry change feed.
class IntelligenceView extends StatefulWidget {
  const IntelligenceView({super.key});

  @override
  State<IntelligenceView> createState() => _IntelligenceViewState();
}

class _IntelligenceViewState extends State<IntelligenceView> {
  final List<CompareCandidate> _selected = [];
  final GlobalKey<ChangeFeedSectionState> _feedKey =
      GlobalKey<ChangeFeedSectionState>();

  void _openPicker() async {
    final chosen = await ApiPickerSheet.show(
      context,
      initiallySelected: _selected.map((c) => c.id).toSet(),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _selected
        ..clear()
        ..addAll(chosen);
    });
  }

  void _removeCandidate(CompareCandidate candidate) {
    setState(() => _selected.remove(candidate));
  }

  void _openCompare() {
    context.push(AppRoutes.compare, extra: _selected.map((c) => c.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.tabIntelligence, style: AppTextStyles.headlineSm),
        centerTitle: false,
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.surfaceVariant),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _feedKey.currentState!.reload(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s24),
          children: [
            _compareCard(c, l10n),
            const SizedBox(height: AppSpacing.s24),
            ChangeFeedSection(key: _feedKey),
          ],
        ),
      ),
    );
  }

  Widget _compareCard(AppColorScheme c, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.scales, color: c.info, size: 28),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(l10n.intelligenceCompareTitle,
                    style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            l10n.intelligenceCompareSubtitle,
            style:
                AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
          ),
          if (_selected.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                for (final candidate in _selected)
                  InputChip(
                    label: Text(candidate.name),
                    onDeleted: () => _removeCandidate(candidate),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openPicker,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.intelligenceChooseApis),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: FilledButton(
                  onPressed: _selected.length >= 2 ? _openCompare : null,
                  child: Text(l10n.intelligenceCompareNow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
