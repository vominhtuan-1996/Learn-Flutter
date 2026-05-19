import 'package:flutter/material.dart';

/// Thanh slider zoom mượt mà hiển thị khi thiết bị hỗ trợ điều khiển zoom phần cứng,
/// cho phép người dùng thay thế pinch gesture bằng slider kéo ngang dễ dàng.
class CameraZoomSlider extends StatelessWidget {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onZoomChanged;

  const CameraZoomSlider({
    super.key,
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (maxZoom <= minZoom) return const SizedBox.shrink();
    return Row(
      children: [
        const SizedBox(width: 8),
        const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
        Expanded(
          child: Slider(
            value: currentZoom,
            min: minZoom,
            max: maxZoom,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: onZoomChanged,
          ),
        ),
        const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
        SizedBox(
          width: 42,
          child: Text(
            '${currentZoom.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
