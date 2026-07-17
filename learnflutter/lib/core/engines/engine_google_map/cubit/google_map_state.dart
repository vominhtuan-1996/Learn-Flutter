import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/engines/engine_google_map/models/map_overlay_models.dart';

/// Trạng thái hiển thị bản đồ.
enum MapDisplayStatus { idle, loading, error }

/// State của GoogleMapCubit – Lưu toàn bộ dữ liệu overlay (Markers, Polylines, Polygons)
/// và các thông tin UI như MapType, camera position, trạng thái loading.
///
/// Sử dụng [Equatable] để Cubit chỉ rebuild khi dữ liệu thực sự thay đổi.
/// Các [Set] được convert sang [List] khi so sánh props vì [Set] không implement equality theo thứ tự.
class GoogleMapState extends Equatable {
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;
  final Set<Heatmap> heatmaps;
  final Set<Marker> clusteredMarkers; // Markers được render sau khi qua cluster engine
  final bool clusterEnabled;         // Bật/tắt auto clustering
  final MapType mapType;
  final bool isFullScreen;
  final bool is3DMode;
  final MapDisplayStatus status;
  final String? errorMessage;
  final CameraPosition? currentCameraPosition;

  // Custom info window state
  final String? selectedMarkerId;
  final CustomMarkerData? selectedMarkerData;
  final bool showInfoWindow;

  const GoogleMapState({
    this.markers = const {},
    this.polylines = const {},
    this.polygons = const {},
    this.heatmaps = const {},
    this.clusteredMarkers = const {},
    this.clusterEnabled = true,
    this.mapType = MapType.normal,
    this.isFullScreen = false,
    this.is3DMode = false,
    this.status = MapDisplayStatus.idle,
    this.errorMessage,
    this.currentCameraPosition,
    this.selectedMarkerId,
    this.selectedMarkerData,
    this.showInfoWindow = false,
  });

  factory GoogleMapState.initial() => const GoogleMapState();

  /// Tạo bản sao với các trường được cập nhật.
  GoogleMapState copyWith({
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Polygon>? polygons,
    Set<Heatmap>? heatmaps,
    Set<Marker>? clusteredMarkers,
    bool? clusterEnabled,
    MapType? mapType,
    bool? isFullScreen,
    bool? is3DMode,
    MapDisplayStatus? status,
    String? errorMessage,
    CameraPosition? currentCameraPosition,
    String? selectedMarkerId,
    CustomMarkerData? selectedMarkerData,
    bool? showInfoWindow,
  }) {
    return GoogleMapState(
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      polygons: polygons ?? this.polygons,
      heatmaps: heatmaps ?? this.heatmaps,
      clusteredMarkers: clusteredMarkers ?? this.clusteredMarkers,
      clusterEnabled: clusterEnabled ?? this.clusterEnabled,
      mapType: mapType ?? this.mapType,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      is3DMode: is3DMode ?? this.is3DMode,
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentCameraPosition: currentCameraPosition ?? this.currentCameraPosition,
      selectedMarkerId: selectedMarkerId ?? this.selectedMarkerId,
      selectedMarkerData: selectedMarkerData ?? this.selectedMarkerData,
      showInfoWindow: showInfoWindow ?? this.showInfoWindow,
    );
  }

  bool get hasData => markers.isNotEmpty || polylines.isNotEmpty || polygons.isNotEmpty || heatmaps.isNotEmpty;

  /// Markers thực sự render ra màn hình: nếu cluster bật dùng clusteredMarkers, ngược lại dùng markers gốc.
  Set<Marker> get displayMarkers => clusterEnabled ? clusteredMarkers : markers;

  @override
  List<Object?> get props => [
        markers.map((m) => m.markerId.value).toList()..sort(),
        clusteredMarkers.map((m) => m.markerId.value).toList()..sort(),
        clusterEnabled,
        polylines.map((p) => p.polylineId.value).toList()..sort(),
        polygons.map((p) => p.polygonId.value).toList()..sort(),
        heatmaps.map((h) => h.heatmapId.value).toList()..sort(),
        mapType,
        isFullScreen,
        is3DMode,
        status,
        errorMessage,
        currentCameraPosition,
        selectedMarkerId,
        selectedMarkerData?.title,
        selectedMarkerData?.description,
        showInfoWindow,
      ];
}
