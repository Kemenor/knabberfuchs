import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';
import '../food/log_food_sheet.dart';
import '../food/manual_food_screen.dart';
import '../scan/scan_screen.dart';

/// Search + add a food to [day]/[meal].
///
/// Search-as-you-type queries only the local cache (instant, no network).
/// An online OFF search fires only after a 600 ms pause — never per keystroke —
/// to respect OFF's 10 searches/min limit.
class AddFoodScreen extends ConsumerStatefulWidget {
  final String day;
  final MealType meal;
  const AddFoodScreen({super.key, required this.day, required this.meal});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<Food> _local = const [];
  List<Food> _online = const [];
  bool _searchingOnline = false;
  int _searchSeq = 0;

  @override
  void initState() {
    super.initState();
    _runLocal('');
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
    final repo = ref.read(foodRepositoryProvider);
    final results = await repo.searchLocal(value);
    if (mounted) setState(() => _local = results);
  }

  Future<void> _runOnline() async {
    final value = _query.trim();
    if (value.length < 2) return;
    final seq = ++_searchSeq;
    setState(() => _searchingOnline = true);
    try {
      final results = await ref.read(foodRepositoryProvider).searchOnline(value);
      if (mounted && seq == _searchSeq) {
        setState(() => _online = results);
      }
    } catch (_) {
      // network/rate-limit issues are non-fatal; local results still show.
    } finally {
      if (mounted && seq == _searchSeq) {
        setState(() => _searchingOnline = false);
      }
      // refresh local cache (online results were upserted)
      _runLocal(_query);
    }
  }

  List<Food> get _merged {
    final seen = <int>{};
    final out = <Food>[];
    for (final f in [..._local, ..._online]) {
      if (seen.add(f.id)) out.add(f);
    }
    return out;
  }

  Future<void> _pick(Food food) async {
    final added = await showLogFoodSheet(context, ref,
        food: food, day: widget.day, meal: widget.meal);
    if (added == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _scan() async {
    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (barcode == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final food = await ref.read(foodRepositoryProvider).lookupBarcode(barcode);
    if (!mounted) return;
    if (food != null) {
      await _pick(food);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text('No product found for $barcode')),
      );
    }
  }

  Future<void> _createCustom() async {
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute(builder: (_) => const ManualFoodScreen()),
    );
    if (food != null && mounted) await _pick(food);
  }

  @override
  Widget build(BuildContext context) {
    final results = _merged;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add food'),
        actions: [
          IconButton(
            tooltip: 'Scan barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scan,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Search foods…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchingOnline
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : (_query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
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
          Expanded(
            child: results.isEmpty
                ? _EmptyState(query: _query, onCreate: _createCustom)
                : ListView.separated(
                    itemCount: results.length + 1,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i == results.length) {
                        return ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('Create custom food'),
                          onTap: _createCustom,
                        );
                      }
                      return _FoodTile(food: results[i], onTap: () => _pick(results[i]));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  final Food food;
  final VoidCallback onTap;
  const _FoodTile({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (food.brand != null && food.brand!.isNotEmpty) food.brand!,
      _sourceLabel(food.source),
    ];
    return ListTile(
      title: Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitleParts.join(' · ')),
      trailing: Text('${kcalStr(food.kcal100)} kcal\n/100 g',
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodySmall),
      onTap: onTap,
    );
  }

  String _sourceLabel(FoodSource s) => switch (s) {
        FoodSource.openFoodFacts => 'Open Food Facts',
        FoodSource.usda => 'USDA',
        FoodSource.custom => 'Custom',
      };
}

class _EmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onCreate;
  const _EmptyState({required this.query, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.no_food_outlined,
              size: 48, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          Text(query.isEmpty
              ? 'Search for a food, scan a barcode,\nor create your own.'
              : 'No matches for "$query".',
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create custom food'),
          ),
        ],
      ),
    );
  }
}
