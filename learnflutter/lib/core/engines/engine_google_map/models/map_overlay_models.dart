import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Trạng thái của marker (online, offline, busy, idle, etc.)
enum MarkerStatus {
  online,
  offline,
  busy,
  idle,
  warning,
  error,
}

/// Mô tả một nút action trên info window
class MarkerActionButton {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const MarkerActionButton({
    required this.id,
    required this.label,
    required this.icon,
    this.color = const Color(0xFF2563EB),
    required this.onPressed,
  });
}

/// Dữ liệu chi tiết của marker – dùng cho custom info window
class CustomMarkerData {
  final String title;
  final String description;
  final String? imageUrl; // Thumbnail image
  final String? subtitle; // Thông tin phụ (country, location, etc.)
  final MarkerStatus status;
  final Map<String, dynamic>? metadata; // Dữ liệu tùy chỉnh
  final List<MarkerActionButton> actions;

  const CustomMarkerData({
    required this.title,
    required this.description,
    this.imageUrl,
    this.subtitle,
    this.status = MarkerStatus.idle,
    this.metadata,
    this.actions = const [],
  });
}

/// Config tạo Marker – Bọc toàn bộ tham số cần thiết.
class MarkerConfig {
  final String id;
  final LatLng position;
  final String? title;
  final String? snippet;
  final BitmapDescriptor? icon;
  final VoidCallback? onTap;
  final double alpha;
  final bool draggable;
  final void Function(LatLng newPosition)? onDragEnd;

  // Dữ liệu custom cho info window
  final CustomMarkerData? customData;
  final Function(CustomMarkerData)? onShowInfo; // Callback khi show info window

  const MarkerConfig({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
    this.icon,
    this.onTap,
    this.alpha = 1.0,
    this.draggable = false,
    this.onDragEnd,
    this.customData,
    this.onShowInfo,
  });

  Marker toMarker() {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
      onTap: onTap,
      alpha: alpha,
      draggable: draggable,
      onDragEnd: onDragEnd != null ? (pos) => onDragEnd!(pos) : null,
    );
  }
}

/// Config tạo Polyline – đường kẻ trên bản đồ.
class PolylineConfig {
  final String id;
  final List<LatLng> points;
  final Color color;
  final int width;
  final List<PatternItem> patterns;
  final bool geodesic;
  final JointType jointType;

  const PolylineConfig({
    required this.id,
    required this.points,
    this.color = const Color(0xFF2563EB),
    this.width = 4,
    this.patterns = const [],
    this.geodesic = false,
    this.jointType = JointType.round,
  });

  Polyline toPolyline() {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: width,
      patterns: patterns,
      geodesic: geodesic,
      jointType: jointType,
    );
  }
}

/// Config tạo Polygon – vùng khép kín trên bản đồ.
class PolygonConfig {
  final String id;
  final List<LatLng> points;
  final Color strokeColor;
  final Color fillColor;
  final int strokeWidth;
  final List<List<LatLng>> holes;
  final VoidCallback? onTap;

  const PolygonConfig({
    required this.id,
    required this.points,
    this.strokeColor = const Color(0xFF2563EB),
    this.fillColor = const Color(0x402563EB),
    this.strokeWidth = 2,
    this.holes = const [],
    this.onTap,
  });

  Polygon toPolygon() {
    return Polygon(
      polygonId: PolygonId(id),
      points: points,
      strokeColor: strokeColor,
      fillColor: fillColor,
      strokeWidth: strokeWidth,
      holes: holes,
      onTap: onTap,
    );
  }
}

/// Config tạo Heatmap – Bản đồ nhiệt.
class HeatmapConfig {
  final String id;
  final List<WeightedLatLng> data;
  final HeatmapGradient? gradient;
  final HeatmapRadius radius;
  final double opacity;
  final double? maxIntensity;
  final int? minimumZoomIntensity;
  final int? maximumZoomIntensity;

  const HeatmapConfig({
    required this.id,
    required this.data,
    this.gradient,
    this.radius = const HeatmapRadius.fromPixels(20),
    this.opacity = 1.0,
    this.maxIntensity,
    this.minimumZoomIntensity,
    this.maximumZoomIntensity,
  });

  Heatmap toHeatmap() {
    return Heatmap(
      heatmapId: HeatmapId(id),
      data: data,
      gradient: gradient,
      radius: radius,
      opacity: opacity,
      maxIntensity: maxIntensity,
      minimumZoomIntensity: minimumZoomIntensity ?? 0,
      maximumZoomIntensity: maximumZoomIntensity ?? 21,
    );
  }
}
