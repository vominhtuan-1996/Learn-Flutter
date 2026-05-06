import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/widget/icon_animation_widget.dart';
import 'package:learnflutter/core/animation/widget/list_view_animation.dart';
import 'package:learnflutter/core/animation/widget/position_animation.dart';
import 'package:learnflutter/core/animation/widget/reload_button_widget.dart';
import 'package:learnflutter/core/animation/widget/ripple_animation_widget.dart';
import 'package:learnflutter/core/animation/widget/scale_translate.dart';

class AnimationHelper {
  /// Ví dụ sử dụng [IconAnimationWidget] với hiệu ứng thông báo xoay
  static Widget iconRotateExample() {
    return const IconAnimationWidget(
      isRotate: true,
      icon: Icons.notifications_active,
    );
  }

  /// Ví dụ sử dụng [IconAnimationWidget] với hiệu ứng nhịp tim (heartbeat)
  static Widget iconHeartbeatExample() {
    return const IconAnimationWidget(
      isRotate: false,
      icon: Icons.favorite,
    );
  }

  /// Ví dụ sử dụng [ListViewAnimated] để hiển thị danh sách có hiệu ứng trượt vào
  static Widget listViewExample() {
    final mockData = List.generate(
      20,
      (index) => {'title': 'Item Animation số ${index + 1}'},
    );
    return ListViewAnimated(fullData: mockData);
  }

  /// Ví dụ sử dụng [PositionedTransitionWidget] di chuyển logo trong Stack
  static Widget positionedTransitionExample() {
    return const PositionedTransitionWidget();
  }

  /// Ví dụ sử dụng [ReloadButtonWidget] - nút bấm có hiệu ứng xoay tròn
  static Widget reloadButtonExample() {
    return ReloadButtonWidget(
      isRotate: false,
      icon: Icons.refresh,
    );
  }

  /// Ví dụ sử dụng [RippleAnimationWidget] - hiệu ứng vòng tròn lan tỏa
  static Widget rippleAnimationExample() {
    return const RippleAnimationWidget();
  }

  /// Ví dụ sử dụng [ScaleTranslateBuilder] thường dùng trong PageView
  /// Cần truyền vào PageController để tính toán giá trị animation theo vị trí cuộn
  static Widget scaleTranslateExample({
    required int index,
    required PageController pageController,
    required Widget child,
  }) {
    return ScaleTranslateBuilder(
      index: index,
      pageController: pageController,
      child: child,
    );
  }
}
