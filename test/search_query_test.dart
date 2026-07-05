import 'package:calorie_tracker/domain/search_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('splits into lowercase tokens', () {
    expect(searchTokens('Olive Oil'), ['olive', 'oil']);
    expect(searchTokens('Tomatoes, red, ripe'), ['tomatoes', 'red', 'ripe']);
  });

  test('applies produce synonyms', () {
    expect(searchTokens('bell pepper'), ['peppers', 'sweet']);
    expect(searchTokens('rocket'), ['arugula']);
    expect(searchTokens('cherry tomato'), ['tomatoes', 'red', 'ripe']);
    expect(searchTokens('courgette'), ['zucchini']);
  });

  test(
    'synonyms match whole tokens, never corrupt words that contain them',
    () {
      // The alias 'chickpea'→'chickpeas' must not turn the already-plural
      // "chickpeas" into "chickpeass" (the old substring-replace bug).
      expect(searchTokens('chickpeas'), ['chickpeas']);
      expect(searchTokens('chickpea'), ['chickpeas']);
      // 'mince'→'ground' must not rewrite "minced" into "groundd".
      expect(searchTokens('mince'), ['ground']);
      expect(searchTokens('minced beef'), ['minced', 'beef']);
    },
  );

  test('empty / whitespace yields no tokens', () {
    expect(searchTokens('   '), isEmpty);
    expect(searchTokens(''), isEmpty);
  });

  test('folds diacritics instead of splitting on them', () {
    // Regression: splitting on [^a-z0-9] treated every accented letter as a
    // separator ("Müsli" -> ['m', 'sli']), which broke offline-pack FTS
    // prefix matching entirely for accented de/fr/it queries.
    expect(searchTokens('Müsli'), ['musli']);
    expect(searchTokens('Käse'), ['kase']);
    expect(searchTokens('Crème fraîche'), ['creme', 'fraiche']);
    expect(searchTokens('süß'), ['suss']);
  });

  test('searchTokenVariants pairs folded tokens with typed spellings', () {
    expect(searchTokenVariants('Müesli'), [
      ['muesli', 'müesli'],
    ]);
    expect(searchTokenVariants('crème fraîche'), [
      ['creme', 'crème'],
      ['fraiche', 'fraîche'],
    ]);
    // Pure-ASCII input has nothing extra to try.
    expect(searchTokenVariants('olive oil'), [
      ['olive'],
      ['oil'],
    ]);
    // Synonym-introduced tokens exist only folded.
    expect(searchTokenVariants('rocket'), [
      ['arugula'],
    ]);
  });
}
