import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/modules/views/home_view/widgets/registry_changes_section.dart';
import 'package:api_scout/app/modules/views/intelligence_view/widgets/api_picker_sheet.dart';
import 'package:api_scout/app/modules/views/intelligence_view/widgets/collections_section.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart' show AppRoutes;
import 'package:api_scout/l10n/app_localizations.dart';

/// Intelligence tab: side-by-side API comparison.
class IntelligenceView extends StatefulWidget {
  const IntelligenceView({super.key});

  @override
  State<IntelligenceView> createState() => _IntelligenceViewState();
}

class _IntelligenceViewState extends State<IntelligenceView> {
  static const _historyKey = 'intelligenceCompareHistory';
  static const _historyCap = 4;

  final List<CompareCandidate> _selected = [];
  List<_CompareRun> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final raw = LocalsDB.instance.getWithKey(_historyKey);
    if (raw is! List) return;
    setState(() {
      _history = [
        for (final e in raw)
          if (e is Map)
            _CompareRun(
              ids: [
                for (final id in (e['ids'] as List? ?? const []))
                  if (id.toString().trim().isNotEmpty) id.toString().trim(),
              ],
              label: e['label']?.toString() ?? '',
            ),
      ].where((r) => r.ids.length >= 2).toList();
    });
  }

  Future<void> _saveRun(List<String> ids, String label) async {
    final runs = [
      _CompareRun(ids: ids, label: label),
      for (final run in _history)
        if (run.ids.join(',') != ids.join(',')) run,
    ].take(_historyCap).toList();
    setState(() => _history = runs);
    await LocalsDB.instance.putWithKey(_historyKey, [
      for (final run in runs) {'ids': run.ids, 'label': run.label},
    ]);
  }

  Future<void> _openPicker() async {
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
    final ids = _selected.map((c) => c.id).toList();
    final label = _selected.map((c) => c.name).join(' vs ');
    _saveRun(ids, label);
    context.push(AppRoutes.comparePath(ids));
  }

  void _rerun(_CompareRun run) {
    context.push(AppRoutes.comparePath(run.ids));
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
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16, AppSpacing.s24, AppSpacing.s16, AppSpacing.s24),
        children: [
          Text(
            l10n.intelligenceHeroTitle,
            style: AppTextStyles.headlineLg,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            l10n.intelligenceHeroSubtitle,
            style: AppTextStyles.bodyMd.copyWith(
              color: c.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          _compareCard(c, l10n),
          if (_history.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            _historyRow(c, l10n),
          ],
          const SizedBox(height: AppSpacing.s32),
          const CollectionsSection(),
          const SizedBox(height: AppSpacing.s32),
          const RegistryChangesSection(refreshTick: 0),
        ],
      ),
    );
  }

  Widget _historyRow(AppColorScheme c, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.intelligenceRecent,
          style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
        ),
        const SizedBox(height: AppSpacing.s8),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final run in _history)
              _HistoryChip(
                run: run,
                onTap: () => _rerun(run),
              ),
          ],
        ),
      ],
    );
  }

  Widget _compareCard(AppColorScheme c, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.fromBorderSide(BorderSide(color: c.surfaceVariant)),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                color: c.surfaceContainerHighest,
                child: Icon(PhosphorIconsRegular.scales,
                    size: 20, color: c.primary),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.intelligenceCompareTitle.toUpperCase(),
                      style: AppTextStyles.labelSmUpper.copyWith(
                        color: c.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      l10n.intelligenceCompareSubtitle,
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selected.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                for (final candidate in _selected) _candidateChip(c, candidate),
              ],
            ),
          ],
          if (_selected.length == 1) ...[
            const SizedBox(height: AppSpacing.s12),
            Text(
              l10n.compareSelectAtLeastTwo,
              style: AppTextStyles.labelSm.copyWith(
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
                color: c.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _openPicker,
                    icon: const Icon(PhosphorIconsRegular.plus, size: 16),
                    label: Text(l10n.intelligenceChooseApis),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _selected.length >= 2 ? _openCompare : null,
                    child: Text(
                      _selected.length >= 2
                          ? l10n.pickerDone(_selected.length)
                          : l10n.intelligenceCompareNow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _candidateChip(AppColorScheme c, CompareCandidate candidate) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s10, AppSpacing.s6, AppSpacing.s4, AppSpacing.s6),
      decoration: BoxDecoration(
        color: c.surfaceContainerLow,
        border: Border.all(color: c.surfaceVariant, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              candidate.name,
              style: AppTextStyles.labelSm.copyWith(color: c.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          IconButton(
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            iconSize: 16,
            padding: EdgeInsets.zero,
            onPressed: () => _removeCandidate(candidate),
            icon: Icon(
              PhosphorIconsRegular.x,
              color: c.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRun {
  final List<String> ids;
  final String label;

  const _CompareRun({required this.ids, required this.label});
}

class _HistoryChip extends StatelessWidget {
  final _CompareRun run;
  final VoidCallback onTap;

  const _HistoryChip({required this.run, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: c.surfaceContainerHigh,
        splashColor: c.surfaceContainerHighest,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.surfaceVariant, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  run.label,
                  style: AppTextStyles.labelSm.copyWith(color: c.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              ExcludeSemantics(
                child: Icon(
                  PhosphorIconsRegular.arrowCounterClockwise,
                  size: 16,
                  color: c.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
