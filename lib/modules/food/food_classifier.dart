/// Food classifier.
///
/// The original InviSafeP wired a TFLite ImageClassifier + Gemini client but
/// the active scan flow returned a scripted sequence (Apple → Biscuit →
/// Banana) because `model.tflite` was absent. We reproduce that scripted demo
/// here. Swap [classify] for `tflite_flutter` inference when a model is added.
class FoodClassifier {
  int _index = 0;
  static const List<String> _demoSequence = ['Apple', 'Biscuit', 'Banana'];

  /// Returns the next demo food label, cycling through the sequence.
  String classify({String? imagePath}) {
    final label = _demoSequence[_index % _demoSequence.length];
    _index++;
    return label;
  }
}
