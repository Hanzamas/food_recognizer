import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:submission/model/food_result.dart';

class ClassifierService {
  static Interpreter? _interpreter;
  static IsolateInterpreter? _isolateInterpreter;
  static List<String> _labels = [];

  static bool get isInitialized => _isolateInterpreter != null;

  static Future<void> init() async {
    _interpreter = await Interpreter.fromAsset('assets/1.tflite');

    _isolateInterpreter = await IsolateInterpreter.create(
      address: _interpreter!.address,
    );

    final labelsRaw = await rootBundle.loadString('assets/labels.txt');
    _labels = labelsRaw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  static Future<FoodResult?> classifyFromPath(String imagePath) async {
    if (_isolateInterpreter == null) return null;

    final imageFile = await img.decodeImageFile(imagePath);
    if (imageFile == null) return null;

    return _runInference(imageFile);
  }

  static Future<FoodResult?> _runInference(img.Image imageFile) async {
    final resized = img.copyResize(imageFile, width: 224, height: 224);

    // Model is uint8 quantized — send raw int pixel values [0, 255]
    // NOT float [0.0, 1.0]
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final px = resized.getPixel(x, y);
            return [px.r.toInt(), px.g.toInt(), px.b.toInt()];
          },
        ),
      ),
    );

    // Output is also uint8: values 0-255 (255 = 100% confidence)
    final outputSize = _interpreter!.getOutputTensor(0).shape[1];
    final output = List.generate(1, (_) => List<int>.filled(outputSize, 0));

    await _isolateInterpreter!.run(input, output);

    final scores = output[0];
    int maxIdx = 0;
    int maxScore = 0;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIdx = i;
      }
    }

    final label = maxIdx < _labels.length ? _labels[maxIdx] : 'Unknown ($maxIdx)';
    // Convert uint8 confidence (0-255) to percentage (0.0-1.0)
    return FoodResult(label: label, confidence: maxScore / 255.0);
  }

  static void dispose() {
    _isolateInterpreter?.close();
    _interpreter?.close();
    _isolateInterpreter = null;
    _interpreter = null;
  }
}
