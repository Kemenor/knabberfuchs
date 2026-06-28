import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A best-effort icon for a food/meal-item [name]. Catalog foods carry no icon
/// data, so this maps common keywords (EN + a few DE/FR/IT) to a Material icon;
/// anything unmatched falls back to a generic plate. Purely decorative — it
/// never affects logging.
IconData foodIconFor(String name) {
  final n = name.toLowerCase();
  bool has(List<String> ks) => ks.any(n.contains);

  if (has(['coffee', 'latte', 'cappuccino', 'espresso', 'kaffee', 'café', 'tea', 'tee', 'thé', 'chai'])) {
    return Symbols.local_cafe_rounded;
  }
  if (has(['smoothie', 'juice', 'jus', 'soda', 'cola', 'drink', 'getränk', 'shake', 'lemonade', 'water', 'wasser'])) {
    return Symbols.local_drink_rounded;
  }
  if (has(['beer', 'bier', 'wine', 'wein', 'vin'])) return Symbols.sports_bar_rounded;
  if (has(['egg', 'ei', 'oeuf', 'omelet', 'omelette', 'frittata'])) return Symbols.egg_alt_rounded;
  if (has(['bread', 'toast', 'bagel', 'brot', 'pain', 'croissant', 'bun', 'roll', 'baguette'])) {
    return Symbols.bakery_dining_rounded;
  }
  if (has(['pizza'])) return Symbols.local_pizza_rounded;
  if (has(['burger', 'hamburger', 'cheeseburger'])) return Symbols.lunch_dining_rounded;
  if (has(['pasta', 'spaghetti', 'noodle', 'ramen', 'nudel', 'pâtes'])) return Symbols.ramen_dining_rounded;
  if (has(['rice', 'reis', 'riz', 'bowl', 'curry', 'risotto', 'paella'])) return Symbols.rice_bowl_rounded;
  if (has(['fish', 'salmon', 'tuna', 'shrimp', 'fisch', 'poisson', 'seafood', 'sushi'])) {
    return Symbols.set_meal_rounded;
  }
  if (has(['chicken', 'beef', 'pork', 'steak', 'meat', 'huhn', 'poulet', 'fleisch', 'lamb', 'sausage', 'wurst'])) {
    return Symbols.lunch_dining_rounded;
  }
  if (has(['salad', 'salat', 'salade', 'vegetable', 'gemüse', 'broccoli', 'spinach', 'lettuce'])) {
    return Symbols.eco_rounded;
  }
  if (has(['apple', 'banana', 'berry', 'fruit', 'apfel', 'obst', 'orange', 'grape', 'melon'])) {
    return Symbols.local_florist_rounded;
  }
  if (has(['yogurt', 'yoghurt', 'joghurt', 'milk', 'milch', 'lait', 'cheese', 'käse', 'skyr', 'quark'])) {
    return Symbols.icecream_rounded;
  }
  if (has(['cake', 'cookie', 'biscuit', 'chocolate', 'dessert', 'kuchen', 'schoko', 'donut', 'muffin', 'pie', 'ice cream'])) {
    return Symbols.cake_rounded;
  }
  if (has(['oat', 'cereal', 'müsli', 'muesli', 'granola', 'porridge', 'haferflocken'])) {
    return Symbols.breakfast_dining_rounded;
  }
  if (has(['soup', 'suppe', 'soupe', 'stew', 'chili'])) return Symbols.soup_kitchen_rounded;
  if (has(['nut', 'almond', 'peanut', 'nuss', 'mandel'])) return Symbols.grain_rounded;
  return Symbols.restaurant_rounded;
}
