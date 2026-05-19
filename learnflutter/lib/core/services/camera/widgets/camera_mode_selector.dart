import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/camera/model/camera_mode.dart';

/// Bộ chọn chế độ (Ảnh/Video) dưới dạng SegmentedButton động, tự động ẩn đi
/// nếu danh sách modes cấu hình chỉ chứa 1 chế độ duy nhất.
class CameraModeSelector extends StatelessWidget {
  final CameraMode currentMode;
  final List<CameraMode> allowedModes;
  final bool isRecording;
  final ValueChanged<CameraMode> onModeChanged;

  const CameraModeSelector({
    super.key,
    required this.currentMode,
    required this.allowedModes,
    required this.isRecording,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (allowedModes.length <= 1) return const SizedBox.shrink();

    final segments = <ButtonSegment<CameraMode>>[];
    if (allowedModes.contains(CameraMode.photo)) {
      segments.add(const ButtonSegment(
        value: CameraMode.photo,
        label: Text('Ảnh'),
        icon: Icon(Icons.photo_camera),
      ));
    }
    if (allowedModes.contains(CameraMode.video)) {
      segments.add(const ButtonSegment(
        value: CameraMode.video,
        label: Text('Video'),
        icon: Icon(Icons.videocam),
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SegmentedButton<CameraMode>(
        style: SegmentedButton.styleFrom(
          foregroundColor: Colors.white,
          selectedForegroundColor: Colors.black,
          selectedBackgroundColor: Colors.white,
          backgroundColor: Colors.black38,
          side: const BorderSide(color: Colors.white54),
        ),
        segments: segments,
        selected: {currentMode},
        onSelectionChanged: (s) {
          if (!isRecording) onModeChanged(s.first);
        },
      ),
    );
  }
}
