import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xml/xml.dart';

/// [GoogleMapKmlExporter] chịu trách nhiệm chuyển đổi danh sách các đối tượng Google Maps
/// (Marker, Polyline, Polygon) thành chuỗi XML định dạng KML chuẩn.
class GoogleMapKmlExporter {
  /// [export] nhận vào tên tài liệu và các tập hợp đối tượng bản đồ, trả về chuỗi KML.
  static String export({
    String documentName = 'Exported Map Data',
    Set<Marker> markers = const {},
    Set<Polyline> polylines = const {},
    Set<Polygon> polygons = const {},
  }) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('kml',
        attributes: {'xmlns': 'http://www.opengis.net/kml/2.2'}, nest: () {
      builder.element('Document', nest: () {
        builder.element('name', nest: documentName);

        // 1. Export Markers (Points)
        for (var marker in markers) {
          builder.element('Placemark', nest: () {
            builder.element('name', nest: marker.infoWindow.title ?? 'Marker');
            if (marker.infoWindow.snippet != null) {
              builder.element('description', nest: marker.infoWindow.snippet);
            }
            builder.element('Point', nest: () {
              builder.element('coordinates',
                  nest:
                      '${marker.position.longitude},${marker.position.latitude},0');
            });
          });
        }

        // 2. Export Polylines (LineStrings)
        for (var polyline in polylines) {
          builder.element('Placemark', nest: () {
            builder.element('name',
                nest: 'Polyline ${polyline.polylineId.value}');
            builder.element('LineString', nest: () {
              builder.element('extrude', nest: '1');
              builder.element('tessellate', nest: '1');
              builder.element('coordinates',
                  nest: _formatPoints(polyline.points));
            });
          });
        }

        // 3. Export Polygons
        for (var polygon in polygons) {
          builder.element('Placemark', nest: () {
            builder.element('name', nest: 'Polygon ${polygon.polygonId.value}');
            builder.element('Polygon', nest: () {
              builder.element('outerBoundaryIs', nest: () {
                builder.element('LinearRing', nest: () {
                  builder.element('coordinates',
                      nest: _formatPoints(polygon.points));
                });
              });
            });
          });
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// [_formatPoints] chuyển đổi danh sách LatLng thành chuỗi "lon,lat,alt" phân cách bởi khoảng trắng.
  static String _formatPoints(List<LatLng> points) {
    return points
        .map((p) => '${p.longitude},${p.latitude},0')
        .join('\n          ');
  }
}
