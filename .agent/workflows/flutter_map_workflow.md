---
description: Quy trình tích hợp flutter_map ^8.1.1 và thêm màn hình bản đồ vào test_screen
---

# Flutter Map Workflow

## Tổng quan

Workflow này hướng dẫn cách tạo một màn hình bản đồ mới sử dụng `flutter_map: ^8.1.1`
và đăng ký vào hệ thống routing để có thể truy cập từ `TestScreen`.

---

## Bước 1 – Kiểm tra dependency

Mở `pubspec.yaml` và xác nhận 2 package sau đã có:

```yaml
dependencies:
  flutter_map: ^8.1.1
  latlong2: ^0.9.0
```

Nếu chưa có, thêm vào rồi chạy:

```bash
flutter pub get
```

---

## Bước 2 – Tạo file màn hình bản đồ mới

Tạo file tại: `lib/features/map/<tên_feature>/<tên_feature>_map_screen.dart`

Ví dụ mẫu đầy đủ (chú thích theo chuẩn senior_dev tiếng Việt):

```dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';

/// [ExampleMapScreen] là màn hình hiển thị bản đồ sử dụng flutter_map.
/// Nó minh hoạ cách tích hợp TileLayer (OpenStreetMap), MarkerLayer và PolylineLayer.
/// Màn hình này hoạt động như một template mẫu để mở rộng sang các use case thực tế
/// như hiển thị vị trí GPS, vẽ tuyến đường, hoặc đánh dấu điểm thi công.
class ExampleMapScreen extends StatefulWidget {
  const ExampleMapScreen({super.key});

  @override
  State<ExampleMapScreen> createState() => _ExampleMapScreenState();
}

class _ExampleMapScreenState extends State<ExampleMapScreen> {
  /// [_mapController] được dùng để điều khiển bản đồ theo hướng dẫn lập trình.
  /// Ví dụ: di chuyển camera, thay đổi zoom level, hoặc animate tới toạ độ cụ thể.
  final MapController _mapController = MapController();

  /// [_markers] chứa danh sách các điểm đánh dấu hiển thị trên bản đồ.
  /// Mỗi Marker xác định toạ độ, kích thước và widget con đại diện cho nó.
  final List<Marker> _markers = [
    Marker(
      point: LatLng(21.0278, 105.8342), // Hà Nội
      width: 40,
      height: 40,
      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
    ),
    Marker(
      point: LatLng(10.8231, 106.6297), // TP.HCM
      width: 40,
      height: 40,
      child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
    ),
  ];

  /// [_polylinePoints] xác định tập hợp toạ độ để vẽ đường nối giữa các vị trí.
  /// Phù hợp cho việc hiển thị tuyến đường di chuyển hoặc đường cáp điện.
  final List<LatLng> _polylinePoints = [
    LatLng(21.0278, 105.8342),
    LatLng(16.0544, 108.2022), // Đà Nẵng
    LatLng(10.8231, 106.6297),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(title: const Text('Flutter Map Example')),
      child: FlutterMap(
        /// [mapController] cho phép tương tác với bản đồ từ code (không cần gesture).
        mapController: _mapController,
        options: MapOptions(
          /// [initialCenter] là toạ độ trung tâm bản đồ khi màn hình khởi tạo.
          initialCenter: LatLng(16.0, 107.0),
          initialZoom: 5.5,
          minZoom: 3.0,
          maxZoom: 18.0,
          onTap: (tapPosition, point) {
            /// Xử lý sự kiện người dùng tap lên bản đồ.
            /// Có thể dùng để thêm marker động hoặc chọn vùng địa lý.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tap: ${point.latitude.toStringAsFixed(4)}, '
                  '${point.longitude.toStringAsFixed(4)}',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        children: [
          /// [TileLayer] hiển thị nền bản đồ từ OpenStreetMap (miễn phí, không cần API key).
          /// Có thể thay bằng Google Maps tile, Mapbox hoặc tile server nội bộ.
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.learnflutter',
            maxZoom: 19,
          ),

          /// [PolylineLayer] vẽ đường nối giữa các điểm toạ độ.
          /// Thường dùng để biểu diễn tuyến đường, đường cáp, hoặc hành trình.
          PolylineLayer(
            polylines: [
              Polyline(
                points: _polylinePoints,
                strokeWidth: 3,
                color: Colors.blue.withOpacity(0.7),
              ),
            ],
          ),

          /// [MarkerLayer] hiển thị các widget tại toạ độ xác định trên bản đồ.
          /// Widget con của Marker có thể là Icon, Image, hoặc Container tuỳ chỉnh.
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
    );
  }
}
```

---

## Bước 3 – Đăng ký Route

Mở file `lib/shared/widgets/routes/route.dart`.

### 3.1 – Thêm import

```dart
import 'package:learnflutter/features/map/<tên_feature>/<tên_feature>_map_screen.dart';
```

### 3.2 – Thêm route constant vào class `Routes`

```dart
static const String exampleMapScreen = 'example_map_screen';
```

### 3.3 – Thêm case trong `generateRoute`

```dart
case exampleMapScreen:
  return SlideRightRoute(
    routeSettings: RouteSettings(name: exampleMapScreen),
    builder: (_) => const ExampleMapScreen(),
  );
```

---

## Bước 4 – Thêm nút vào TestScreen

Mở file `lib/features/test_screen/test_screen.dart`.

Thêm `TextButton` vào danh sách `children` của `Column`:

```dart
TextButton(
  onPressed: () {
    Navigator.of(context).pushNamed(Routes.exampleMapScreen);
  },
  child: const Text('Flutter Map Example'),
),
```

> **Vị trí khuyến nghị**: Đặt gần nhóm nút bản đồ hiện có (xung quanh `Routes.mapScreen`).

---

## Bước 5 – Kiểm tra iOS (nếu cần)

`flutter_map` với `TileLayer` cần quyền truy cập network. Kiểm tra `ios/Runner/Info.plist`:

Nếu tile server http (không phải https), thêm:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

> **OpenStreetMap sử dụng https** nên thường không cần thêm cấu hình này.

---

## Bước 6 – Chạy và kiểm tra

```bash
flutter run
```

1. Từ màn hình chính → `TestScreen`
2. Nhấn nút **`Flutter Map Example`**
3. Xác nhận bản đồ hiển thị, marker xuất hiện đúng vị trí
4. Test tap để xem Snackbar tọa độ

---

## Các tính năng mở rộng phổ biến

| Tính năng            | Layer / Widget          | Ghi chú                              |
|----------------------|-------------------------|--------------------------------------|
| Vùng polygon         | `PolygonLayer`          | Xem `map_screen.dart` hiện có        |
| Định vị GPS          | `geolocator` package    | Đã có trong `pubspec.yaml`           |
| Tile server khác     | `TileLayer.urlTemplate` | Mapbox, Google Maps, tile nội bộ     |
| Tương tác polygon    | `onTap` + `isPointInPolygon` | Xem `VietnamMapScreen`         |
| Custom marker widget | `Marker.child`          | Có thể dùng bất kỳ Flutter widget    |
| Fly to location      | `MapController.move()`  | Animation camera đến toạ độ chỉ định |
