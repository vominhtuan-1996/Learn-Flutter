import 'package:equatable/equatable.dart';
import 'package:learnflutter/features/login/model/login_response_model.dart';

/// Lớp LoginState đóng vai trò là kho lưu trữ dữ liệu trạng thái cho toàn bộ quá trình xác thực người dùng trong module Login.
/// Nó chứa đựng các thông tin quan trọng như trạng thái đang tải dữ liệu, thông điệp lỗi khi xác thực thất bại và kết quả phản hồi từ máy chủ.
/// Việc kế thừa từ Equatable cho phép hệ thống so sánh các trạng thái một cách hiệu quả, từ đó tối ưu hóa việc cập nhật giao diện người dùng.
/// Phương thức cloneWith được cung cấp để tạo ra các bản sao mới của trạng thái với những thay đổi cụ thể, đảm bảo tính bất biến của dữ liệu.
class LoginState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final LoginResponseModel? loginResponse;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.loginResponse,
  });

  /// Phương thức initial tạo ra trạng thái khởi đầu cho module Login với các giá trị mặc định an toàn.
  /// Nó thiết lập trạng thái đang tải là sai và các thông tin về lỗi cũng như phản hồi đăng nhập là rỗng.
  /// Đây là điểm bắt đầu cho mọi luồng xử lý trong Cubit trước khi có bất kỳ thao tác nào từ phía người dùng.
  factory LoginState.initial() {
    return const LoginState(
      isLoading: false,
    );
  }

  /// Phương thức cloneWith hỗ trợ cập nhật linh hoạt các thuộc tính của LoginState mà không làm thay đổi đối tượng hiện tại.
  /// Nó nhận vào các tham số tùy chọn và sử dụng toán tử null-coalescing để giữ lại giá trị cũ nếu không có giá trị mới được cung cấp.
  /// Cơ chế này cực kỳ hữu ích trong kiến trúc BLoC để duy trì tính nhất quán và dễ dàng theo dõi các thay đổi của hệ thống.
  LoginState cloneWith({
    bool? isLoading,
    String? errorMessage,
    LoginResponseModel? loginResponse,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      loginResponse: loginResponse ?? this.loginResponse,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, loginResponse];
}
