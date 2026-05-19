import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/camera/model/camera_mode.dart';
import 'circle_icon_button.dart';

/// Thanh công cụ phía trên hiển thị nút đóng, chỉ số thời lượng video,
/// và các phím tắt cài đặt flash/xoay camera.
class CameraTopBar extends StatelessWidget {
  final CameraMode mode;
  final bool isRecording;
  final bool isPaused;
  final Duration recDuration;
  final IconData flashIcon;
  final VoidCallback onFlashTap;
  final VoidCallback onFlipTap;
  final VoidCallback onCloseTap;

  const CameraTopBar({
    super.key,
    required this.mode,
    required this.isRecording,
    required this.isPaused,
    required this.recDuration,
    required this.flashIcon,
    required this.onFlashTap,
    required this.onFlipTap,
    required this.onCloseTap,
  });

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
      '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleIconButton(
            icon: Icons.close,
            onTap: onCloseTap,
          ),
          if (mode == CameraMode.video && (isRecording || isPaused))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _fmt(recDuration),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )
          else
            const SizedBox(width: 44),
          Row(
            children: [
              CircleIconButton(icon: flashIcon, onTap: onFlashTap),
              const SizedBox(width: 8),
              CircleIconButton(icon: Icons.flip_camera_ios, onTap: onFlipTap),
            ],
          ),
        ],
      ),
    );
  }
}
