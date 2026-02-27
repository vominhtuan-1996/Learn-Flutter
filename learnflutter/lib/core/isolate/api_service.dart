import 'dart:convert';
import 'package:http/http.dart' as http;

/// Lớp ApiService đóng vai trò là một dịch vụ trung gian để thực hiện các yêu cầu mạng cơ bản.
/// Nó tập trung quản lý URL và logic gọi các tài nguyên từ máy chủ thông qua giao thức HTTP.
/// Việc đóng gói mã nguồn này giúp ứng dụng dễ dàng bảo trì và tái sử dụng logic kết nối ở nhiều nơi khác nhau.
class ApiService {
  final String apiUrl;

  ApiService(this.apiUrl);

  /// Phương thức fetchDataFromApi thực hiện việc gửi yêu cầu GET tới máy chủ để lấy dữ liệu về ứng dụng.
  /// Nó kiểm tra mã trạng thái phản hồi để đảm bảo dữ liệu được nhận thành công trước khi trả về chuỗi JSON thô.
  /// Trong trường hợp có lỗi xảy ra từ phía máy chủ, phương thức sẽ ném ra một ngoại lệ để thông báo cho các lớp xử lý cấp cao hơn.
  Future<String> fetchDataFromApi() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return response.body; // Trả về JSON dưới dạng chuỗi
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }
}
