part of 'login_cubit.dart';

/// Lớp LoginState đóng vai trò là kho lưu trữ dữ liệu trạng thái cho toàn bộ quá trình đăng nhập và đăng ký trong ứng dụng.
/// Nó chứa đựng các thông tin cần thiết như giá trị nhập liệu của email, mật khẩu cùng với các thông báo lỗi tương ứng khi validate.
/// Ngoài ra, lớp này còn theo dõi các trạng thái của hệ thống bao gồm việc đang tải dữ liệu hay xác thực thành công để UI có thể phản hồi kịp thời.
/// Việc sử dụng Equatable giúp hệ thống so sánh các trạng thái một cách hiệu quả, từ đó tối ưu hóa việc rebuild các widget không cần thiết.
class LoginState extends Equatable {
  final String email;
  final String? emailError;
  final String password;
  final String? passwordError;
  final bool isFormValid;
  final bool isLoading;
  final bool isLoginSuccess;
  final bool isRegistrationSuccess;
  final String? errorMessage;
  final String? successMessage;
  final UserModel? loggedInUser;

  const LoginState({
    this.email = '',
    this.emailError,
    this.password = '',
    this.passwordError,
    this.isFormValid = false,
    this.isLoading = false,
    this.isLoginSuccess = false,
    this.isRegistrationSuccess = false,
    this.errorMessage,
    this.successMessage,
    this.loggedInUser,
  });

  /// Phương thức copyWith được cung cấp để tạo ra một bản sao mới của LoginState với các giá trị được cập nhật một cách bất biến.
  /// Nó cho phép thay đổi có chọn lọc một hoặc nhiều thuộc tính trong khi vẫn giữ nguyên các giá trị hiện tại của các thuộc tính khác.
  /// Mẫu thiết kế này rất quan trọng trong kiến trúc BLoC/Cubit để đảm bảo tính nhất quán của dữ liệu và dễ dàng kiểm soát các luồng sự kiện.
  /// Khi một trạng thái mới được emit, luồng dữ liệu sẽ được kích hoạt để cập nhật giao diện người dùng dựa trên những thay đổi vừa thực hiện.
  LoginState copyWith({
    String? email,
    String? emailError,
    String? password,
    String? passwordError,
    bool? isFormValid,
    bool? isLoading,
    bool? isLoginSuccess,
    bool? isRegistrationSuccess,
    String? errorMessage,
    String? successMessage,
    UserModel? loggedInUser,
  }) {
    return LoginState(
      email: email ?? this.email,
      emailError: emailError,
      password: password ?? this.password,
      passwordError: passwordError,
      isFormValid: isFormValid ?? this.isFormValid,
      isLoading: isLoading ?? this.isLoading,
      isLoginSuccess: isLoginSuccess ?? this.isLoginSuccess,
      isRegistrationSuccess:
          isRegistrationSuccess ?? this.isRegistrationSuccess,
      errorMessage: errorMessage,
      successMessage: successMessage,
      loggedInUser: loggedInUser ?? this.loggedInUser,
    );
  }

  @override
  List<Object?> get props => [
        email,
        emailError,
        password,
        passwordError,
        isFormValid,
        isLoading,
        isLoginSuccess,
        isRegistrationSuccess,
        errorMessage,
        successMessage,
        loggedInUser,
      ];
}
