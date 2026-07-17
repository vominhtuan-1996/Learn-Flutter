part of 'test_markers_cubit.dart';

class TestMarkersState extends Equatable {
  final List<MarkerConfig> markers;
  final String? selectedMarkerId;
  final CustomMarkerData? selectedMarkerData;
  final bool showInfoWindow;
  final String selectedTestCase; // 'restaurants', 'delivery', 'service'
  final String statusMessage;

  const TestMarkersState({
    this.markers = const [],
    this.selectedMarkerId,
    this.selectedMarkerData,
    this.showInfoWindow = false,
    this.selectedTestCase = 'restaurants',
    this.statusMessage = 'Select a test case',
  });

  factory TestMarkersState.initial() => const TestMarkersState();

  TestMarkersState copyWith({
    List<MarkerConfig>? markers,
    String? selectedMarkerId,
    CustomMarkerData? selectedMarkerData,
    bool? showInfoWindow,
    String? selectedTestCase,
    String? statusMessage,
  }) {
    return TestMarkersState(
      markers: markers ?? this.markers,
      selectedMarkerId: selectedMarkerId ?? this.selectedMarkerId,
      selectedMarkerData: selectedMarkerData ?? this.selectedMarkerData,
      showInfoWindow: showInfoWindow ?? this.showInfoWindow,
      selectedTestCase: selectedTestCase ?? this.selectedTestCase,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        markers.map((m) => m.id).toList(),
        selectedMarkerId,
        selectedMarkerData?.title,
        showInfoWindow,
        selectedTestCase,
        statusMessage,
      ];
}
