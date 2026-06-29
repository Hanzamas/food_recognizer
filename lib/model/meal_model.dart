class MealModel {
  final String idMeal;
  final String strMeal;
  final String? strMealThumb;
  final String? strCategory;
  final String? strInstructions;
  final List<String> ingredients;
  final List<String> measures;

  MealModel({
    required this.idMeal,
    required this.strMeal,
    this.strMealThumb,
    this.strCategory,
    this.strInstructions,
    required this.ingredients,
    required this.measures,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measures.add(measure?.toString().trim() ?? '');
      }
    }

    return MealModel(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'],
      strCategory: json['strCategory'],
      strInstructions: json['strInstructions'],
      ingredients: ingredients,
      measures: measures,
    );
  }
}

class MealsResponse {
  final List<MealModel> meals;

  MealsResponse({required this.meals});

  factory MealsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawMeals = json['meals'];
    if (rawMeals == null) return MealsResponse(meals: []);
    return MealsResponse(
      meals: rawMeals.map((m) => MealModel.fromJson(m)).toList(),
    );
  }
}
