class NutritionModel {
  final int calories;
  final int carbs;
  final int protein;
  final int fat;
  final int fiber;

  NutritionModel({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      calories: (json['calories'] ?? 0) as int,
      carbs: (json['carbs'] ?? 0) as int,
      protein: (json['protein'] ?? 0) as int,
      fat: (json['fat'] ?? 0) as int,
      fiber: (json['fiber'] ?? 0) as int,
    );
  }
}
