import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/data/repositories/user_repository.dart';
import 'package:learnflutter/data/models/user_model.dart';
import 'package:learnflutter/core/extensions/form/form.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';

part 'login_state.dart';

/// Lớp LoginCubit chịu trách nhiệm quản lý các logic nghiệp vụ (Business Logic) liên quan đến quá trình xác thực người dùng trong ứng dụng.
/// Nó đóng vai trò là cầu nối trung gian điều phối dữ liệu giữa tầng Hiển thị (Presentation Layer) và tầng Dữ liệu (Data Layer).
/// Quy trình hoạt động của Cubit bao gồm việc nhận các đầu vào từ giao diện người dùng, thực hiện kiểm tra tính hợp lệ và truy vấn cơ sở dữ liệu thông qua UserRepository.
/// Sau khi xử lý các nghiệp vụ như kiểm tra mật khẩu hay cập nhật trạng thái, nó sẽ phát ra (emit) các trạng thái mới để giao diện người dùng có thể cập nhật tương ứng.
class LoginCubit extends Cubit<LoginState> {
  final UserRepository _userRepository = UserRepository.instance;

  LoginCubit() : super(const LoginState());

  /// Phương thức updateEmail được sử dụng để cập nhật giá trị email từ giao diện và thực hiện kiểm tra tính hợp lệ ngay lập tức (real-time).
  /// Mỗi khi người dùng thay đổi dữ liệu trong khung nhập liệu email, phương thức này sẽ được gọi để xác thực định dạng email thông qua FormValidator.
  /// Việc cập nhật trạng thái lỗi ngay lập tức giúp cải thiện trải nghiệm người dùng bằng cách cung cấp phản hồi nhanh chóng về tính hợp lệ của dữ liệu.
  /// Cuối cùng, nó sẽ kiểm tra lại toàn bộ form để cập nhật trạng thái isFormValid giúp kiểm soát việc kích hoạt nút đăng nhập trên màn hình.
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

  /// Hàm updatePassword chịu trách nhiệm quản lý trạng thái của mật khẩu khi người dùng thực hiện các thay đổi trên giao diện.
  /// Nó kiểm tra xem mật khẩu có bị bỏ trống hay không và cung cấp một thông báo lỗi cục bộ thông qua hệ thống bản dịch nếu cần thiết.
  /// Trạng thái mới của mật khẩu cùng với thông tin về tính hợp lệ của toàn bộ form sẽ được cập nhật đồng thời để đảm bảo tính nhất quán.
  /// Cơ chế này giúp ứng dụng duy trì được sự phản hồi linh hoạt và chính xác đối với các thao tác nhập liệu bí mật của người dùng.
  void updatePassword(String password) {
    final context = UtilsHelper.navigatorKey.currentContext;
    final passwordError = password.isEmpty
        ? (context != null
            ? AppLocaleTranslate.passwordEmptyError.getString(context)
            : 'Mật khẩu không được để trống')
        : null;
    emit(state.copyWith(
      password: password,
      passwordError: passwordError,
      isFormValid: _validateLoginForm(
        email: state.email,
        password: password,
      ),
    ));
  }

  /// Phương thức login thực hiện toàn bộ quy trình xác thực người dùng dựa trên thông tin email và mật khẩu đã cung cấp.
  /// Đầu tiên, nó sẽ thực hiện validate lại form một lần cuối để đảm bảo tất cả các ràng buộc về dữ liệu đều được thỏa mãn trước khi xử lý.
  /// Trong quá trình gửi yêu cầu tới máy chủ, trạng thái isLoading sẽ được kích hoạt để hiển thị hiệu ứng chờ đợi cho người dùng trên giao diện.
  /// Nếu đăng nhập thành công, các thông tin về người dùng cùng thông báo thành công sẽ được phát ra, ngược lại các lỗi phát sinh sẽ được bắt và hiển thị tương ứng.
  Future<void> login() async {
    final context = UtilsHelper.navigatorKey.currentContext;
    if (!_validateLoginForm(email: state.email, password: state.password)) {
      final emailError = FormValidator.validateEmail(state.email);
      final passwordError = state.password.isEmpty
          ? (context != null
              ? AppLocaleTranslate.passwordEmptyError.getString(context)
              : 'Mật khẩu không được để trống')
          : null;
      emit(state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final user = await _userRepository.login(
          email: state.email, password: state.password);

      emit(state.copyWith(
        isLoading: false,
        isLoginSuccess: true,
        successMessage: context != null
            ? AppLocaleTranslate.loginSuccess.getString(context)
            : 'Đăng nhập thành công',
        loggedInUser: user,
      ));
    } catch (e) {
      final unknownError = context != null
          ? AppLocaleTranslate.unknownError.getString(context)
          : 'Lỗi không xác định';
      final errorPrefix = context != null
          ? AppLocaleTranslate.errorPrefix.getString(context)
          : 'Lỗi: ';
      final errMsg = e is Exception ? e.toString() : unknownError;
      emit(state.copyWith(
        isLoading: false,
        errorMessage: '$errorPrefix$errMsg',
      ));
    }
  }

  /// Hàm register cung cấp tính năng đăng ký thành viên mới cho ứng dụng thông qua việc gửi dữ liệu hồ sơ tới hệ thống.
  /// Trước khi thực hiện đăng ký, nó kiểm tra tính hợp lệ của các trường như email, mật khẩu và mật khẩu xác nhận để đảm bảo dữ liệu chuẩn xác.
  /// Nếu có bất kỳ lỗi xác thực nào xảy ra, một trạng thái lỗi sẽ được phát ra ngay lập tức để người dùng có thể điều chỉnh kịp thời.
  /// Khi quá trình đăng ký hoàn tất thành công, ứng dụng sẽ thông báo tới người dùng và yêu cầu họ thực hiện đăng nhập để bắt đầu sử dụng dịch vụ.
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? fullName,
    String? phone,
  }) async {
    final context = UtilsHelper.navigatorKey.currentContext;
    try {
      final emailError = FormValidator.validateEmail(email);
      final passwordError = FormValidator.validatePassword(password);
      final confirmError =
          FormValidator.validateConfirmPassword(password, confirmPassword);

      if (emailError != null || passwordError != null || confirmError != null) {
        emit(state.copyWith(
          errorMessage: emailError ?? passwordError ?? confirmError,
        ));
        return false;
      }

      final payload = {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      };
      final newUser = await _userRepository.register(payload);
      emit(state.copyWith(
        successMessage: context != null
            ? AppLocaleTranslate.registerSuccess.getString(context)
            : 'Đăng ký thành công. Vui lòng đăng nhập',
        isRegistrationSuccess: true,
        loggedInUser: newUser,
      ));
      return true;
    } catch (e) {
      final regErrorPrefix = context != null
          ? AppLocaleTranslate.registrationErrorPrefix.getString(context)
          : 'Lỗi đăng ký: ';
      emit(state.copyWith(
        errorMessage: '$regErrorPrefix${e.toString()}',
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
