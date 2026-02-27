import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/shared/widgets/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/shared/widgets/bottom_sheet/cubit/bottom_sheet_cubit.dart';
import 'package:learnflutter/features/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';
import 'package:path_provider/path_provider.dart';

/// Phương thức getThemeBloc cung cấp cách tiếp cận nhanh chóng để lấy đối tượng SettingThemeCubit từ BuildContext hiện tại.
/// Việc sử dụng hàm này giúp mã nguồn ở tầng giao diện trở nên gọn gàng hơn khi không cần phải lặp lại cú pháp BlocProvider.of.
/// Nó đảm bảo rằng các thành phần widget có thể dễ dàng truy cập và phản hồi với các thay đổi về chủ đề giao diện một cách trực tiếp.
SettingThemeCubit getThemeBloc(BuildContext context) {
  return BlocProvider.of<SettingThemeCubit>(context);
}

/// Hàm getLoadingCubit giúp truy xuất BaseLoadingCubit để điều khiển trạng thái hiển thị của màn hình chờ (loading screen).
/// Đây là giải pháp tập trung để quản lý logic hiển thị loading mà không cần truyền trạng thái qua nhiều lớp widget trung gian.
/// Nó hỗ trợ việc đồng bộ hóa việc hiển thị chỉ báo tải dữ liệu trên toàn bộ phạm vi ứng dụng thông qua provider.
BaseLoadingCubit getLoadingCubit(BuildContext context) {
  return BlocProvider.of<BaseLoadingCubit>(context);
}

/// Phương thức getBottomSheetCubit trả về BottomSheetCubit nhằm quản lý trạng thái của các bảng thông báo từ dưới lên (bottom sheet).
/// Nó cho phép các widget con có thể yêu cầu cập nhật kích thước hoặc nội dung của bottom sheet một cách linh hoạt và độc lập.
/// Cách tiếp cận này giúp tách biệt hoàn toàn logic điều khiển giao diện bottom sheet khỏi logic nghiệp vụ của từng màn hình.
BottomSheetCubit getBottomSheetCubit(BuildContext context) {
  return BlocProvider.of<BottomSheetCubit>(context);
}

/// Hàm showLoading thực hiện việc hiển thị một màn hình chờ với thông điệp tùy chỉnh để thông báo cho người dùng về tiến trình đang xử lý.
/// Nó tự động lấy context từ UtilsHelper nếu không được truyền trực tiếp, giúp việc gọi hàm từ tầng logic (Cubit) trở nên đơn giản hơn.
/// Việc hiển thị loading là một phản hồi quan trọng để duy trì trải nghiệm người dùng mượt mà khi ứng dụng thực hiện các tác vụ nặng.
void showLoading({BuildContext? context, String? message}) {
  getLoadingCubit(context ?? UtilsHelper.navigatorKey.currentContext!)
      .showLoading(
    message: message,
    func: () {
      debugPrint('Loading showing...');
    },
  );
}

/// Phương thức dismissLoading chịu trách nhiệm ẩn màn hình chờ ngay sau khi các tác vụ bất đồng bộ hoặc tiến trình xử lý hoàn tất.
/// Nó đảm bảo rằng giao diện người dùng được giải phóng để họ có thể tiếp tục tương tác với các chức năng khác của ứng dụng.
/// Hàm này luôn yêu cầu một context hợp lệ để xác định chính xác Cubit đang quản lý trạng thái loading hiện tại.
void dismissLoading(BuildContext? context) {
  getLoadingCubit(context!).dissmissLoading();
}

/// Hàm updateHeightBottomSheet gửi yêu cầu cập nhật chiều cao mới cho bottom sheet đang được hiển thị trên màn hình.
/// Cơ chế này rất hữu ích khi nội dung bên trong bottom sheet thay đổi động và yêu cầu không gian hiển thị khác nhau.
/// Nó gọi trực tiếp phương thức updateHeight của BottomSheetCubit thông qua context để thực hiện việc thay đổi trạng thái an toàn.
void updateHeightBottomSheet(BuildContext? context, double? newHeight) {
  getBottomSheetCubit(context!).updateHeight(newHeight: newHeight);
}

/// Phương thức downLoadFolder thực hiện việc khởi tạo và lấy đường dẫn đến thư mục tải xuống nội bộ của ứng dụng trên thiết bị.
/// nó sử dụng thư viện path_provider để đảm bảo đường dẫn luôn chính xác trên cả hai nền tảng Android và iOS.
/// Thư mục 'DownLoadFile' sẽ được tự động tạo mới nếu chưa tồn tại để sẵn sàng lưu trữ các tài liệu hoặc hình ảnh được tải về.
Future<String> downLoadFolder() async {
  Directory appDocumentsDirectory =
      await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/DownLoadFile'; // 3
  Directory(filePath).create(recursive: true).then(
    (value) {
      debugPrint("Created download folder at: ${value.path}");
    },
  );
  return filePath;
}

/// Hàm math nhận vào một biểu thức toán học dưới dạng chuỗi và thực hiện việc tính toán giá trị kết quả cuối cùng.
/// Trước khi tính toán, nó luôn kiểm tra tính hợp lệ của biểu thức để đảm bảo không xảy ra các lỗi cú pháp nghiêm trọng.
/// Nếu biểu thức chứa các ký tự không hợp lệ hoặc cấu trúc sai, một ngoại lệ FormatException sẽ được ném ra để thông báo lỗi.
dynamic math(expression) {
  if (!isValidMathExpression(expression)) {
    throw const FormatException("Phép tính không hợp lệ");
  }
  return _evaluateExpression(expression);
}

/// Phương thức isValidMathExpression thực hiện việc kiểm soát chất lượng của một biểu thức toán học trước khi được đưa vào bộ xử lý.
/// Nó sử dụng Regex để lọc bỏ các ký tự lạ, kiểm tra sự cân bằng của các dấu ngoặc đơn và ngăn chặn các phép chia cho số không.
/// Việc kiểm tra kỹ lưỡng này giúp ứng dụng tránh được việc bị treo hoặc crash do xử lý các dữ liệu toán học không an toàn từ người dùng.
bool isValidMathExpression(dynamic expression) {
  // Convert the expression to a string if it is not already
  String expr = expression.toString();

  // Regular expression to check for valid characters and structure
  final validCharacters = RegExp(r'^[0-9+\-*/().\s]+$');
  if (!validCharacters.hasMatch(expr)) {
    return false;
  }

  // Check for balanced parentheses
  int parenthesesCount = 0;
  for (int i = 0; i < expr.length; i++) {
    if (expr[i] == '(') {
      parenthesesCount++;
    } else if (expr[i] == ')') {
      parenthesesCount--;
      if (parenthesesCount < 0) {
        return false;
      }
    }
  }
  if (parenthesesCount != 0) {
    return false;
  }

  // Check for division by zero
  try {
    double result = _evaluateExpression(expr);
    if (result.isInfinite || result.isNaN) {
      return false;
    }
  } catch (e) {
    return false;
  }

  return true;
}

/// Hàm _evaluateExpression chứa thuật toán nội bộ để phân tích và tính toán giá trị của các biểu thức toán học phức tạp.
/// Nó ưu tiên xử lý các dấu ngoặc đơn trước, sau đó đến nhân chia và cuối cùng thực hiện các phép cộng trừ theo đúng quy tắc toán học.
/// Thuật toán sử dụng đệ quy để giải quyết các biểu thức lồng nhau, đảm bảo tính chính xác tuyệt đối cho các phép tính đa cấp.
double _evaluateExpression(String expression) {
  // Remove spaces
  expression = expression.replaceAll(' ', '');

  // Handle parentheses
  while (expression.contains('(')) {
    int start = expression.lastIndexOf('(');
    int end = expression.indexOf(')', start);
    if (end == -1) {
      throw const FormatException("Unmatched parentheses");
    }
    String subExpression = expression.substring(start + 1, end);
    double subResult = _evaluateExpression(subExpression);
    expression = expression.replaceRange(start, end + 1, subResult.toString());
  }

  // Evaluate multiplication and division
  final mulDivPattern = RegExp(r'(\d+(\.\d+)?)([*/])(\d+(\.\d+)?)');
  while (mulDivPattern.hasMatch(expression)) {
    expression = expression.replaceAllMapped(mulDivPattern, (match) {
      double left = double.parse(match.group(1)!);
      String operator = match.group(3)!;
      double right = double.parse(match.group(4)!);
      double result;
      if (operator == '*') {
        result = left * right;
      } else {
        if (right == 0) {
          throw const FormatException("Division by zero");
        }
        result = left / right;
      }
      return result.toString();
    });
  }

  // Evaluate addition and subtraction
  final addSubPattern = RegExp(r'(\d+(\.\d+)?)([+\-])(\d+(\.\d+)?)');
  while (addSubPattern.hasMatch(expression)) {
    expression = expression.replaceAllMapped(addSubPattern, (match) {
      double left = double.parse(match.group(1)!);
      String operator = match.group(3)!;
      double right = double.parse(match.group(4)!);
      double result;
      if (operator == '+') {
        result = left + right;
      } else {
        result = left - right;
      }
      return result.toString();
    });
  }

  return double.parse(expression);
}
