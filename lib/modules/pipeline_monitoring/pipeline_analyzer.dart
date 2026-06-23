import '../../models/detection_result.dart';
import '../../services/inference_service.dart';

/// Pipeline leak / damage analyzer.
///
/// InvisafeU visualized a pipe via ARCore/GLB and used hardcoded report data
/// (Underground Pipeline Risk Report: 26 / 21 / 38 / 15). We reproduce
/// equivalent findings; the AR view is provided by [ArService].
class PipelineAnalyzer extends SimulatedInferenceEngine {
  const PipelineAnalyzer();

  @override
  String get moduleId => 'pipeline';

  static const List<String> stages = [
    'Corrosion',
    'Joint Stress',
    'Leak Risk',
    'Collapse',
  ];
  static const List<double> stageValues = [26, 21, 38, 15];

  @override
  List<DetectionResult> produce(InferenceInput input) {
    return const [
      DetectionResult(
        label: 'Corrosion',
        description: 'Surface corrosion detected along the pipe wall.',
        confidence: 0.78,
        severity: 0.26,
      ),
      DetectionResult(
        label: 'Potential Leak Point',
        description: 'Stress concentration at joint indicating leak risk.',
        confidence: 0.71,
        severity: 0.38,
      ),
    ];
  }
}
