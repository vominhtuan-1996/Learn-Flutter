import 'package:equatable/equatable.dart';

enum HouseViewerStatus { loading, ready, error }

enum HousePartGroup {
  exterior('Exterior'),
  rooms('Rooms'),
  details('Details'),
  modules('Modules');

  const HousePartGroup(this.label);
  final String label;
}

enum HouseType {
  villa('Villa 10x8'),
  tube('Nhà ống 4x22');

  const HouseType(this.label);
  final String label;
}

/// Which glb a part is shown in.
enum HouseModel {
  detailed('assets/3d/house_detailed.glb'),
  interior('assets/3d/house_interior.glb'),
  tube('assets/3d/house_tube.glb'),
  tubeInterior('assets/3d/house_tube_interior.glb'),
  tubeLiving('assets/3d/modules/tube_living.glb'),
  tubeKitchen('assets/3d/modules/tube_kitchen.glb'),
  tubeBed1('assets/3d/modules/tube_bed1.glb'),
  tubeBed2('assets/3d/modules/tube_bed2.glb'),
  tubeWc('assets/3d/modules/tube_wc.glb'),
  tubeCorridor('assets/3d/modules/tube_corridor.glb'),
  tubeYardStair('assets/3d/modules/tube_yard_stair.glb'),
  tubePergola('assets/3d/modules/tube_pergola.glb'),
  tubeRoofGarden('assets/3d/modules/tube_roof_garden.glb');

  const HouseModel(this.asset);
  final String asset;
}

/// A named camera shot. [tx]/[ty]/[tz] are the look-at point in model
/// coordinates (meters, Y-up). [radius] is a % of the auto-fit distance.
class HousePart extends Equatable {
  const HousePart({
    required this.house,
    required this.group,
    required this.label,
    required this.description,
    required this.model,
    required this.theta,
    required this.phi,
    required this.radius,
    this.tx = 0,
    this.ty = 2.5,
    this.tz = 0,
  });

  final HouseType house;
  final HousePartGroup group;
  final String label;
  final String description;
  final HouseModel model;
  final double theta;
  final double phi;
  final double radius;
  final double tx;
  final double ty;
  final double tz;

  @override
  List<Object?> get props =>
      [group, label, model, theta, phi, radius, tx, ty, tz];
}

class HouseViewerState extends Equatable {
  const HouseViewerState({
    required this.house,
    required this.group,
    required this.part,
    this.status = HouseViewerStatus.loading,
    this.progress = 0,
    this.autoRotate = false,
    this.errorMessage,
    this.reloadToken = 0,
  });

  final HouseType house;
  final HousePartGroup group;
  final HousePart part;
  final HouseViewerStatus status;
  final double progress;
  final bool autoRotate;
  final String? errorMessage;
  final int reloadToken;

  HouseViewerState copyWith({
    HouseType? house,
    HousePartGroup? group,
    HousePart? part,
    HouseViewerStatus? status,
    double? progress,
    bool? autoRotate,
    String? errorMessage,
    bool clearError = false,
    int? reloadToken,
  }) {
    return HouseViewerState(
      house: house ?? this.house,
      group: group ?? this.group,
      part: part ?? this.part,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      autoRotate: autoRotate ?? this.autoRotate,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      reloadToken: reloadToken ?? this.reloadToken,
    );
  }

  @override
  List<Object?> get props => [
        house,
        group,
        part,
        status,
        progress,
        autoRotate,
        errorMessage,
        reloadToken
      ];
}
