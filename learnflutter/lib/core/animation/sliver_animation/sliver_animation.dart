// Barrel — 1 engine, 2 chiến lược progress.
//
// Effects (interface chung) ---------------------------------------------------
export 'sliver_effect.dart';

// Coordinator engine (scroll offset range driven) ----------------------------
export 'coordinator/sliver_animation_state.dart';
export 'coordinator/sliver_animation_coordinator.dart';
export 'coordinator/sliver_animated_builder.dart';
export 'coordinator/sliver_animated_item.dart';

// Viewport engine (auto progress theo khoảng cách tới tâm) -------------------
export 'viewport/viewport_engine.dart';
export 'viewport/viewport_aware.dart';
export 'viewport/tiktok_viewport_list.dart';
