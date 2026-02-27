import 'package:equatable/equatable.dart';

/// Lớp LoginResponseModel đại diện cho cấu trúc dữ liệu trả về từ hệ thống sau khi người dùng thực hiện yêu cầu đăng nhập thành công.
/// Nó chứa một mã thông báo truy cập giúp xác thực cho các yêu cầu API tiếp theo cũng như thông tin cơ bản về hồ sơ của người dùng.
/// Việc kế thừa từ Equatable giúp hệ thống tối ưu hóa việc so sánh các phản hồi và quyết định có cần cập nhật lại giao diện người dùng hay không.
/// Phương thức factory fromJson đóng vai trò quan trọng trong việc chuyển đổi linh hoạt các dữ liệu JSON thô từ máy chủ thành một đối tượng có cấu trúc rõ ràng.
class LoginResponseModel extends Equatable {
  final String? token;
  final String? userName;
  final String? email;

  LoginResponseModel({
    this.token,
    this.userName,
    this.email,
  });

  @override
  List<Object?> get props => [token, userName, email];

  factory LoginResponseModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return LoginResponseModel();
    }
    return LoginResponseModel(
      token: json['token'],
      userName: json['userName'],
      email: json['email'],
    );
  }
}
