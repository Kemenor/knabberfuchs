/// Fold common Latin accents to ASCII in an already lower-cased string, so
/// "müsli" → "musli" and "crème fraîche" → "creme fraiche". Mirrors the
/// `remove_diacritics 2` folding of the offline-pack FTS index for the
/// characters that occur in the app's locales (de/fr/it + en).
String foldDiacritics(String s) {
  var n = s;
  const accents = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'ñ': 'n',
    'ß': 'ss',
  };
  accents.forEach((k, v) => n = n.replaceAll(k, v));
  return n;
}
