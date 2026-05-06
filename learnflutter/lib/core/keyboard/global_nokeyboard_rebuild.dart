import 'package:flutter/material.dart';

/* ============================================================================
 * 🛠 ADVANCED MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì nâng cao)
 * ============================================================================
 * 
 * 1. QUẢN LÝ ĐA MÀN HÌNH (Multi-Window Support):
 *    - Hiện tại đang sử dụng `WidgetsBinding.instance.platformDispatcher.views.first`.
 *    - ĐỊNH HƯỚNG: Khi Flutter hỗ trợ Multi-window hoàn thiện hơn trên Desktop/iPad, 
 *      cần chuyển sang lặp qua danh sách `views` hoặc sử dụng `View.of(context)` 
 *      để lấy đúng inset của màn hình đang tương tác.
 * 
 * 2. TỐI ƯU HÓA HIỆU NĂNG ANIMATION (Performance Optimization):
 *    - `didChangeMetrics` được gọi liên tục mỗi frame khi keyboard trượt lên/xuống.
 *    - QUY TẮC: TUYỆT ĐỐI KHÔNG thêm các tác vụ nặng (parse JSON, loop lớn) vào 
 *      hàm `build` của `_KeyboardPaddingWrapper` vì nó sẽ gây jank (giật lag) animation.
 * 
 * 3. CUỘN TỰ ĐỘNG (Auto-Scroll to Focus):
 *    - Hàm `Scrollable.ensureVisible` đang được gọi qua `addPostFrameCallback`.
 *    - ĐỊNH HƯỚNG: Nếu sau này UI có nhiều nested ScrollView phức tạp, cần bổ sung 
 *      cơ chế kiểm tra xem Widget đang focus có thực sự bị che khuất hay không 
 *      trước khi gọi cuộn, để tránh hiện tượng màn hình bị giật (jump) không cần thiết.
 * 
 * 4. TƯƠNG THÍCH THEME (Dark Mode / Light Mode):
 *    - QUY TẮC: Không hardcode màu nền (VD: Colors.white) ở các Wrapper gốc vì 
 *      sẽ làm hỏng Dark Mode của các màn hình bên dưới. Luôn để trong suốt (transparent).
 * ============================================================================
 */

/// Lớp KeyboardPaddingConstants định nghĩa các thông số cấu hình mặc định cho các hiệu ứng chuyển cảnh của bàn phím.
/// Nó giúp duy trì sự nhất quán về trải nghiệm người dùng bằng cách tập trung các giá trị như thời gian chạy và kiểu đường cong của animation.
/// Việc thay đổi các hằng số này sẽ ảnh hưởng đến toàn bộ ứng dụng, giúp việc tinh chỉnh giao diện trở nên nhanh chóng và dễ dàng hơn.
class KeyboardPaddingConstants {
  /// Thời gian mặc định cho hiệu ứng xuất hiện hoặc biến mất của bàn phím (đơn vị: mili giây).
  static const int animationDurationMs = 200;

  /// Kiểu đường cong animation giúp hiệu ứng trượt của bàn phím trở nên tự nhiên và mượt mà hơn.
  static const Curve animationCurve = Curves.decelerate;
}

/// Lớp GlobalNoKeyboardRebuild ngăn chặn việc rebuild toàn bộ ứng dụng khi bàn phím xuất hiện/biến mất.
///
/// Là [StatefulWidget] với [WidgetsBindingObserver], nó tự quản lý vòng đời observer và chỉ
/// rebuild [MediaQuery] khi metric thay đổi do nguyên nhân KHÔNG phải keyboard (xoay màn hình,
/// safe area, thay đổi kích thước cửa sổ). Khi keyboard show/hide, `viewInsets.bottom` thay đổi
/// nhưng widget này KHÔNG rebuild — nhờ đó cây widget con được bảo vệ hoàn toàn khỏi jank.
///
/// Việc padding theo keyboard được xử lý riêng bởi [_KeyboardPaddingWrapper] thông qua
/// [WidgetsBindingObserver.didChangeMetrics] trực tiếp trên từng frame native.
class GlobalNoKeyboardRebuild extends StatefulWidget {
  /// Widget con thường là toàn bộ cây ứng dụng (MyApp) cần được bảo vệ khỏi rebuild không cần thiết.
  final Widget child;

  /// Xác định xem có tự động thêm khoảng đệm lót phía dưới khi bàn phím xuất hiện hay không.
  final bool addBottomPadding;

  /// Thời gian diễn ra hiệu ứng chuyển đổi — chỉ dùng cho ensureVisible khi keyboard hiện.
  final int animationDurationMs;

  /// Loại đường cong mô tả tốc độ của hiệu ứng animation.
  final Curve animationCurve;

  const GlobalNoKeyboardRebuild({
    super.key,
    required this.child,
    this.addBottomPadding = true,
    this.animationDurationMs = KeyboardPaddingConstants.animationDurationMs,
    this.animationCurve = KeyboardPaddingConstants.animationCurve,
  });

  @override
  State<GlobalNoKeyboardRebuild> createState() =>
      _GlobalNoKeyboardRebuildState();
}

class _GlobalNoKeyboardRebuildState extends State<GlobalNoKeyboardRebuild>
    with WidgetsBindingObserver {
  /// Lưu viewInsets.bottom lần trước để phân biệt keyboard-change vs non-keyboard-change.
  double _lastKeyboardInset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    _lastKeyboardInset = view.viewInsets.bottom;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Chỉ rebuild MediaQuery khi metric thay đổi KHÔNG phải do keyboard.
  /// Keyboard thay đổi → _KeyboardPaddingWrapper tự xử lý qua observer của nó.
  /// Orientation/safe area thay đổi → rebuild để cập nhật MediaQuery cho cả app.
  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final currentKeyboardInset = view.viewInsets.bottom;

    if (currentKeyboardInset != _lastKeyboardInset) {
      // Thay đổi do keyboard → chỉ cập nhật cache, KHÔNG rebuild cây con.
      _lastKeyboardInset = currentKeyboardInset;
      return;
    }

    // Thay đổi do nguyên nhân khác (orientation, safe area, resize) → cần rebuild MediaQuery.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    // Lấy MediaQueryData từ view gốc — bao gồm đầy đủ thông tin hệ thống.
    final originalMediaQuery = MediaQueryData.fromView(view);

    // Loại bỏ bottom viewInsets (chiều cao keyboard) để các widget con không bị rebuild
    // hay thay đổi layout khi keyboard xuất hiện/biến mất.
    final modifiedMediaQuery = originalMediaQuery.removeViewInsets(
      removeBottom: true,
    );

    return MediaQuery(
      data: modifiedMediaQuery,
      child: widget.addBottomPadding
          ? _KeyboardPaddingWrapper(
              animationDurationMs: widget.animationDurationMs,
              animationCurve: widget.animationCurve,
              child: widget.child,
            )
          : widget.child,
    );
  }
}

/// Lớp nội bộ _KeyboardPaddingWrapper theo dõi chiều cao bàn phím real-time qua
/// [WidgetsBindingObserver.didChangeMetrics] — được native gọi mỗi frame trong suốt
/// quá trình keyboard show/dismiss — rồi mirror chính xác từng pixel vào [Padding].
///
/// Cách tiếp cận này đảm bảo Flutter UI luôn đồng bộ 100% với native keyboard animation
/// mà không cần [AnimatedContainer] hay debounce cố định, tránh mọi timing drift.
class _KeyboardPaddingWrapper extends StatefulWidget {
  final Widget child;
  final int animationDurationMs;
  final Curve animationCurve;

  const _KeyboardPaddingWrapper({
    required this.child,
    required this.animationDurationMs,
    required this.animationCurve,
  });

  @override
  State<_KeyboardPaddingWrapper> createState() =>
      _KeyboardPaddingWrapperState();
}

class _KeyboardPaddingWrapperState extends State<_KeyboardPaddingWrapper>
    with WidgetsBindingObserver {
  /// Chiều cao bàn phím hiện tại (logical pixels), cập nhật real-time mỗi frame native.
  double _keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readKeyboardHeight();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Native gọi didChangeMetrics() mỗi frame khi keyboard đang animate (show/dismiss).
  /// Đây là cách sync 100% với native — không cần AnimatedContainer hay debounce.
  @override
  void didChangeMetrics() {
    _readKeyboardHeight();
  }

  void _readKeyboardHeight() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final rawHeight = view.viewInsets.bottom / view.devicePixelRatio;

    // Tính screen height trực tiếp từ view để tránh gọi MediaQuery.of() ngoài build().
    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    final clamped = rawHeight.isNaN || rawHeight < 0
        ? 0.0
        : rawHeight.clamp(0.0, screenHeight * 0.7);

    // Chỉ setState khi có thay đổi đủ lớn để tránh rebuild thừa.
    if ((clamped - _keyboardHeight).abs() > 0.5) {
      setState(() => _keyboardHeight = clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tự động cuộn đến field đang focus khi keyboard đang hiện.
    if (_keyboardHeight > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final focusContext = FocusManager.instance.primaryFocus?.context;
          if (focusContext != null) {
            Scrollable.ensureVisible(
              focusContext,
              duration: Duration(milliseconds: widget.animationDurationMs),
              curve: widget.animationCurve,
              alignment: 0.1,
            );
          }
        } catch (_) {}
      });
    }

    // Padding follow đúng từng pixel native keyboard.
    // Native đã tự animate — ta chỉ mirror lại giá trị thực mỗi frame.
    return Container(
      color: Colors.transparent, // [Rule 4] Sử dụng transparent thay vì white để hỗ trợ Dark Mode
      child: Padding(
        padding: EdgeInsets.only(bottom: _keyboardHeight),
        child: widget.child,
      ),
    );
  }
}
