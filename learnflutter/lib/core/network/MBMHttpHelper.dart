// ignore_for_file: file_names, prefer_typing_uninitialized_variables, unused_local_variable, non_constant_identifier_names, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/utils/magic_number_test/mime_type.dart';
import 'package:learnflutter/features/menu/model/model_menu.dart';
import 'package:http/http.dart' as http;

/// Đối tượng dio được khởi tạo toàn cục để thực hiện các yêu cầu mạng trong toàn bộ ứng dụng.
/// Việc sử dụng một instance duy nhất giúp quản lý cấu hình kết nối, interceptor và bộ nhớ đệm hiệu quả hơn.
/// Instance này được cấu hình sẵn các thiết lập về thời gian chờ và log để hỗ trợ quá trình phát triển.
final dio = Dio();

/// Hàm configureDio thực hiện việc thiết lập các thông số cơ bản cho đối tượng Dio trước khi ứng dụng bắt đầu giao tiếp với server.
/// Nó định nghĩa URL gốc, thời gian chờ kết nối và thời gian chờ nhận phản hồi để ứng dụng hoạt động ổn định trong các điều kiện mạng khác nhau.
/// Đồng thời, interceptor CurlLoggerDioInterceptor cũng được thêm vào để ghi lại các lệnh curl trong quá trình debug luồng dữ liệu.
void configureDio() {
  // Set default configs
  dio.options.baseUrl =
      'https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/file%20(4).json';
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);
  dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));

  // Or create `Dio` with a `BaseOptions` instance if needed for specific cases.
  final options = BaseOptions(
    baseUrl:
        'https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/file%20(4).json',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  );
  final anotherDio = Dio(options);
}

/// Phương thức handleDataResponseResult chịu trách nhiệm phân tích cú pháp (parsing) lớp dữ liệu bao gói bên ngoài của phản hồi API.
/// Nó trích xuất phần 'responseResult' từ dữ liệu JSON thô và chuyển đổi nó thành đối tượng Result để các lớp nghiệp vụ dễ xử lý.
/// Việc chuẩn hóa cách đọc phản hồi giúp giảm thiểu các lỗi liên quan đến cấu trúc dữ liệu không đồng nhất từ phía server.
Future<Result> handleDataResponseResult(Map<String, dynamic> json) async {
  Map<String, dynamic> result = json['responseResult'];
  var res = Result.fromJson(result);
  return res;
}

/// Lớp ResponseResult định nghĩa cấu trúc cơ bản của một phản hồi từ máy chủ bao gồm dữ liệu kết quả chính.
/// Nó đóng vai trò như một mô hình dữ liệu trung gian để ánh xạ các thông tin từ định dạng JSON sang các đối tượng Dart an toàn.
class ResponseResult {
  var responseResult;
  ResponseResult({
    required responseResult,
  });

  factory ResponseResult.fromJson(Map<String, dynamic> json) {
    return ResponseResult(responseResult: json['responseResult']);
  }
}

/// Lớp Result chứa các thông tin chi tiết về trạng thái của một yêu cầu API bao gồm mã lỗi, thông báo và dữ liệu thực tế.
/// Nó giúp lập trình viên xác định nhanh chóng liệu yêu cầu có thành công hay không dựa trên trường errorCode.
/// Dữ liệu trả về được lưu trữ trong một bản đồ (Map) linh hoạt để có thể ánh xạ sang bất kỳ mô hình dữ liệu cụ thể nào.
class Result {
  var errorCode;
  var message;
  Map<String, dynamic> result;
  Result(
      {required this.errorCode, required this.message, required this.result});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
        errorCode: json['errorCode'],
        message: json['message'],
        result: json['result']);
  }
}

/// Hàm getHttp thực hiện việc lấy danh sách thực đơn từ kho lưu trữ GitHub thông qua giao thức GET HTTP.
/// Sau khi nhận được dữ liệu, nó thực hiện giải mã và ánh xạ thông tin vào mô hình ModelMenu nếu mã lỗi bằng không.
/// Đây là một ví dụ điển hình về việc kết nối và lấy dữ liệu tĩnh để hiển thị giao diện động cho người dùng.
Future<ModelMenu> getHttp() async {
  var menuModel;
  final response = await dio.get(
      'https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/menus_json.json');
  if (response.statusCode == 200) {
    var menus;
    await handleDataResponseResult(jsonDecode(response.data)).then((value) => {
          if (value.errorCode == 0) {menus = ModelMenu.fromJson((value.result))}
        });

    return menus;
  }
  dio.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
  return menuModel;
}

/// Phương thức getListCategories trích xuất danh sách các phân loại sản phẩm từ dữ liệu thực đơn tổng thể.
/// Nó tái sử dụng logic gọi API của getHttp nhưng chỉ trả về thuộc tính categories để giảm bớt dữ liệu không cần thiết cho lớp gọi.
/// Hàm này giúp tối ưu hóa việc lấy dữ liệu cho các thành phần giao diện chỉ quan tâm đến danh mục thay vì toàn bộ thực đơn.
Future<List> getListCategories() async {
  var menuModel;
  final response = await dio.get(
      'https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/menus_json.json');
  if (response.statusCode == 200) {
    var menus;
    await handleDataResponseResult(jsonDecode(response.data)).then((value) => {
          if (value.errorCode == 0) {menus = ModelMenu.fromJson((value.result))}
        });
    return menus.categories;
  }
  return menuModel.categories;
}

/// Hàm postdataTelegram gửi một nội dung tin nhắn văn bản đến một phòng chat Telegram cụ thể thông qua Bot API.
/// Nó đóng vai trò như một kênh thông báo khẩn cấp hoặc nhật ký lỗi để đội ngũ phát triển có thể theo dõi tức thời.
/// Phương thức sử dụng yêu cầu POST với định dạng JSON để truyền nội dung tin nhắn một cách bảo mật và chính xác.
Future<dynamic> postdataTelegram(String message) async {
  final body = {
    "chat_id": "-720215949",
    "text": message,
  };
  final response = await dio.post(
      'https://api.telegram.org/bot5296962866:AAEhBcpidAR1Fs2autI86D2Eff7fmwPI3ZI/sendMessage',
      data: body);
  return response;
}

/// Phương thức downLoadFileWithLink thực hiện việc tải một tài liệu từ web và lưu trữ trực tiếp vào bộ nhớ thiết bị tại đường dẫn chỉ định.
/// Nó sử dụng tính năng stream của Dio để xử lý việc tải về hiệu quả, giúp tiết kiệm bộ nhớ khi tải các tệp tin có kích thước lớn.
/// Các thông tin về tên tệp và nội dung phản hồi sẽ được in ra console để phục vụ mục đích giám sát quá trình tải.
Future<void> downLoadFileWithLink(String link, String savePath) async {
  final response = await dio.download(link, savePath);
  debugPrint("Filename: ${response.headers['filename']}");
  debugPrint("Download data: ${response.data}");
}

/// Hàm downloadFile sử dụng thư viện http cơ bản để tải dữ liệu thô và tự động xác định định dạng tệp thông qua Magic Number.
/// Nó giúp tạo ra tên tệp dựa trên thời gian hiện tại và phần mở rộng MIME đã được nhận diện để tránh xung đột dữ liệu.
/// Đây là giải pháp tải tệp tin linh hoạt khi ứng dụng cần xử lý các nguồn dữ liệu đa phương tiện từ nhiều máy chủ khác nhau.
Future downloadFile(
  String url,
  String saveFolder,
) async {
  File file;
  String filePath = '';
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final mimeType =
          lookupMimeType(saveFolder, headerBytes: response.bodyBytes);
      mimeType?.split('/');
      filePath = '$saveFolder/${DateTime.now()}.${mimeType?.split('/').last}';
      file = File(filePath);
      const asciiDecoder = AsciiDecoder(allowInvalid: true);
      final asciiValues = response.bodyBytes;
      final result = asciiDecoder.convert(asciiValues);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      filePath = 'Error code: ${response.statusCode}';
    }
  } catch (ex) {
    filePath = 'Can not fetch url';
  }
  return filePath;
}

/// Hàm getBase64FileExtension xác định phần mở rộng của tệp tin dựa trên ký tự bắt đầu của chuỗi mã hóa Base64.
/// Mỗi loại tệp như ảnh JPEG, PNG, tài liệu PDF thường có một chữ cái định danh đặc trưng ở đầu chuỗi dữ liệu nhị phân.
/// Việc nhận diện này giúp ứng dụng có thể khôi phục định dạng tệp chính xác ngay cả khi thông tin phần mở rộng bị thiếu.
String getBase64FileExtension(String base64String) {
  if (base64String.isEmpty) return 'unknown';
  switch (base64String.characters.first) {
    case '/':
      return 'jpeg';
    case 'i':
      return 'png';
    case 'R':
      return 'gif';
    case 'U':
      return 'webp';
    case 'J':
      return 'pdf';
    default:
      return 'unknown';
  }
}
