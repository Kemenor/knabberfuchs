import 'package:flutter/material.dart';

/// A best-effort icon for a food/meal-item [name]. Catalog foods carry no icon
/// data, so this maps common keywords (EN + a few DE/FR/IT) to a Material icon;
/// anything unmatched falls back to a generic plate. Purely decorative — it
/// never affects logging.
IconData foodIconFor(String name) {
  final n = name.toLowerCase();
  bool has(List<String> ks) => ks.any(n.contains);

  if (has(['coffee', 'latte', 'cappuccino', 'espresso', 'kaffee', 'café', 'tea', 'tee', 'thé', 'chai'])) {
    return Icons.local_cafe;
  }
  if (has(['smoothie', 'juice', 'jus', 'soda', 'cola', 'drink', 'getränk', 'shake', 'lemonade', 'water', 'wasser'])) {
    return Icons.local_drink;
  }
  if (has(['beer', 'bier', 'wine', 'wein', 'vin'])) return Icons.sports_bar;
  if (has(['egg', 'ei', 'oeuf', 'omelet', 'omelette', 'frittata'])) return Icons.egg_alt;
  if (has(['bread', 'toast', 'bagel', 'brot', 'pain', 'croissant', 'bun', 'roll', 'baguette'])) {
    return Icons.bakery_dining;
  }
  if (has(['pizza'])) return Icons.local_pizza;
  if (has(['burger', 'hamburger', 'cheeseburger'])) return Icons.lunch_dining;
  if (has(['pasta', 'spaghetti', 'noodle', 'ramen', 'nudel', 'pâtes'])) return Icons.ramen_dining;
  if (has(['rice', 'reis', 'riz', 'bowl', 'curry', 'risotto', 'paella'])) return Icons.rice_bowl;
  if (has(['fish', 'salmon', 'tuna', 'shrimp', 'fisch', 'poisson', 'seafood', 'sushi'])) {
    return Icons.set_meal;
  }
  if (has(['chicken', 'beef', 'pork', 'steak', 'meat', 'huhn', 'poulet', 'fleisch', 'lamb', 'sausage', 'wurst'])) {
    return Icons.lunch_dining;
  }
  if (has(['salad', 'salat', 'salade', 'vegetable', 'gemüse', 'broccoli', 'spinach', 'lettuce'])) {
    return Icons.eco;
  }
  if (has(['apple', 'banana', 'berry', 'fruit', 'apfel', 'obst', 'orange', 'grape', 'melon'])) {
    return Icons.local_florist;
  }
  if (has(['yogurt', 'yoghurt', 'joghurt', 'milk', 'milch', 'lait', 'cheese', 'käse', 'skyr', 'quark'])) {
    return Icons.icecream;
  }
  if (has(['cake', 'cookie', 'biscuit', 'chocolate', 'dessert', 'kuchen', 'schoko', 'donut', 'muffin', 'pie', 'ice cream'])) {
    return Icons.cake;
  }
  if (has(['oat', 'cereal', 'müsli', 'muesli', 'granola', 'porridge', 'haferflocken'])) {
    return Icons.breakfast_dining;
  }
  if (has(['soup', 'suppe', 'soupe', 'stew', 'chili'])) return Icons.soup_kitchen;
  if (has(['nut', 'almond', 'peanut', 'nuss', 'mandel'])) return Icons.grain;
  return Icons.restaurant;
}
