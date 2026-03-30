import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/utils/dialog_utils.dart';
import 'package:learnflutter/features/web_view/street_view_screen.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

/// [CachedTileProvider] là một implementation của [TileProvider] giúp tự động cache các mảnh bản đồ.
/// Nó kiểm tra xem mảnh bản đồ (tile) đã tồn tại trong bộ nhớ máy chưa, nếu chưa sẽ tải từ URL và lưu lại.
class CachedTileProvider implements TileProvider {
  final Dio _dio = Dio();

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    try {
      if (zoom == null) return TileProvider.noTile;

      // Đường dẫn lưu cache: ~/Documents/map_tiles/{zoom}/{x}/{y}.png
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/map_tiles/$zoom/$x/$y.png';
      final file = File(path);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return Tile(256, 256, bytes);
      }

      // Nếu chưa có, tải từ OpenStreetMap (Ví dụ)
      final url = 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        // Lưu file vào cache (background)
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
        return Tile(256, 256, bytes);
      }
    } catch (e) {
      debugPrint('Error loading tile ($x, $y, $zoom): $e');
    }
    return TileProvider.noTile;
  }
}

/// [ExampleMapScreen] là màn hình hiển thị bản đồ sử dụng thư viện google_maps_flutter.
/// Màn hình này được bổ sung thêm ví dụ về Caching TileOverlay.
class ExampleMapScreen extends StatefulWidget {
  const ExampleMapScreen({super.key});

  @override
  State<ExampleMapScreen> createState() => _ExampleMapScreenState();
}

class _ExampleMapScreenState extends State<ExampleMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(16.0, 107.0),
    zoom: 5.5,
  );

  bool _showCacheLayer = false;

  final Set<Marker> _markers = {
    Marker(
      markerId: const MarkerId('hanoi'),
      position: const LatLng(21.0278, 105.8342),
      infoWindow: const InfoWindow(title: 'Hà Nội'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ),
    Marker(
      markerId: const MarkerId('hcm'),
      position: const LatLng(10.8231, 106.6297),
      infoWindow: const InfoWindow(title: 'TP.HCM'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
    Marker(
      markerId: const MarkerId('danang'),
      position: const LatLng(16.0544, 108.2022),
      infoWindow: const InfoWindow(title: 'Đà Nẵng'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
  };

  late final Set<Polyline> _polylines = {
    Polyline(
      polylineId: const PolylineId('route1'),
      points: const [
        LatLng(21.0278, 105.8342), // Hà Nội
        LatLng(16.0544, 108.2022), // Đà Nẵng
        LatLng(10.8231, 106.6297), // TP.HCM
      ],
      color: Colors.blue.withOpacity(0.7),
      width: 3,
    ),
  };

  /// Định nghĩa TileOverlay sử dụng CachedTileProvider.
  Set<TileOverlay> get _tileOverlays {
    return _showCacheLayer
        ? {
            TileOverlay(
              tileOverlayId: const TileOverlayId('cached_osm'),
              tileProvider: CachedTileProvider(),
            ),
          }
        : {};
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: const Text('Google Maps Caching'),
        actions: [
          /// Nút bật/tắt lớp bản đồ có cache.
          IconButton(
            icon: Icon(
              _showCacheLayer ? Icons.layers_outlined : Icons.layers,
              color: _showCacheLayer ? Colors.blue : null,
            ),
            tooltip: 'Bật/tắt Cached Layer',
            onPressed: () => setState(() => _showCacheLayer = !_showCacheLayer),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Về Hà Nội',
            onPressed: () async {
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(
                    const LatLng(21.0278, 105.8342), 10.0),
              );
            },
          ),
        ],
      ),
      child: GoogleMap(
        mapType: MapType.satellite,
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        polylines: _polylines,
        tileOverlays: _tileOverlays, // Tích hợp lớp cache vào bản đồ
        onTap: (LatLng point) {
          DialogUtils.openDraggableBottomSheet(
            context: context,
            initialSize: 0.7,
            maxSize: 0.7,
            isScrollControlled: true,
            child: StreetViewScreen(
              initialLat: point.latitude,
              initialLng: point.longitude,
              isEmbed: true,
            ),
          );
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }
}
