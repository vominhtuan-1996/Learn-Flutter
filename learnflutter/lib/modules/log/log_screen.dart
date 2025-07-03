import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/core/service/log/log_google_chat.dart';
import 'package:learnflutter/modules/material/component/material_textfield/material_textfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});
  @override
  State<LogScreen> createState() => LogScreenState();
}

class LogScreenState extends State<LogScreen> {
  TextEditingController controller = TextEditingController();
  String log = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    bool fileExists = FileSystemEntity.isFileSync('$path/log.json');
    if (!fileExists) {
      return File(path).create();
    }
    // String filePath = '$path/DB'; // 3
    // await Directory(filePath).create(recursive: true).then(
    //   (value) {
    //     return File('$filePath/log.json');
    //   },
    // );
    return File('$path/log.json');
  }

  Future<File> writeCounter(String text) async {
    final file = await _localFile;
    String textBeforeLog = await file.readAsString();
    textBeforeLog = "$textBeforeLog\n$text";
    // Write the file
    return file.writeAsString(textBeforeLog);
  }

  Future<String> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return '';
    }
  }

  Future<File> clearLog() async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('');
  }

  String generateTextParagraph({required Map<String, String> info, required String header}) {
    final buffer = StringBuffer();
    buffer.writeln("<b>$header</b>");
    info.forEach((key, value) {
      buffer.writeln("$key : <b>${_escapeHtml(value)}</b>");
    });

    return buffer.toString();
  }

// Optional: escape basic HTML characters
  String _escapeHtml(String input) {
    return input.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
  }

  String convertCurlToGoogleChatMarkdown(String rawCurl) {
    return '```bash\n$rawCurl\n```';
  }

  Future<void> sendPayloadToApi(String payload) async {
    final Uri url = Uri.parse("https://chat.googleapis.com/v1/spaces/AAQAVUl-jME/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=wJoSK0-Wf6gL3lKINQlD0QNvZPPYW3aYtVrVAulBVrQ");
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    // final Map<String, dynamic> body = {
    //   'text': message,
    // };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: payload,
      );

      if (response.statusCode == 200) {
        // Message sent successfully
      } else {
        // Handle error when sending message
      }
    } catch (e) {
      // Handle exceptions
    }
  }

  // Implement your logic to send the message to the API her
  @override
  Widget build(BuildContext context) {
    final loadingCubit = getLoadingCubit(context);
    return BaseLoading(
        isLoading: true,
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                Map<String, dynamic> jsonMap = {
                  "cards": [
                    {
                      "header": {
                        "title": "Report Log - CURL",
                        "subtitle": "Nhập CURL command để báo cáo"
                        // "imageUrl": "https://www.gstatic.com/images/icons/material/system/2x/bug_report_black_48dp.png",
                        // "imageStyle": "AVATAR"
                      },
                      "sections": [
                        {
                          "widgets": [
                            {
                              "buttons": [
                                {
                                  "textButton": {
                                    "text": "Gửi log",
                                    "onClick": {
                                      "action": {
                                        "actionMethodName": "submitLog",
                                        "parameters": [
                                          {"key": "logType", "value": "curl"}
                                        ]
                                      }
                                    }
                                  }
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                };
                String jsonString = jsonEncode(jsonMap);
                // loadingCubit.showLoading();
                await sendPayloadToApi(jsonString);
                // loadingCubit.hideLoading();
              },
              child: const Text('send message'),
            ),
            MaterialTextField(
              hintText: 'write log',
              onChanged: (value) {},
              decorationBorderColor: Colors.amberAccent,
              controller: controller,
            ),
            TextButton(
              onPressed: () async {
                await writeCounter(controller.text);
              },
              child: const Text('Write text into log file json'),
            ),
            TextButton(
              onPressed: () async {
                await clearLog();
                log = await readCounter();
                setState(() {});
              },
              child: const Text('Clear Log'),
            ),
            TextButton(
              onPressed: () async {
                final curl =
                    '''cURL -X GET -H "Accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiJUdWFubnYyMS50aW4iLCJuYmYiOjE3NDgzOTUzODQsImV4cCI6MTc0ODQzODU4NCwiaWF0IjoxNzQ4Mzk1Mzg0fQ.w-yRipC4tD_bBM8h1AHnnQkr1eqMwR28OMoiO69wIvY" -H "Content-type: application/json"  "https://mapapi.fpt.vn/maintenance/api/stationPop/checkIn?checklist_id=217096&pop_name=HNIP537&lat=21.1091069&lng=105.488787&user_id=Tuannv21.tin" -L''';
                // Map<String, dynamic> payload = {
                //   "cardsV2": [
                //     {
                //       "cardId": "curlCard",
                //       "card": {
                //         "header": {"title": "Error Report", "subtitle": "Time: ${DateTime.now().toString()}", "imageUrl": "https://developers.google.com/chat/images/quickstart-app-avatar.png"},
                //         "sections": [
                //           {
                //             "widgets": [
                //               {
                //                 "textParagraph": {
                //                   "text": generateTextParagraph(info: {"ErrorCode": "400", "Message": "Connection Error: Kết nối mạng quá chậm vui lòng."}, header: "Thông tin Error")
                //                 }
                //               }
                //             ]
                //           },
                //           {
                //             "widgets": [
                //               {
                //                 "textParagraph": {
                //                   "text": generateTextParagraph(info: {
                //                     "UserName": "TuanVm37@fpt.com",
                //                     "Location": "(21.0066589,105.8301622)",
                //                     "Device Info": "samsung-SM-F956B-q6q Android 15 - SDK 35",
                //                     "App version": "4.10.0",
                //                     "Build Code": "94f25c3"
                //                   }, header: "Thông tin người dùng")
                //                 }
                //               }
                //             ]
                //           },
                //           {
                //             "header": "Thông tin Curl",
                //             "collapsible": true,
                //             "uncollapsibleWidgetsCount": 0,
                //             "widgets": [
                //               {
                //                 "textParagraph": {"text": convertCurlToGoogleChatMarkdown(curl)}
                //               }
                //             ]
                //           }
                //         ]
                //       }
                //     }
                //   ]
                // };
                final payload = GoogleChatUtils.buildPayLoad(curl: curl, title: "1", section1: {
                  "1": 1,
                  "2": 2,
                }, section2: {
                  "3": 3,
                  "4": 4,
                });
                await LogGoogleChat.sendPayloadToApi(payload);
                // await sendPayloadToApi(json);
              },
              child: const Text('build UI log '),
            ),
            Text(log)
          ],
        ));
  }
}
