import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import 'scene_3d_test_state.dart';

class Scene3dTestCubit extends Cubit<Scene3dTestState> {
  Scene3dTestCubit()
      : super(Scene3dTestState(
            model: models.first, cameraPreset: cameraPresets.first));

  static const List<Scene3dModelOption> models = [
    Scene3dModelOption(
        label: 'Business man (asset)',
        src: 'assets/3d/business_man.glb',
        isRemote: false),
    Scene3dModelOption(
        label: 'House (procedural)',
        src: 'assets/3d/house.glb',
        isRemote: false,
        cameraPresets: housePresets),
    Scene3dModelOption(
        label: 'House + nature (procedural)',
        src: 'assets/3d/house_scene.glb',
        isRemote: false,
        cameraPresets: houseScenePresets),
    Scene3dModelOption(
        label: 'House detailed (4 sides)',
        src: 'assets/3d/house_detailed.glb',
        isRemote: false,
        cameraPresets: houseDetailedPresets),
    Scene3dModelOption(
        label: 'House interior (no roof)',
        src: 'assets/3d/house_interior.glb',
        isRemote: false,
        cameraPresets: houseInteriorPresets),
    // Public glb, needs network; used because only one local glb exists.
    Scene3dModelOption(
      label: 'Astronaut (URL)',
      src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      isRemote: true,
    ),
    Scene3dModelOption(
      label: 'Robot Expressive (URL)',
      src: 'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb',
      isRemote: true,
    ),
  ];

  // radius is a % of the auto-fit distance (100 = whole model fits the view).
  // House is 14 x 6 x 12 m, front faces +Z, chimney at the back.
  static const List<Scene3dCameraPreset> housePresets = [
    Scene3dCameraPreset(label: '3/4 view', theta: 35, phi: 65, radius: 95),
    Scene3dCameraPreset(label: 'Front', theta: 0, phi: 80, radius: 100),
    Scene3dCameraPreset(label: 'Side', theta: 90, phi: 80, radius: 100),
    Scene3dCameraPreset(label: 'Back', theta: 180, phi: 80, radius: 100),
    Scene3dCameraPreset(label: 'Roof', theta: 0, phi: 10, radius: 110),
    Scene3dCameraPreset(label: 'Close', theta: 35, phi: 70, radius: 65),
  ];

  // Scene is ~70 x 28 x 72 m (house, river in front, mountains and sun behind).
  static const List<Scene3dCameraPreset> houseScenePresets = [
    Scene3dCameraPreset(label: 'Overview', theta: 30, phi: 70, radius: 90),
    Scene3dCameraPreset(label: 'Front (river)', theta: 0, phi: 78, radius: 85),
    Scene3dCameraPreset(label: 'Back (mountains)', theta: 180, phi: 78, radius: 85),
    Scene3dCameraPreset(label: 'Side', theta: 90, phi: 78, radius: 90),
    Scene3dCameraPreset(label: 'Top', theta: 0, phi: 10, radius: 100),
    Scene3dCameraPreset(label: 'Close', theta: 30, phi: 75, radius: 50),
  ];

  // House detailed is 16 x 6 x 14 m (incl. yard). theta: 0 front, 90 right,
  // 180 back, 270 left.
  static const List<Scene3dCameraPreset> houseDetailedPresets = [
    Scene3dCameraPreset(label: '3/4 view', theta: 35, phi: 65, radius: 90),
    Scene3dCameraPreset(label: 'Front', theta: 0, phi: 80, radius: 85),
    Scene3dCameraPreset(label: 'Right', theta: 90, phi: 80, radius: 85),
    Scene3dCameraPreset(label: 'Back', theta: 180, phi: 80, radius: 85),
    Scene3dCameraPreset(label: 'Left', theta: 270, phi: 80, radius: 85),
    Scene3dCameraPreset(label: 'Roof', theta: 0, phi: 10, radius: 100),
  ];

  // Same house without roof. Plan: kitchen/bath at the back, living/bedroom
  // at the front.
  static const List<Scene3dCameraPreset> houseInteriorPresets = [
    Scene3dCameraPreset(label: 'Top-down', theta: 0, phi: 8, radius: 90),
    Scene3dCameraPreset(label: 'Cutaway front', theta: 25, phi: 45, radius: 80),
    Scene3dCameraPreset(label: 'Cutaway back', theta: 205, phi: 45, radius: 80),
    Scene3dCameraPreset(label: 'Cutaway left', theta: 290, phi: 45, radius: 80),
    Scene3dCameraPreset(label: 'Cutaway right', theta: 70, phi: 45, radius: 80),
    Scene3dCameraPreset(label: 'Close', theta: 20, phi: 40, radius: 55),
  ];

  static const List<Scene3dCameraPreset> cameraPresets = [
    Scene3dCameraPreset(label: 'Front', theta: 0, phi: 75, radius: 100),
    Scene3dCameraPreset(label: 'Side', theta: 90, phi: 75, radius: 100),
    Scene3dCameraPreset(label: 'Back', theta: 180, phi: 75, radius: 100),
    Scene3dCameraPreset(label: 'Top', theta: 0, phi: 5, radius: 120),
    Scene3dCameraPreset(label: 'Close', theta: 0, phi: 75, radius: 60),
  ];

  // Viewer disposes its controller's notifier on dispose, so each
  // (re)created viewer needs a fresh controller.
  Flutter3DController viewer = Flutter3DController();

  static List<Scene3dCameraPreset> presetsFor(Scene3dModelOption model) =>
      model.cameraPresets ?? cameraPresets;

  void selectModel(Scene3dModelOption model) {
    if (model == state.model) return;
    viewer = Flutter3DController();
    emit(
      state.copyWith(
        model: model,
        cameraPreset: presetsFor(model).first,
        status: Scene3dStatus.loading,
        progress: 0,
        clearError: true,
        reloadToken: state.reloadToken + 1,
      ),
    );
  }

  void reload() {
    viewer = Flutter3DController();
    emit(
      state.copyWith(
          status: Scene3dStatus.loading,
          progress: 0,
          clearError: true,
          reloadToken: state.reloadToken + 1),
    );
  }

  void onProgress(double value) {
    if (state.status != Scene3dStatus.loading) return;
    emit(state.copyWith(progress: value));
  }

  void onLoaded() {
    emit(state.copyWith(
        status: Scene3dStatus.ready, progress: 1, clearError: true));
    _applyCamera(state.cameraPreset);
    if (state.autoRotate) viewer.startRotation();
  }

  void onLoadFailed(String error) {
    emit(state.copyWith(status: Scene3dStatus.error, errorMessage: error));
  }

  void selectCameraPreset(Scene3dCameraPreset preset) {
    emit(state.copyWith(cameraPreset: preset));
    if (state.status == Scene3dStatus.ready) _applyCamera(preset);
  }

  void toggleAutoRotate(bool value) {
    emit(state.copyWith(autoRotate: value));
    if (state.status != Scene3dStatus.ready) return;
    value ? viewer.startRotation() : viewer.stopRotation();
  }

  void _applyCamera(Scene3dCameraPreset preset) {
    viewer.setCameraOrbit(preset.theta, preset.phi, preset.radius);
  }
}
