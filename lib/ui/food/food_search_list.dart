import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../domain/food_name.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'food_form_screen.dart';

/// Reusable food search: instant local cache results as you type, plus a
/// 600 ms-debounced online OFF search (never per keystroke). Calls [onPick]
/// when a food is tapped. Used both to log into a day and to add recipe
/// ingredients.
class FoodSearchList extends ConsumerStatefulWidget {
  final ValueChanged<Food> onPick;
  final VoidCallback? onCreateCustom;

  /// When set, a "Quick add" tile appears while typing — passes the current
  /// query so the free-add sheet can pre-fill the name. Only wired in logging
  /// contexts (not when picking a food for a recipe/OCR match).
  final ValueChanged<String>? onQuickAdd;

  /// Pre-fill the search box and run the search immediately (e.g. an OCR
  /// ingredient name). The text starts selected so it's one keystroke to
  /// refine a messy/over-specific match.
  final String? initialQuery;
  const FoodSearchList({
    super.key,
    required this.onPick,
    this.onCreateCustom,
    this.onQuickAdd,
    this.initialQuery,
  });

  @override
  ConsumerState<FoodSearchList> createState() => _FoodSearchListState();
}

class _FoodSearchListState extends ConsumerState<FoodSearchList> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<Food> _local = const [];
  List<Food> _online = const [];
  bool _searchingOnline = false;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim() ?? '';
    if (q.isNotEmpty) {
      _controller.text = q;
      // Select the whole prefill so typing replaces it in one go.
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: q.length,
      );
      _query = q;
      if (q.length >= 2) {
        _debounce = Timer(const Duration(milliseconds: 600), _runOnline);
      }
    }
    _runLocal(q);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _query = value);
    _runLocal(value);
    _debounce?.cancel();
    if (value.trim().length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 600), _runOnline);
    } else {
      setState(() => _online = const []);
    }
  }

  Future<void> _runLocal(String value) async {
    final results = await ref.read(foodRepositoryProvider).searchLocal(value);
    // Drop stale results: if the query moved on while we awaited, a newer
    // _runLocal is already in flight and owns _local.
    if (mounted && value == _query) setState(() => _local = results);
  }

  Future<void> _runOnline() async {
    final value = _query.trim();
    if (value.length < 2) return;
    final seq = ++_seq;
    setState(() => _searchingOnline = true);
    try {
      final results = await ref
          .read(foodRepositoryProvider)
          .searchOnline(value);
      if (mounted && seq == _seq) setState(() => _online = results);
    } catch (_) {
      // network/rate-limit issues are non-fatal; local results remain.
    } finally {
      // Only the latest online search refreshes local (to pick up rows it just
      // cached); a stale one must not clobber newer results.
      if (mounted && seq == _seq) {
        setState(() => _searchingOnline = false);
        _runLocal(_query);
      }
    }
  }

  /// Open the food form pre-filled to update this custom food, then refresh
  /// the list so the edited values show right away.
  Future<void> _editFood(Food food) async {
    final updated = await Navigator.of(context).push<Food>(
      MaterialPageRoute(builder: (_) => FoodFormScreen(initial: food)),
    );
    if (updated != null && mounted) _runLocal(_query);
  }

  List<Food> get _merged {
    // Same identity key as FoodRepository.searchLocal: pack results all carry
    // the synthetic id 0, so deduping on raw ids would collapse them into one.
    final seen = <String>{};
    final out = <Food>[];
    for (final f in [..._local, ..._online]) {
      if (seen.add(f.barcode ?? 'id:${f.id}:${f.name}')) out.add(f);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final results = _merged;
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: l10n.searchFoodsHint,
              prefixIcon: const Icon(Symbols.search_rounded),
              suffixIcon: _searchingOnline
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_query.isNotEmpty
                        ? IconButton(
                            tooltip: l10n.a11yClearSearch,
                            icon: const Icon(Symbols.clear_rounded),
                            onPressed: () {
                              _controller.clear();
                              _onChanged('');
                            },
                          )
                        : null),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (widget.onQuickAdd != null && _query.trim().isNotEmpty)
          ListTile(
            leading: const Icon(Symbols.bolt_rounded),
            title: Text(
              l10n.quickAddNamed(_query.trim()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(l10n.quickAddSubtitle),
            onTap: () => widget.onQuickAdd!(_query.trim()),
          ),
        if (_query.isEmpty && results.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Text(
                l10n.searchRecentlyUsed,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
        Expanded(
          child: results.isEmpty
              ? _EmptyState(query: _query, onCreate: widget.onCreateCustom)
              : ListView.separated(
                  // Bottom inset so the last row clears a floating action button.
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount:
                      results.length + (widget.onCreateCustom != null ? 1 : 0),
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i == results.length) {
                      return ListTile(
                        leading: const Icon(Symbols.add_rounded),
                        title: Text(l10n.createCustomFood),
                        onTap: widget.onCreateCustom,
                      );
                    }
                    final food = results[i];
                    return _FoodTile(
                      food: food,
                      onTap: () => widget.onPick(food),
                      // Only persisted custom foods are editable (pack rows
                      // carry the synthetic id 0 until first use).
                      onEdit: food.source == FoodSource.custom && food.id != 0
                          ? () => _editFood(food)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FoodTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  const _FoodTile({required this.food, required this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parts = <String>[
      if (food.brand != null && food.brand!.isNotEmpty) food.brand!,
      switch (food.source) {
        FoodSource.openFoodFacts => l10n.sourceOff,
        FoodSource.custom => l10n.sourceCustom,
        FoodSource.swissFcdb => l10n.sourceSwiss,
      },
    ];
    return ListTile(
      title: Text(
        food.localizedNameOf(context),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(parts.join(' · ')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.kcalPer100Short(kcalStr(food.kcal100)),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (onEdit != null)
            PopupMenuButton<String>(
              icon: const Icon(Symbols.more_vert_rounded, size: 20),
              onSelected: (_) => onEdit!(),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
              ],
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final VoidCallback? onCreate;
  const _EmptyState({required this.query, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.no_food_rounded,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 12),
          Text(
            query.isEmpty
                ? l10n.searchEmptyPrompt
                : l10n.searchNoMatches(query),
            textAlign: TextAlign.center,
          ),
          if (onCreate != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onCreate,
              icon: const Icon(Symbols.add_rounded),
              label: Text(l10n.createCustomFood),
            ),
          ],
        ],
      ),
    );
  }
}
