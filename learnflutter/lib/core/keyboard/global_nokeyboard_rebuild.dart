import 'package:flutter/material.dart';
import 'package:learnflutter/core/keyboard/keyboard_service.dart';

/// Keyboard Padding Constants
class KeyboardPaddingConstants {
  /// Default animation duration khi keyboard show/hide (milliseconds)
  static const int animationDurationMs = 200;

  /// Curve animation cho keyboard transition
  static const Curve animationCurve = Curves.easeInOut;
}

/// GlobalNoKeyboardRebuild - Prevent UI Rebuild When Keyboard Show/Hide
///
/// Widget này giải quyết vấn đề: Khi keyboard show, MediaQuery insets thay đổi,
/// dẫn tới rebuild toàn bộ app (cause jank/lag).
///
/// Giải pháp: Loại bỏ bottom inset từ MediaQuery data.
/// Kết quả: Keyboard show nhưng không rebuild, chỉ add padding khi cần.
///
/// Architecture Role: Core Layer - Keyboard Management Wrapper.
/// Là StatelessWidget wrapper bao quanh app root để:
/// 1. Prevent rebuild khi keyboard show (removeViewInsets bottom: true)
/// 2. Cung cấp keyboard visibility state (KeyboardService)
/// 3. App có thể manually add padding nếu cần (via KeyboardService.visible)
/// 4. Tránh jank/flash animation khi keyboard transition
///
/// Usage:
/// ```dart
/// runApp(GlobalNoKeyboardRebuild(child: MyApp()));
/// ```
///
/// Khi user tap TextField:
/// - Keyboard show từ bottom
/// - MediaQuery insets thay đổi (bottom: keyboard height)
/// - GlobalNoKeyboardRebuild loại bỏ insets → không rebuild
/// - Child widgets đọc KeyboardService.visible để manually add padding
/// - Result: Smooth keyboard animation mà không jank
///
/// How it works:
/// 1. MediaQuery.fromView() lấy current MediaQuery data (include insets)
/// 2. removeViewInsets(removeBottom: true) loại bỏ bottom inset
/// 3. Wrap child với modified MediaQuery data
/// 4. Keyboard vẫn show nhưng insets không trigger rebuild
/// 5. Widgets dùng KeyboardService.keyboardVisible ValueNotifier để add padding
class GlobalNoKeyboardRebuild extends StatelessWidget {
  /// Child widget - Thường là MyApp (entire app tree)
  final Widget child;

  /// Có thêm bottom padding khi keyboard visible không (default: true)
  /// Nếu true: Thêm padding để content không bị keyboard che
  /// Nếu false: Không add padding, allow custom padding logic
  final bool addBottomPadding;

  /// Animation duration cho keyboard show/hide transition (milliseconds)
  final int animationDurationMs;

  /// Animation curve cho keyboard transition
  final Curve animationCurve;

  const GlobalNoKeyboardRebuild({
    super.key,
    required this.child,
    this.addBottomPadding = true,
    this.animationDurationMs = KeyboardPaddingConstants.animationDurationMs,
    this.animationCurve = KeyboardPaddingConstants.animationCurve,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy current MediaQuery data từ FlutterView (platform layer)
    // platformDispatcher.views.first là main view (entire device screen)
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    // Tạo MediaQueryData từ view (include current insets)
    final originalMediaQuery = MediaQueryData.fromView(view);

    // Loại bỏ bottom inset (keyboard height)
    // removeViewInsets(removeBottom: true) sẽ remove bottom inset
    // Kết quả: Keyboard vẫn show nhưng MediaQuery.viewInsets.bottom = 0
    // → Không trigger rebuild vì MediaQuery data không thay đổi
    final modifiedMediaQuery = originalMediaQuery.removeViewInsets(
      removeBottom: true,
    );

    // Wrap child với modified MediaQuery (no bottom insets)
    // Tất cả descendants đọc MediaQuery sẽ thấy bottom inset = 0
    // Nhưng KeyboardService.visible vẫn reflect actual keyboard state
    return MediaQuery(
      data: modifiedMediaQuery,
      // ValueListenableBuilder lắng nghe keyboard visibility changes
      // Khi keyboard show/hide, kích hoạt rebuild layer keyboard padding
      // Nhưng parent UI (không dùng keyboard padding) không rebuild
      child: addBottomPadding
          ? _KeyboardPaddingWrapper(
              animationDurationMs: animationDurationMs,
              animationCurve: animationCurve,
              child: child,
            )
          : child,
    );
  }
}

/// _KeyboardPaddingWrapper - Animated Bottom Padding When Keyboard Visible
///
/// Private widget cung cấp smooth animated padding khi keyboard show.
/// Dùng AnimatedContainer để animate padding transition.
///
/// Flow:
/// 1. ValueListenableBuilder lắng nghe KeyboardService.keyboardVisible
/// 2. Khi keyboard visible = true: Add padding = keyboard height
/// 3. Khi keyboard visible = false: Padding = 0
/// 4. AnimatedContainer smooth transition between states (200ms)
/// 5. Tất cả animation nằm trong Widget này (không rebuild parent)
class _KeyboardPaddingWrapper extends StatelessWidget {
  final Widget child;
  final int animationDurationMs;
  final Curve animationCurve;

  const _KeyboardPaddingWrapper({
    required this.child,
    required this.animationDurationMs,
    required this.animationCurve,
  });

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder lắng nghe KeyboardService.keyboardVisible
    // Khi ValueNotifier value thay đổi (keyboard show/hide),
    // chỉ rebuild _KeyboardPaddingWrapper (bên dưới child layer)
    // Parent UI không rebuild (vì MediaQuery insets không thay đổi)
    return ValueListenableBuilder<bool>(
      valueListenable: KeyboardService.instance.keyboardVisible,
      builder: (context, isKeyboardVisible, child) {
        // Lấy keyboard height từ platform window viewInsets để chính xác hơn.
        // Lưu ý: Window.viewInsets trả về giá trị theo physical pixels, vì vậy
        // cần chia cho devicePixelRatio để có logical pixels giống MediaQuery.
        final window = WidgetsBinding.instance.window;
        double keyboardHeight = window.viewInsets.bottom / window.devicePixelRatio;

        // Defensive checks: đảm bảo giá trị hợp lệ và không quá lớn.
        // Một số nền tảng có thể trả về giá trị lớn hoặc không mong muốn,
        // nên giới hạn tối đa theo tỷ lệ của chiều cao màn hình.
        final screenHeight = MediaQuery.of(context).size.height;
        final maxAllowed = screenHeight * 0.4; // không cho keyboard chiếm >70% màn hình
        if (keyboardHeight.isNaN || keyboardHeight < 0) {
          keyboardHeight = 0.0;
        }
        keyboardHeight = keyboardHeight.clamp(0.0, maxAllowed);

        // Nếu keyboard không visible thì padding = 0.
        final bottomPadding = isKeyboardVisible ? keyboardHeight : 0.0;

        // Khi keyboard vừa show, cố gắng scroll tới TextField đang focus.
        // Sử dụng Scrollable.ensureVisible trên primaryFocus.context.
        if (isKeyboardVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final focusContext = FocusManager.instance.primaryFocus?.context;
              if (focusContext != null) {
                Scrollable.ensureVisible(
                  focusContext,
                  duration: Duration(milliseconds: animationDurationMs),
                  curve: animationCurve,
                  alignment: 0.1,
                );
              }
            } catch (e) {
              // Nếu ensureVisible thất bại (không có Scrollable ancestor), bỏ qua.
            }
          });
        }

        // AnimatedContainer để animate padding một cách mượt mà.
        return AnimatedContainer(
          duration: Duration(milliseconds: animationDurationMs),
          curve: animationCurve,
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: child,
        );
      },
      child: child,
    );
  }
}
