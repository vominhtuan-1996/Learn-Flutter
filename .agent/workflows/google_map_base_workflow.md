---
description: Quy trình xây dựng màn hình Google Map cơ bản với các nút chức năng (Location, Map Style, Full Screen) sử dụng Stack.
---

# Google Map Base Workflow

## Tổng quan

Workflow này hướng dẫn cách xây dựng một màn hình bản đồ Google Map tiêu chuẩn, tích hợp các nút điều khiển tùy chỉnh (Custom UI Overlay) bằng cách sử dụng `Stack`. Các tính năng bao gồm:
- Di chuyển tới vị trí hiện tại.
- Thay đổi kiểu bản đồ (Normal, Satellite, Terrain, Hybrid).
- Chế độ xem toàn màn hình (Ẩn/Hiện AppBar và các nút).
- Vẫn duy trì AppBar để quay lại màn hình trước.

---

## Bước 1 – Kiểm tra Dependency

Đảm bảo `pubspec.yaml` đã có các thư viện sau:

```yaml
dependencies:
  google_maps_flutter: ^2.6.0
  geolocator: ^13.0.4
```

Nếu chưa có, hãy thêm vào và chạy `flutter pub get`.

---

## Bước 2 – Cấu hình API Key (Quan trọng)

### 2.1 – Android
Mở `android/app/src/main/AndroidManifest.xml`, thêm vào trong thẻ `<application>`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR_ANDROID_API_KEY_HERE"/>
```

### 2.2 – iOS
Mở `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps
// ...
GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
```

---

## Bước 3 – Tạo màn hình Google Map cơ bản

Tạo file tại: `lib/features/map/google_map_base/google_map_base_screen.dart`

```dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';

/// [GoogleMapBaseScreen] cung cấp một khung nhìn bản đồ Google Maps cơ bản.
/// Nó sử dụng [Stack] để đè các nút chức năng như: Vị trí hiện tại, Đổi style, Toàn màn hình.
/// Màn hình này vẫn giữ Appbar để đảm bảo tính điều hướng (Back) của ứng dụng.
class GoogleMapBaseScreen extends StatefulWidget {
  const GoogleMapBaseScreen({super.key});

  @override
  State<GoogleMapBaseScreen> createState() => _GoogleMapBaseScreenState();
}

class _GoogleMapBaseScreenState extends State<GoogleMapBaseScreen> {
  late GoogleMapController _mapController;
  
  // Trạng thái cấu hình bản đồ
  MapType _currentMapType = MapType.normal;
  bool _isFullScreen = false;
  
  // Vị trí mặc định (Hà Nội)
  static final CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(21.0285, 105.8542),
    zoom: 14.0,
  );

  /// [_onMapCreated] khởi tạo controller khi bản đồ đã sẵn sàng.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// [_goToCurrentLocation] lấy vị trí GPS hiện tại và di chuyển camera tới đó.
  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        16.0,
      ),
    );
  }

  /// [_toggleMapType] xoay vòng giữa các kiểu bản đồ khác nhau.
  void _toggleMapType() {
    setState(() {
      if (_currentMapType == MapType.normal) {
        _currentMapType = MapType.satellite;
      } else if (_currentMapType == MapType.satellite) {
        _currentMapType = MapType.terrain;
      } else if (_currentMapType == MapType.terrain) {
        _currentMapType = MapType.hybrid;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// [AppBar] sẽ ẩn đi khi người dùng chọn chế độ [Full Screen].
      appBar: _isFullScreen ? null : AppBar(
        title: const Text('Google Map Base'),
        actions: [
          IconButton(
            icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. Lớp Bản đồ (Dưới cùng)
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _kInitialPosition,
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Ẩn mặc định để dùng nút tùy chỉnh
            zoomControlsEnabled: false,
          ),

          // 2. Lớp Nút chức năng (Overlay)
          Positioned(
            top: _isFullScreen ? MediaQuery.of(context).padding.top + 16 : 16,
            right: 16,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.my_location,
                  onPressed: _goToCurrentLocation,
                  tooltip: 'Vị trí hiện tại',
                ),
                const SizedBox(height: 12),
                _buildMapButton(
                  icon: Icons.layers,
                  onPressed: _toggleMapType,
                  tooltip: 'Thay đổi kiểu bản đồ',
                ),
                const SizedBox(height: 12),
                _buildMapButton(
                  icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  onPressed: () => setState(() => _isFullScreen = !_isFullScreen),
                  tooltip: 'Toàn màn hình',
                ),
              ],
            ),
          ),
          
          // Nút Back thủ công khi ở Full Screen (nếu cần)
          if (_isFullScreen)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: _buildMapButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.blueAccent),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
```

---

## Bước 4 – Đăng ký Route

Mở `lib/shared/widgets/routes/route.dart`:

1. Thêm hằng số: `static const String googleMapBase = 'google_map_base';`
2. Thêm case trong `generateRoute`:
```dart
case googleMapBase:
  return SlideRightRoute(
    routeSettings: RouteSettings(name: googleMapBase),
    builder: (_) => const GoogleMapBaseScreen(),
  );
```

---

## Bước 5 – Thêm nút vào TestScreen

Mở `lib/features/test_screen/test_screen.dart`, thêm:

```dart
TextButton(
  onPressed: () {
    Navigator.of(context).pushNamed(Routes.googleMapBase);
  },
  child: const Text('Google Map Base (Custom UI)'),
),
```

---

## Bước 6 – Kiểm tra và Verify

1. Chạy `flutter run`.
2. Kiểm tra log nếu gặp lỗi vể API Key.
3. Thử nghiệm nút **Location**: Đảm bảo camera di chuyển về vị trí hiện tại.
4. Thử nghiệm nút **Layers**: Chuyển đổi giữa các loại MapType.
5. Thử nghiệm **Full Screen**: Kiểm tra AppBar ẩn/hiện và layout các nút có bị lệch không.
