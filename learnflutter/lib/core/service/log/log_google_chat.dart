import 'dart:convert';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:learnflutter/core/constants/define_constraint.dart';
import 'package:learnflutter/core/utils/datetime_utils.dart';

/// Lớp GoogleChatUtils cung cấp các công cụ tiện ích để định dạng nội dung tin nhắn trước khi gửi tới Google Chat.
/// Nó hỗ trợ việc tạo ra các đoạn văn bản có cấu trúc, xử lý các ký tự đặc biệt để tránh lỗi hiển thị HTML và chuyển đổi lệnh Curl sang định dạng Markdown.
/// Việc chuẩn hóa định dạng tin nhắn giúp các báo cáo lỗi trở nên dễ đọc và chuyên nghiệp hơn đối với đội ngũ phát triển.
/// Các phương thức này đảm bảo rằng thông tin kỹ thuật phức tạp được trình bày một cách rõ ràng và trực quan nhất có thể.
class GoogleChatUtils {
  /// Phương thức generateTextParagraph xây dựng một đoạn văn bản HTML từ một bản đồ thông tin và tiêu đề cho trước.
  /// Nó lặp qua từng cặp khóa-giá trị để tạo ra danh sách các thuộc tính được in đậm một cách có hệ thống.
  /// Kết quả trả về là một chuỗi ký tự đã được định dạng sẵn sàng để nhúng vào các thẻ văn bản của Google Chat.
  static String generateTextParagraph(
      {required Map<String, dynamic> info, required String header}) {
    final buffer = StringBuffer();
    buffer.writeln("<b>$header</b>");
    info.forEach((key, value) {
      buffer.writeln("$key : <b>${_escapeHtml(value.toString())}</b>");
    });

    return buffer.toString();
  }

  /// Hàm _escapeHtml thực hiện việc thay thế các ký tự HTML cơ bản để đảm bảo nội dung tin nhắn không bị hiểu nhầm là mã điều khiển.
  /// Đây là một bước bảo mật và định dạng quan trọng khi xử lý dữ liệu từ các nguồn bên ngoài hoặc các thông báo lỗi kỹ thuật.
  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Chuyển đổi một chuỗi Curl thô sang định dạng Markdown tương thích với trình hiển thị mã nguồn của Google Chat.
  static String convertCurlToGoogleChatMarkdown(String rawCurl) {
    return "<b><code>$rawCurl</code></b><br>";
  }

  /// Phương thức buildPayLoad chịu trách nhiệm cấu trúc toàn bộ nội dung tin nhắn theo định dạng Card V2 của Google Chat.
  /// Nó tổ chức thông tin thành các phần (section) riêng biệt như thông tin lỗi, thông tin người dùng và chi tiết lệnh Curl.
  /// Việc sử dụng các tham số mặc định cho phép linh hoạt tùy chỉnh tiêu đề và nội dung báo cáo phù hợp với từng ngữ cảnh cụ thể.
  /// Cấu trúc này giúp tự động hóa việc tạo ra các thông báo giám sát hệ thống một cách nhất quán và đầy đủ thông tin.
  static Map<String, dynamic> buildPayLoad({
    required String curl,
    String title = "Error Report",
    Map<String, dynamic> section1 = const {},
    String titleHeaderSection1 = "Thông tin Error",
    String titleHeaderSection2 = "Thông tin người dùng",
    Map<String, dynamic> section2 = const {},
    String titleHeaderSection3 = "Thông tin Curl",
  }) {
    Map<String, dynamic> payload = {
      "cardsV2": [
        {
          "cardId": "curlCard",
          "card": {
            "header": {
              "title": title,
              "subtitle":
                  "Time: ${DateTimeUtils.getCurrentTime(format: DateTimeType.DATE_TIME_FORMAT_VN)}",
              "imageUrl":
                  "https://developers.google.com/chat/images/quickstart-app-avatar.png"
            },
            "sections": [
              {
                "widgets": [
                  {
                    "textParagraph": {
                      "text": generateTextParagraph(
                          info: section1, header: titleHeaderSection1)
                    }
                  }
                ]
              },
              {
                "widgets": [
                  {
                    "textParagraph": {
                      "text": generateTextParagraph(
                          info: section2, header: titleHeaderSection2)
                    }
                  }
                ]
              },
              {
                "collapsible": true,
                "uncollapsibleWidgetsCount": 1,
                "widgets": [
                  {
                    "textParagraph": {
                      "text":
                          "<b>$titleHeaderSection3</b><br>------------------------------<br> ${convertCurlToGoogleChatMarkdown(curl)}<br>------------------------------",
                      "maxLines": 1
                    }
                  }
                ]
              }
            ]
          }
        }
      ]
    };
    return payload;
  }
}

/// Lớp ConstantKeyGoogleChat lưu trữ các thông tin bảo mật và cấu hình kết nối tới phòng chat Google Chat.
/// Nó phân tách rõ ràng giữa môi trường phát triển (Staging) và môi trường thực tế (Production) để tránh nhầm lẫn dữ liệu.
/// Các phương thức lấy khóa, token và ID phòng chat được thiết kế theo dạng bất đồng bộ để có thể mở rộng lấy từ server nếu cần.
/// Việc tập trung các khóa bảo mật vào một nơi giúp nâng cao khả năng quản lý và bảo trì hệ thống thông báo.
class ConstantKeyGoogleChat {
  // evn Production
  static const keyPro = "AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI";
  static const tokenPro = "wJoSK0-Wf6gL3lKINQlD0QNvZPPYW3aYtVrVAulBVrQ";
  static const idRoomChatPro = "AAQAVUl-jME"; // ID của phòng chat Google Chat

  // evn Stag
  static const keyStag = "AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI";
  static const tokenStag = "4nXdkH6MQPLCvZS_11RZURK7EIZ-gOYBGOm71YXOusg";
  static const idRoomChatStag = "AAQA7k-fSVA"; // ID của phòng chat Google Chat

  static Future<String> getKey() async => keyStag;

  static Future<String> getToken() async => tokenStag;

  static Future<String> getRoomChatId() async => idRoomChatStag;
}

/// Lớp LogGoogleChat là thành phần chính thực hiện việc gửi các gói tin báo cáo lên API của Google Chat.
/// Nó sử dụng cơ chế Isolate để thực hiện yêu cầu mạng ở luồng riêng biệt, không làm gián đoạn trải nghiệm người dùng hiện tại.
/// Toàn bộ quá trình chuẩn bị URL và thiết lập header được thực hiện tự động trước khi gói tin được đẩy đi qua thư viện Dio.
/// Đây là một công cụ mạnh mẽ để giám sát lỗi ứng dụng trong thời gian thực một cách hiệu quả và kín đáo.
class LogGoogleChat {
  LogGoogleChat._();

  /// Google Chat card tối đa ~4096 ký tự trong một textParagraph.
  static const int _maxLogCharsPerMessage = 3500;

  /// [sendPayloadToApi] đẩy dữ liệu lên Google Chat thông qua phương thức POST HTTP.
  /// Chạy trong Isolate riêng để không block UI thread.
  static Future<void> sendPayloadToApi(Map<String, dynamic> payload) async {
    final roomId = await ConstantKeyGoogleChat.getRoomChatId();
    final key = await ConstantKeyGoogleChat.getKey();
    final tokenGoogleChat = await ConstantKeyGoogleChat.getToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Isolate.spawn((message) async {
      await Dio().post(
        "https://chat.googleapis.com/v1/spaces/$roomId/messages?key=$key&token=$tokenGoogleChat",
        options:
            Options(headers: headers, sendTimeout: const Duration(seconds: 30)),
        data: jsonEncode(payload),
      );
    }, payload);
  }

  /// [sendLogFile] đọc nội dung file log và gửi lên Google Chat.
  ///
  /// Nội dung được chia thành nhiều tin nhắn nếu quá [_maxLogCharsPerMessage] ký tự.
  /// Trả về `true` nếu gửi thành công ít nhất 1 tin nhắn.
  static Future<bool> sendLogFile(
    dynamic file, {
    // dart:io File
    String title = '📋 Daily Log Report',
  }) async {
    try {
      String content;
      if (file == null) return false;
      content = await file.readAsString() as String;
      if (content.trim().isEmpty) return false;

      await _sendLogChunks(content, title: title);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// [sendLogText] gửi nội dung log dưới dạng text thẳng (không cần file).
  static Future<bool> sendLogText(
    String content, {
    String title = '📋 Log Report',
  }) async {
    try {
      if (content.trim().isEmpty) return false;
      await _sendLogChunks(content, title: title);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  static Future<void> _sendLogChunks(String content,
      {required String title}) async {
    final chunks = _chunkString(content, _maxLogCharsPerMessage);
    final totalChunks = chunks.length;

    for (int i = 0; i < chunks.length; i++) {
      final chunkTitle =
          totalChunks > 1 ? '$title (${i + 1}/$totalChunks)' : title;
      final payload = _buildLogPayload(chunkTitle, chunks[i]);
      await sendPayloadToApi(payload);
      // Nhỏ delay giữa các message tránh rate limit
      if (i < chunks.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  static Map<String, dynamic> _buildLogPayload(
      String title, String logContent) {
    return {
      'cardsV2': [
        {
          'cardId': 'logCard_${DateTime.now().millisecondsSinceEpoch}',
          'card': {
            'header': {
              'title': title,
              'subtitle': DateTimeUtils.getCurrentTime(
                  format: DateTimeType.DATE_TIME_FORMAT_VN),
              'imageUrl':
                  'https://developers.google.com/chat/images/quickstart-app-avatar.png',
            },
            'sections': [
              {
                'widgets': [
                  {
                    'textParagraph': {
                      'text':
                          '<code>${GoogleChatUtils._escapeHtml(logContent)}</code>',
                    }
                  }
                ]
              }
            ]
          }
        }
      ]
    };
  }

  static List<String> _chunkString(String s, int chunkSize) {
    final chunks = <String>[];
    for (int i = 0; i < s.length; i += chunkSize) {
      chunks.add(
          s.substring(i, i + chunkSize > s.length ? s.length : i + chunkSize));
    }
    return chunks;
  }
}
