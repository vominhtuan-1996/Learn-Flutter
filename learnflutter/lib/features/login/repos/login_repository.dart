import 'package:learnflutter/core/network/api_client/api_client.dart';
import 'package:learnflutter/features/login/model/login_request_model.dart';
import 'package:learnflutter/features/login/model/login_response_model.dart';

/// Lớp LoginRepository chịu trách nhiệm thực hiện các tương tác với hệ thống máy chủ để xử lý yêu cầu xác thực người dùng.
/// Nó hoạt động như một tầng trung gian giữa logic nghiệp vụ và dịch vụ mạng, giúp tách biệt việc quản lý dữ liệu thô khỏi logic ứng dụng.
/// Thông qua việc sử dụng ApiClient, lớp này gửi thông tin đăng nhập và nhận về các kết quả phản hồi đã được chuẩn hóa dưới dạng model.
/// Việc tập trung logic gọi API tại đây giúp dễ dàng bảo trì, kiểm thử và thay đổi nguồn dữ liệu mà không ảnh hưởng đến các phần khác của hệ thống.
class LoginRepository {
  LoginRepository._();
  static final LoginRepository instance = LoginRepository._();

  /// Phương thức login gửi yêu cầu xác thực tới máy chủ bằng cách sử dụng thông tin từ LoginRequestModel đã được cung cấp.
  /// Nó thực hiện một yêu cầu POST tới endpoint xác thực và chờ đợi kết quả trả về từ hệ thống API của dự án.
  /// Sau khi nhận được dữ liệu thô, phương thức này sẽ tiến hành chuyển đổi chúng sang định dạng LoginResponseModel để sẵn sàng cho Cubit xử lý.
  /// Đây là bước quan trọng để đảm bảo tính sẵn sàng của thông tin xác thực trước khi cho phép người dùng truy cập vào các tính năng bảo mật.
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await ApiClient.instance.post(
      '/auth/login',
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(response);
  }

  /// Phương thức loginWithSocial hỗ trợ việc xác thực thông qua các nhà cung cấp dịch vụ bên thứ ba như Apple, Google hoặc Facebook.
  /// Nó tiếp nhận mã thông báo truy cập (access token) thu được từ các bộ công cụ phát triển phần mềm (SDK) tương ứng và gửi tới backend.
  /// Quá trình này giúp đồng bộ hóa thông tin người dùng từ mạng xã hội với hệ thống tài khoản nội bộ của ứng dụng một cách an toàn.
  /// Việc sử dụng một hàm chung giúp tối ưu hóa cấu trúc mã nguồn và dễ dàng mở rộng thêm các nhà cung cấp dịch vụ khác trong tương lai.
  Future<LoginResponseModel> loginWithSocial({
    required String provider,
    required String token,
    String? email,
    String? name,
  }) async {
    final response = await ApiClient.instance.post(
      '/auth/social-login',
      data: {
        'provider': provider,
        'token': token,
        'email': email,
        'name': name,
      },
    );
    return LoginResponseModel.fromJson(response);
  }
}
