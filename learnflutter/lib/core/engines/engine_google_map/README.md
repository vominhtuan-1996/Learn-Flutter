# 🗺 Google Map Engine Suite (v1.0)

Bộ công cụ `engine_google_map` là một giải pháp bản đồ toàn diện (Comprehensive Map Solution) dành cho Flutter, được xây dựng theo kiến trúc Clean Architecture & BLoC Pattern.

Nó cung cấp một bộ điều khiển trung tâm (`GoogleMapCubit`) hoàn toàn độc lập với UI, cho phép bạn dễ dàng tích hợp bản đồ với các tính năng nâng cao như **Auto-Clustering**, **CRUD Overlays** (Markers, Polylines, Polygons), và **Xử lý luồng nền (Isolates)** mà không bị giật lag (Jank-free).

---

## 🌟 Tính năng nổi bật

1. **Kiến trúc BLoC (State Management)**: Tách biệt hoàn toàn logic bản đồ (Camera, Overlays) khỏi UI. Bạn có thể tương tác với bản đồ từ bất kỳ đâu thông qua `GoogleMapCubit`.
2. **Auto-Clustering (Gom cụm tự động)**: Xử lý mượt mà hàng nghìn Marker trên bản đồ nhờ thuật toán gom cụm (Clustering) thông minh. Hiển thị mượt mà ở mọi cấp độ Zoom.
3. **Quản lý Overlays chuẩn CRUD**: Hỗ trợ thêm (Add), sửa (Update), xóa (Remove) các Marker, Polyline, Polygon và **Heatmap** một cách dễ dàng.
4. **Isolate Processing (Tương thích Dữ liệu Khổng lồ)**: Tích hợp sẵn cơ chế nạp dữ liệu Polygon/Marker qua Isolate (sử dụng `AppIsolateHandler`), kết hợp kỹ thuật **Progressive Batch Rendering** (nạp theo từng lô nhỏ) để vẽ hàng trăm ranh giới, hàng nghìn điểm tọa độ mà vẫn giữ nguyên **60 FPS**.
5. **Điều khiển Camera linh hoạt**: Các API tiện ích như `goToCurrentLocation()`, `zoomToFitAll()`, `toggle3DMode()`,...

---

## 📦 Cấu trúc Thư mục

```text
lib/core/engine_google_map/
├── cubit/
│   ├── google_map_cubit.dart     # Bộ điều khiển trung tâm (Logic)
│   └── google_map_state.dart     # Trạng thái bản đồ (Models, Settings)
├── models/
│   ├── map_overlay_models.dart   # MarkerConfig, PolylineConfig, PolygonConfig, HeatmapConfig
│   └── cluster_engine.dart       # Engine tính toán gom cụm điểm (Clustering)
├── engine_google_map.dart        # File xuất khẩu tập trung (Barrel file)
└── README.md                     # Tài liệu hướng dẫn sử dụng (File này)
```

---

## 🚀 Hướng dẫn Sử dụng Căn bản

### 1. Khởi tạo và Hiển thị Bản đồ

Sử dụng `BlocProvider` để cấp phát `GoogleMapCubit` cho màn hình của bạn, sau đó sử dụng `BlocBuilder` để lặp lại (re-build) UI mỗi khi State thay đổi.

```dart
import 'package:learnflutter/core/engine_google_map/engine_google_map.dart';

// Bọc màn hình bằng BlocProvider
class MyMapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoogleMapCubit(),
      child: const MyMapBody(),
    );
  }
}

class MyMapBody extends StatelessWidget {
  const MyMapBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GoogleMapCubit>();

    return Scaffold(
      body: BlocBuilder<GoogleMapCubit, GoogleMapState>(
        builder: (context, state) {
          return GoogleMap(
            // Vị trí mặc định ban đầu
            initialCameraPosition: const CameraPosition(
              target: LatLng(10.7769, 106.7009),
              zoom: 11,
            ),
            
            // Render các Overlays từ State
            markers: state.displayMarkers, // Sử dụng displayMarkers thay vì markers để hỗ trợ Auto-Cluster
            polylines: state.polylines,
            polygons: state.polygons,
            heatmaps: state.heatmaps, // Bản đồ nhiệt
            
            // Cài đặt hiển thị (Thường, Vệ tinh, 3D...)
            mapType: state.mapType,
            
            // Lắng nghe sự kiện Camera
            onMapCreated: cubit.onMapCreated, // Cực kỳ quan trọng: Gắn Controller vào Cubit
            onCameraMove: cubit.onCameraMove, // Dùng để tính toán lại Cluster khi Zoom
          );
        },
      ),
    );
  }
}
```

---

### 2. Quản lý Markers (Ghim tọa độ)

Thay vì phải khởi tạo thủ công class `Marker` của SDK gốc, hãy sử dụng `MarkerConfig`. Class này bọc lại toàn bộ tham số giúp bạn thao tác dễ hơn.

```dart
final cubit = context.read<GoogleMapCubit>();

// Thêm 1 Marker
cubit.addMarker(
  MarkerConfig(
    id: 'store_1',
    position: const LatLng(10.7769, 106.7009),
    title: 'Cửa hàng Trung tâm',
    snippet: 'Đang mở cửa',
    onTap: () {
      print('Nhấn vào cửa hàng!');
    },
  ),
);

// Thêm nhiều Marker cùng lúc
cubit.addMarkers([...danh_sách_config]);

// Cập nhật (Cùng ID)
cubit.updateMarker(MarkerConfig(id: 'store_1', title: 'Đã đóng cửa', ...));

// Xóa Marker
cubit.removeMarker('store_1');

// Xóa tất cả
cubit.clearMarkers();
```

---

### 3. Điều khiển Tính năng Auto-Cluster (Gom Cụm)

Mặc định Auto-Cluster có thể bị tắt. Khi bạn có hàng ngàn Marker, bật Cluster sẽ gom các Marker gần nhau thành 1 cụm có chứa con số đếm (Ví dụ: vòng tròn báo `[12]`).

```dart
// Bật / Tắt Auto Cluster
cubit.toggleCluster(); 

// Lưu ý: Trên UI Widget GoogleMap, phải truyền `state.displayMarkers`
// Nếu Cluster bật -> displayMarkers sẽ chứa các "Cụm tròn".
// Nếu Cluster tắt -> displayMarkers sẽ trả về toàn bộ điểm đơn lẻ gốc.
```

---

### 4. Quản lý Polylines, Polygons & Bản đồ nhiệt (Heatmap)

Sử dụng `PolylineConfig`, `PolygonConfig` và `HeatmapConfig`.

```dart
// Vẽ đường đi (Polyline)
cubit.addPolyline(
  const PolylineConfig(
    id: 'route_1',
    points: [LatLng(10.7, 106.7), LatLng(10.8, 106.8)],
    color: Colors.blue,
    width: 6,
  ),
);

// Vẽ khu vực / vùng ranh giới (Polygon)
cubit.addPolygon(
  const PolygonConfig(
    id: 'zone_hcm',
    points: [...danh_sách_toạ_độ_đường_viền],
    strokeColor: Colors.red,
    fillColor: Color(0x33FF0000), // Nên dùng màu có mã Alpha trong suốt (VD: 0x33)
    strokeWidth: 2,
  ),
);

// Vẽ bản đồ nhiệt (Heatmap)
cubit.addHeatmap(
  HeatmapConfig(
    id: 'heatmap_demo',
    data: [
      WeightedLatLng(LatLng(10.7769, 106.7009), weight: 1),
      WeightedLatLng(LatLng(10.7770, 106.7010), weight: 2),
    ],
    radius: const HeatmapRadius.fromPixels(30),
    gradient: const HeatmapGradient(
      [
        HeatmapGradientColor(Colors.green, 0.2),
        HeatmapGradientColor(Colors.red, 0.8),
      ],
    ),
  ),
);
```

---

### 5. Điều khiển Camera (Camera Operations)

Bản chất của việc dùng BLoC là bạn không bao giờ được phép gọi trực tiếp `GoogleMapController`. Thay vào đó, hãy gọi qua `cubit`.

```dart
// Zoom bao quát tất cả dữ liệu trên Map (Tự tính toán Boundary của Marker/Polygon)
await cubit.zoomToFitAll();

// Zoom và bay về vị trí GPS thiết bị (Tự động xin quyền Location)
await cubit.goToCurrentLocation();

// Chuyển chế độ 3D (Bản đồ nghiêng 75 độ)
cubit.toggle3DMode();

// Thay đổi loại bản đồ
cubit.setMapType(MapType.satellite);
```

---

## ⚡ Tối ưu Hiệu Năng cho Dữ liệu Lớn (Best Practices)

### Vấn đề:
Khi bạn nhận một chuỗi JSON hàng MB (Ví dụ: ranh giới của 100 tỉnh/huyện) và bạn thực hiện hàm `jsonDecode()` kết hợp với vòng lặp `for` để bóc tách toạ độ `(lat,lng)` ngay trên UI Thread (Main Isolate), **giao diện (UI) sẽ bị đóng băng (Jank / Freeze)**. Mọi Spinner quay loading sẽ bị đứng khựng lại.

### Giải pháp (Isolates + Progressive Batch Rendering):
1. **Đọc Asset dạng Binary**: Sử dụng `rootBundle.load()` thay vì `loadString()`.
2. **Đẩy sang Isolate (Luồng nền)**: Sử dụng `AppIsolateHandler` để decode JSON và cấu trúc toàn bộ danh sách `PolygonConfig` hoặc `MarkerConfig` ẩn dưới nền.
3. **Nạp lô (Batching)**: Chia dữ liệu (Ví dụ 168 polygons) thành các đợt nhỏ (20 cái/đợt) và đưa dần lên Map với `Future.delayed(30ms)`.

**Ví dụ Chuẩn mực:**

```dart
// 1. Hàm STATIC bóc tách dữ liệu (Chạy ở Isolate - Không capture BuildContext)
static List<PolygonConfig> _parseJsonBytes(Uint8List bytes) {
  final jsonString = utf8.decode(bytes); // Decode UTF-8 ở Isolate
  final decoded = json.decode(jsonString);
  final List<PolygonConfig> configs = [];
  
  // ... (Vòng lặp extract data và tạo PolygonConfig vào [configs])
  return configs;
}

// 2. Chuyển hàm static vào IsolateHandler
static Future<List<PolygonConfig>> runParsing(Uint8List bytes) async {
  return await AppIsolateHandler().parseJson(() => _parseJsonBytes(bytes));
}

// 3. Quy trình thực thi tại luồng chính (Main Thread)
Future<void> loadBigData() async {
  // A. Tải binary raw
  final byteData = await rootBundle.load('assets/data.json');
  final bytes = byteData.buffer.asUint8List();
  
  // B. Nhận List Models hoàn chỉnh từ Isolate
  final configs = await runParsing(bytes);
  
  // C. Progressive Batch Rendering (Render nhấp nhả tránh Lag)
  final cubit = context.read<GoogleMapCubit>();
  const int batchSize = 20;
  for (int i = 0; i < configs.length; i += batchSize) {
    if (!mounted) break; // An toàn vòng đời Widget
    final chunk = configs.sublist(i, (i + batchSize).clamp(0, configs.length));
    cubit.addPolygons(chunk);
    await Future.delayed(const Duration(milliseconds: 30)); // Nghỉ 2 Frame (~60fps)
  }
  
  // D. Hoàn tất (VD: Zoom to Fit)
  cubit.zoomToFitAll();
}
```

Xem đầy đủ cách triển khai ví dụ này tại: `lib/features/test_screen/google_map_engine_demo_screen.dart`.
