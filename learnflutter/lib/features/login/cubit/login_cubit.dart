import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learnflutter/features/login/model/login_request_model.dart';
import 'package:learnflutter/features/login/repos/login_repository.dart';
import 'package:learnflutter/features/login/state/login_state.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Lớp LoginCubit chịu trách nhiệm quản lý các luồng logic nghiệp vụ liên quan đến việc xác thực người dùng trong hệ thống.
/// Nó đóng vai trò là trung tâm điều khiển, nhận các yêu cầu từ giao diện người dùng và phối hợp với LoginRepository để thực hiện đăng nhập.
/// Thông qua việc phát ra các trạng thái LoginState khác nhau, nó giúp giao diện người dùng có thể phản hồi linh hoạt với quá trình xác thực.
/// Cơ chế xử lý lỗi và quản lý trạng thái loading được tích hợp chặt chẽ để đảm bảo trải nghiệm người dùng mượt mà và tin cậy.
class LoginCubit extends Cubit<LoginState> {
  final LoginRepository _repository = LoginRepository.instance;

  LoginCubit() : super(LoginState.initial());

  /// Phương thức login thực hiện toàn bộ quy trình gửi thông tin đăng nhập từ người dùng tới hệ thống máy chủ để xác thực.
  /// Khi bắt đầu, nó sẽ phát ra trạng thái đang tải (isLoading = true) để giao diện hiển thị các hiệu ứng chờ đợi tương ứng.
  /// Nếu quá trình đăng nhập thành công, dữ liệu phản hồi sẽ được cập nhật vào state; ngược lại, các thông báo lỗi sẽ được bắt và hiển thị.
  /// Việc tách biệt logic xử lý này giúp đảm bảo mã nguồn dễ bảo trì, dễ kiểm thử và tuân thủ chặt chẽ kiến trúc của dự án.
  Future<void> login(String username, String password) async {
    try {
      emit(state.cloneWith(isLoading: true, errorMessage: null));

      final request = LoginRequestModel(username: username, password: password);
      final response = await _repository.login(request);

      emit(state.cloneWith(
        isLoading: false,
        loginResponse: response,
      ));
    } catch (e) {
      emit(state.cloneWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Phương thức loginWithGoogle thực hiện quy trình đăng nhập thông qua tài khoản Google của người dùng.
  /// Nó khởi động luồng giao diện của bộ công cụ GoogleSignIn để người dùng lựa chọn tài khoản và cấp quyền truy cập.
  /// Sau khi nhận được mã thông báo định danh (ID Token), nó sẽ gửi thông tin này tới backend để hoàn tất quy trình xác thực.
  /// Hệ thống sẽ tự động cập nhật trạng thái giao diện dựa trên kết quả trả về từ dịch vụ của Google và máy chủ ứng dụng.
  Future<void> loginWithGoogle() async {
    try {
      emit(state.cloneWith(isLoading: true, errorMessage: null));

      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        emit(state.cloneWith(isLoading: false));
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final response = await _repository.loginWithSocial(
        provider: 'google',
        token: auth.idToken ?? '',
        email: account.email,
        name: account.displayName,
      );

      emit(state.cloneWith(isLoading: false, loginResponse: response));
    } catch (e) {
      emit(state.cloneWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Phương thức loginWithFacebook hỗ trợ người dùng đăng nhập nhanh chóng bằng việc sử dụng tài khoản Facebook cá nhân.
  /// Nó gọi hàm login của FacebookAuth SDK để yêu cầu quyền truy cập vào thông tin hồ sơ công khai và email của người dùng.
  /// Nếu người dùng chấp thuận, mã thông báo truy cập (Access Token) sẽ được trích xuất và gửi về backend để kiểm tra tính hợp lệ.
  /// Toàn bộ quá trình được bảo mật nghiêm ngặt và đồng bộ với trạng thái ứng dụng nhằm mang lại trải nghiệm đăng nhập không mật khẩu thuận tiện.
  Future<void> loginWithFacebook() async {
    try {
      emit(state.cloneWith(isLoading: true, errorMessage: null));

      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final response = await _repository.loginWithSocial(
          provider: 'facebook',
          token: result.accessToken?.tokenString ?? '',
        );
        emit(state.cloneWith(isLoading: false, loginResponse: response));
      } else {
        emit(state.cloneWith(
          isLoading: false,
          errorMessage: result.message ?? 'Facebook login failed',
        ));
      }
    } catch (e) {
      emit(state.cloneWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// Phương thức loginWithApple tích hợp giải pháp xác thực bảo mật của Apple dành cho người dùng thiết bị iOS và macOS.
  /// Nó sử dụng plugin sign_in_with_apple để thực hiện các yêu cầu xác thực sinh trắc học hoặc mã pin của thiết bị.
  /// Thông tin định danh được trả về bao gồm mã thông báo xác thực (Identity Token) giúp máy chủ xác minh danh tính người dùng mà không cần mật khẩu.
  /// Đây là tính năng quan trọng giúp ứng dụng tuân thủ các chính sách mới nhất của Apple về quyền riêng tư và trải nghiệm người dùng.
  Future<void> loginWithApple() async {
    try {
      emit(state.cloneWith(isLoading: true, errorMessage: null));

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final response = await _repository.loginWithSocial(
        provider: 'apple',
        token: credential.identityToken ?? '',
        email: credential.email,
        name: '${credential.givenName} ${credential.familyName}',
      );

      emit(state.cloneWith(isLoading: false, loginResponse: response));
    } catch (e) {
      emit(state.cloneWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
