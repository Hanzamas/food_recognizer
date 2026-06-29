import 'dart:io';
import 'package:flutter/material.dart';
import 'package:submission/model/food_result.dart';
import 'package:submission/model/meal_model.dart';
import 'package:submission/model/nutrition_model.dart';
import 'package:submission/service/classifier_service.dart';
import 'package:submission/service/gemini_service.dart';
import 'package:submission/service/meal_service.dart';

enum ResultState { initial, loading, loaded, error }

class ResultController extends ChangeNotifier {
  ResultState _state = ResultState.initial;
  FoodResult? _foodResult;
  NutritionModel? _nutrition;
  List<MealModel> _meals = [];
  String? _errorMessage;

  ResultState get state => _state;
  FoodResult? get foodResult => _foodResult;
  NutritionModel? get nutrition => _nutrition;
  List<MealModel> get meals => _meals;
  String? get errorMessage => _errorMessage;

  Future<void> analyze(File imageFile) async {
    _state = ResultState.loading;
    notifyListeners();

    try {
      if (!ClassifierService.isInitialized) {
        await ClassifierService.init();
      }
      _foodResult = await ClassifierService.classifyFromPath(imageFile.path);

      if (_foodResult != null) {
        final foodName = _foodResult!.label;

        // Fetch MealDB and Gemini in parallel — safe cast with fallback
        final mealsFuture = MealService.searchMeal(foodName);
        final nutritionFuture = GeminiService.getNutrition(foodName);

        _meals = await mealsFuture;
        _nutrition = await nutritionFuture;
      }

      _state = ResultState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ResultState.error;
    }
    notifyListeners();
  }
}
