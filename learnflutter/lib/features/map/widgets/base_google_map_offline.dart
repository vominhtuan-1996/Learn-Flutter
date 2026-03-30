import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Class BaseGoogleMapOffline là một widget nền tảng dùng chung cho các tính năng liên quan đến bản đồ Google Maps trong ứng dụng.
/// Nó giúp chuẩn hóa cách hiển thị bản đồ, quản lý camera và cung cấp các tương tác cơ bản như ghim vị trí và tìm vị trí hiện tại.
/// Việc tách biệt logic hiển thị bản đồ ra một widget dùng chung giúp giảm thiểu việc lặp lại mã nguồn và dễ dàng bảo trì.
class BaseGoogleMapOffline extends StatefulWidget {
  /// Danh sách các markers sẽ được hiển thị trên bản đồ, cho phép các màn hình khác nhau truyền vào dữ liệu ghim riêng biệt.
  final Set<Marker> markers;

  /// Callback được kích hoạt mỗi khi người dùng chạm vào một điểm trên bản đồ để yêu cầu ghim một vị trí mới.
  /// Nó trả về đối tượng LatLng chứa tọa độ chính xác của điểm vừa chạm để lớp cha có thể xử lý logic lưu trữ.
  final Function(LatLng) onMapTap;

  /// Vị trí camera ban đầu khi bản đồ lần đầu được hiển thị, giúp tập trung vào khu vực mục tiêu ngay lập tức.
  final CameraPosition initialCameraPosition;

  /// Cờ xác định xem có hiển thị nút di chuyển tới vị trí thiết bị hay không, tăng tính linh hoạt cho widget.
  final bool showLocationButton;

  /// Cờ xác định xem có tự động tập trung vào vị trí thiết bị khi mới vào hay không.
  final bool focusDeviceOnStart;

  /// Hàm khởi tạo BaseGoogleMapOffline yêu cầu các thông số cấu hình bản đồ và các callback xử lý tương tác.
  /// Tham số markers và onMapTap là bắt buộc để đảm bảo tính năng ghim tọa độ hoạt động đúng như yêu cầu.
  const BaseGoogleMapOffline({
    super.key,
    required this.markers,
    required this.onMapTap,
    this.initialCameraPosition = const CameraPosition(
      target: LatLng(21.0285, 105.8542), // Mặc định Hà Nội
      zoom: 14.0,
    ),
    this.showLocationButton = true,
    this.focusDeviceOnStart = false,
  });

  @override
  State<BaseGoogleMapOffline> createState() => _BaseGoogleMapOfflineState();
}

class _BaseGoogleMapOfflineState extends State<BaseGoogleMapOffline> {
  /// Biến _mapController giữ quyền điều khiển camera bản đồ, cho phép thực hiện các hoạt ảnh di chuyển mượt mà.
  GoogleMapController? _mapController;

  /// Phương thức _gotoLocationDevice lấy tọa độ thực tế của thiết bị và thực hiện hoạt ảnh di chuyển camera tới đó.
  /// Nó sử dụng thư viện Geolocator để truy vấn vị trí GPS với độ chính xác cao nhất có thể tại thời điểm gọi.
  /// Đây là một tính năng tiện ích quan trọng giúp người dùng nhanh chóng định hướng lại vị trí của mình trên bản đồ lớn.
  Future<void> _gotoLocationDevice() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16.0,
        ),
      );
    } catch (e) {
      debugPrint("Lỗi khi lấy vị trí trong BaseMap: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Widget GoogleMap chính hiển thị lớp bản đồ cơ sở và các điểm ghim nhận được từ widget cha thông qua prop markers.
        /// Sự kiện onTap được chuyển tiếp trực tiếp tới callback onMapTap của widget cha để xử lý logic nghiệp vụ riêng.
        GoogleMap(
          initialCameraPosition: widget.initialCameraPosition,
          onMapCreated: (controller) {
            _mapController = controller;
            if (widget.focusDeviceOnStart) {
              _gotoLocationDevice();
            }
          },
          markers: widget.markers,
          onTap: widget.onMapTap,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        /// Nếu showLocationButton được bật, một nút nhấn trôi nổi sẽ xuất hiện ở góc dưới bên phải để hỗ trợ tìm vị trí GPS.
        /// Nút này được bọc trong Positioned để đảm bảo nó luôn nằm cố định trên lớp bản đồ khi người dùng di chuyển hoặc xoay.
        if (widget.showLocationButton)
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'btnBaseLocation',
              tooltip: 'Di chuyển tới vị trí của tôi',
              onPressed: _gotoLocationDevice,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
      ],
    );
  }
}
