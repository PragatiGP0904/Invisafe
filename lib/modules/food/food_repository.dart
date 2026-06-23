import '../../models/nutrition_info.dart';

/// Static nutrition database with a deterministic fallback for unknown foods.
/// Ported from InviSafeP's FoodNutritionRepository.
class FoodRepository {
  FoodRepository._();

  static const Map<String, NutritionInfo> _db = {
    'apple': NutritionInfo(
        name: 'Apple',
        calories: 95,
        protein: 0.5,
        carbs: 25,
        fat: 0.3,
        vitaminC: 8.4,
        healthRating: 5,
        tip: 'Great source of fiber and antioxidants.'),
    'banana': NutritionInfo(
        name: 'Banana',
        calories: 105,
        protein: 1.3,
        carbs: 27,
        fat: 0.4,
        vitaminC: 10.3,
        healthRating: 4,
        tip: 'Rich in potassium; good pre-workout fuel.'),
    'orange': NutritionInfo(
        name: 'Orange',
        calories: 62,
        protein: 1.2,
        carbs: 15,
        fat: 0.2,
        vitaminC: 70,
        healthRating: 5,
        tip: 'Excellent vitamin C content.'),
    'pizza': NutritionInfo(
        name: 'Pizza',
        calories: 285,
        protein: 12,
        carbs: 36,
        fat: 10,
        vitaminC: 1,
        healthRating: 2,
        tip: 'High in sodium and saturated fat; enjoy occasionally.'),
    'burger': NutritionInfo(
        name: 'Burger',
        calories: 354,
        protein: 17,
        carbs: 29,
        fat: 17,
        vitaminC: 1,
        healthRating: 2,
        tip: 'Calorie-dense; pair with vegetables.'),
    'biscuit': NutritionInfo(
        name: 'Biscuit',
        calories: 150,
        protein: 2,
        carbs: 20,
        fat: 7,
        vitaminC: 0,
        healthRating: 2,
        tip: 'Refined carbs and added sugar; limit intake.'),
    'rice': NutritionInfo(
        name: 'Rice',
        calories: 206,
        protein: 4.3,
        carbs: 45,
        fat: 0.4,
        vitaminC: 0,
        healthRating: 3,
        tip: 'Good energy source; prefer whole-grain variants.'),
  };

  static NutritionInfo lookup(String name) {
    final key = name.toLowerCase().trim();
    final hit = _db[key];
    if (hit != null) return hit;

    // Deterministic fallback derived from the name hash (mirrors original).
    final h = key.hashCode.abs();
    return NutritionInfo(
      name: name,
      calories: 80 + h % 320,
      protein: (h % 20).toDouble(),
      carbs: (h % 45).toDouble(),
      fat: (h % 18).toDouble(),
      vitaminC: (h % 30).toDouble(),
      healthRating: 2 + h % 4,
      tip: 'Estimated values — exact nutrition unavailable for this item.',
    );
  }
}
