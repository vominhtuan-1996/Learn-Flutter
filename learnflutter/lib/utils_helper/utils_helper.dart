// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnflutter/core/network/MBMHttpHelper.dart';
import 'package:learnflutter/core/utils/extension/extension_string.dart';


/// UtilsHelper cung cấp tập hợp các phương thức tiện ích dùng chung cho toàn bộ ứng dụng.
/// Nó bao gồm các chức năng về điều hướng (navigation), ghi nhật ký (logging), đo lường văn bản và xử lý tệp.
/// Lớp này được thiết kế theo dạng static để người dùng có thể truy cập các tiện ích nhanh chóng mà không cần khởi tạo.
class UtilsHelper {
  UtilsHelper._();

  /// Khóa toàn cục được sử dụng để quản lý trạng thái của Navigator mà không cần context trực tiếp.
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Đóng màn hình hiện tại và trả về kết quả tùy chọn.
  static void pop(BuildContext context, [dynamic result]) {
    final navigator = Navigator.of(context);
    navigator.pop(result);
  }

  /// Thực hiện pop các màn hình cho đến khi gặp một điều kiện logic cụ thể được thỏa mãn.
  /// Tiện ích này thường dùng để quay lại màn hình chính hoặc một điểm dừng cụ thể trong luồng điều hướng.
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    final navigator = Navigator.of(context);
    navigator.popUntil(predicate);
  }

  /// Quay lại một màn hình cụ thể theo tên (routeName) bằng cách xóa các route nằm trên nó.
  static void popUntilRouteTo(BuildContext context, String routeName) {
    popUntil(context, (route) => route.settings.name == routeName);
  }

  /// Đóng màn hình hiện tại và ngay lập tức điều hướng sang một màn hình mới theo tên.
  static void popAndPushName(BuildContext context, String routeName,
      [dynamic result]) {
    Navigator.popAndPushNamed(context, routeName, result: result);
  }

  /// Chuyển hướng sang một màn hình mới theo tên và tùy chọn truyền theo dữ liệu (arguments).
  static Future<dynamic> navigationPushNamed(BuildContext context, String route,
      {dynamic data}) async {
    var navigator = Navigator.of(context);
    return await navigator.pushNamed(route, arguments: data);
  }

  /// Ghi log định dạng kèm theo vết ngăn xếp để hỗ trợ quá trình gỡ lỗi chuyên sâu.
  static void fMapLog(String fmt,
      [Object? arg1, Object? arg2, Object? arg3, Object? arg4]) {
    debugPrint('${StackTrace.current} --> $fmt');
  }

  /// Phân tích và in ra thông tin chi tiết về vị trí dòng mã đang được thực thi trong tệp nguồn.
  /// Phương thức này trích xuất thông tin từ StackTrace để hiển thị gói và dòng mã cụ thể một cách trực quan.
  static void logDebug(dynamic label) {
    debugPrint(label.toString());
    Iterable<String> lines =
        StackTrace.current.toString().trimRight().split('\n');
    for (var element in lines) {
      if (element.substring(1, 3).toInt == 1) {
        String temp = element;
        final tempss = temp.split("dart");
        final pack = tempss.first;
        final packs = pack.split('(');
        final line = tempss.last.split(':');
        debugPrint("package : ${packs.last}dart\t\t\t\tline : ${line[1]}");
        break;
      }
    }
  }

  /// Điều hướng sang một controller mới thông qua rootNavigator nếu cần thiết.
  static Future<T?> pushToController<T>(
      {required BuildContext context,
      bool useRootNavigator = true,
      required String route}) {
    return Navigator.of(context, rootNavigator: useRootNavigator)
        .pushNamed(route);
  }

  /// Quay trở lại màn hình gốc đầu tiên trong cấu trúc điều hướng của ứng dụng.
  static void popToRootControler({
    required BuildContext context,
  }) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Tính toán chiều cao hiển thị tối thiểu của một đoạn văn bản dựa trên kiểu chữ và chiều rộng tối đa cho phép.
  /// Phương thức này rất hữu ích để điều chỉnh kích thước động cho các widget chứa văn bản biến đổi.
  static double getTextHeight(
      {required String text,
      required TextStyle textStyle,
      required double maxWidthOfWidget,
      double minWidthOfWidget = 0}) {
    final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: textStyle))
      ..layout(maxWidth: maxWidthOfWidget, minWidth: minWidthOfWidget);
    return textPainter.height;
  }

  /// Lấy chiều rộng thực tế của một đoạn văn bản khi được hiển thị với một kiểu chữ cụ thể.
  static double getTextWidth(
      {required String text, required TextStyle textStyle}) {
    final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(text: text, style: textStyle))
      ..layout();
    return textPainter.size.width;
  }

  /// Tải tệp xuống từ một URL và báo cáo tiến trình thông qua StreamController.
  /// Phương thức này hỗ trợ theo dõi tỷ lệ phần trăm tải về để cập nhật giao diện người dùng theo thời gian thực.
  static Future<String> downloadFile(
      String savePath, StreamController<double> stream) async {
    String path = '$savePath/${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      final resut = await dio.download(
        'https://sampletestfile.com/wp-content/uploads/2023/08/11.5-MB.png',
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            stream.sink.add((received / total));
          }
        },
      );
      if (resut.statusCode == 0) {
        stream.close();
        return path;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return path;
  }

  static dynamic getJsonValue(dynamic json, List<String> keys,
      {bool isCheckAllCase = true, dynamic defaultValue}) {
    if (json is! Map) return defaultValue;
    int index = 1;
    for (String key in keys) {
      // convert key theo các trường hợp key
      if (isCheckAllCase) {
        //   }
        if (json[key] != null) {
          return json[key] ?? defaultValue;
        } else if (json[key.camelCaseChange] != null) {
          return json[key.camelCaseChange] ?? defaultValue;
        } else if (json[key.snakeCase] != null) {
          return json[key.snakeCase] ?? defaultValue;
        } else if (json[key.pascalCase] != null) {
          return json[key.pascalCase] ?? defaultValue;
        } else if (json[key.paramCaseChange] != null) {
          return json[key.paramCaseChange] ?? defaultValue;
        } else if (json[key.headerUnderlinedCase] != null) {
          return json[key.headerUnderlinedCase] ?? defaultValue;
        } else if (json[key.headerCase] != null) {
          return json[key.headerCase] ?? defaultValue;
        }
        if (keys.length == index) {
          return defaultValue;
        } else {
          index++;
          continue;
        }
      } else {
        return json[key] ?? defaultValue;
      }
    }
    return defaultValue;
  }

  /// lấy json string theo key và hỗ trợ multi key
  /// @json: object json nguồn
  /// @keys: danh sách keys các json có thể chứa trong json object vd ['userName', 'userNames']
  /// @isCheckAllCase = true: tự động chuyển đổi và check key theo các trường hợp camelCase, snake_case, PascalCase và param-case
  /// @return string value by json key
  ///
  static String getJsonValueString(dynamic json, List<String> keys,
      {bool isCheckAllCase = true, String defaultValue = ''}) {
    return (getJsonValue(json, keys,
            isCheckAllCase: isCheckAllCase, defaultValue: defaultValue))
        .toString();
  }

  static List<T?> getJsonValueList<T>(
    dynamic json,
    List<String> keys, {
    bool isCheckAllCase = true,
    required T Function(dynamic item) fromJson,
    List<T>? defaultList,
  }) {
    final result = getJsonValue(json, keys, isCheckAllCase: isCheckAllCase);

    if (result is List) {
      return result
          .map<T?>((item) {
            try {
              return fromJson(item);
            } catch (e) {
              return null;
            }
          })
          .whereType<T>()
          .toList();
    }
    return defaultList ?? <T>[];
  }

  static void dismissKeyBoard({required BuildContext context}) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
