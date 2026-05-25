import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/qr_code/overlay/cccd_scan_overlay.dart';
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_blinking_border_overlay.dart';
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_border.dart';
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_laser_overlay.dart';
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_rotating_border_overlay.dart';
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_zigzag_overlay.dart';

/// Màn hình demo trực quan tất cả overlay trong `core/services/qr_code/overlay`.
///
/// Mỗi overlay được render trên một "fake camera" (nền tối + grid) để có thể
/// thấy hiệu ứng mà không cần quyền camera thật.
class QrOverlaysDemoScreen extends StatelessWidget {
  const QrOverlaysDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double boxSize = 260;
    final laserKey = GlobalKey<QRScanLaserOverlayState>();

    final items = <_OverlayDemo>[
      _OverlayDemo(
        title: 'QRBorderOverlay',
        description: 'Khung 4 góc L — chuẩn quét QR.',
        builder: (_) => const QRBorderOverlay(
          scanAreaSize: boxSize,
          borderLength: 28,
          strokeWidth: 5,
          borderColor: Colors.greenAccent,
        ),
        // Overlay này tự lấy MediaQuery, nên cần khung full-size riêng.
        fullSize: true,
      ),
      _OverlayDemo(
        title: 'QRScanLaserOverlay',
        description: 'Tia laser chạy dọc + shadow gradient. Bấm để stop/resume.',
        builder: (_) => QRScanLaserOverlay(
          key: laserKey,
          size: const Size(boxSize, boxSize),
        ),
        onTap: () {
          final s = laserKey.currentState;
          if (s == null) return;
          s.stop();
          Future.delayed(const Duration(seconds: 1), s.resume);
        },
      ),
      _OverlayDemo(
        title: 'BlinkingBorderOverlay',
        description: 'Viền nhấp nháy opacity 0.2 ↔ 1.0.',
        builder: (_) => const BlinkingBorderOverlay(width: boxSize, height: boxSize),
      ),
      _OverlayDemo(
        title: 'RotatingBorderOverlay',
        description: 'Viền xoay liên tục 4s/vòng.',
        builder: (_) => const RotatingBorderOverlay(width: boxSize, height: boxSize),
      ),
      _OverlayDemo(
        title: 'ZigZagLaserOverlay',
        description: 'Tia laser zigzag chạy dọc.',
        builder: (_) => const ZigZagLaserOverlay(width: boxSize, height: boxSize),
      ),
      _OverlayDemo(
        title: 'CccdScanOverlay',
        description: 'Khung CCCD/CMND tỉ lệ 1.58:1.',
        builder: (_) => const SizedBox(
          width: boxSize,
          height: boxSize,
          child: CccdScanOverlay(),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Overlays Demo'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _OverlayCard(item: items[index], boxSize: boxSize),
      ),
    );
  }
}

class _OverlayDemo {
  const _OverlayDemo({
    required this.title,
    required this.description,
    required this.builder,
    this.onTap,
    this.fullSize = false,
  });

  final String title;
  final String description;
  final WidgetBuilder builder;
  final VoidCallback? onTap;

  /// Nếu true: overlay tự dùng `MediaQuery.size` (ví dụ `QRBorderOverlay`),
  /// cần wrap trong `SizedBox` cố định và `MediaQuery` lồng.
  final bool fullSize;
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({required this.item, required this.boxSize});

  final _OverlayDemo item;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    Widget overlay = item.builder(context);
    if (item.fullSize) {
      overlay = MediaQuery(
        data: MediaQueryData(size: Size(boxSize + 60, boxSize + 60)),
        child: overlay,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: item.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: boxSize + 60,
                height: boxSize + 60,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const _FakeCameraBackground(),
                    overlay,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nền giả camera: vài đường grid trắng mờ cho thấy overlay đang nằm trên ảnh nền.
class _FakeCameraBackground extends StatelessWidget {
  const _FakeCameraBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
