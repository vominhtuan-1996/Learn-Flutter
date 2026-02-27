import 'package:equatable/equatable.dart';

/// Lớp LoginRequestModel được sử dụng để đóng gói thông tin đăng nhập của người dùng khi gửi yêu cầu lên hệ thống máy chủ.
/// Nó bao gồm hai trường dữ liệu chính là tên đăng nhập và mật khẩu, cả hai đều được đánh dấu là bắt buộc để đảm bảo tính đầy đủ của dữ liệu.
/// Thông qua việc triển khai giao thức Equatable, lớp này cho phép so sánh các đối tượng dựa trên giá trị thuộc tính thực tế thay vì tham chiếu bộ nhớ.
/// Phương thức toJson được cung cấp để dễ dàng chuyển đổi đối tượng sang định dạng bản đồ giúp ích cho việc truyền tải qua giao thức HTTP.
class LoginRequestModel extends Equatable {
  final String username;
  final String password;

  LoginRequestModel({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
