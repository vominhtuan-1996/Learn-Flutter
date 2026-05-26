import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// [ClusterItem] – Data model gắn với 1 điểm nguồn trước khi được cluster.
/// Mỗi item mang theo dữ liệu gốc [T] để tiện hiển thị InfoWindow hoặc xử lý tap.
class ClusterItem<T> {
  final String id;
  final LatLng position;
  final T? data;

  const ClusterItem({
    required this.id,
    required this.position,
    this.data,
  });
}

/// [ClusterGroup] – Đại diện cho 1 nhóm Cluster sau khi được gom.
/// - Nếu [isCluster] = true: có nhiều điểm → vẽ bubble "Nx".
/// - Nếu [isCluster] = false: chỉ 1 điểm → vẽ marker đơn lẻ.
class ClusterGroup {
  final String id;
  final LatLng position; // Tọa độ trung tâm cluster
  final int count; // Số lượng điểm trong cluster
  final List<ClusterItem> items; // Danh sách điểm gốc

  const ClusterGroup({
    required this.id,
    required this.position,
    required this.count,
    required this.items,
  });

  bool get isCluster => count > 1;
}

/// [GoogleMapClusterEngine] – Công cụ tính toán cluster thuần Dart.
///
/// Sử dụng thuật toán **Grid-based clustering**: chia màn hình thành ô lưới theo zoom level.
/// Các điểm rơi vào cùng 1 ô lưới sẽ được gom lại thành 1 cluster.
/// Thuật toán O(n) theo số markers, phù hợp với tập dữ liệu tới 5000+ điểm.
class GoogleMapClusterEngine {
  /// Kích thước ô lưới (theo đơn vị tọa độ) tại mỗi mức zoom.
  /// Zoom càng cao → ô lưới càng nhỏ → cluster ít điểm hơn.
  static double _gridSizeForZoom(double zoom) {
    if (zoom >= 17) return 0.001;
    if (zoom >= 15) return 0.003;
    if (zoom >= 13) return 0.01;
    if (zoom >= 11) return 0.03;
    if (zoom >= 9) return 0.1;
    if (zoom >= 7) return 0.3;
    return 1.0;
  }

  /// Tính toán và trả về danh sách [ClusterGroup] từ [items] tại [zoomLevel].
  static List<ClusterGroup> compute({
    required List<ClusterItem> items,
    required double zoomLevel,
  }) {
    if (items.isEmpty) return [];

    final gridSize = _gridSizeForZoom(zoomLevel);
    final Map<String, List<ClusterItem>> cells = {};

    for (final item in items) {
      final cellLat = (item.position.latitude / gridSize).floor();
      final cellLng = (item.position.longitude / gridSize).floor();
      final key = '$cellLat:$cellLng';
      cells.putIfAbsent(key, () => []).add(item);
    }

    final clusters = <ClusterGroup>[];
    for (final entry in cells.entries) {
      final cellItems = entry.value;
      final centerLat = cellItems.map((i) => i.position.latitude).reduce((a, b) => a + b) / cellItems.length;
      final centerLng = cellItems.map((i) => i.position.longitude).reduce((a, b) => a + b) / cellItems.length;

      clusters.add(ClusterGroup(
        id: 'cluster_${entry.key}',
        position: LatLng(centerLat, centerLng),
        count: cellItems.length,
        items: cellItems,
      ));
    }

    return clusters;
  }

  /// Tạo [BitmapDescriptor] cho bubble cluster có số đếm hiển thị.
  /// - size 1: bubble nhỏ (< 10 điểm)
  /// - size 2: bubble vừa (10–50)
  /// - size 3: bubble lớn (50+)
  static Future<BitmapDescriptor> buildClusterBitmap(
    int count, {
    Color color = const Color(0xFF2563EB),
  }) async {
    final int size = count < 10 ? 80 : count < 50 ? 100 : 120;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Vòng tròn ngoài (shadow / ring)
    final shadowPaint = Paint()..color = color.withOpacity(0.25);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, shadowPaint);

    // Vòng tròn chính
    final circlePaint = Paint()..color = color;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.5, circlePaint);

    // Text số đếm
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: count > 99 ? '99+' : count.toString(),
      style: TextStyle(
        color: Colors.white,
        fontSize: size / 3.5,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2),
    );

    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
