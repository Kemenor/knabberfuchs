import 'dart:collection';

import 'text_fold.dart';

/// Common-name → USDA-name aliases. USDA uses formal "Noun, qualifier" names
/// (e.g. "Peppers, sweet, green, raw"), so natural searches miss them. We
/// rewrite the query after tokenizing, matching on whole-token phrases (longest
/// key first), so an alias never corrupts a word that merely contains it
/// (e.g. "chickpeas" must not be rewritten by the "chickpea" alias).
const Map<String, String> kSearchSynonyms = {
  'bell peppers': 'peppers sweet',
  'bell pepper': 'peppers sweet',
  'cherry tomatoes': 'tomatoes red ripe',
  'cherry tomato': 'tomatoes red ripe',
  'spring onion': 'onions spring',
  'spring onions': 'onions spring',
  'green onion': 'onions spring',
  'green onions': 'onions spring',
  'scallion': 'onions spring',
  'scallions': 'onions spring',
  'aubergine': 'eggplant',
  'courgette': 'zucchini',
  'rocket': 'arugula',
  'coriander': 'cilantro',
  'chickpea': 'chickpeas',
  'garbanzo': 'chickpeas',
  'garbanzos': 'chickpeas',
  'prawns': 'shrimp',
  'prawn': 'shrimp',
  'mince': 'ground',
  'aubergines': 'eggplant',
};

/// Lower-case, fold diacritics, split into alphanumeric tokens, apply produce
/// synonyms on whole-token phrases. Folding must happen BEFORE the split:
/// splitting on `[^a-z0-9]` treats every accented letter as a separator, so
/// "Müsli" used to tokenize as ['m', 'sli'] — and 'sli*' can never prefix-match
/// the offline packs' FTS index, which stores the diacritic-folded 'musli'.
List<String> searchTokens(String raw) {
  var tokens = foldDiacritics(
    raw.toLowerCase(),
  ).split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty).toList();

  // Longest key first so multi-word aliases ("bell pepper") win over any
  // shorter overlap before the tokens they'd consume are replaced.
  final keys = kSearchSynonyms.keys.toList()
    ..sort((a, b) => b.split(' ').length.compareTo(a.split(' ').length));
  for (final key in keys) {
    tokens = _replacePhrase(
      tokens,
      key.split(' '),
      kSearchSynonyms[key]!.split(' '),
    );
  }

  // Dedupe while preserving order (synonyms can introduce repeats).
  return LinkedHashSet<String>.from(tokens).toList();
}

/// Per-token spellings for LIKE-based local search: the folded token plus,
/// when the user actually typed accents, the original accented token. Stored
/// names and Swiss search_text keep their accents, and SQLite LIKE only
/// case-folds ASCII — '%muesli%' alone would miss "Birchermüesli".
List<List<String>> searchTokenVariants(String raw) {
  final byFold = <String, String>{};
  for (final t
      in raw
          .toLowerCase()
          .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
          .where((t) => t.isNotEmpty)) {
    byFold.putIfAbsent(foldDiacritics(t), () => t);
  }
  return [
    for (final t in searchTokens(raw))
      [t, if (byFold[t] != null && byFold[t] != t) byFold[t]!],
  ];
}

/// Replace every contiguous run of [find] tokens with [replace] tokens.
List<String> _replacePhrase(
  List<String> tokens,
  List<String> find,
  List<String> replace,
) {
  if (find.isEmpty) return tokens;
  final out = <String>[];
  var i = 0;
  while (i < tokens.length) {
    var match = i + find.length <= tokens.length;
    for (var j = 0; match && j < find.length; j++) {
      if (tokens[i + j] != find[j]) match = false;
    }
    if (match) {
      out.addAll(replace);
      i += find.length;
    } else {
      out.add(tokens[i++]);
    }
  }
  return out;
}
