import 'dart:convert';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:learnflutter/constraint/define_constraint.dart';
import 'package:learnflutter/utils_helper/datetime_utils.dart';

class GoogleChatUtils {
  static String generateTextParagraph({required Map<String, dynamic> info, required String header}) {
    final buffer = StringBuffer();
    buffer.writeln("<b>$header</b>");
    info.forEach((key, value) {
      buffer.writeln("$key : <b>${_escapeHtml(value.toString())}</b>");
    });

    return buffer.toString();
  }

// Optional: escape basic HTML characters
  static String _escapeHtml(String input) {
    return input.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
  }

  static String convertCurlToGoogleChatMarkdown(String rawCurl) {
    return "<b><code>$rawCurl</code></b><br>";
  }

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
              "subtitle": "Time: ${DateTimeUtils.getCurrentTime(format: DateTimeType.DATE_TIME_FORMAT_VN)}",
              "imageUrl": "https://developers.google.com/chat/images/quickstart-app-avatar.png"
            },
            "sections": [
              {
                "widgets": [
                  {
                    "textParagraph": {"text": generateTextParagraph(info: section1, header: titleHeaderSection1)}
                  }
                ]
              },
              {
                "widgets": [
                  {
                    "textParagraph": {"text": generateTextParagraph(info: section2, header: titleHeaderSection2)}
                  }
                ]
              },
              {
                "collapsible": true,
                "uncollapsibleWidgetsCount": 1,
                "widgets": [
                  {
                    "textParagraph": {
                      "text": "<b>$titleHeaderSection3</b><br>------------------------------<br> ${convertCurlToGoogleChatMarkdown(curl)}<br>------------------------------",
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

/// A class to send logs to Google Chat using the Google Chat API.
/// example usage:
/// ```dart
///   Map<String, dynamic> payload = LogGoogleChat.buildPayLoad(
///    curl: "curl -X GET https://api.example.com/data",
///   section1: {
/// "Error": "Null pointer exception",
/// "Stack Trace": "at line 42 in main.dart",
/// },
///  section2: {
///   "User ID": "12345",
/// "User Name": "John Doe",
/// },
///  titleHeaderSection1: "Error Details",
///  titleHeaderSection2: "User Information",
///  titleHeaderSection3: "Curl Command",
///  );
///    await LogGoogleChat.sendPayloadToApi(payload);
///  ```

class LogGoogleChat {
  LogGoogleChat._();
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
        options: Options(headers: headers, sendTimeout: const Duration(seconds: 30)),
        data: jsonEncode(payload),
      );
    }, payload);
  }
}
