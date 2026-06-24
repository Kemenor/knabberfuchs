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
}
