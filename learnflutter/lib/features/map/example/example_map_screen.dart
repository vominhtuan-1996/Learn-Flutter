import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/utils/dialog_utils.dart';
import 'package:learnflutter/features/web_view/street_view_screen.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';

/// [ExampleMapScreen] là màn hình hiển thị bản đồ sử dụng thư viện google_maps_flutter.
/// Màn hình này thay thế flutter_map trước đó để tận dụng các tính năng cao cấp của Google Maps
/// như dữ liệu địa điểm phong phú, bản đồ vệ tinh chất lượng cao và khả năng tương tác mượt mà.
/// Chúng ta vẫn giữ nguyên logic xử lý Markers, Polylines và tích hợp Street View khi người dùng tap.
class ExampleMapScreen extends StatefulWidget {
  const ExampleMapScreen({super.key});

  @override
  State<ExampleMapScreen> createState() => _ExampleMapScreenState();
}

class _ExampleMapScreenState extends State<ExampleMapScreen> {
  /// [Completer] được dùng để giữ instance của [GoogleMapController].
  /// Việc dùng Completer đảm bảo chúng ta chỉ thực hiện các thao tác điều khiển
  /// (như animateCamera) sau khi bản đồ đã hoàn tất quá trình khởi tạo trên thiết bị.
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  /// [CameraPosition] xác định toạ độ và mức zoom khởi tạo ban đầu.
  /// Chúng ta hướng camera về trung tâm Việt Nam để bao quát toàn bộ lãnh thổ.
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(16.0, 107.0),
    zoom: 5.5,
  );

  /// [_markers] trong Google Maps sử dụng [Set<Marker>] thay vì danh sách.
  /// Mỗi marker yêu cầu một [markerId] duy nhất để hệ thống phân biệt và quản lý trạng thái.
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

  /// [_polylines] định nghĩa tập hợp các đoạn đường vẽ nối tiếp nhau.
  /// Google Maps quản lý polylines qua [Set<Polyline>], cho phép tuỳ chỉnh độ dày,
  /// màu sắc và kiểu vẽ (đứt đoạn, liền mạch) một cách linh hoạt.
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

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: const Text('Google Maps Example'),
        actions: [
          /// Nút quay về Hà Nội sử dụng [animateCamera] để tạo hiệu ứng di chuyển mượt mà.
          /// Việc gọi [Completer.future] đảm bảo controller đã sẵn sàng trước khi thực thi lệnh.
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
        /// [mapType] thiết lập hiển thị bản đồ dạng vệ tinh để giống với TileLayer ban đầu.
        mapType: MapType.satellite,
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        polylines: _polylines,

        /// [onTap] nhận toạ độ nơi người dùng nhấn và mở Street View tương ứng.
        /// Sử dụng [DialogUtils] để hiển thị nội dung Street View trong một Bottom Sheet kéo dãn được.
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

        /// Các tính năng mặc định được hỗ trợ tốt bởi Google Maps SDK.
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }
}
