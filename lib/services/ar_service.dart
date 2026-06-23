import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../core/theme/app_colors.dart';

/// Standardized AR / 3D model rendering logic.
///
/// InviSafeU rendered a GLB pipe model via ARCore + raw OpenGL ES. In the
/// unified Flutter app we standardize on `model_viewer_plus` (which also
/// provides Scene Viewer / Quick Look AR on supported devices). When the model
/// asset is absent (the original `pipe.glb` is missing from the checkout) we
/// fall back to an animated holographic placeholder so the flow still works.
class ArService {
  ArService._();
  static final ArService instance = ArService._();

  /// Registered model assets per module.
  static const Map<String, String> _models = {
    'pipeline': 'assets/models/pipe.glb',
  };

  String? modelFor(String moduleId) => _models[moduleId];

  /// Builds the AR/3D viewer widget for a module. [accent] tints the fallback.
  Widget buildViewer({
    required String moduleId,
    required Color accent,
    String? overlayLabel,
  }) {
    final model = modelFor(moduleId);
    if (model == null) {
      return _Hologram(accent: accent, label: overlayLabel ?? 'AR MODEL');
    }
    return _AssetBackedModelViewer(
      src: model,
      accent: accent,
      fallbackLabel: overlayLabel ?? 'AR MODEL',
    );
  }
}

/// Verifies the GLB is bundled before handing it to the WebView-based renderer.
class _AssetBackedModelViewer extends StatelessWidget {
  final String src;
  final Color accent;
  final String fallbackLabel;
  const _AssetBackedModelViewer({
    required this.src,
    required this.accent,
    required this.fallbackLabel,
  });

  Future<bool> _assetExists() async {
    try {
      await rootBundle.load(src);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator(color: accent)),
          );
        }
        if (snapshot.data != true) {
          return _Hologram(accent: accent, label: fallbackLabel);
        }
        return _GuardedModelViewer(src: src, fallbackLabel: fallbackLabel);
      },
    );
  }
}

/// Renders the bundled GLB through the model-viewer web component.
class _GuardedModelViewer extends StatelessWidget {
  final String src;
  final String fallbackLabel;
  const _GuardedModelViewer({
    required this.src,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      key: ValueKey(src),
      src: src,
      alt: fallbackLabel,
      ar: true,
      autoRotate: true,
      cameraControls: true,
      backgroundColor: AppColors.background,
    );
  }
}

/// Animated holographic placeholder used when no GLB asset is present.
class _Hologram extends StatefulWidget {
  final Color accent;
  final String label;
  const _Hologram({required this.accent, required this.label});

  @override
  State<_Hologram> createState() => _HologramState();
}

class _HologramState extends State<_Hologram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: _c.value * 6.283,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.accent, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: widget.accent.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 4),
                      ],
                    ),
                    child: Icon(Icons.view_in_ar,
                        size: 64, color: widget.accent),
                  ),
                ),
                const SizedBox(height: 16),
                Text('${widget.label} • 3D MODEL UNAVAILABLE',
                    style: TextStyle(
                        color: widget.accent,
                        fontSize: 11,
                        letterSpacing: 1.5)),
                const SizedBox(height: 4),
                const Text('Drop pipe.glb into assets/models/',
                    style:
                        TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              ],
            );
          },
        ),
      ),
    );
  }
}
