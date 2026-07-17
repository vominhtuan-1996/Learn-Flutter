import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper class cho marker management & coordinate conversion.
class MarkerHelper {
  /// Kiểm tra xem một marker ID có tồn tại trong danh sách markers không.
  static bool markerExists(Set<Marker> markers, String markerId) {
    return markers.any((m) => m.markerId.value == markerId);
  }

  /// Tìm marker theo ID.
  static Marker? findMarkerById(Set<Marker> markers, String markerId) {
    try {
      return markers.firstWhere((m) => m.markerId.value == markerId);
    } catch (_) {
      return null;
    }
  }

  /// Lấy tất cả marker IDs.
  static List<String> getAllMarkerIds(Set<Marker> markers) {
    return markers.map((m) => m.markerId.value).toList();
  }

  /// Lọc markers theo điều kiện.
  static List<Marker> filterMarkers(
    Set<Marker> markers,
    bool Function(Marker) predicate,
  ) {
    return markers.where(predicate).toList();
  }

  /// Tìm marker gần nhất với một tọa độ.
  static Marker? findNearestMarker(Set<Marker> markers, LatLng position) {
    if (markers.isEmpty) return null;

    Marker? nearest;
    double minDistance = double.infinity;

    for (final marker in markers) {
      final distance = calculateDistance(position, marker.position);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = marker;
      }
    }

    return nearest;
  }

  /// Tính khoảng cách giữa 2 điểm (Haversine formula).
  /// Trả về khoảng cách tính bằng km.
  static double calculateDistance(LatLng point1, LatLng point2) {
    const earthRadiusKm = 6371.0;

    final lat1Rad = _degreesToRadians(point1.latitude);
    final lat2Rad = _degreesToRadians(point2.latitude);
    final deltaLat = _degreesToRadians(point2.latitude - point1.latitude);
    final deltaLng = _degreesToRadians(point2.longitude - point1.longitude);

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Tính độ chênh từ LatLng (dùng cho distance display).
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)}m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)}km';
    } else {
      return '${km.toStringAsFixed(0)}km';
    }
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

/// Extension tiện ích để convert LatLng tọa độ bản đồ.
/// Lưu ý: Cần access GoogleMapController để convert screen coordinates.
extension MarkerInfoWindowHelper on LatLng {
  /// Estimate screen position dựa trên camera position.
  /// Đây là approximation, không chính xác 100% vì phép chiếu Mercator.
  Offset estimateScreenPosition(
    LatLng cameraCenter,
    double zoom,
    Size screenSize,
  ) {
    const tileSize = 256.0; // Google Maps tile size

    // Convert to tile coordinates
    final cameraTile = _latLngToTile(cameraCenter, zoom);
    final markerTile = _latLngToTile(this, zoom);

    // Calculate pixel offset from camera
    final pixelDx = (markerTile.dx - cameraTile.dx) * tileSize;
    final pixelDy = (markerTile.dy - cameraTile.dy) * tileSize;

    // Center on screen
    final screenDx = screenSize.width / 2 + pixelDx;
    final screenDy = screenSize.height / 2 + pixelDy;

    return Offset(screenDx, screenDy);
  }

  static Offset _latLngToTile(LatLng latLng, double zoom) {
    final scale = math.pow(2, zoom) as double;

    final x = ((latLng.longitude + 180) / 360) * scale;

    final sinLat = math.sin(latLng.latitude * math.pi / 180);
    final y = ((1 - math.log((1 + sinLat) / (1 - sinLat)) / (2 * math.pi)) / 2) *
        scale;

    return Offset(x, y);
  }
}
