import 'package:equatable/equatable.dart';

enum Scene3dStatus { loading, ready, error }

class Scene3dModelOption extends Equatable {
  const Scene3dModelOption(
      {required this.label,
      required this.src,
      required this.isRemote,
      this.cameraPresets});

  final String label;
  final String src;
  final bool isRemote;

  /// Model-specific presets; null falls back to the default presets.
  final List<Scene3dCameraPreset>? cameraPresets;

  @override
  List<Object?> get props => [label, src, isRemote];
}

class Scene3dCameraPreset extends Equatable {
  const Scene3dCameraPreset(
      {required this.label,
      required this.theta,
      required this.phi,
      required this.radius});

  final String label;
  final double theta;
  final double phi;
  final double radius;

  @override
  List<Object?> get props => [label, theta, phi, radius];
}

class Scene3dTestState extends Equatable {
  const Scene3dTestState({
    required this.model,
    required this.cameraPreset,
    this.status = Scene3dStatus.loading,
    this.progress = 0,
    this.autoRotate = false,
    this.errorMessage,
    this.reloadToken = 0,
  });

  final Scene3dModelOption model;
  final Scene3dCameraPreset cameraPreset;
  final Scene3dStatus status;
  final double progress;
  final bool autoRotate;
  final String? errorMessage;
  final int reloadToken;

  Scene3dTestState copyWith({
    Scene3dModelOption? model,
    Scene3dCameraPreset? cameraPreset,
    Scene3dStatus? status,
    double? progress,
    bool? autoRotate,
    String? errorMessage,
    bool clearError = false,
    int? reloadToken,
  }) {
    return Scene3dTestState(
      model: model ?? this.model,
      cameraPreset: cameraPreset ?? this.cameraPreset,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      autoRotate: autoRotate ?? this.autoRotate,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      reloadToken: reloadToken ?? this.reloadToken,
    );
  }

  @override
  List<Object?> get props => [
        model,
        cameraPreset,
        status,
        progress,
        autoRotate,
        errorMessage,
        reloadToken
      ];
}
