/// Nutrition data for a recognized food item.
///
/// Ported from InviSafeP's FoodNutritionRepository / NutritionInfo.
enum HealthStatus { healthy, moderate, unhealthy }

class NutritionInfo {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double vitaminC;
  final int healthRating; // 1..5
  final String tip;

  const NutritionInfo({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.vitaminC,
    required this.healthRating,
    required this.tip,
  });

  HealthStatus get status {
    if (healthRating >= 4) return HealthStatus.healthy;
    if (healthRating >= 3) return HealthStatus.moderate;
    return HealthStatus.unhealthy;
  }
}
