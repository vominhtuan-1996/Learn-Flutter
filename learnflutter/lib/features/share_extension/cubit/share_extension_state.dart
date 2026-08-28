part of 'share_extension_cubit.dart';

enum ShareExtensionStatus { idle, loaded }
enum LocationStatus { idle, loading, denied, error }

class ShareExtensionState extends Equatable {
  final List<SharedItem> items;
  final ShareExtensionStatus status;
  final LocationStatus locationStatus;
  final LatLng? myLocation;

  const ShareExtensionState({
    this.items = const [],
    this.status = ShareExtensionStatus.idle,
    this.locationStatus = LocationStatus.idle,
    this.myLocation,
  });

  ShareExtensionState copyWith({
    List<SharedItem>? items,
    ShareExtensionStatus? status,
    LocationStatus? locationStatus,
    LatLng? myLocation,
    bool clearLocation = false,
  }) =>
      ShareExtensionState(
        items: items ?? this.items,
        status: status ?? this.status,
        locationStatus: locationStatus ?? this.locationStatus,
        myLocation: clearLocation ? null : (myLocation ?? this.myLocation),
      );

  @override
  List<Object?> get props => [items, status, locationStatus, myLocation];
}
