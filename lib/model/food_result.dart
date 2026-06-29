class FoodResult {
  final String label;
  final double confidence;

  FoodResult({required this.label, required this.confidence});

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(2)}%';
}
