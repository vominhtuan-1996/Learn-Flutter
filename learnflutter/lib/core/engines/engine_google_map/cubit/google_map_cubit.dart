import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';
import 'package:learnflutter/core/engines/engine_google_map/cubit/google_map_state.dart';
import 'package:learnflutter/core/engines/engine_google_map/models/map_overlay_models.dart';
import 'package:learnflutter/core/engines/engine_google_map/models/cluster_engine.dart';

/// [GoogleMapCubit] – Bộ điều khiển trung tâm cho toàn bộ logic nghiệp vụ của bản đồ.
///
/// Cubit này hoàn toàn **độc lập với UI**, có thể tái sử dụng bởi bất kỳ màn hình nào
/// muốn tích hợp Google Maps với các tính năng Overlay (Marker, Polyline, Polygon).
///
/// Sử dụng cặp đôi [GoogleMapController] để thực thi camera operations và
/// [GoogleMapState] để phản chiếu lên UI qua [BlocBuilder].
class GoogleMapCubit extends BaseCubit<GoogleMapState> {
  GoogleMapController? _mapController;

  /// Danh sách ClusterItem gốc (song song với markers) – dùng để tính toán cluster.
  final List<ClusterItem> _clusterItems = [];

  /// Zoom hiện tại của camera, dùng để quyết định độ phân giải cluster.
  double _currentZoom = 12.0;

  GoogleMapCubit() : super(GoogleMapState.initial());

  // ─────────────────────────────────────────────
  // Lifecycle & Controller
  // ─────────────────────────────────────────────

  /// Gọi trong [onMapCreated] của GoogleMap widget để gắn controller.
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  /// Giải phóng controller khi Widget bị dispose.
  void disposeController() {
    _mapController?.dispose();
    _mapController = null;
  }

  // ─────────────────────────────────────────────
  // Camera Operations
  // ─────────────────────────────────────────────

  /// Di chuyển camera đến [position] với [zoom] cụ thể.
  Future<void> animateCameraTo(LatLng position, {double zoom = 14.0}) async {
    await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, zoom));
  }

  /// Di chuyển camera đến vị trí GPS hiện tại của thiết bị.
  Future<void> goToCurrentLocation({double zoom = 16.0}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), zoom),
    );
  }

  /// Tự động zoom để bao quát tất cả markers, polylines và polygons.
  Future<void> zoomToFitAll({double padding = 60.0}) async {
    final allPoints = _collectAllPoints();
    if (allPoints.isEmpty) return;

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        padding,
      ),
    );
  }

  /// Cập nhật vị trí camera hiện tại vào State (gọi từ onCameraMove).
  void onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
    emit(state.copyWith(currentCameraPosition: position));
    if (state.clusterEnabled) {
      _refreshClusters();
    }
  }

  // ─────────────────────────────────────────────
  // Marker CRUD
  // ─────────────────────────────────────────────

  /// Thêm 1 marker mới vào bản đồ theo [MarkerConfig].
  /// Nếu đã tồn tại markerId thì sẽ không thêm lại.
  void addMarker(MarkerConfig config) {
    final newMarkers = Set<Marker>.from(state.markers);
    newMarkers.removeWhere((m) => m.markerId == MarkerId(config.id));
    newMarkers.add(config.toMarker());
    emit(state.copyWith(markers: newMarkers));
  }

  /// Thêm nhiều marker cùng lúc (batch insert).
  void addMarkers(List<MarkerConfig> configs) {
    final newMarkers = Set<Marker>.from(state.markers);
    for (final config in configs) {
      newMarkers.removeWhere((m) => m.markerId == MarkerId(config.id));
      newMarkers.add(config.toMarker());
    }
    emit(state.copyWith(markers: newMarkers));
  }

  /// Cập nhật marker có cùng [id] với dữ liệu mới từ [config].
  void updateMarker(MarkerConfig config) {
    final newMarkers = Set<Marker>.from(state.markers);
    newMarkers.removeWhere((m) => m.markerId == MarkerId(config.id));
    newMarkers.add(config.toMarker());
    emit(state.copyWith(markers: newMarkers));
  }

  /// Xoá marker theo [id].
  void removeMarker(String id) {
    final newMarkers = Set<Marker>.from(state.markers)
      ..removeWhere((m) => m.markerId == MarkerId(id));
    emit(state.copyWith(markers: newMarkers));
  }

  /// Xoá tất cả markers.
  void clearMarkers() => emit(state.copyWith(markers: {}));

  // ─────────────────────────────────────────────
  // Polyline CRUD
  // ─────────────────────────────────────────────

  /// Thêm 1 polyline mới vào bản đồ theo [PolylineConfig].
  void addPolyline(PolylineConfig config) {
    final newPolylines = Set<Polyline>.from(state.polylines);
    newPolylines.removeWhere((p) => p.polylineId == PolylineId(config.id));
    newPolylines.add(config.toPolyline());
    emit(state.copyWith(polylines: newPolylines));
  }

  /// Thêm nhiều polylines cùng lúc (batch insert).
  void addPolylines(List<PolylineConfig> configs) {
    final newPolylines = Set<Polyline>.from(state.polylines);
    for (final config in configs) {
      newPolylines.removeWhere((p) => p.polylineId == PolylineId(config.id));
      newPolylines.add(config.toPolyline());
    }
    emit(state.copyWith(polylines: newPolylines));
  }

  /// Cập nhật polyline có cùng [id] với [config] mới.
  void updatePolyline(PolylineConfig config) {
    final newPolylines = Set<Polyline>.from(state.polylines);
    newPolylines.removeWhere((p) => p.polylineId == PolylineId(config.id));
    newPolylines.add(config.toPolyline());
    emit(state.copyWith(polylines: newPolylines));
  }

  /// Xoá polyline theo [id].
  void removePolyline(String id) {
    final newPolylines = Set<Polyline>.from(state.polylines)
      ..removeWhere((p) => p.polylineId == PolylineId(id));
    emit(state.copyWith(polylines: newPolylines));
  }

  /// Xoá tất cả polylines.
  void clearPolylines() => emit(state.copyWith(polylines: {}));

  // ─────────────────────────────────────────────
  // Polygon CRUD
  // ─────────────────────────────────────────────

  /// Thêm 1 polygon mới vào bản đồ theo [PolygonConfig].
  void addPolygon(PolygonConfig config) {
    final newPolygons = Set<Polygon>.from(state.polygons);
    newPolygons.removeWhere((p) => p.polygonId == PolygonId(config.id));
    newPolygons.add(config.toPolygon());
    emit(state.copyWith(polygons: newPolygons));
  }

  /// Thêm nhiều polygons cùng lúc (batch insert).
  void addPolygons(List<PolygonConfig> configs) {
    final newPolygons = Set<Polygon>.from(state.polygons);
    for (final config in configs) {
      newPolygons.removeWhere((p) => p.polygonId == PolygonId(config.id));
      newPolygons.add(config.toPolygon());
    }
    emit(state.copyWith(polygons: newPolygons));
  }

  /// Cập nhật polygon có cùng [id] với [config] mới.
  void updatePolygon(PolygonConfig config) {
    final newPolygons = Set<Polygon>.from(state.polygons);
    newPolygons.removeWhere((p) => p.polygonId == PolygonId(config.id));
    newPolygons.add(config.toPolygon());
    emit(state.copyWith(polygons: newPolygons));
  }

  /// Xoá polygon theo [id].
  void removePolygon(String id) {
    final newPolygons = Set<Polygon>.from(state.polygons)
      ..removeWhere((p) => p.polygonId == PolygonId(id));
    emit(state.copyWith(polygons: newPolygons));
  }

  /// Xoá tất cả polygons.
  void clearPolygons() => emit(state.copyWith(polygons: {}));

  // ─────────────────────────────────────────────
  // Heatmap CRUD
  // ─────────────────────────────────────────────

  /// Thêm 1 heatmap mới vào bản đồ theo [HeatmapConfig].
  void addHeatmap(HeatmapConfig config) {
    final newHeatmaps = Set<Heatmap>.from(state.heatmaps);
    newHeatmaps.removeWhere((h) => h.heatmapId == HeatmapId(config.id));
    newHeatmaps.add(config.toHeatmap());
    emit(state.copyWith(heatmaps: newHeatmaps));
  }

  /// Thêm nhiều heatmaps cùng lúc.
  void addHeatmaps(List<HeatmapConfig> configs) {
    final newHeatmaps = Set<Heatmap>.from(state.heatmaps);
    for (final config in configs) {
      newHeatmaps.removeWhere((h) => h.heatmapId == HeatmapId(config.id));
      newHeatmaps.add(config.toHeatmap());
    }
    emit(state.copyWith(heatmaps: newHeatmaps));
  }

  /// Cập nhật heatmap.
  void updateHeatmap(HeatmapConfig config) {
    final newHeatmaps = Set<Heatmap>.from(state.heatmaps);
    newHeatmaps.removeWhere((h) => h.heatmapId == HeatmapId(config.id));
    newHeatmaps.add(config.toHeatmap());
    emit(state.copyWith(heatmaps: newHeatmaps));
  }

  /// Xoá heatmap theo [id].
  void removeHeatmap(String id) {
    final newHeatmaps = Set<Heatmap>.from(state.heatmaps)
      ..removeWhere((h) => h.heatmapId == HeatmapId(id));
    emit(state.copyWith(heatmaps: newHeatmaps));
  }

  /// Xoá tất cả heatmaps.
  void clearHeatmaps() => emit(state.copyWith(heatmaps: {}));

  // ─────────────────────────────────────────────
  // Map UI Controls
  // ─────────────────────────────────────────────

  /// Thay đổi kiểu bản đồ (Normal, Satellite, Hybrid, Terrain).
  void setMapType(MapType type) => emit(state.copyWith(mapType: type));

  /// Bật/tắt chế độ Toàn màn hình.
  void toggleFullScreen() => emit(state.copyWith(isFullScreen: !state.isFullScreen));

  /// Bật/tắt chế độ 3D (tilt camera).
  void toggle3DMode() {
    final newIs3D = !state.is3DMode;
    emit(state.copyWith(is3DMode: newIs3D));
    final target = state.currentCameraPosition?.target ?? const LatLng(0, 0);
    final zoom = state.currentCameraPosition?.zoom ?? 14.0;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom, tilt: newIs3D ? 75.0 : 0.0),
      ),
    );
  }

  /// Xoá toàn bộ dữ liệu trên bản đồ.
  void clearAll() {
    _clusterItems.clear();
    emit(state.copyWith(markers: {}, polylines: {}, polygons: {}, heatmaps: {}, clusteredMarkers: {}));
  }

  // ─────────────────────────────────────────────
  // Custom Info Window
  // ─────────────────────────────────────────────

  /// Hiển thị custom info window cho marker được select.
  /// Tìm [CustomMarkerData] từ marker config hoặc dùng default.
  void showMarkerInfo(String markerId, CustomMarkerData? customData) {
    emit(state.copyWith(
      selectedMarkerId: markerId,
      selectedMarkerData: customData,
      showInfoWindow: true,
    ));
  }

  /// Ẩn custom info window.
  void hideMarkerInfo() {
    emit(state.copyWith(
      selectedMarkerId: null,
      selectedMarkerData: null,
      showInfoWindow: false,
    ));
  }

  /// Toggle visibility của custom info window.
  void toggleMarkerInfo(String markerId, CustomMarkerData? customData) {
    if (state.selectedMarkerId == markerId && state.showInfoWindow) {
      hideMarkerInfo();
    } else {
      showMarkerInfo(markerId, customData);
    }
  }

  // ─────────────────────────────────────────────
  // Cluster Controls
  // ─────────────────────────────────────────────

  /// Bật/tắt chế độ auto cluster.
  void toggleCluster() {
    final newEnabled = !state.clusterEnabled;
    emit(state.copyWith(clusterEnabled: newEnabled));
    if (newEnabled) {
      _refreshClusters();
    }
  }

  /// Buộc tính lại cluster với zoom hiện tại (gọi thủ công khi cần).
  void recomputeClusters() => _refreshClusters();

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  List<LatLng> _collectAllPoints() {
    final points = <LatLng>[];
    points.addAll(state.markers.map((m) => m.position));
    for (final p in state.polylines) {
      points.addAll(p.points);
    }
    for (final p in state.polygons) {
      points.addAll(p.points);
    }
    for (final h in state.heatmaps) {
      points.addAll(h.data.map((e) => e.point));
    }
    return points;
  }

  /// Tính toán lại các cluster markers từ [_clusterItems] và zoom hiện tại.
  /// Sau đó emit state mới chứa [clusteredMarkers] để UI render.
  Future<void> _refreshClusters() async {
    if (_clusterItems.isEmpty) {
      emit(state.copyWith(clusteredMarkers: {}));
      return;
    }

    final groups = GoogleMapClusterEngine.compute(
      items: _clusterItems,
      zoomLevel: _currentZoom,
    );

    final newClusteredMarkers = <Marker>{};
    for (final group in groups) {
      if (group.isCluster) {
        // Cluster bubble: hiển số đếm
        final icon = await GoogleMapClusterEngine.buildClusterBitmap(group.count);
        newClusteredMarkers.add(Marker(
          markerId: MarkerId(group.id),
          position: group.position,
          icon: icon,
          onTap: () {
            // Zoom vào tâm cluster khi tap
            animateCameraTo(group.position, zoom: _currentZoom + 2);
          },
        ));
      } else {
        // Điểm đơn: tìm marker gốc tương ứng
        final sourceId = group.items.first.id;
        final original = state.markers.where((m) => m.markerId.value == sourceId).firstOrNull;
        if (original != null) {
          newClusteredMarkers.add(original);
        }
      }
    }

    emit(state.copyWith(clusteredMarkers: newClusteredMarkers));
  }
}
