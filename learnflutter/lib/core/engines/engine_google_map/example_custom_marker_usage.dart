// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/engines/engine_google_map/engine_google_map.dart';

/// ============================================================================
/// CUSTOM MARKER USAGE EXAMPLES
/// ============================================================================
///
/// Hướng dẫn chi tiết cách sử dụng hệ thống custom marker & info window.
/// Bao gồm: định nghĩa custom data, actions, hiển thị info window.

class GoogleMapCustomMarkerExample {
  // ─────────────────────────────────────────────────────────────────
  // EXAMPLE 1: Basic Custom Marker
  // ─────────────────────────────────────────────────────────────────

  /// Tạo marker đơn giản với custom data.
  static MarkerConfig createBasicMarker() {
    return MarkerConfig(
      id: 'marker_1',
      position: const LatLng(21.0285, 105.8542), // Hà Nội
      title: 'Hà Nội',
      snippet: 'Thủ đô Việt Nam',
      customData: const CustomMarkerData(
        title: 'Hà Nội',
        description: 'Thủ đô của Việt Nam, nằm bên sông Hồng.',
        subtitle: 'Vietnam',
        status: MarkerStatus.online,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EXAMPLE 2: Marker với Actions
  // ─────────────────────────────────────────────────────────────────

  /// Tạo marker với multiple action buttons.
  static MarkerConfig createMarkerWithActions() {
    return MarkerConfig(
      id: 'marker_restaurant',
      position: const LatLng(21.0285, 105.8542),
      title: 'The Most',
      snippet: 'Restaurant',
      customData: CustomMarkerData(
        title: 'The Most Restaurant',
        description: '⭐⭐⭐⭐⭐ Modern Vietnamese Cuisine',
        subtitle: 'Ba Đình, Hà Nội',
        imageUrl: 'https://via.placeholder.com/240x100',
        status: MarkerStatus.online,
        actions: [
          MarkerActionButton(
            id: 'call',
            label: 'Gọi',
            icon: Icons.phone,
            color: const Color(0xFF10B981),
            onPressed: () {
              // Action: Gọi nhà hàng
              print('Calling restaurant...');
            },
          ),
          MarkerActionButton(
            id: 'message',
            label: 'Nhắn',
            icon: Icons.message,
            color: const Color(0xFF3B82F6),
            onPressed: () {
              // Action: Gửi tin nhắn
              print('Sending message...');
            },
          ),
          MarkerActionButton(
            id: 'favorite',
            label: 'Yêu thích',
            icon: Icons.favorite_border,
            color: const Color(0xFFEF4444),
            onPressed: () {
              // Action: Thêm vào yêu thích
              print('Adding to favorites...');
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EXAMPLE 3: Marker with Status Indicator
  // ─────────────────────────────────────────────────────────────────

  /// Tạo marker với status real-time (online/offline/busy).
  static MarkerConfig createMarkerWithStatus(
    String markerId,
    LatLng position,
    String name,
    MarkerStatus status,
  ) {
    return MarkerConfig(
      id: markerId,
      position: position,
      title: name,
      snippet: _getStatusLabel(status),
      customData: CustomMarkerData(
        title: name,
        description: 'Xe đang ${_getStatusDescription(status)}',
        subtitle: _getStatusLabel(status),
        status: status,
        actions: [
          MarkerActionButton(
            id: 'navigate',
            label: 'Chỉ đường',
            icon: Icons.directions,
            color: const Color(0xFF3B82F6),
            onPressed: () {
              print('Starting navigation to $name...');
            },
          ),
          MarkerActionButton(
            id: 'info',
            label: 'Chi tiết',
            icon: Icons.info,
            color: const Color(0xFF6B7280),
            onPressed: () {
              print('Showing details for $name...');
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // EXAMPLE 4: Batch Markers for Delivery
  // ─────────────────────────────────────────────────────────────────

  /// Tạo danh sách markers cho hệ thống giao hàng.
  static List<MarkerConfig> createDeliveryMarkers() {
    final deliveries = [
      {
        'id': 'delivery_1',
        'name': 'Đơn hàng #001',
        'position': const LatLng(21.0285, 105.8542),
        'status': MarkerStatus.online,
        'description': 'Shipper: Nguyễn Văn A',
      },
      {
        'id': 'delivery_2',
        'name': 'Đơn hàng #002',
        'position': const LatLng(21.0350, 105.8600),
        'status': MarkerStatus.busy,
        'description': 'Shipper: Trần Văn B',
      },
      {
        'id': 'delivery_3',
        'name': 'Đơn hàng #003',
        'position': const LatLng(21.0200, 105.8500),
        'status': MarkerStatus.offline,
        'description': 'Shipper: Phạm Văn C',
      },
    ];

    return deliveries.map((d) {
      return MarkerConfig(
        id: d['id'] as String,
        position: d['position'] as LatLng,
        title: d['name'] as String,
        customData: CustomMarkerData(
          title: d['name'] as String,
          description: d['description'] as String,
          status: d['status'] as MarkerStatus,
          subtitle: _getStatusLabel(d['status'] as MarkerStatus),
          actions: [
            MarkerActionButton(
              id: 'call_shipper',
              label: 'Gọi',
              icon: Icons.phone,
              color: const Color(0xFF10B981),
              onPressed: () => print('Calling shipper for ${d['name']}'),
            ),
            MarkerActionButton(
              id: 'track',
              label: 'Track',
              icon: Icons.map,
              color: const Color(0xFF3B82F6),
              onPressed: () => print('Tracking ${d['name']}'),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────
  // EXAMPLE 5: Marker with Navigation Callback
  // ─────────────────────────────────────────────────────────────────

  /// Marker với action điều hướng tới detail screen.
  static MarkerConfig createNavigableMarker(
    String markerId,
    LatLng position,
    String title,
    Function(String) onNavigateToDetail,
  ) {
    return MarkerConfig(
      id: markerId,
      position: position,
      title: title,
      customData: CustomMarkerData(
        title: title,
        description: 'Nhấn để xem chi tiết',
        status: MarkerStatus.idle,
        actions: [
          MarkerActionButton(
            id: 'view_details',
            label: 'Xem chi tiết',
            icon: Icons.arrow_forward,
            color: const Color(0xFF3B82F6),
            onPressed: () => onNavigateToDetail(markerId),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // CUBIT USAGE PATTERN
  // ─────────────────────────────────────────────────────────────────

  /// Cách sử dụng GoogleMapCubit với custom markers.
  ///
  /// ```dart
  /// // 1. Trong build(), initialize cubit
  /// GoogleMapCubit mapCubit = context.read<GoogleMapCubit>();
  ///
  /// // 2. Thêm markers với custom data
  /// mapCubit.addMarker(createBasicMarker());
  /// mapCubit.addMarkers(createDeliveryMarkers());
  ///
  /// // 3. Khi tap marker, show custom info window
  /// onMarkerTapped: (markerId) {
  ///   final markerConfig = ...; // get config
  ///   mapCubit.showMarkerInfo(markerId, markerConfig.customData);
  /// }
  ///
  /// // 4. Trong build, listen to state
  /// BlocBuilder<GoogleMapCubit, GoogleMapState>(
  ///   builder: (context, state) {
  ///     return Stack(
  ///       children: [
  ///         GoogleMap(...),
  ///         if (state.showInfoWindow && state.selectedMarkerData != null)
  ///           CustomMarkerInfoWindow(
  ///             markerData: state.selectedMarkerData!,
  ///             position: convertLatLngToScreenPos(state.selectedMarkerId),
  ///             onClose: () => mapCubit.hideMarkerInfo(),
  ///           ),
  ///       ],
  ///     );
  ///   },
  /// );
  /// ```
}

String _getStatusLabel(MarkerStatus status) {
  switch (status) {
    case MarkerStatus.online:
      return 'Online';
    case MarkerStatus.offline:
      return 'Offline';
    case MarkerStatus.busy:
      return 'Đang bận';
    case MarkerStatus.idle:
      return 'Sẵn sàng';
    case MarkerStatus.warning:
      return 'Cảnh báo';
    case MarkerStatus.error:
      return 'Lỗi';
  }
}

String _getStatusDescription(MarkerStatus status) {
  switch (status) {
    case MarkerStatus.online:
      return 'kết nối';
    case MarkerStatus.offline:
      return 'mất kết nối';
    case MarkerStatus.busy:
      return 'giao hàng';
    case MarkerStatus.idle:
      return 'chờ đợi';
    case MarkerStatus.warning:
      return 'có vấn đề';
    case MarkerStatus.error:
      return 'gặp lỗi';
  }
}
