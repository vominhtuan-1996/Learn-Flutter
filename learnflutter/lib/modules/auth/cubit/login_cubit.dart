import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:learnflutter/db/models/user_model.dart';
import 'package:learnflutter/data/repositories/user_repository.dart';
import 'package:learnflutter/extendsion_ui/form/form.dart';

part 'login_state.dart';

/// LoginCubit - Tầng Business Logic cho quá trình authentication
///
/// Cubit này chịu trách nhiệm quản lý toàn bộ logic liên quan đến login/register.
/// Nó điều phối giữa Presentation Layer (UI) và Data Layer (Database).
/// Quy trình hoạt động:
/// 1. Nhận input từ UI (email, password)
/// 2. Validate dữ liệu sử dụng FormValidator
/// 3. Truy vấn database thông qua UserDatabase
/// 4. Xử lý business logic (check password, update lastLogin)
/// 5. Emit state mới để UI cập nhật
class LoginCubit extends Cubit<LoginState> {
  final UserRepository _userRepository = UserRepository.instance;

  LoginCubit() : super(const LoginState());

  /// updateEmail - Cập nhật email và validate real-time.
  ///
  /// Method này được gọi mỗi khi user thay đổi text trong email field.
  /// Nó validate email format sử dụng FormValidator và emit state mới.
  /// Người dùng thấy lỗi ngay khi nhập, giúp cải thiện UX.
  void updateEmail(String email) {
    final emailError = FormValidator.validateEmail(email);
    emit(state.copyWith(
      email: email,
      emailError: emailError,
      isFormValid: _validateLoginForm(
        email: email,
        password: state.password,
      ),
    ));
  }

  /// updatePassword - Cập nhật password và validate real-time.
  ///
  /// Method này được gọi mỗi khi user thay đổi text trong password field.
  /// Nó kiểm tra password không trống và emit state mới cho UI update.
  void updatePassword(String password) {
    final passwordError = password.isEmpty ? 'Mật khẩu không được để trống' : null;
    emit(state.copyWith(
      password: password,
      passwordError: passwordError,
      isFormValid: _validateLoginForm(
        email: state.email,
        password: password,
      ),
    ));
  }

  /// login - Thực hiện quá trình đăng nhập của user.
  ///
  /// Quy trình:
  /// 1. Validate form (email, password hợp lệ)
  /// 2. Set loading state
  /// 3. Tìm user từ database theo email
  /// 4. Kiểm tra user có tồn tại và account có active không
  /// 5. Verify password
  /// 6. Update lastLogin timestamp
  /// 7. Emit LoginSuccess state hoặc emit error state
  /// Nếu lỗi xảy ra ở bất kỳ bước nào, emit error message cho UI hiển thị
  Future<void> login() async {
    // Validate form trước
    if (!_validateLoginForm(email: state.email, password: state.password)) {
      final emailError = FormValidator.validateEmail(state.email);
      final passwordError = state.password.isEmpty ? 'Mật khẩu không được để trống' : null;
      emit(state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      // Sử dụng UserRepository để login qua API
      final user = await _userRepository.login(email: state.email, password: state.password);

      // Login thành công
      emit(state.copyWith(
        isLoading: false,
        isLoginSuccess: true,
        successMessage: 'Đăng nhập thành công',
        loggedInUser: user,
      ));
    } catch (e) {
      final errMsg = e is Exception ? e.toString() : 'Lỗi không xác định';
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi: $errMsg',
      ));
    }
  }

  /// Đăng ký user mới
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? fullName,
    String? phone,
  }) async {
    try {
      // Validate form
      final emailError = FormValidator.validateEmail(email);
      final passwordError = FormValidator.validatePassword(password);
      final confirmError = FormValidator.validateConfirmPassword(password, confirmPassword);

      if (emailError != null || passwordError != null || confirmError != null) {
        emit(state.copyWith(
          errorMessage: emailError ?? passwordError ?? confirmError,
        ));
        return false;
      }

      // Sử dụng UserRepository để đăng ký
      final payload = {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      };
      final newUser = await _userRepository.register(payload);
      emit(state.copyWith(
        successMessage: 'Đăng ký thành công. Vui lòng đăng nhập',
        isRegistrationSuccess: true,
        loggedInUser: newUser,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Lỗi đăng ký: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Reset form
  void resetForm() {
    emit(const LoginState());
  }

  /// Clear messages
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
      isLoginSuccess: false,
      isRegistrationSuccess: false,
    ));
  }

  /// Logout
  void logout() {
    emit(const LoginState());
  }

  /// Private method để validate login form
  bool _validateLoginForm({required String email, required String password}) {
    return FormValidator.validateEmail(email) == null && password.isNotEmpty;
  }
}
