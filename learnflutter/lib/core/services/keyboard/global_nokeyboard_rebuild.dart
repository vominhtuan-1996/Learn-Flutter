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

  /// Gradient fill cho vùng keyboard. Null = không paint (trong suốt). Đặt trên scaffold
  /// qua Stack nên không bị scaffoldBackgroundColor đè khi dismiss.
  final Gradient? bottomFillGradient;

  const GlobalNoKeyboardRebuild({
    super.key,
    required this.child,
    this.addBottomPadding = true,
    this.animationDurationMs = KeyboardPaddingConstants.animationDurationMs,
    this.animationCurve = KeyboardPaddingConstants.animationCurve,
    this.bottomFillGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFF9CA3AF)],
    ),
  });

  @override
  State<GlobalNoKeyboardRebuild> createState() => _GlobalNoKeyboardRebuildState();
}

class _GlobalNoKeyboardRebuildState extends State<GlobalNoKeyboardRebuild> with WidgetsBindingObserver {
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
              bottomFillGradient: widget.bottomFillGradient,
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
  final Gradient? bottomFillGradient;

  const _KeyboardPaddingWrapper({
    required this.child,
    required this.animationDurationMs,
    required this.animationCurve,
    this.bottomFillGradient,
  });

  @override
  State<_KeyboardPaddingWrapper> createState() => _KeyboardPaddingWrapperState();
}

class _KeyboardPaddingWrapperState extends State<_KeyboardPaddingWrapper> with WidgetsBindingObserver, TickerProviderStateMixin {
  /// Chiều cao bàn phím hiện tại theo viewInsets — drive cho [Padding] để layout
  /// nội dung tránh keyboard. Mirror chính xác viewInsets từng frame.
  double _keyboardHeight = 0.0;

  /// Chiều cao decay cho overlay fill — tách rời khỏi viewInsets để giữ vùng
  /// fill phủ trên scaffold trong suốt thời gian keyboard slide xuống, kể cả
  /// khi iOS report viewInsets = 0 ngay khi dismiss bắt đầu.
  double _fillHeight = 0.0;

  AnimationController? _dismissCtrl;
  double _dismissFrom = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _readKeyboardHeight();
  }

  @override
  void dispose() {
    _dismissCtrl?.dispose();
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

    final screenHeight = view.physicalSize.height / view.devicePixelRatio;
    final clamped = rawHeight.isNaN || rawHeight < 0 ? 0.0 : rawHeight.clamp(0.0, screenHeight * 0.7);

    if ((clamped - _keyboardHeight).abs() < 0.5) return;

    final wasOpen = _keyboardHeight > 0;
    final nowClosed = clamped == 0;
    _keyboardHeight = clamped;

    if (wasOpen && nowClosed) {
      // Dismiss: viewInsets có thể nhảy về 0 ngay (iOS). Decay _fillHeight riêng
      // qua AnimationController để overlay che kín suốt thời gian keyboard slide
      // xuống — không cho scaffoldBg lộ ra ở vùng keyboard.
      _dismissFrom = _fillHeight;
      _dismissCtrl?.dispose();
      _dismissCtrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDurationMs),
      )
        ..addListener(() {
          setState(() {
            _fillHeight = _dismissFrom * (1 - _dismissCtrl!.value);
          });
        })
        ..forward();
    } else {
      // Show hoặc resize: fill bám sát keyboard ngay lập tức.
      _dismissCtrl?.stop();
      setState(() => _fillHeight = clamped);
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

    // Padding mirror viewInsets cho content (scaffold compress đúng nhịp keyboard).
    final padded = Padding(
      padding: EdgeInsets.only(bottom: _keyboardHeight),
      child: widget.child,
    );

    // Khi không cần fill → trả Padding trực tiếp; scaffoldBg sẽ lộ ra khi dismiss.
    final gradient = widget.bottomFillGradient;
    if (gradient == null) return padded;

    // Khi có gradient → đặt overlay NẰM TRÊN scaffold qua Stack, cao đúng _fillHeight
    // (decay riêng khi dismiss) → vùng keyboard luôn có gradient này, không bị
    // scaffoldBg đè lên trong lúc keyboard trượt xuống. Stack cần Directionality.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Positioned.fill(child: padded),
          if (_fillHeight > 0.5)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _fillHeight,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
