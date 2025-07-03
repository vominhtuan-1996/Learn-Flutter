import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';

import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class VietnamMapScreen extends StatefulWidget {
  @override
  _VietnamMapScreenState createState() => _VietnamMapScreenState();
}

class _VietnamMapScreenState extends State<VietnamMapScreen> {
  List<Polygon> _polygons = [];
  Map<Polygon, String> _polygonToProvinceName = {};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      loadGeoJson(await rootBundle.loadString('assets/json/vietnam.geo.json'));
      loadGeoJson(await rootBundle.loadString('assets/json/vietname_praraces_islands.geo.json'));
      loadGeoJson(await rootBundle.loadString('assets/json/vietname_spratly_islands.geo.json'));
    });
    super.initState();
  }

  Future<void> loadGeoJson(String data) async {
    final jsonData = json.decode(data);
    final features = jsonData['features'] as List;

    final rand = Random();

    for (var feature in features) {
      final props = feature['properties'];
      final name = props['NAME_1'];

      final geometry = feature['geometry'];
      final coordsList = geometry['coordinates'];

      if (geometry['type'] == 'Polygon') {
        final coords = coordsList[0]; // Single polygon
        final points = coords.map<LatLng>((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();

        final color = Colors.primaries[rand.nextInt(Colors.primaries.length)].withOpacity(0.4);

        final polygon = Polygon(
          points: points,
          color: color,
          borderColor: Colors.black,
          borderStrokeWidth: 0.5,
          // isFilled: true,
          label: name,
        );

        _polygons.add(polygon);
        _polygonToProvinceName[polygon] = name;
      }

      if (geometry['type'] == 'MultiPolygon') {
        final multiCoords = geometry['coordinates'] as List;
        for (final polygonCoords in multiCoords) {
          final coords = polygonCoords[0]; // lấy ring ngoài
          final points = coords.map<LatLng>((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();

          _polygons.add(Polygon(
            points: points,
            color: Colors.primaries[rand.nextInt(Colors.primaries.length)].withOpacity(0.4),
            borderStrokeWidth: 1,
            borderColor: Colors.black,
            // isFilled: true,
            label: name,
          ));
        }
      }

      // Nếu bạn muốn hỗ trợ MultiPolygon → có thể mở rộng ở đây
    }

    setState(() {});
  }

  LatLng _calculateCentroid(List<LatLng> points) {
    double lat = 0;
    double lng = 0;
    for (final point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  List<Marker> _createProvinceLabels(List<Polygon> polygons) {
    return polygons.map((polygon) {
      final name = polygon.label ?? 'Unknown'; // Gán từ đâu đó
      final center = _calculateCentroid(polygon.points);

      return Marker(
          point: center,
          width: 100,
          height: 30,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ));
    }).toList();
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;

    for (int i = 0; i < polygon.length - 1; i++) {
      LatLng a = polygon[i];
      LatLng b = polygon[i + 1];

      double px = point.longitude;
      double py = point.latitude;
      double ax = a.longitude;
      double ay = a.latitude;
      double bx = b.longitude;
      double by = b.latitude;

      if (((ay > py) != (by > py))) {
        double atX = (bx - ax) * (py - ay) / (by - ay + 0.0000001) + ax;
        if (px < atX) {
          intersectCount++;
        }
      }
    }

    return (intersectCount % 2 == 1);
  }

  void _handleTap(LatLng tappedPoint) {
    _polygonToProvinceName.forEach((polygon, name) {
      final polygonPoints = polygon.points;
      if (isPointInPolygon(tappedPoint, polygonPoints)) {
        // final center = _calculateCentroid(polygonPoints);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped: $name')),
        );
        // break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(16.320352, 105.469695),
          initialZoom: 5.8,
          minZoom: 5.8,
          maxZoom: 16,
          onTap: (tapPosition, point) {
            // Xử lý sự kiện tap tại đây
            _handleTap(point);
          }, // Bắt buộc để Polygon tương tác được
          onPositionChanged: (pos, _) {
            // Optional: debug zoom
          },
        ),
        // maxBounds: LatLngBounds(
        //   LatLng(7.752425, 98.308897), // góc dưới bên trái (phuket thailand)
        //   LatLng(24.159292, 121.298139), // góc trên bên phải (taiwan)
        // ),
        // enableScrollWheel: false,
        // interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.doubleTapZoom | InteractiveFlag.drag),
        children: [
          // TileLayer(
          //   urlTemplate: 'http://sgx.geodatenzentrum.de/wmts_topplus_open/tile/1.0.0/web/default/WEBMERCATOR/{z}/{y}/{x}.png',
          //   subdomains: ['a', 'b', 'c'],
          //   maxZoom: 19,
          // ),
          PolygonLayer(
            polygons: _polygons,
            polygonCulling: false,
          ),
          // MarkerLayer(
          //   markers: _createProvinceLabels(_polygons),
          // ),
        ],
      ),
    );
  }
}
