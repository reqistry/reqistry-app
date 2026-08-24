import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/l10n/app_localizations.dart';

/// A pickable API for comparison.
class CompareCandidate {
  final String id;
  final String name;

  const CompareCandidate({required this.id, required this.name});
}

/// Bottom sheet to select 2–4 APIs for comparison from saved APIs and search.
class ApiPickerSheet extends StatefulWidget {
  final Set<String> initiallySelected;
  static const maxSelection = 4;

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
        _candidates[b.api.id] =
            CompareCandidate(id: b.api.id, name: b.api.name);
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
        _candidates[api.id] = CompareCandidate(id: api.id, name: api.name);
      }
      if (!mounted) return;
      setState(() {
        _results = apis
            .where((a) => a.id.isNotEmpty)
            .map((a) => CompareCandidate(id: a.id, name: a.name))
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
    final c = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        color: c.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.pickerSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.pickerSelectedCount(_selected.length),
                  style: c.textTheme.bodySmall,
                ),
              ),
            ),
            Flexible(child: _buildList(c)),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selected.length >= 2 ? _submit : null,
                    child: Text(l10n.pickerDone(_selected.length)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ThemeData c) {
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
      return Center(child: Text(l10n.stateSomethingWentWrong));
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
          ),
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      children: [
        for (final candidate in visible)
          ListTile(
            dense: true,
            leading: Icon(
              _selected.contains(candidate.id)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            title: Text(candidate.name),
            onTap: () => _toggle(candidate),
          ),
      ],
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
