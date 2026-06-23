/// User health profile shared by the Food and Skin modules.
///
/// Ported from InviSafeP's UserHealthProfile + FoodPreferences. Persistence
/// is intentionally in-memory for the demo; swap [UserHealthProfileStore] for
/// shared_preferences in production.
class UserHealthProfile {
  bool diabetes;
  bool highBloodPressure;
  bool lowBloodPressure;
  bool ironDeficiency;
  bool obesity;
  List<String> allergies;

  UserHealthProfile({
    this.diabetes = false,
    this.highBloodPressure = false,
    this.lowBloodPressure = false,
    this.ironDeficiency = false,
    this.obesity = false,
    List<String>? allergies,
  }) : allergies = allergies ?? <String>[];
}

enum DietType { none, vegetarian, vegan, keto }

enum HealthGoal { maintain, loseWeight, gainMuscle }

class FoodPreferences {
  DietType diet;
  HealthGoal goal;

  FoodPreferences({this.diet = DietType.none, this.goal = HealthGoal.maintain});
}

/// Simple in-memory singleton store (stands in for SharedPreferences).
class UserHealthProfileStore {
  UserHealthProfileStore._();
  static final UserHealthProfileStore instance = UserHealthProfileStore._();

  final UserHealthProfile profile = UserHealthProfile();
  final FoodPreferences preferences = FoodPreferences();
}
