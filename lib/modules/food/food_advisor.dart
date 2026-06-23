import '../../models/nutrition_info.dart';
import '../../models/user_health_profile.dart';

enum RecommendationStatus { recommended, caution, avoid }

class PersonalizedAdvice {
  final RecommendationStatus status;
  final String message;
  const PersonalizedAdvice(this.status, this.message);
}

/// Rule engine producing personalized food advice from the user's health
/// profile. Ported from InviSafeP's FoodHealthAdvisor.
class FoodAdvisor {
  static PersonalizedAdvice advise(
      NutritionInfo food, UserHealthProfile profile) {
    // Allergy hard-stop.
    final lower = food.name.toLowerCase();
    for (final a in profile.allergies) {
      if (a.isNotEmpty && lower.contains(a.toLowerCase())) {
        return PersonalizedAdvice(RecommendationStatus.avoid,
            'Contains a known allergen ($a). Avoid.');
      }
    }

    if (profile.diabetes && food.carbs > 30) {
      return const PersonalizedAdvice(RecommendationStatus.caution,
          'High carbohydrate content — monitor blood sugar if diabetic.');
    }
    if (profile.highBloodPressure && food.healthRating <= 2) {
      return const PersonalizedAdvice(RecommendationStatus.caution,
          'Likely high sodium/fat — limit portion given high blood pressure.');
    }
    if (profile.obesity && food.calories > 300) {
      return const PersonalizedAdvice(RecommendationStatus.caution,
          'Calorie-dense — consider a smaller portion for weight goals.');
    }

    switch (food.status) {
      case HealthStatus.healthy:
        return const PersonalizedAdvice(
            RecommendationStatus.recommended, 'A healthy choice for you.');
      case HealthStatus.moderate:
        return const PersonalizedAdvice(
            RecommendationStatus.caution, 'Fine in moderation.');
      case HealthStatus.unhealthy:
        return const PersonalizedAdvice(RecommendationStatus.avoid,
            'Best enjoyed occasionally rather than daily.');
    }
  }
}
