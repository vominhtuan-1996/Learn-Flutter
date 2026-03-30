---
description: Quy trình xây dựng feature Google Map cho phép ghim tọa độ (Marker) và lưu offline (Hive), có nút di chuyển tới vị trí thiết bị.
---

# Google Map Offline Pin Workflow

Workflow này hướng dẫn xây dựng tính năng bản đồ Google Map với khả năng ghim vị trí (Pin) và lưu trữ cục bộ (Offline) bằng Hive, kèm theo chức năng di chuyển đến vị trí hiện tại của thiết bị.

---

## Bước 1 – Cấu hình Dependency

Đảm bảo `pubspec.yaml` đã có các gói sau:

```yaml
dependencies:
  google_maps_flutter: ^2.12.3
  geolocator: ^13.0.4
  hive_flutter: ^1.1.0
  flutter_bloc: ^8.0.1 # Sử dụng Cubit để quản lý state
```

---

## Bước 2 – Định nghĩa Model cho Pin (Offline)

Tạo file model để lưu trữ tọa độ vào Hive.

Tạo file: `lib/features/map/models/map_pin_model.dart`

```dart
import 'package:hive/hive.dart';

part 'map_pin_model.g.dart';

@HiveType(typeId: 0)
class MapPinModel {
  @HiveField(0)
  final double latitude;
  
  @HiveField(1)
  final double longitude;
  
  @HiveField(2)
  final String? title;

  MapPinModel({
    required this.latitude,
    required this.longitude,
    this.title,
  });
}
```
*Lưu ý: Chạy `flutter pub run build_runner build` để tạo file `.g.dart` nếu cần.*

---

## Bước 3 – Xây dựng Cubit Quản lý Pin

Cubit này sẽ xử lý việc load pin từ Hive khi init và save pin mới khi người dùng ghim lên bản đồ.

Tạo file: `lib/features/map/cubit/map_offline_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/map_pin_model.dart';

class MapOfflineState {
  final List<MapPinModel> pins;
  MapOfflineState({this.pins = const []});
}

class MapOfflineCubit extends Cubit<MapOfflineState> {
  MapOfflineCubit() : super(MapOfflineState()) {
    _initHive();
  }

  static const String boxName = 'map_pins_box';

  Future<void> _initHive() async {
    final box = await Hive.openBox<MapPinModel>(boxName);
    emit(MapOfflineState(pins: box.values.toList()));
  }

  Future<void> addPin(double lat, double lng) async {
    final box = Hive.box<MapPinModel>(boxName);
    final newPin = MapPinModel(
      latitude: lat,
      longitude: lng,
      title: 'Pin ${state.pins.length + 1}',
    );
    await box.add(newPin);
    emit(MapOfflineState(pins: box.values.toList()));
  }

  Future<void> clearAllPins() async {
    final box = Hive.box<MapPinModel>(boxName);
    await box.clear();
    emit(MapOfflineState(pins: []));
  }
}
```

---

## Bước 4 – Xây dựng Giao diện Google Map

Màn hình này tích hợp Google Map, nút "Go to Location" và xử lý sự kiện `onTap` để ghim pin.

Tạo file: `lib/features/map/google_map_offline/google_map_offline_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../cubit/map_offline_cubit.dart';

class GoogleMapOfflineScreen extends StatefulWidget {
  const GoogleMapOfflineScreen({super.key});

  @override
  State<GoogleMapOfflineScreen> createState() => _GoogleMapOfflineScreenState();
}

class _GoogleMapOfflineScreenState extends State<GoogleMapOfflineScreen> {
  GoogleMapController? _mapController;

  static const CameraPosition _kDefaultCenter = CameraPosition(
    target: LatLng(21.0285, 105.8542), // Hà Nội
    zoom: 14.0,
  );

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
      debugPrint("Lỗi khi lấy vị trí: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapOfflineCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Offline Pin Map'),
          actions: [
            BlocBuilder<MapOfflineCubit, MapOfflineState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => context.read<MapOfflineCubit>().clearAllPins(),
                );
              },
            )
          ],
        ),
        body: Stack(
          children: [
            BlocBuilder<MapOfflineCubit, MapOfflineState>(
              builder: (context, state) {
                // Chuyển đổi Model sang Marker của Google Maps
                Set<Marker> markers = state.pins.map((pin) {
                  return Marker(
                    markerId: MarkerId('${pin.latitude}_${pin.longitude}'),
                    position: LatLng(pin.latitude, pin.longitude),
                    infoWindow: InfoWindow(title: pin.title),
                  );
                }).toSet();

                return GoogleMap(
                  initialCameraPosition: _kDefaultCenter,
                  onMapCreated: (controller) => _mapController = controller,
                  markers: markers,
                  onTap: (latLng) {
                    context.read<MapOfflineCubit>().addPin(
                          latLng.latitude,
                          latLng.longitude,
                        );
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                );
              },
            ),
            // Nút Goto Location Device
            Positioned(
              bottom: 100,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'btnLocation',
                onPressed: _gotoLocationDevice,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Bước 5 – Đăng ký Route và Test

1. Mở `lib/shared/widgets/routes/route.dart`.
2. Đăng ký `static const String googleMapOffline = 'google_map_offline';`.
3. Thêm case vào `generateRoute`.
4. Thêm nút bấm vào `TestScreen` để mở màn hình mới.

---

## Bước 6 – Kiểm tra và Xác nhận

1. **Ghim Offline**: Thử ghim vài điểm, tắt app, mở lại xem các điểm ghim còn không.
2. **Offline**: Tắt Wifi/4G, thực hiện ghim tọa độ. Đảm bảo UI vẫn hoạt động và lưu được vào Hive.
3. **Goto Location**: Bấm nút vị trí, camera phải di chuyển về tọa độ GPS hiện tại.
