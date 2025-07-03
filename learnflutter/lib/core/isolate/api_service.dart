import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service để gọi API
class ApiService {
  final String apiUrl;

  ApiService(this.apiUrl);

  /// Gọi API để lấy dữ liệu
  Future<String> fetchDataFromApi() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      return response.body; // Trả về JSON dưới dạng chuỗi
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }
}
