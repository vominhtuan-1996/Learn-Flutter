# Custom Markers & Info Windows Guide

Hướng dẫn đầy đủ về hệ thống custom markers với rich info window và action buttons.

## 📋 Tính năng

✅ **Custom Marker Data** — Thông tin chi tiết (title, description, image, status)  
✅ **Status Indicators** — Online/Offline/Busy/Warning/Error states  
✅ **Action Buttons** — Call, Message, Navigate, Favorite, Delete, etc.  
✅ **Real-time Updates** — Cập nhật status động  
✅ **Rich UI** — Avatar, status badge, custom actions  
✅ **Helper Utilities** — Distance calculation, marker filtering  

---

## 🚀 Quick Start

### 1. Tạo marker với custom data

```dart
final marker = MarkerConfig(
  id: 'marker_1',
  position: const LatLng(21.0285, 105.8542),
  title: 'Restaurant A',
  customData: const CustomMarkerData(
    title: 'Restaurant A',
    description: '⭐⭐⭐⭐⭐ Vietnamese Cuisine',
    subtitle: 'Ba Đình, Hà Nội',
    imageUrl: 'https://example.com/image.jpg',
    status: MarkerStatus.online,
  ),
);
```

### 2. Thêm actions tới marker

```dart
final marker = MarkerConfig(
  // ... basic config ...
  customData: CustomMarkerData(
    title: 'Restaurant',
    description: 'Great food!',
    status: MarkerStatus.online,
    actions: [
      MarkerActionButton(
        id: 'call',
        label: 'Gọi',
        icon: Icons.phone,
        color: Colors.green,
        onPressed: () => print('Calling...'),
      ),
      MarkerActionButton(
        id: 'navigate',
        label: 'Chỉ đường',
        icon: Icons.directions,
        color: Colors.blue,
        onPressed: () => print('Navigating...'),
      ),
    ],
  ),
);
```

### 3. Hiển thị custom info window

```dart
// Khi tap marker, show info window
onMarkerTapped: (markerId) {
  final marker = findMarkerConfig(markerId);
  mapCubit.showMarkerInfo(markerId, marker.customData);
}

// Trong build, render info window
BlocBuilder<GoogleMapCubit, GoogleMapState>(
  builder: (context, state) {
    return Stack(
      children: [
        GoogleMap(
          // ... map config ...
          onMarkerTapped: onMarkerTapped,
        ),
        if (state.showInfoWindow && state.selectedMarkerData != null)
          CustomMarkerInfoWindow(
            markerData: state.selectedMarkerData!,
            position: _calculateScreenPosition(),
            onClose: () => mapCubit.hideMarkerInfo(),
          ),
        if (state.showInfoWindow)
          CustomMarkerInfoOverlay(
            onDismiss: () => mapCubit.hideMarkerInfo(),
          ),
      ],
    );
  },
);
```

---

## 📊 Models

### MarkerStatus

```dart
enum MarkerStatus {
  online,      // ✅ Green - Active/Available
  offline,     // ⚫ Gray - Inactive
  busy,        // 🟡 Yellow - Occupied
  idle,        // 🔵 Blue - Waiting
  warning,     // 🟠 Orange - Issue detected
  error,       // 🔴 Red - Error state
}
```

### CustomMarkerData

```dart
const CustomMarkerData(
  title: String,              // Tên chính (bắt buộc)
  description: String,        // Mô tả ngắn (bắt buộc)
  imageUrl: String?,          // URL ảnh thumbnail
  subtitle: String?,          // Thông tin phụ (quốc gia, vị trí, etc.)
  status: MarkerStatus,       // Trạng thái marker
  metadata: Map?,             // Dữ liệu tùy chỉnh (object info, stats, etc.)
  actions: List<MarkerActionButton>, // Danh sách actions
)
```

### MarkerActionButton

```dart
const MarkerActionButton(
  id: String,                 // Unique ID
  label: String,              // Text hiển thị
  icon: IconData,             // Icon
  color: Color,               // Màu button
  onPressed: VoidCallback,    // Callback khi tap
)
```

---

## 🛠️ Helper Methods

### MarkerHelper

```dart
// Kiểm tra marker có tồn tại
MarkerHelper.markerExists(markers, 'marker_1');

// Tìm marker theo ID
final marker = MarkerHelper.findMarkerById(markers, 'marker_1');

// Lấy tất cả marker IDs
final ids = MarkerHelper.getAllMarkerIds(markers);

// Lọc markers
final filtered = MarkerHelper.filterMarkers(
  markers,
  (m) => m.position.latitude > 21.0,
);

// Tìm marker gần nhất
final nearest = MarkerHelper.findNearestMarker(
  markers,
  const LatLng(21.0285, 105.8542),
);

// Tính khoảng cách (km)
final distance = MarkerHelper.calculateDistance(
  const LatLng(21.0285, 105.8542),
  const LatLng(21.0350, 105.8600),
);

// Format khoảng cách
final formatted = MarkerHelper.formatDistance(2.5); // "2.5km"
```

### MarkerInfoWindowHelper (Extension)

```dart
// Estimate screen position từ LatLng
final screenPos = markerLatLng.estimateScreenPosition(
  cameraCenter,
  zoom,
  screenSize,
);
```

---

## 🎯 Real-world Examples

### Example 1: Delivery Tracking

```dart
// Tạo markers cho delivery drivers
final deliveryMarkers = [
  MarkerConfig(
    id: 'driver_1',
    position: driverLatLng,
    customData: CustomMarkerData(
      title: 'Shipper A',
      description: '5 deliveries in progress',
      status: MarkerStatus.busy,
      actions: [
        MarkerActionButton(
          id: 'call',
          label: 'Gọi',
          icon: Icons.phone,
          onPressed: () => _callDriver('driver_1'),
        ),
        MarkerActionButton(
          id: 'track',
          label: 'Track',
          icon: Icons.map,
          onPressed: () => _navigateToDetail('driver_1'),
        ),
      ],
    ),
  ),
];
```

### Example 2: Real-time Status Update

```dart
// Update marker status khi có thay đổi
void updateDriverStatus(String driverId, MarkerStatus newStatus) {
  final oldConfig = findMarkerConfig(driverId);
  final newData = oldConfig.customData!.copyWith(
    status: newStatus,
  );
  
  final updatedConfig = MarkerConfig(
    // ... keep other fields ...
    customData: newData,
  );
  
  mapCubit.updateMarker(updatedConfig);
}

// Extension để copy CustomMarkerData
extension CustomMarkerDataCopy on CustomMarkerData {
  CustomMarkerData copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? subtitle,
    MarkerStatus? status,
    Map<String, dynamic>? metadata,
    List<MarkerActionButton>? actions,
  }) {
    return CustomMarkerData(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      actions: actions ?? this.actions,
    );
  }
}
```

### Example 3: Location-based Actions

```dart
// Tìm restaurant gần nhất và navigate
final nearestRestaurant = MarkerHelper.findNearestMarker(
  restaurantMarkers,
  userLatLng,
);

if (nearestRestaurant != null) {
  final distance = MarkerHelper.calculateDistance(
    userLatLng,
    nearestRestaurant.position,
  );
  
  mapCubit.showMarkerInfo(
    nearestRestaurant.markerId.value,
    CustomMarkerData(
      // ... with distance info ...
      description: 'Khoảng cách: ${MarkerHelper.formatDistance(distance)}',
    ),
  );
}
```

---

## 🎨 UI Customization

### Info Window Colors

Status badge colors:
```dart
• online:  #10B981 (Green)
• offline: #6B7280 (Gray)
• busy:    #F59E0B (Amber)
• idle:    #3B82F6 (Blue)
• warning: #EF4444 (Red)
• error:   #DC2626 (Dark Red)
```

### Sizing

```dart
• Card width:      240px
• Image height:    100px
• Max title lines: 2
• Max desc lines:  2
• Action buttons:  28px height, up to 4 per row
```

---

## 🔧 Integration Pattern

### Complete Example

```dart
class GoogleMapWithCustomMarkers extends StatefulWidget {
  @override
  State<GoogleMapWithCustomMarkers> createState() =>
      _GoogleMapWithCustomMarkersState();
}

class _GoogleMapWithCustomMarkersState extends State<GoogleMapWithCustomMarkers> {
  late GoogleMapCubit _mapCubit;
  late Map<String, MarkerConfig> _markerConfigs;

  @override
  void initState() {
    super.initState();
    _mapCubit = context.read<GoogleMapCubit>();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    _markerConfigs = {
      'marker_1': _createMarkerConfig('marker_1'),
      'marker_2': _createMarkerConfig('marker_2'),
    };
    
    _mapCubit.addMarkers(
      _markerConfigs.values.toList(),
    );
  }

  void _onMarkerTapped(MarkerId markerId) {
    final config = _markerConfigs[markerId.value];
    if (config != null) {
      _mapCubit.showMarkerInfo(markerId.value, config.customData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoogleMapCubit, GoogleMapState>(
      builder: (context, state) {
        return Stack(
          children: [
            GoogleMap(
              markers: state.displayMarkers,
              onMarkerTapped: _onMarkerTapped,
              // ... other config ...
            ),
            if (state.showInfoWindow && state.selectedMarkerData != null)
              CustomMarkerInfoWindow(
                markerData: state.selectedMarkerData!,
                position: _calculatePosition(state.selectedMarkerId!),
                onClose: () => _mapCubit.hideMarkerInfo(),
              ),
            if (state.showInfoWindow)
              CustomMarkerInfoOverlay(
                onDismiss: () => _mapCubit.hideMarkerInfo(),
              ),
          ],
        );
      },
    );
  }

  Offset _calculatePosition(String markerId) {
    // Tính screen position từ marker config
    // Hoặc dùng estimateScreenPosition extension
    return const Offset(0, 0);
  }
}
```

---

## 📝 API Reference

### GoogleMapCubit Methods

```dart
// Show/hide custom info window
mapCubit.showMarkerInfo(String markerId, CustomMarkerData? data);
mapCubit.hideMarkerInfo();
mapCubit.toggleMarkerInfo(String markerId, CustomMarkerData? data);

// Update marker
mapCubit.updateMarker(MarkerConfig config);
```

### GoogleMapState Properties

```dart
state.selectedMarkerId     // Marker hiện được select
state.selectedMarkerData   // Custom data của marker được select
state.showInfoWindow       // Info window có đang show không
state.displayMarkers       // Markers render hiện tại (cluster hoặc normal)
```

---

## 🐛 Troubleshooting

**Q: Info window không hiển thị?**  
A: Kiểm tra:
- `state.showInfoWindow` phải là `true`
- `state.selectedMarkerData` không được `null`
- `CustomMarkerInfoOverlay` phải được stack dưới `CustomMarkerInfoWindow`

**Q: Position info window không chính xác?**  
A: Dùng `estimateScreenPosition` extension từ marker LatLng

**Q: Actions không respond?**  
A: Kiểm tra `onPressed` callback được gán đúng

**Q: Status color không thay đổi?**  
A: Update marker bằng `mapCubit.updateMarker()` với status mới

---

## 📚 Files

- `models/map_overlay_models.dart` — Model definitions
- `cubit/google_map_cubit.dart` — State management
- `cubit/google_map_state.dart` — State definition
- `widgets/custom_marker_info_window.dart` — UI components
- `extensions/marker_extensions.dart` — Helper utilities
- `example_custom_marker_usage.dart` — Usage examples

