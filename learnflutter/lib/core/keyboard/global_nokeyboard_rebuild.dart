import 'package:flutter/material.dart';
import 'package:learnflutter/core/keyboard/keyboard_service.dart';

/// Lớp KeyboardPaddingConstants định nghĩa các thông số cấu hình mặc định cho các hiệu ứng chuyển cảnh của bàn phím.
/// Nó giúp duy trì sự nhất quán về trải nghiệm người dùng bằng cách tập trung các giá trị như thời gian chạy và kiểu đường cong của animation.
/// Việc thay đổi các hằng số này sẽ ảnh hưởng đến toàn bộ ứng dụng, giúp việc tinh chỉnh giao diện trở nên nhanh chóng và dễ dàng hơn.
class KeyboardPaddingConstants {
  /// Thời gian mặc định cho hiệu ứng xuất hiện hoặc biến mất của bàn phím (đơn vị: mili giây).
  static const int animationDurationMs = 200;

  /// Kiểu đường cong animation giúp hiệu ứng trượt của bàn phím trở nên tự nhiên và mượt mà hơn.
  static const Curve animationCurve = Curves.decelerate;
}

/// Lớp GlobalNoKeyboardRebuild là một giải pháp tối ưu nhằm ngăn chặn việc toàn bộ ứng dụng bị vẽ lại (rebuild) khi bàn phím xuất hiện hoặc biến mất.
/// Trong Flutter, mặc định việc thay đổi kích thước view insets sẽ kích hoạt lại hàm build của các widget cấp cao, gây ra hiện tượng giật lag (jank).
/// Lớp này can thiệp vào dữ liệu MediaQuery để loại bỏ thông số đệm dưới từ hệ thống, từ đó tránh được sự thay đổi kích thước đột ngột ở lớp root.
/// Thay vào đó, nó khuyến khích việc sử dụng KeyboardService để chủ động thêm khoảng đệm lót một cách thủ công và mượt mà hơn cho các thành phần cần thiết.
class GlobalNoKeyboardRebuild extends StatelessWidget {
  /// Widget con thường là toàn bộ cây ứng dụng (MyApp) cần được bảo vệ khỏi việc rebuild không cần thiết.
  final Widget child;

  /// Xác định xem có tự động thêm khoảng đệm lót phía dưới khi bàn phím xuất hiện hay không.
  final bool addBottomPadding;

  /// Thời gian diễn ra hiệu ứng chuyển đổi giữa các trạng thái bàn phím.
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
  Widget build(BuildContext context) {
    // Truy xuất thông tin cấu hình hiển thị hiện tại từ cửa sổ ứng dụng chính của thiết bị.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    // Khởi tạo dữ liệu MediaQuery thô bao gồm cả các khoảng đệm hệ thống mặc định.
    final originalMediaQuery = MediaQueryData.fromView(view);

    // Thực hiện việc loại bỏ thông số khoảng đệm dưới (thường là chiều cao bàn phím) để đánh lừa các widget con.
    // Kết quả là khi bàn phím hiện lên, các thành phần giao diện cấp cao sẽ không nhận thấy sự thay đổi về kích thước màn hình.
    // Điều này cực kỳ quan trọng để duy trì tốc độ khung hình ổn định khi người dùng tap vào các trường nhập liệu.
    final modifiedMediaQuery = originalMediaQuery.removeViewInsets(
      removeBottom: true,
    );

    // Cung cấp dữ liệu MediaQuery đã chỉnh sửa cho toàn bộ các thành phần cấp dưới thông qua widget MediaQuery.
    return MediaQuery(
      data: modifiedMediaQuery,
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

/// Lớp nội bộ _KeyboardPaddingWrapper thực hiện việc thêm khoảng đệm lót một cách có kiểm soát và mượt mà.
/// Nó lắng nghe trạng thái bàn phím từ KeyboardService và chỉ vẽ lại chính nó thay vì làm ảnh hưởng đến các widget cha cấp cao.
/// Việc tính toán chiều cao bàn phím được thực hiện kỹ lưỡng dựa trên tỷ lệ điểm ảnh vật lý để đảm bảo độ chính xác tuyệt đối trên mọi thiết bị.
/// Ngoài ra, nó còn hỗ trợ tự động cuộn đến trường đang được focus để mang lại trải nghiệm nhập liệu thuận tiện nhất cho người dùng.
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
    // Sử dụng ValueListenableBuilder để chỉ thực hiện rebuild cục bộ khi trạng thái bàn phím thay đổi.
    return ValueListenableBuilder<bool>(
      valueListenable: KeyboardService.instance.keyboardVisible,
      builder: (context, isKeyboardVisible, child) {
        // Lấy thông tin chiều cao bàn phím từ window và quy đổi sang đơn vị điểm ảnh logic (logical pixels).
        final window = WidgetsBinding.instance.window;
        double keyboardHeight =
            window.viewInsets.bottom / window.devicePixelRatio;

        // Thực hiện kiểm tra an toàn để đảm bảo chiều cao bàn phím không vượt quá giới hạn cho phép hoặc có giá trị bất thường.
        final screenHeight = MediaQuery.of(context).size.height;
        final maxAllowed = screenHeight * 0.6;
        if (keyboardHeight.isNaN || keyboardHeight < 0) {
          keyboardHeight = 0.0;
        }
        keyboardHeight = keyboardHeight.clamp(0.0, maxAllowed);

        // Xác định giá trị đệm cuối cùng dựa trên việc bàn phím có đang hiển thị hay không.
        final bottomPadding = isKeyboardVisible ? keyboardHeight : 0.0;

        // Tự động đảm bảo trường nhập liệu đang được focus luôn nằm trong vùng nhìn thấy của người dùng khi bàn phím hiện lên.
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
              // Bỏ qua nếu không tìm thấy tổ tiên là Scrollable hoặc có lỗi xảy ra trong quá trình cuộn.
            }
          });
        }

        // Sử dụng AnimatedContainer để thực hiện việc thay đổi khoảng đệm một cách mượt mà và tự nhiên nhất.
        return AnimatedContainer(
          duration: Duration(milliseconds: animationDurationMs),
          curve: animationCurve,
          padding: EdgeInsets.only(bottom: bottomPadding),
          color: Colors.white,
          child: child,
        );
      },
      child: child,
    );
  }
}
