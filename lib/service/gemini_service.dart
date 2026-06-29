import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:submission/model/nutrition_model.dart';

class GeminiService {
  static const _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static Future<NutritionModel?> getNutrition(String foodName) async {
    if (_apiKey.isEmpty) return null;
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(
          'Saya adalah suatu mesin yang mampu mengidentifikasi nutrisi atau kandungan gizi pada makanan layaknya uji laboratorium makanan. '
          'Hal yang bisa diidentifikasi adalah kalori, karbohidrat, lemak, serat, dan protein pada makanan. '
          'Satuan dari indikator tersebut berupa gram.',
        ),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'nutrition': Schema.object(
                properties: {
                  'calories': Schema.integer(),
                  'carbs': Schema.integer(),
                  'protein': Schema.integer(),
                  'fat': Schema.integer(),
                  'fiber': Schema.integer(),
                },
                requiredProperties: ['calories', 'carbs', 'protein', 'fat', 'fiber'],
              ),
            },
            requiredProperties: ['nutrition'],
          ),
        ),
      );

      final response = await model.generateContent([
        Content.text('Nama makanannya adalah $foodName.'),
      ]);

      final text = response.text;
      if (text == null || text.isEmpty) return null;

      final json = jsonDecode(text) as Map<String, dynamic>;
      return NutritionModel.fromJson(json['nutrition'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
