// ignore_for_file: prefer_const_constructors

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';

/// [MapTileStyle] định nghĩa các loại tile style có thể dùng với CARTO Basemaps.
/// CARTO cung cấp tile miễn phí, không cần API key, giao diện đẹp tương tự Mapbox.
enum MapTileStyle {
  voyager,
  dark,
  light,
  satellite,
}

extension MapTileStyleExtension on MapTileStyle {
  String get label {
    switch (this) {
      case MapTileStyle.voyager:
        return 'Voyager';
      case MapTileStyle.dark:
        return 'Dark';
      case MapTileStyle.light:
        return 'Light';
      case MapTileStyle.satellite:
        return 'Satellite';
    }
  }

  IconData get icon {
    switch (this) {
      case MapTileStyle.voyager:
        return Icons.map_outlined;
      case MapTileStyle.dark:
        return Icons.dark_mode_outlined;
      case MapTileStyle.light:
        return Icons.light_mode_outlined;
      case MapTileStyle.satellite:
        return Icons.satellite_alt_outlined;
    }
  }

  /// [urlTemplate] trả về URL tile tương ứng với style.
  /// CARTO Basemaps: miễn phí, không cần API key, chất lượng cao.
  /// Satellite dùng OpenStreetMap (không có satellite thực từ CARTO free).
  String get urlTemplate {
    switch (this) {
      case MapTileStyle.voyager:
        // Giống Mapbox Streets — màu sắc tươi sáng, dễ đọc
        return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
      case MapTileStyle.dark:
        // Dark mode đẹp — phù hợp ứng dụng ban đêm
        return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
      case MapTileStyle.light:
        // Light sạch sẽ — phù hợp ứng dụng ban ngày
        return 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
      case MapTileStyle.satellite:
        // OpenStreetMap — fallback khi không có satellite miễn phí
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }
}

/// [FlutterMapOsmScreen] là màn hình bản đồ sử dụng flutter_map với CARTO Basemaps.
/// CARTO cung cấp tile miễn phí, không cần API key, chất lượng tương đương Mapbox.
/// Hỗ trợ chuyển đổi 4 style bản đồ, hiển thị Marker và Polyline.
class FlutterMapOsmScreen extends StatefulWidget {
  const FlutterMapOsmScreen({super.key});

  @override
  State<FlutterMapOsmScreen> createState() => _FlutterMapOsmScreenState();
}

class _FlutterMapOsmScreenState extends State<FlutterMapOsmScreen> {
  /// [_mapController] điều khiển camera bản đồ từ code.
  final MapController _mapController = MapController();

  /// [_currentStyle] theo dõi style tile đang hiển thị.
  MapTileStyle _currentStyle = MapTileStyle.voyager;

  /// [_markers] danh sách điểm đánh dấu trên bản đồ.
  final List<Marker> _markers = [
    Marker(
      point: LatLng(21.0278, 105.8342), // Hà Nội
      width: 44,
      height: 44,
      child: _MarkerPin(color: Colors.red, label: 'HN'),
    ),
    Marker(
      point: LatLng(10.8231, 106.6297), // TP.HCM
      width: 44,
      height: 44,
      child: _MarkerPin(color: Colors.blue, label: 'HCM'),
    ),
    Marker(
      point: LatLng(16.0544, 108.2022), // Đà Nẵng
      width: 44,
      height: 44,
      child: _MarkerPin(color: Colors.green, label: 'ĐN'),
    ),
  ];

  /// [_polylinePoints] tập hợp toạ độ vẽ tuyến đường Bắc – Trung – Nam.
  final List<LatLng> _polylinePoints = [
    LatLng(21.0278, 105.8342),
    LatLng(16.0544, 108.2022),
    LatLng(10.8231, 106.6297),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: const Text('CARTO Basemap (Free)'),
        actions: [
          /// Nút fly-to vị trí Hà Nội.
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Hà Nội',
            onPressed: () => _mapController.move(LatLng(21.0278, 105.8342), 12.0),
          ),
          /// Nút fly-to vị trí TP.HCM.
          IconButton(
            icon: const Icon(Icons.south),
            tooltip: 'TP.HCM',
            onPressed: () => _mapController.move(LatLng(10.8231, 106.6297), 12.0),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Bản đồ chính.
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(16.0, 107.0),
              initialZoom: 5.5,
              minZoom: 3.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      '📍 ${point.latitude.toStringAsFixed(5)}, '
                      '${point.longitude.toStringAsFixed(5)}',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            children: [
              /// [TileLayer] sử dụng CARTO Basemaps — miễn phí, không cần token.
              TileLayer(
                urlTemplate: _currentStyle.urlTemplate,
                userAgentPackageName: 'com.example.learnflutter',
                maxZoom: 19,
              ),

              /// [PolylineLayer] vẽ tuyến đường Bắc – Trung – Nam.
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _polylinePoints,
                    strokeWidth: 3.5,
                    color: Colors.orange.withOpacity(0.85),
                    borderStrokeWidth: 1.0,
                    borderColor: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),

              /// [MarkerLayer] hiển thị các pin tại toạ độ được định nghĩa.
              MarkerLayer(markers: _markers),
            ],
          ),

          /// Panel chọn style bản đồ — góc dưới bên phải.
          Positioned(
            bottom: 24,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MapTileStyle.values.map((style) {
                final isSelected = _currentStyle == style;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _currentStyle = style),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      width: isSelected ? 108 : 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            style.icon,
                            size: 20,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Text(
                              style.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          /// Badge nguồn dữ liệu — góc dưới bên trái.
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _currentStyle == MapTileStyle.satellite
                    ? '© OpenStreetMap'
                    : '© CARTO  © OpenStreetMap',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// [_MarkerPin] là widget pin đánh dấu tuỳ chỉnh với màu và nhãn chữ.
class _MarkerPin extends StatelessWidget {
  final Color color;
  final String label;

  const _MarkerPin({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePainter(color: color),
        ),
      ],
    );
  }
}

/// [_TrianglePainter] vẽ mũi nhọn phía dưới của pin marker.
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
