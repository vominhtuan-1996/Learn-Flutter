import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart' show Colors, debugPrint;

/// [GoogleMapKmlData] chứa các thành phần đã được parse từ file KML.
class GoogleMapKmlData {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;
  final List<String> networkLinks;

  GoogleMapKmlData({
    this.markers = const {},
    this.polylines = const {},
    this.polygons = const {},
    this.networkLinks = const [],
  });
}

/// [GoogleMapKmlParser] chịu trách nhiệm chuyển đổi nội dung XML của KML
/// thành các đối tượng Marker, Polyline và Polygon của Google Maps Flutter.
class GoogleMapKmlParser {
  /// [parse] nhận vào một chuỗi String chứa nội dung KML và trả về [GoogleMapKmlData].
  static GoogleMapKmlData parse(String kmlContent) {
    try {
      debugPrint('--- Bắt đầu parse KML ---');
      final document = XmlDocument.parse(kmlContent);
      final markers = <Marker>{};
      final polylines = <Polyline>{};
      final polygons = <Polygon>{};
      final networkLinks = <String>[];

      // 1. Tìm tất cả các thẻ NetworkLink
      final links = document.findAllElements('NetworkLink');
      for (var link in links) {
        final hrefs = link.findAllElements('href');
        if (hrefs.isNotEmpty) {
          final url = hrefs.first.innerText.trim();
          debugPrint('Tìm thấy NetworkLink: $url');
          networkLinks.add(url);
        }
      }

      // 2. Tìm tất cả các thẻ Placemark
      final placemarks = document.findAllElements('Placemark');
      debugPrint('Tìm thấy ${placemarks.length} Placemarks');

      for (var placemark in placemarks) {
        final name = placemark.findElements('name').isNotEmpty
            ? placemark.findElements('name').first.innerText
            : 'Không tên';
        final description = placemark.findElements('description').isNotEmpty
            ? placemark.findElements('description').first.innerText
            : '';

        // Xử lý Point (Marker)
        final points = placemark.findAllElements('Point');
        for (var point in points) {
          final coordElements = point.findElements('coordinates');
          if (coordElements.isNotEmpty) {
            final coords = _parseCoordinates(coordElements.first.innerText);
            if (coords.isNotEmpty) {
              markers.add(
                Marker(
                  markerId: MarkerId(
                      'kml_marker_${markers.length}_${DateTime.now().microsecondsSinceEpoch}'),
                  position: coords.first,
                  infoWindow: InfoWindow(title: name, snippet: description),
                ),
              );
            }
          }
        }

        // Xử lý LineString (Polyline)
        final lineStrings = placemark.findAllElements('LineString');
        for (var line in lineStrings) {
          final coordElements = line.findElements('coordinates');
          if (coordElements.isNotEmpty) {
            final coords = _parseCoordinates(coordElements.first.innerText);
            if (coords.isNotEmpty) {
              polylines.add(
                Polyline(
                  polylineId: PolylineId(
                      'kml_line_${polylines.length}_${DateTime.now().microsecondsSinceEpoch}'),
                  points: coords,
                  color: Colors.blue,
                  width: 4,
                ),
              );
            }
          }
        }

        // Xử lý Polygon
        final polygonElements = placemark.findAllElements('Polygon');
        for (var poly in polygonElements) {
          final outerBoundary = poly.findAllElements('outerBoundaryIs');
          if (outerBoundary.isNotEmpty) {
            final linearRing =
                outerBoundary.first.findAllElements('LinearRing');
            if (linearRing.isNotEmpty) {
              final coordElements =
                  linearRing.first.findElements('coordinates');
              if (coordElements.isNotEmpty) {
                final coords = _parseCoordinates(coordElements.first.innerText);
                if (coords.isNotEmpty) {
                  polygons.add(
                    Polygon(
                      polygonId: PolygonId(
                          'kml_poly_${polygons.length}_${DateTime.now().microsecondsSinceEpoch}'),
                      points: coords,
                      strokeColor: Colors.red,
                      strokeWidth: 2,
                      fillColor: Colors.red.withOpacity(0.2),
                    ),
                  );
                }
              }
            }
          }
        }
      }

      debugPrint(
          'Parse hoàn tất: ${markers.length} Markers, ${polylines.length} Polylines, ${polygons.length} Polygons');
      return GoogleMapKmlData(
        markers: markers,
        polylines: polylines,
        polygons: polygons,
        networkLinks: networkLinks,
      );
    } catch (e) {
      debugPrint('LỖI KHI PARSE KML: $e');
      return GoogleMapKmlData();
    }
  }

  /// [_parseCoordinates] chuyển đổi chuỗi tọa độ KML (lon,lat,alt) thành danh sách [LatLng].
  static List<LatLng> _parseCoordinates(String coordsString) {
    final List<LatLng> latLngs = [];
    // Tách bằng khoảng trắng, tab hoặc xuống dòng
    final pairs = coordsString.trim().split(RegExp(r'[\s\n\r\t]+'));

    for (var pair in pairs) {
      if (pair.isEmpty) continue;
      final parts = pair.split(',');
      if (parts.length >= 2) {
        final lonStr = parts[0].trim();
        final latStr = parts[1].trim();
        final lon = double.tryParse(lonStr);
        final lat = double.tryParse(latStr);
        if (lat != null && lon != null) {
          latLngs.add(LatLng(lat, lon));
        }
      }
    }
    return latLngs;
  }
}
