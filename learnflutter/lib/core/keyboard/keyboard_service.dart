import 'dart:async';
import 'package:flutter/material.dart';

/// Lớp KeyboardService cung cấp một cơ chế tập trung để theo dõi và quản lý các sự kiện liên quan đến bàn phím ảo trên thiết bị.
/// Nó sử dụng mô hình Singleton để đảm bảo rằng toàn bộ ứng dụng chỉ sử dụng duy nhất một bộ quản lý trạng thái bàn phím nhất quán.
/// Thông qua các đối tượng ValueNotifier, các thành phần giao diện khác có thể dễ dàng đăng ký lắng nghe sự thay đổi về chiều cao và trạng thái hiển thị của bàn phím.
/// Dịch vụ này giúp tự động hóa việc tính toán khoảng trống giao diện, mang lại trải nghiệm nhập liệu tốt hơn cho người dùng.
class KeyboardService {
  /// Singleton instance của KeyboardService.
  static final KeyboardService instance = KeyboardService._internal();
  KeyboardService._internal();

  /// ValueNotifier keyboardHeight lưu trữ thông tin về chiều cao hiện tại của bàn phím theo đơn vị điểm ảnh (pixels).
  final ValueNotifier<double> keyboardHeight = ValueNotifier(0);

  /// ValueNotifier keyboardVisible giúp xác định xem bàn phím có đang được hiển thị trên màn hình hay không.
  final ValueNotifier<bool> keyboardVisible = ValueNotifier(false);

  /// ValueNotifier isBottomBarVisible được sử dụng để điều khiển trạng thái hiển thị của thanh công cụ phía dưới (bottom bar).
  /// Trong thiết kế trải nghiệm người dùng hiện đại, việc ẩn bottom bar khi bàn phím xuất hiện giúp tối ưu hóa diện tích hiển thị cho nội dung nhập liệu.
  /// Nó giúp ngăn chặn tình trạng bottom bar bị đẩy lên phía trên bàn phím, gây ra hiện tượng che khuất hoặc làm rối rắm bố cục giao diện.
  /// Dịch vụ sẽ tự động đồng bộ hóa trạng thái này dựa trên các thay đổi về kích thước giao diện được ghi nhận từ hệ thống.
  final ValueNotifier<bool> isBottomBarVisible = ValueNotifier(true);

  /// _lastHeight dùng để ghi nhớ giá trị chiều cao cuối cùng nhằm tránh việc kích hoạt cập nhật giao diện không cần thiết.
  double _lastHeight = 0;

  /// _debounce hỗ trợ việc trì hoãn cập nhật để đợi cho đến khi các hiệu ứng chuyển cảnh của bàn phím thực sự kết thúc.
  Timer? _debounce;

  /// Phương thức start thực hiện việc đăng ký một observer để lắng nghe các thay đổi về kích thước giao diện từ hệ điều hành.
  /// Việc này cần được gọi sớm trong vòng đời ứng dụng để đảm bảo trạng thái bàn phím luôn được cập nhật kịp thời.
  void start() {
    WidgetsBinding.instance.addObserver(_KeyboardObserver());
  }

  /// Phương thức _updateFromInsets xử lý dữ liệu thô về khoảng đệm từ hệ thống và thực hiện cập nhật các Notifier sau khi đã qua bộ lọc debounce.
  /// Nó giúp lọc bỏ các dao động nhỏ và chỉ kích hoạt cập nhật giao diện khi có sự thay đổi đáng kể về vị trí của bàn phím.
  /// Cơ chế này cực kỳ quan trọng để duy trì hiệu năng mượt mà, tránh việc widget bị vẽ lại quá nhiều lần trong quá trình bàn phím trượt lên hoặc xuống.
  void _updateFromInsets(double inset) {
    _debounce?.cancel();

    // Đợi hiệu ứng chuyển cảnh của bàn phím ổn định trước khi cập nhật dữ liệu chính thức
    _debounce = Timer(const Duration(milliseconds: 40), () {
      final visible = inset > 0;

      if (visible != keyboardVisible.value) {
        keyboardVisible.value = visible;

        /// Khi trạng thái của bàn phím thay đổi, chúng tôi cũng tiến hành cập nhật trạng thái hiển thị của bottom bar một cách tương ứng.
        /// Việc ẩn bottom bar ngay khi bàn phím xuất hiện và chỉ hiển thị lại khi bàn phím đã đóng hoàn toàn giúp duy trì tính nhất quán của UI.
        /// Toàn bộ quá trình này diễn ra tự động, giúp các nhà phát triển giao diện không cần phải quản lý thủ công trạng thái này tại từng màn hình riêng lẻ.
        isBottomBarVisible.value = !visible;
      }

      if ((_lastHeight - inset).abs() > 5) {
        _lastHeight = inset;
        keyboardHeight.value = inset;
      }
    });
  }
}

/// Lớp nội bộ _KeyboardObserver thực hiện việc theo dõi các thay đổi về thông số vật lý của ứng dụng thông qua WidgetsBindingObserver.
/// Khi hệ thống thay đổi kích thước (ví dụ: xoay màn hình hoặc bàn phím xuất hiện), phương thức didChangeMetrics sẽ được gọi tự động.
/// Nó tiến hành trích xuất thông tin khoảng đệm phía dưới của màn hình chính và chuyển tiếp dữ liệu đến KeyboardService để xử lý logic tiếp theo.
class _KeyboardObserver with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    final inset = view.viewInsets.bottom;

    KeyboardService.instance._updateFromInsets(inset);
  }
}
