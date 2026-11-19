import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/date_x.dart';
import '../../core/snackbar.dart';
import '../../domain/ai_instructions.dart';
import '../../domain/day_summary.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';

/// Settings → AI helper (replaces the Gemini key, PLAN "AI bridge" A.6):
/// knabberfuchs never talks to an AI itself. The user's own AI app does the
/// thinking — this screen hands it instructions to paste once, and a summary
/// of the last days to analyse. Answers come back through the share sheet or
/// "Paste from your AI app".
class AiHelperScreen extends ConsumerWidget {
  const AiHelperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    Widget section(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiHelperTitle)),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + bottom),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(l10n.aiHelperIntro, style: theme.textTheme.bodyMedium),
          ),
          section(l10n.aiInstructionsSection),
          _TaskTile(
            task: AiTask.logMeal,
            icon: Symbols.restaurant_rounded,
            title: l10n.aiTaskLogTitle,
            subtitle: l10n.aiTaskLogSub,
          ),
          _TaskTile(
            task: AiTask.adaptRecipe,
            icon: Symbols.menu_book_rounded,
            title: l10n.aiTaskRecipeTitle,
            subtitle: l10n.aiTaskRecipeSub,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.aiHowTo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          section(l10n.aiSummarySection),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.aiSummarySub,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareSummary(context, ref, 7),
                    icon: const Icon(Symbols.share_rounded),
                    label: Text(l10n.aiSummary7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareSummary(context, ref, 30),
                    icon: const Icon(Symbols.share_rounded),
                    label: Text(l10n.aiSummary30),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareSummary(BuildContext context, WidgetRef ref, int n) async {
    final db = ref.read(dbProvider);
    final today = DateTime.now();
    final days = [
      for (var i = n - 1; i >= 0; i--)
        DayKey.of(DateTime(today.year, today.month, today.day - i)),
    ];
    final rows = await db.watchDailyTotals(days.first, days.last).first;
    final text = buildShareSummary(
      days: days,
      totals: {for (final r in rows) r.day: r},
      kcal: CalorieTarget(
        await ref.read(defaultMinProvider.future),
        await ref.read(defaultMaxProvider.future),
      ),
      nutrients: await ref.read(macroDefaultsProvider.future),
      tracked: await ref.read(trackedNutrientsProvider.future),
    );
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

class _TaskTile extends ConsumerWidget {
  final AiTask task;
  final IconData icon;
  final String title, subtitle;

  const _TaskTile({
    required this.task,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: FilledButton.tonalIcon(
        onPressed: () => _copy(context, ref),
        icon: const Icon(Symbols.content_copy_rounded, size: 18),
        label: Text(l10n.aiCopy),
      ),
    );
  }

  Future<void> _copy(BuildContext context, WidgetRef ref) =>
      copyAiInstructions(context, ref, task);
}

/// [task]'s instructions for the user's AI app, with their current targets,
/// in the app's language.
Future<String> aiInstructionsFor(
  BuildContext context,
  WidgetRef ref,
  AiTask task,
) async {
  final language = Localizations.localeOf(context).languageCode;
  return buildAiInstructions(
    task,
    language: language,
    kcal: CalorieTarget(
      await ref.read(defaultMinProvider.future),
      await ref.read(defaultMaxProvider.future),
    ),
    nutrients: await ref.read(macroDefaultsProvider.future),
    tracked: await ref.read(trackedNutrientsProvider.future),
  );
}

/// Copies [task]'s instructions and confirms with a snackbar.
Future<void> copyAiInstructions(
  BuildContext context,
  WidgetRef ref,
  AiTask task,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final text = await aiInstructionsFor(context, ref, task);
  await Clipboard.setData(ClipboardData(text: text));
  messenger.showAutoSnackBar(SnackBar(content: Text(l10n.aiCopied)));
}
