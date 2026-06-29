import 'package:flutter/material.dart';
import 'package:submission/model/meal_model.dart';

class DetailPage extends StatelessWidget {
  final MealModel meal;
  const DetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(meal.strMeal),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image
              if (meal.strMealThumb != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    meal.strMealThumb!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              const SizedBox(height: 16),

              // Ingredients
              Text(
                'Ingredients',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(meal.ingredients.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${meal.ingredients[i]}'
                          '${meal.measures[i].isNotEmpty ? ' — ${meal.measures[i]}' : ''}',
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Instructions
              if (meal.strInstructions != null &&
                  meal.strInstructions!.isNotEmpty) ...[
                Text(
                  'Instructions',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(meal.strInstructions!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
