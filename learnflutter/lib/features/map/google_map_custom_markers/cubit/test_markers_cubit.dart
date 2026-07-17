import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';
import 'package:learnflutter/core/engines/engine_google_map/engine_google_map.dart';

part 'test_markers_state.dart';

/// Cubit cho testing custom markers.
class TestMarkersCubit extends BaseCubit<TestMarkersState> {
  TestMarkersCubit() : super(TestMarkersState.initial());

  /// Tạo markers cho test case: Restaurants
  void loadRestaurantMarkers() {
    final markers = [
      MarkerConfig(
        id: 'restaurant_1',
        position: const LatLng(21.0285, 105.8542),
        title: 'The Most',
        customData: CustomMarkerData(
          title: 'The Most Restaurant',
          description: '⭐⭐⭐⭐⭐ Modern Vietnamese Cuisine',
          subtitle: 'Ba Đình, Hà Nội',
          imageUrl: null,
          status: MarkerStatus.online,
          actions: [
            MarkerActionButton(
              id: 'call',
              label: 'Gọi',
              icon: Icons.phone,
              color: const Color(0xFF10B981),
              onPressed: () => _handleAction('call', 'restaurant_1'),
            ),
            MarkerActionButton(
              id: 'message',
              label: 'Nhắn',
              icon: Icons.message,
              color: const Color(0xFF3B82F6),
              onPressed: () => _handleAction('message', 'restaurant_1'),
            ),
            MarkerActionButton(
              id: 'favorite',
              label: 'Yêu thích',
              icon: Icons.favorite_border,
              color: const Color(0xFFEF4444),
              onPressed: () => _handleAction('favorite', 'restaurant_1'),
            ),
          ],
        ),
      ),
      MarkerConfig(
        id: 'restaurant_2',
        position: const LatLng(21.0350, 105.8600),
        title: 'Cơm Tấm',
        customData: CustomMarkerData(
          title: 'Cơm Tấm 68',
          description: '⭐⭐⭐⭐ Authentic Saigon Style',
          subtitle: 'Hoàn Kiếm, Hà Nội',
          status: MarkerStatus.busy,
          actions: [
            MarkerActionButton(
              id: 'call',
              label: 'Gọi',
              icon: Icons.phone,
              onPressed: () => _handleAction('call', 'restaurant_2'),
            ),
          ],
        ),
      ),
      MarkerConfig(
        id: 'restaurant_3',
        position: const LatLng(21.0200, 105.8500),
        title: 'Phở Hà',
        customData: CustomMarkerData(
          title: 'Phở Hà Nội',
          description: '⭐⭐⭐⭐ Traditional Pho',
          subtitle: 'Đống Đa, Hà Nội',
          status: MarkerStatus.offline,
          actions: [
            MarkerActionButton(
              id: 'info',
              label: 'Chi tiết',
              icon: Icons.info,
              color: const Color(0xFF6B7280),
              onPressed: () => _handleAction('info', 'restaurant_3'),
            ),
          ],
        ),
      ),
    ];

    emit(state.copyWith(
      markers: markers,
      selectedTestCase: 'restaurants',
      statusMessage: 'Đã load ${markers.length} nhà hàng',
    ));
  }

  /// Tạo markers cho test case: Delivery
  void loadDeliveryMarkers() {
    final markers = [
      MarkerConfig(
        id: 'delivery_1',
        position: const LatLng(21.0285, 105.8542),
        title: 'Order #001',
        customData: CustomMarkerData(
          title: 'Đơn hàng #001',
          description: 'Shipper: Nguyễn Văn A',
          subtitle: 'Đang giao hàng',
          status: MarkerStatus.busy,
          metadata: {'order_id': '001', 'distance': '2.5km'},
          actions: [
            MarkerActionButton(
              id: 'call',
              label: 'Gọi',
              icon: Icons.phone,
              color: const Color(0xFF10B981),
              onPressed: () => _handleAction('call', 'delivery_1'),
            ),
            MarkerActionButton(
              id: 'track',
              label: 'Track',
              icon: Icons.map,
              color: const Color(0xFF3B82F6),
              onPressed: () => _handleAction('track', 'delivery_1'),
            ),
          ],
        ),
      ),
      MarkerConfig(
        id: 'delivery_2',
        position: const LatLng(21.0350, 105.8600),
        title: 'Order #002',
        customData: CustomMarkerData(
          title: 'Đơn hàng #002',
          description: 'Shipper: Trần Văn B',
          subtitle: 'Sẵn sàng nhận hàng',
          status: MarkerStatus.online,
          metadata: {'order_id': '002', 'distance': '1.2km'},
          actions: [
            MarkerActionButton(
              id: 'call',
              label: 'Gọi',
              icon: Icons.phone,
              color: const Color(0xFF10B981),
              onPressed: () => _handleAction('call', 'delivery_2'),
            ),
            MarkerActionButton(
              id: 'cancel',
              label: 'Hủy',
              icon: Icons.close,
              color: const Color(0xFFEF4444),
              onPressed: () => _handleAction('cancel', 'delivery_2'),
            ),
          ],
        ),
      ),
      MarkerConfig(
        id: 'delivery_3',
        position: const LatLng(21.0200, 105.8500),
        title: 'Order #003',
        customData: CustomMarkerData(
          title: 'Đơn hàng #003',
          description: 'Shipper: Phạm Văn C',
          subtitle: 'Mất kết nối',
          status: MarkerStatus.offline,
          metadata: {'order_id': '003', 'distance': '5.0km'},
          actions: [
            MarkerActionButton(
              id: 'reassign',
              label: 'Gán lại',
              icon: Icons.person_add,
              color: const Color(0xFFF59E0B),
              onPressed: () => _handleAction('reassign', 'delivery_3'),
            ),
          ],
        ),
      ),
    ];

    emit(state.copyWith(
      markers: markers,
      selectedTestCase: 'delivery',
      statusMessage: 'Đã load ${markers.length} đơn hàng',
    ));
  }

  /// Tạo markers cho test case: Service Stations
  void loadServiceMarkers() {
    final markers = [
      MarkerConfig(
        id: 'service_1',
        position: const LatLng(21.0285, 105.8542),
        title: 'Gas Station',
        customData: CustomMarkerData(
          title: 'Trạm Xăng A',
          description: 'Xăng 95, Dầu diesel',
          subtitle: 'Có sẵn',
          status: MarkerStatus.online,
          actions: [
            MarkerActionButton(
              id: 'directions',
              label: 'Chỉ đường',
              icon: Icons.directions,
              color: const Color(0xFF3B82F6),
              onPressed: () => _handleAction('directions', 'service_1'),
            ),
            MarkerActionButton(
              id: 'price',
              label: 'Giá',
              icon: Icons.attach_money,
              color: const Color(0xFF10B981),
              onPressed: () => _handleAction('price', 'service_1'),
            ),
          ],
        ),
      ),
      MarkerConfig(
        id: 'service_2',
        position: const LatLng(21.0350, 105.8600),
        title: 'Repair Shop',
        customData: CustomMarkerData(
          title: 'Xưởng Sửa Chữa B',
          description: 'Sửa chữa đa năng',
          subtitle: 'Đang bận',
          status: MarkerStatus.busy,
          actions: [
            MarkerActionButton(
              id: 'book',
              label: 'Đặt lịch',
              icon: Icons.calendar_today,
              color: const Color(0xFFF59E0B),
              onPressed: () => _handleAction('book', 'service_2'),
            ),
          ],
        ),
      ),
    ];

    emit(state.copyWith(
      markers: markers,
      selectedTestCase: 'service',
      statusMessage: 'Đã load ${markers.length} dịch vụ',
    ));
  }

  /// Cập nhật status của marker
  void updateMarkerStatus(String markerId, MarkerStatus newStatus) {
    final marker = state.markers.firstWhere((m) => m.id == markerId);
    final oldData = marker.customData;

    if (oldData != null) {
      final newData = CustomMarkerData(
        title: oldData.title,
        description: oldData.description,
        imageUrl: oldData.imageUrl,
        subtitle: oldData.subtitle,
        status: newStatus,
        metadata: oldData.metadata,
        actions: oldData.actions,
      );

      final updatedMarker = MarkerConfig(
        id: marker.id,
        position: marker.position,
        title: marker.title,
        customData: newData,
      );

      final newMarkers = state.markers.map((m) {
        return m.id == markerId ? updatedMarker : m;
      }).toList();

      emit(state.copyWith(
        markers: newMarkers,
        statusMessage: 'Cập nhật status: ${newStatus.name}',
      ));
    }
  }

  /// Select marker để show info
  void selectMarker(String markerId) {
    final marker = state.markers.firstWhere((m) => m.id == markerId);
    emit(state.copyWith(
      selectedMarkerId: markerId,
      selectedMarkerData: marker.customData,
      showInfoWindow: true,
    ));
  }

  /// Ẩn info window
  void hideInfoWindow() {
    emit(state.copyWith(
      selectedMarkerId: null,
      selectedMarkerData: null,
      showInfoWindow: false,
    ));
  }

  void _handleAction(String actionId, String markerId) {
    emit(state.copyWith(
      statusMessage: 'Action: $actionId on $markerId',
    ));
  }
}
