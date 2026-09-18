import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// A pickable API for comparison.
class CompareCandidate {
  final String id;
  final String name;
  final String category;

  const CompareCandidate({
    required this.id,
    required this.name,
    this.category = '',
  });
}

/// Bottom sheet to select APIs for comparison (2–8).
class ApiPickerSheet extends StatefulWidget {
  final Set<String> initiallySelected;
  static const maxSelection = 8;

  const ApiPickerSheet({super.key, required this.initiallySelected});

  /// Returns the chosen candidates, or null if dismissed.
  static Future<List<CompareCandidate>?> show(
    BuildContext context, {
    required Set<String> initiallySelected,
  }) {
    return showModalBottomSheet<List<CompareCandidate>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FavoritesCubit>(),
        child: ApiPickerSheet(initiallySelected: initiallySelected),
      ),
    );
  }

  @override
  State<ApiPickerSheet> createState() => _ApiPickerSheetState();
}

class _ApiPickerSheetState extends State<ApiPickerSheet> {
  final _searchController = TextEditingController();
  final Map<String, CompareCandidate> _candidates = {};
  Set<String> _selected;
  List<CompareCandidate> _results = [];
  bool _searching = false;
  bool _searchFailed = false;
  Timer? _debounce;

  _ApiPickerSheetState() : _selected = {};

  @override
  void initState() {
    super.initState();
    _selected = Set.of(widget.initiallySelected);
    for (final b in context.read<FavoritesCubit>().state.bookmarks) {
      if (b.api.id.isNotEmpty) {
        _candidates[b.api.id] = CompareCandidate(
          id: b.api.id,
          name: b.api.name,
          category: b.api.categoryName,
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _searchFailed = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _runSearch(query.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() => _searching = true);
    try {
      final response = await RemoteService.searchApis(q: query, limit: 20);
      final apis = response.data;
      for (final api in apis.where((a) => a.id.isNotEmpty)) {
        _candidates[api.id] = CompareCandidate(
          id: api.id,
          name: api.name,
          category: api.category,
        );
      }
      if (!mounted) return;
      setState(() {
        _results = apis
            .where((a) => a.id.isNotEmpty)
            .map((a) => CompareCandidate(
                  id: a.id,
                  name: a.name,
                  category: a.category,
                ))
            .toList();
        _searching = false;
        _searchFailed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _searchFailed = true;
        _searching = false;
      });
    }
  }

  void _toggle(CompareCandidate candidate) {
    setState(() {
      if (_selected.contains(candidate.id)) {
        _selected.remove(candidate.id);
      } else if (_selected.length < ApiPickerSheet.maxSelection) {
        _selected.add(candidate.id);
        _candidates[candidate.id] = candidate;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = AppColors.of(Theme.of(context).brightness);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.primary, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: AppSpacing.s12, bottom: AppSpacing.s8),
              width: 40,
              height: 4,
              color: c.outlineVariant,
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, AppSpacing.s12),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.scales,
                      size: 20, color: c.primary),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      l10n.intelligenceCompareTitle.toUpperCase(),
                      style: AppTextStyles.labelSmUpper.copyWith(
                        color: c.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    l10n.pickerSelectedCount(_selected.length),
                    style: AppTextStyles.labelSmUpper.copyWith(
                      fontSize: 10,
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: c.surfaceVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16, AppSpacing.s12, 16, AppSpacing.s8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.pickerSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            Flexible(child: _buildList(c)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.surfaceVariant, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _selected.length >= 2 ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: c.onPrimary,
                        disabledBackgroundColor: c.surfaceContainerHighest,
                        disabledForegroundColor: c.onSurfaceVariant,
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.pickerDone(_selected.length),
                        style:
                            AppTextStyles.labelSmUpper.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(AppColorScheme c) {
    final l10n = AppLocalizations.of(context)!;
    if (_searching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_searchFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.stateSomethingWentWrong,
                style: AppTextStyles.labelSm.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.s8),
              TextButton(
                onPressed: () =>
                    _runSearch(_searchController.text.trim()),
                child: Text(l10n.actionRetry),
              ),
            ],
          ),
        ),
      );
    }

    final savedIds = context
        .read<FavoritesCubit>()
        .state
        .bookmarks
        .map((b) => b.api.id)
        .toSet();
    final searching = _searchController.text.trim().length >= 2;
    final visible = searching
        ? _results
        : _candidates.values
            .where((candidate) => savedIds.contains(candidate.id))
            .toList();

    if (visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            searching ? l10n.stateNoApis : l10n.pickerNoSavedApis,
            textAlign: TextAlign.center,
            style:
                AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          _candidateRow(c, visible[i]),
          if (i != visible.length - 1)
            Divider(height: 1, thickness: 1, color: c.surfaceVariant),
        ],
      ],
    );
  }

  Widget _candidateRow(AppColorScheme c, CompareCandidate candidate) {
    final isSelected = _selected.contains(candidate.id);
    return InkWell(
      onTap: () => _toggle(candidate),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16, vertical: AppSpacing.s10),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? PhosphorIconsFill.checkSquare
                  : PhosphorIconsRegular.square,
              size: 20,
              color: isSelected ? c.primary : c.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.name,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (candidate.category.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      candidate.category.toUpperCase(),
                      style: AppTextStyles.labelSmUpper.copyWith(
                        fontSize: 9,
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.s8),
              Text(
                '${_selected.toList().indexOf(candidate.id) + 1}',
                style: AppTextStyles.codeMd.copyWith(color: c.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _submit() {
    Navigator.of(context).pop(
      _selected
          .map((id) => _candidates[id] ?? CompareCandidate(id: id, name: id))
          .toList(),
    );
  }
}
