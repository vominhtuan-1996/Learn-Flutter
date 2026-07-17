import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:learnflutter/core/engines/engine_google_map/engine_google_map.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/base_loading.dart';
import '../cubit/test_markers_cubit.dart';

class CustomMarkersTestScreen extends StatefulWidget {
  const CustomMarkersTestScreen({Key? key}) : super(key: key);

  @override
  State<CustomMarkersTestScreen> createState() =>
      _CustomMarkersTestScreenState();
}

class _CustomMarkersTestScreenState extends State<CustomMarkersTestScreen>
    with TickerProviderStateMixin {
  late GoogleMapCubit _googleMapCubit;
  late TestMarkersCubit _testCubit;
  CustomMarkerData? _selectedMarkerData;
  bool _showBottomSheet = false;

  // Draggable bottom sheet properties
  late AnimationController _dragAnimationController;
  double _dragHeight = 0;
  final double _minHeight = 100;
  double _maxHeight = 0;

  @override
  void initState() {
    super.initState();
    _googleMapCubit = GoogleMapCubit();
    _testCubit = context.read<TestMarkersCubit>();
    _testCubit.loadRestaurantMarkers();

    _dragAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _googleMapCubit.disposeController();
    _dragAnimationController.dispose();
    super.dispose();
  }

  void _onBottomSheetDragStart() {
    _dragAnimationController.stop();
  }

  void _onBottomSheetDragUpdate(double delta) {
    setState(() {
      _dragHeight = (_dragHeight - delta).clamp(_minHeight, _maxHeight);
    });
  }

  void _onBottomSheetDragEnd(double velocity) {
    final midPoint = _maxHeight / 2;

    if (_dragHeight < _minHeight + 20 || velocity > 500) {
      // Snap to close
      setState(() {
        _showBottomSheet = false;
        _selectedMarkerData = null;
        _dragHeight = 0;
      });
    } else if (_dragHeight > midPoint) {
      // Snap to max
      setState(() {
        _dragHeight = _maxHeight;
      });
    } else {
      // Snap to min
      setState(() {
        _dragHeight = _minHeight;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapCubit.onMapCreated(controller);
  }

  void _onMarkerTapped(MarkerId markerId) {
    try {
      debugPrint('🔍 _onMarkerTapped called with markerId: ${markerId.value}');

      final marker = _testCubit.state.markers
          .firstWhere((m) => m.id == markerId.value, orElse: () {
        debugPrint('⚠️ Marker not found, using first marker');
        return _testCubit.state.markers.isNotEmpty ? _testCubit.state.markers.first : MarkerConfig(id: 'none', position: const LatLng(0, 0));
      });

      debugPrint('📍 Marker found: ${marker.id}, hasCustomData: ${marker.customData != null}');

      if (marker.customData == null) {
        debugPrint('❌ Marker customData is null, returning');
        return;
      }

      _testCubit.selectMarker(markerId.value);
      _googleMapCubit.showMarkerInfo(markerId.value, marker.customData);
      debugPrint('📊 Calling _showMarkerBottomSheet...');
      _showMarkerBottomSheet(marker.customData!);
    } catch (e, stacktrace) {
      debugPrint('❌ Error tapping marker: $e');
      debugPrint('📋 StackTrace: $stacktrace');
    }
  }

  void _showMarkerBottomSheet(CustomMarkerData markerData) {
    debugPrint('🎯 Bottom sheet triggered for: ${markerData.title}');
    setState(() {
      _selectedMarkerData = markerData;
      _showBottomSheet = true;
    });
  }

  Widget _buildMarkerContent(CustomMarkerData markerData) {
    final statusColor = _getStatusColor(markerData.status);
    final statusLabel = _getStatusLabel(markerData.status);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with image & status
          if (markerData.imageUrl != null || markerData.imageUrl == null)
            Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(12),
              image: markerData.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(markerData.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: markerData.imageUrl == null
                ? Center(
                    child: Icon(
                      Icons.location_on,
                      size: 64,
                      color: const Color(0xFF9CA3AF),
                    ),
                  )
                : null,
          ),
        const SizedBox(height: 16),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            border: Border.all(color: statusColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          markerData.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        if (markerData.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            markerData.subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
        const SizedBox(height: 8),
        // Description
        Text(
          markerData.description,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
        // Actions
        if (markerData.actions.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: markerData.actions.map((action) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    action.onPressed();
                    setState(() {
                      _showBottomSheet = false;
                      _selectedMarkerData = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: action.color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(action.icon, color: action.color, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          action.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: action.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getStatusColor(MarkerStatus status) {
    switch (status) {
      case MarkerStatus.online:
        return const Color(0xFF10B981);
      case MarkerStatus.offline:
        return const Color(0xFF6B7280);
      case MarkerStatus.busy:
        return const Color(0xFFF59E0B);
      case MarkerStatus.idle:
        return const Color(0xFF3B82F6);
      case MarkerStatus.warning:
        return const Color(0xFFEF4444);
      case MarkerStatus.error:
        return const Color(0xFFDC2626);
    }
  }

  String _getStatusLabel(MarkerStatus status) {
    switch (status) {
      case MarkerStatus.online:
        return 'Online';
      case MarkerStatus.offline:
        return 'Offline';
      case MarkerStatus.busy:
        return 'Busy';
      case MarkerStatus.idle:
        return 'Idle';
      case MarkerStatus.warning:
        return 'Warning';
      case MarkerStatus.error:
        return 'Error';
    }
  }

  void _updateAllMarkerStatus(MarkerStatus status) {
    for (final marker in _testCubit.state.markers) {
      _testCubit.updateMarkerStatus(marker.id, status);
    }
  }

  Widget _buildDraggableBottomSheet(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _maxHeight = screenHeight * 0.65;

    if (_dragHeight == 0) {
      _dragHeight = _maxHeight;
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Transparent barrier - allows taps to pass through to map
          IgnorePointer(
            child: Container(
              color: Colors.transparent,
              height: screenHeight - _dragHeight,
            ),
          ),
          // Draggable bottom sheet
          GestureDetector(
            onVerticalDragStart: (_) => _onBottomSheetDragStart(),
            onVerticalDragUpdate: (details) =>
                _onBottomSheetDragUpdate(details.delta.dy),
            onVerticalDragEnd: (details) =>
                _onBottomSheetDragEnd(details.velocity.pixelsPerSecond.dy),
            child: SizedBox(
              height: _dragHeight,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildMarkerContent(_selectedMarkerData!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      appBar: AppBar(
        title: const Text('Custom Markers Test'),
        elevation: 0,
      ),
      child: BlocBuilder<TestMarkersCubit, TestMarkersState>(
        builder: (context, testState) {
          return BlocBuilder<GoogleMapCubit, GoogleMapState>(
            bloc: _googleMapCubit,
            builder: (context, mapState) {
              return Stack(
                children: [
                  // Map with controls
                  Column(
                    children: [
                      // Test case selector
                      _buildTestCaseSelector(testState),
                      // Status message
                      _buildStatusBar(testState),
                      // Map
                      Expanded(
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(21.0285, 105.8542),
                            zoom: 14,
                          ),
                          markers: testState.markers
                              .map((config) => Marker(
                                    markerId: MarkerId(config.id),
                                    position: config.position,
                                    infoWindow: const InfoWindow(),
                                    icon: config.icon ?? BitmapDescriptor.defaultMarker,
                                    onTap: () =>
                                        _onMarkerTapped(MarkerId(config.id)),
                                  ))
                              .toSet(),
                        ),
                      ),
                      // Controls
                      _buildControls(testState),
                    ],
                  ),
                  // Bottom sheet overlay with drag
                  if (_showBottomSheet && _selectedMarkerData != null)
                    _buildDraggableBottomSheet(context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTestCaseSelector(TestMarkersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTestCaseButton(
                    'Restaurants',
                    'restaurants',
                    state.selectedTestCase,
                    () => _testCubit.loadRestaurantMarkers(),
                  ),
                  const SizedBox(width: 8),
                  _buildTestCaseButton(
                    'Delivery',
                    'delivery',
                    state.selectedTestCase,
                    () => _testCubit.loadDeliveryMarkers(),
                  ),
                  const SizedBox(width: 8),
                  _buildTestCaseButton(
                    'Services',
                    'service',
                    state.selectedTestCase,
                    () => _testCubit.loadServiceMarkers(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCaseButton(
    String label,
    String id,
    String selected,
    VoidCallback onTap,
  ) {
    final isSelected = id == selected;
    return Material(
      color: isSelected ? const Color(0xFF2563EB) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(TestMarkersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.blue[50],
      child: Row(
        children: [
          const Icon(Icons.info, size: 16, color: Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.statusMessage,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E40AF),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(TestMarkersState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Update All Markers Status',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusButton(MarkerStatus.online, 'Online',
                    const Color(0xFF10B981), state),
                const SizedBox(width: 6),
                _buildStatusButton(MarkerStatus.offline, 'Offline',
                    const Color(0xFF6B7280), state),
                const SizedBox(width: 6),
                _buildStatusButton(
                    MarkerStatus.busy, 'Busy', const Color(0xFFF59E0B), state),
                const SizedBox(width: 6),
                _buildStatusButton(MarkerStatus.idle, 'Idle',
                    const Color(0xFF3B82F6), state),
                const SizedBox(width: 6),
                _buildStatusButton(MarkerStatus.warning, 'Warning',
                    const Color(0xFFEF4444), state),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Markers: ${state.markers.length}',
                  style: const TextStyle(fontSize: 11),
                ),
                if (state.selectedMarkerId != null)
                  Text(
                    'Selected: ${state.selectedMarkerId}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    MarkerStatus status,
    String label,
    Color color,
    TestMarkersState state,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: () => _updateAllMarkerStatus(status),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
