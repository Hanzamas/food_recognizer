import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:submission/model/food_result.dart';

class ClassifierService {
  static Interpreter? _interpreter;
  static IsolateInterpreter? _isolateInterpreter;
  static List<String> _labels = [];
  static int _numClasses = 2023;

  static bool get isInitialized => _isolateInterpreter != null;

  static Future<void> init() async {
    _interpreter = await Interpreter.fromAsset('assets/1.tflite');

    // Cache output size from model
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    _numClasses = outputShape.length > 1 ? outputShape[1] : 2023;

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

    // Build [1, 224, 224, 3] float input
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final px = resized.getPixel(x, y);
            return [px.r / 255.0, px.g / 255.0, px.b / 255.0];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List<double>.filled(_numClasses, 0.0));

    await _isolateInterpreter!.run(input, output);

    final scores = output[0];
    int maxIdx = 0;
    double maxScore = 0;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIdx = i;
      }
    }

    final label = maxIdx < _labels.length ? _labels[maxIdx] : 'Unknown ($maxIdx)';
    return FoodResult(label: label, confidence: maxScore);
  }

  static void dispose() {
    _isolateInterpreter?.close();
    _interpreter?.close();
    _isolateInterpreter = null;
    _interpreter = null;
  }
}
