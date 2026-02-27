import 'dart:async';
import 'package:flutter/foundation.dart';

/// Lớp Debounce cung cấp cơ chế kiểm soát tần suất thực thi của một hành động cụ thể trong ứng dụng.
/// Nó giúp ngăn chặn việc thực hiện quá nhiều tác vụ giống nhau trong một khoảng thời gian ngắn, chẳng hạn như khi người dùng nhập liệu tìm kiếm.
/// Lớp này được thiết kế theo mô hình Singleton để đảm bảo toàn bộ hệ thống chia sẻ chung một bộ đếm thời gian thống nhất.
/// Đây là một giải pháp hữu hiệu để tối ưu hóa hiệu suất và giảm tải cho các dịch vụ nền hoặc API bên thứ ba.
class Debounce {
  static Debounce? _singleton;

  Debounce._();

  factory Debounce() {
    _singleton ??= Debounce._();
    return _singleton!;
  }

  static Debounce get instance => Debounce();

  /// The callback you want to call in debounce
  VoidCallback? action;

  /// This is the counter
  Timer? _timer;

  /// Is there any functions are calling
  bool isBusy = false;

  /// Time for 1 debounce (ms)
  final delay = 300;

  /// Phương thức runAfter trì hoãn việc thực thi hành động cho đến khi một khoảng thời gian chờ (delay) đã trôi qua kể từ lần gọi cuối cùng.
  /// Nếu có một yêu cầu mới xuất hiện trong khi bộ đếm đang chạy, hành động cũ sẽ bị hủy bỏ và bộ đếm sẽ bắt đầu lại từ đầu.
  /// Cơ chế này cực kỳ hữu ích cho việc xử lý tìm kiếm tự động khi người dùng đang gõ phím liên tục trong ô nhập liệu.
  /// Nó giúp ứng dụng chỉ thực hiện kết quả cuối cùng, tiết kiệm đáng kể tài nguyên tính toán và băng thông mạng.
  runAfter({required VoidCallback action, int? rate}) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: rate ?? delay), action);
  }

  /// Phương thức runBefore thực thi hành động ngay lập tức tại lần gọi đầu tiên và sau đó ngăn chặn các lần gọi tiếp theo trong khoảng thời gian chờ.
  /// Trong giai đoạn "nghỉ" (cool down), mọi yêu cầu thực thi hành động sẽ hoàn toàn bị bỏ qua cho đến khi trạng thái bận kết thúc.
  /// Đây là giải pháp hoàn hảo để chống việc người dùng nhấn nút (double tap) quá nhanh dẫn đến các hành động không mong muốn như gửi đơn hàng trùng lặp.
  /// Nó mang lại trải nghiệm tương tác chắc chắn và tin cậy cho người dùng đối với các nút bấm quan trọng.
  runBefore({required VoidCallback action, int? rate}) {
    try {
      if (!isBusy) {
        isBusy = true;
        Timer(Duration(milliseconds: rate ?? delay), () => isBusy = false);
        action();
      }
    } catch (e) {}
  }

  /// Phương thức removeTimer thực hiện việc hủy bỏ bộ đếm thời gian hiện tại nếu nó đang trong quá trình chờ đợi.
  /// Việc này cần thiết khi bạn muốn dừng hoàn toàn các hành động đã được lập lịch trước đó do thay đổi trạng thái giao diện hoặc người dùng thoát trang.
  removeTimer() {
    _timer?.cancel();
  }
}

/// Lớp SingleDebounce là phiên bản độc lập của cơ chế kiểm soát tần suất hành động, không sử dụng mô hình Singleton.
/// Nó cho phép tạo ra nhiều bộ đếm riêng biệt cho các widget hoặc logic khác nhau mà không ảnh hưởng lẫn nhau.
/// Các phương thức runAfter và runBefore hoạt động tương tự như lớp Debounce nhưng duy trì trạng thái riêng cho từng đối tượng khởi tạo.
/// Lớp này mang lại sự linh hoạt cao khi ứng dụng yêu cầu các bộ đếm thời gian hoạt động song song tại nhiều vị trí khác nhau.
class SingleDebounce {
  /// The callback you want to call in debounce
  VoidCallback? action;

  /// This is the counter
  Timer? _timer;

  /// Is there any functions are calling
  bool isBusy = false;

  /// Time for 1 debounce (ms)
  final delay = 300;

  /// Thực thi hành động sau một khoảng thời gian chờ kể từ lần yêu cầu cuối cùng để tối ưu hóa hiệu suất xử lý.
  runAfter({required VoidCallback action, int? rate}) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: rate ?? delay), action);
  }

  /// Thực thi hành động ngay lập tức và chặn các lần gọi tiếp theo trong thời gian nghỉ để tránh các tác vụ trùng lặp.
  runBefore({required VoidCallback action, int? rate}) {
    try {
      if (!isBusy) {
        isBusy = true;
        Timer(Duration(milliseconds: rate ?? delay), () => isBusy = false);
        action();
      }
    } catch (e) {}
  }

  /// Hủy bỏ bộ đếm thời gian đang chạy để giải phóng tài nguyên và ngăn chặn các hành động không còn cần thiết.
  removeTimer() {
    _timer?.cancel();
  }
}
