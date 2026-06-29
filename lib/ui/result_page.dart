import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission/controller/result_controller.dart';
import 'package:submission/model/meal_model.dart';
import 'package:submission/model/nutrition_model.dart';
import 'package:submission/ui/detail_page.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;
  const ResultPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResultController()..analyze(imageFile),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Result Page'),
          centerTitle: true,
        ),
        body: SafeArea(child: _ResultBody(imageFile: imageFile)),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final File imageFile;
  const _ResultBody({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResultController>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Food image
          SizedBox(
            height: 280,
            child: Image.file(imageFile, fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ML result
                if (controller.state == ResultState.loading)
                  const Center(child: CircularProgressIndicator())
                else if (controller.state == ResultState.error)
                  Text(
                    'Error: ${controller.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  )
                else if (controller.foodResult != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          controller.foodResult!.label,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        controller.foodResult!.confidencePercent,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Nutrition Card
                  if (controller.nutrition != null) ...[
                    _NutritionCard(nutrition: controller.nutrition!),
                    const SizedBox(height: 16),
                  ],

                  // MealDB Reference
                  if (controller.meals.isNotEmpty) ...[
                    Text(
                      'Reference',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...controller.meals.take(3).map(
                      (meal) => _MealReferenceTile(meal: meal),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final NutritionModel nutrition;
  const _NutritionCard({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Facts',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _NutritionRow('Calories', '${nutrition.calories} g'),
            _NutritionRow('Carbs', '${nutrition.carbs} g'),
            _NutritionRow('Fat', '${nutrition.fat} g'),
            _NutritionRow('Fiber', '${nutrition.fiber} g'),
            _NutritionRow('Protein', '${nutrition.protein} g'),
          ],
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  const _NutritionRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MealReferenceTile extends StatelessWidget {
  final MealModel meal;
  const _MealReferenceTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: meal.strMealThumb != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  meal.strMealThumb!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.food_bank, size: 40),
                ),
              )
            : const Icon(Icons.food_bank, size: 40),
        title: Text(meal.strMeal),
        subtitle: Text(meal.strCategory ?? ''),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailPage(meal: meal)),
        ),
      ),
    );
  }
}
