import 'package:flutter/widgets.dart';
import 'sliver_animation_state.dart';

class SliverAnimationCoordinator {
  final ScrollController scrollController;

  final Map<String, SliverAnimationState> _states = {};

  SliverAnimationCoordinator(this.scrollController);

  double getScrollOffset() => scrollController.hasClients ? scrollController.offset : 0.0;

  /// Đăng ký một trạng thái animation mới với dải cuộn [start] và [end].
  SliverAnimationState register(String id, {
    required double start,
    required double end,
  }) {
    final state = SliverAnimationState(start: start, end: end);
    _states[id] = state;
    return state;
  }

  /// Cập nhật tất cả các trạng thái đã đăng ký dựa trên vị trí cuộn hiện tại.
  void update() {
    final offset = getScrollOffset();

    for (final state in _states.values) {
      state.update(offset);
    }
  }

  /// Phương thức tiện ích để tự động gắn listener vào ScrollController.
  void attach() {
    scrollController.addListener(update);
  }

  /// Gỡ listener để tránh memory leak.
  void detach() {
    scrollController.removeListener(update);
  }
}
