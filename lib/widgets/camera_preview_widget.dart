import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/camera_service.dart';

/// Renders the live camera feed from a [CameraService], or a styled placeholder
/// when the camera is unavailable (no permission / emulator / desktop). This
/// lets every scanning module use one preview widget.
class CameraPreviewWidget extends StatelessWidget {
  final CameraService service;
  final Color accent;

  const CameraPreviewWidget({
    super.key,
    required this.service,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (service.isAvailable) {
      return CameraPreview(service.controller!);
    }
    return _Placeholder(accent: accent);
  }
}

class _Placeholder extends StatelessWidget {
  final Color accent;
  const _Placeholder({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_rounded, color: accent, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Camera unavailable — running in demo mode',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
