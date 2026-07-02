import 'package:calorie_tracker/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => setNumberLocale(null));

  group('kcalStr', () {
    test('rounds and applies locale thousands grouping', () {
      setNumberLocale('en');
      expect(kcalStr(1999.6), '2,000');
      setNumberLocale('de');
      expect(kcalStr(2000), '2.000');
      setNumberLocale('it');
      expect(kcalStr(2000), '2.000');
      // fr groups with an NBSP-family space whose exact code point varies by
      // CLDR release; assert "some non-digit separator" instead of pinning it.
      setNumberLocale('fr');
      expect(kcalStr(2000), matches(RegExp(r'^2\D000$')));
    });

    test('small values have no fraction digits', () {
      setNumberLocale('de');
      expect(kcalStr(87.4), '87');
    });
  });

  group('gramsStr', () {
    test('whole numbers render without a decimal', () {
      setNumberLocale('de');
      expect(gramsStr(100), '100');
      setNumberLocale('en');
      expect(gramsStr(100), '100');
    });

    test('decimal comma in de/fr/it, decimal point in en', () {
      setNumberLocale('de');
      expect(gramsStr(1.5), '1,5');
      setNumberLocale('fr');
      expect(gramsStr(1.5), '1,5');
      setNumberLocale('it');
      expect(gramsStr(1.5), '1,5');
      setNumberLocale('en');
      expect(gramsStr(1.5), '1.5');
    });

    test('at most one decimal', () {
      setNumberLocale('en');
      expect(gramsStr(12.34), '12.3');
    });

    test('never groups (pre-fills inputs whose parsers keep no separators)', () {
      setNumberLocale('de');
      expect(gramsStr(1234.5), '1234,5');
      setNumberLocale('fr');
      expect(gramsStr(1234.5), '1234,5');
      setNumberLocale('en');
      expect(gramsStr(1234.5), '1234.5');
    });
  });

  group('macroStr', () {
    test('always exactly one decimal', () {
      setNumberLocale('de');
      expect(macroStr(10), '10,0');
      expect(macroStr(1.56), '1,6');
      setNumberLocale('en');
      expect(macroStr(10), '10.0');
    });

    test('never groups', () {
      setNumberLocale('en');
      expect(macroStr(1234.0), '1234.0');
      setNumberLocale('de');
      expect(macroStr(1234.0), '1234,0');
    });
  });

  group('CSV serialization', () {
    test('period decimal and no grouping even under a comma display locale', () {
      setNumberLocale('de');
      expect(kcalCsv(1999.6), '2000');
      expect(gramsCsv(100), '100');
      expect(gramsCsv(12.34), '12.34');
      expect(macroCsv(1.26), '1.3');
      expect(macroCsv(10), '10.0');
    });
  });
}
