import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cubit/map_offline_cubit.dart';
import '../widgets/base_google_map_offline.dart';

/// Class GoogleMapOfflineScreen thực hiện chức năng hiển thị bản đồ ghim tọa độ offline dựa trên widget nền tảng BaseGoogleMapOffline.
/// Bằng cách sử dụng widget base, màn hình này tập trung hoàn toàn vào việc quản lý trạng thái thông qua Cubit và xử lý logic lưu trữ dữ liệu.
/// Đây là một ví dụ về việc áp dụng tính đóng gói và tái sử dụng thành phần giao diện để duy trì mã nguồn sạch và dễ mở rộng.
class GoogleMapOfflineScreen extends StatefulWidget {
  /// Hàm khởi tạo GoogleMapOfflineScreen hỗ trợ tạo ra màn hình bản đồ ghim tọa độ với cấu hình mặc định.
  /// Việc sử dụng const giúp Flutter tối ưu hóa cây widget bằng cách lưu trữ và tái sử dụng các instance không thay đổi.
  const GoogleMapOfflineScreen({super.key});

  @override
  State<GoogleMapOfflineScreen> createState() => _GoogleMapOfflineScreenState();
}

class _GoogleMapOfflineScreenState extends State<GoogleMapOfflineScreen> {
  @override
  Widget build(BuildContext context) {
    /// Cung cấp MapOfflineCubit để quản lý các điểm ghim trong phạm vi của màn hình này.
    /// Cubit này chịu trách nhiệm tương tác với Hive để đảm bảo dữ liệu ghim được bảo toàn qua các lần khởi động ứng dụng.
    return BlocProvider(
      create: (context) => MapOfflineCubit(),
      child: Scaffold(
        /// AppBar chứa tiêu đề và nút chức năng cho phép người dùng xóa sạch toàn bộ các điểm ghim hiện có một cách nhanh chóng.
        appBar: AppBar(
          title: const Text('Bản đồ Ghim Offline (Base)'),
          actions: [
            BlocBuilder<MapOfflineCubit, MapOfflineState>(
              builder: (context, state) {
                return IconButton(
                  tooltip: 'Xóa tất cả các điểm ghim',
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => context.read<MapOfflineCubit>().clearAllPins(),
                );
              },
            )
          ],
        ),

        /// Sử dụng BaseGoogleMapOffline để hiển thị bản đồ và xử lý các tương tác chạm để ghim vị trí.
        /// Toàn bộ logic hiển thị map và nút vị trí thiết bị đã được đóng gói bên trong widget base này.
        body: BlocBuilder<MapOfflineCubit, MapOfflineState>(
          builder: (context, state) {
            /// Ánh xạ danh sách các điểm ghim từ trạng thái của Cubit sang danh sách các Markers của Google Maps.
            /// Mỗi khi danh sách pins trong Cubit thay đổi, BlocBuilder sẽ kích hoạt việc cập nhật lại bản đồ tự động.
            Set<Marker> markers = state.pins.map((pin) {
              return Marker(
                markerId: MarkerId('${pin.latitude}_${pin.longitude}'),
                position: LatLng(pin.latitude, pin.longitude),
                infoWindow: InfoWindow(title: pin.title),
              );
            }).toSet();

            return BaseGoogleMapOffline(
              markers: markers,
              focusDeviceOnStart: true,

              /// Callback onMapTap được kích hoạt từ BaseGoogleMapOffline mỗi khi người dùng chạm vào bản đồ.
              /// Màn hình cha nhận tọa độ này và gọi Cubit để thực hiện việc thêm và lưu ghim mới vào Hive.
              onMapTap: (latLng) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm ghim tại: (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})'),
                  ),
                );
                // context.read<MapOfflineCubit>().addPin(
                //       latLng.latitude,
                //       latLng.longitude,
                //     );
              },
            );
          },
        ),
      ),
    );
  }
}
