import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:submission/model/meal_model.dart';

class MealService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<MealModel>> searchMeal(String query) async {
    try {
      final uri = Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(query)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return MealsResponse.fromJson(json).meals;
      }
    } catch (_) {}
    return [];
  }

  static Future<MealModel?> getMealById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/lookup.php?i=$id');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final meals = MealsResponse.fromJson(json).meals;
        return meals.isNotEmpty ? meals.first : null;
      }
    } catch (_) {}
    return null;
  }
}
