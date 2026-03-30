import 'package:learnflutter/core/network/api_client/api_client.dart';
import 'package:learnflutter/features/news/model/news_model.dart';

class NewsRepository {
  /// Một domain khác để lấy tin tức, ví dụ từ NewsAPI hoặc một mock server.
  static const String newsBaseUrl = 'https://apis-stag.fpt.vn';

  Future<BaseResponse<List<NewsModel>>> getTopHeadlines() async {
    // Gọi API từ domain mới thông qua tham số baseUrl
    final response = await ApiClient.instance.get(
      '/resource/internet-infra/user-management/api/m/v1/users/auth/timeRemaining',
      queryParameters: {
        'email': 'tuanvm37@fpt.com',
      },
      baseUrl: newsBaseUrl,
    );

    // Sử dụng BaseResponse để parse dữ liệu chuẩn của dự án
    return BaseResponse<List<NewsModel>>.fromJson(
      response,
      (data) {
        // Giả sử data trả về là map chứa danh sách articles hoặc chính là danh sách
        if (data is List) {
          return data.map((json) => NewsModel.fromJson(json)).toList();
        } else if (data is Map && data['articles'] != null) {
          final List articles = data['articles'];
          return articles.map((json) => NewsModel.fromJson(json)).toList();
        }
        return [];
      },
    );
  }
}
