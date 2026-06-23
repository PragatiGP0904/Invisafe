import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// Standardized camera pipeline shared by every scanning module.
///
/// The three source apps each set up CameraX independently (P used
/// ImageAnalysis, K a Compose PreviewView, U declared CameraX but never used
/// it). This service centralizes permission handling, controller lifecycle and
/// still capture, and degrades gracefully when no camera is available
/// (emulators / desktop) so the demo flows still run.
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _available = false;

  CameraController? get controller => _controller;
  bool get isAvailable => _available && _controller != null;

  /// Requests permission and initializes the requested lens. Returns true on
  /// success; false (without throwing) if permission denied or no camera.
  Future<bool> initialize({
    CameraLensDirection lens = CameraLensDirection.back,
    ResolutionPreset preset = ResolutionPreset.high,
  }) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _available = false;
        return false;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _available = false;
        return false;
      }

      final selected = _cameras.firstWhere(
        (c) => c.lensDirection == lens,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        selected,
        preset,
        enableAudio: false,
      );
      await controller.initialize();
      _controller = controller;
      _available = true;
      return true;
    } catch (_) {
      // Graceful fallback: modules render a placeholder preview instead.
      _available = false;
      return false;
    }
  }

  /// Captures a still frame. Returns the file path or null on failure.
  Future<String?> capture() async {
    if (!isAvailable) return null;
    try {
      final file = await _controller!.takePicture();
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _available = false;
  }
}
