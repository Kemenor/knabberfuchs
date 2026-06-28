/// A curated, category-level fallback for turning a recognized dish *label*
/// into a sane portion estimate when the local catalog has no good match (or a
/// match with no serving size).
///
/// The on-device classifier emits specific dish names ("Neapolitan pizza",
/// "Chocolate brownie"); ~85% of the generic catalog rows have no serving size,
/// so without this almost every on-device guess fell back to a flat 300 g
/// plate. This maps the dish's head category to a realistic single-serving
/// weight + a typical energy density, so the prefilled Free-add estimate is in
/// the right ballpark instead of wildly off.
///
/// Values are deliberately rough — the result is always shown as an *editable*
/// estimate, never logged blindly. Entries are ordered most-specific first so
/// e.g. "brownie" wins over the generic "chocolate".
library;

/// A typical portion for a food category: its weight and energy density.
class PortionEstimate {
  final int grams;
  final double kcal100;
  const PortionEstimate(this.grams, this.kcal100);

  int get kcal => (kcal100 * grams / 100).round();
}

/// (keywords, typical portion). First entry with a whole-word keyword match in
/// the label wins, so list specific categories before the generic words they
/// contain.
const _table = <(List<String>, PortionEstimate)>[
  // — Desserts & baked sweets (small, energy-dense) —
  (['brownie', 'cookie', 'biscuit', 'muffin', 'donut', 'doughnut'], PortionEstimate(80, 450)),
  (['cheesecake', 'cake', 'gateau', 'gâteau', 'tart', 'pastry', 'cupcake'], PortionEstimate(120, 350)),
  (['pie', 'cobbler', 'strudel'], PortionEstimate(140, 270)),
  (['ice cream', 'gelato', 'sundae', 'sorbet'], PortionEstimate(120, 207)),
  (['chocolate', 'candy', 'fudge', 'truffle'], PortionEstimate(40, 535)),
  (['pudding', 'custard', 'mousse', 'flan'], PortionEstimate(150, 130)),
  // — Mains by carb base —
  (['pizza'], PortionEstimate(300, 266)),
  (['lasagna', 'lasagne', 'pasta', 'spaghetti', 'noodle', 'macaroni', 'ravioli', 'carbonara'], PortionEstimate(350, 150)),
  (['risotto', 'paella', 'fried rice', 'rice', 'biryani'], PortionEstimate(300, 130)),
  (['burrito', 'taco', 'quesadilla', 'enchilada', 'fajita'], PortionEstimate(250, 220)),
  (['hamburger', 'cheeseburger', 'burger'], PortionEstimate(250, 250)),
  (['sandwich', 'panini', 'cheesesteak', 'wrap'], PortionEstimate(220, 250)),
  (['hot dog', 'hotdog', 'sausage', 'bratwurst'], PortionEstimate(150, 290)),
  (['curry', 'chili', 'stew', 'goulash', 'tagine'], PortionEstimate(350, 130)),
  (['sushi', 'sashimi', 'maki', 'nigiri'], PortionEstimate(200, 150)),
  (['dumpling', 'gyoza', 'wonton', 'spring roll', 'samosa'], PortionEstimate(200, 200)),
  // — Proteins —
  (['steak', 'beef', 'pork', 'lamb', 'ribs', 'meatball', 'meatloaf'], PortionEstimate(250, 250)),
  (['chicken', 'turkey', 'duck', 'poultry'], PortionEstimate(250, 220)),
  (['salmon', 'tuna', 'shrimp', 'prawn', 'fish', 'seafood', 'cod', 'crab', 'lobster'], PortionEstimate(200, 200)),
  (['egg', 'omelette', 'omelet', 'frittata', 'quiche'], PortionEstimate(150, 155)),
  (['tofu', 'tempeh'], PortionEstimate(150, 145)),
  // — Breakfast / bread —
  (['pancake', 'waffle', 'crepe', 'crêpe', 'french toast'], PortionEstimate(200, 230)),
  (['oatmeal', 'porridge', 'cereal', 'granola', 'muesli'], PortionEstimate(250, 110)),
  (['bagel', 'croissant', 'bun', 'toast', 'bread', 'roll', 'baguette'], PortionEstimate(100, 270)),
  // — Sides & lighter —
  (['fries', 'french fries', 'chips'], PortionEstimate(150, 312)),
  (['salad', 'coleslaw', 'slaw'], PortionEstimate(250, 90)),
  (['soup', 'chowder', 'bisque', 'broth', 'ramen', 'pho'], PortionEstimate(350, 55)),
  (['yogurt', 'yoghurt'], PortionEstimate(150, 60)),
  (['cheese'], PortionEstimate(50, 350)),
  (['nut', 'almond', 'peanut', 'cashew', 'walnut'], PortionEstimate(30, 600)),
  (['fruit', 'apple', 'banana', 'orange', 'berry', 'melon', 'grape'], PortionEstimate(150, 60)),
  (['vegetable', 'broccoli', 'carrot', 'spinach', 'cucumber', 'tomato'], PortionEstimate(200, 35)),
  // — Drinks (the on-device model can't detect these, but a catalog/Gemini
  //   label or a future model might; sane defaults can't hurt) —
  (['smoothie', 'milkshake', 'shake'], PortionEstimate(350, 70)),
  (['latte', 'cappuccino', 'coffee', 'espresso', 'tea', 'chai'], PortionEstimate(250, 25)),
  (['juice', 'lemonade'], PortionEstimate(250, 45)),
  (['soda', 'cola', 'soft drink'], PortionEstimate(330, 40)),
  (['beer'], PortionEstimate(330, 43)),
  (['wine'], PortionEstimate(150, 85)),
];

/// Best portion estimate for a recognized dish [label], or null if no category
/// matches (callers should leave kcal blank rather than fabricate a number).
PortionEstimate? portionForLabel(String label) {
  final l = label.toLowerCase();
  for (final (keywords, portion) in _table) {
    for (final kw in keywords) {
      // Whole-word match (with optional plural) so "egg" doesn't fire on
      // "eggplant" or "rice" on "licorice", but "cookies"/"fries" still match.
      final re = RegExp('\\b${RegExp.escape(kw)}s?\\b', caseSensitive: false);
      if (re.hasMatch(l)) return portion;
    }
  }
  return null;
}
