import 'package:flutter/services.dart';
import 'package:learnflutter/core/utils/input_formatter/input_date_formatter.dart';
import 'package:learnflutter/core/utils/input_formatter/input_numerical_range_formatter.dart';
import 'package:learnflutter/core/utils/input_formatter/text_formatter.dart';
import 'package:learnflutter/core/constants/regex.dart';

/// Lớp tiện ích cung cấp các TextInputFormatter được cấu hình sẵn cho các trường nhập liệu phổ biến.
/// InputFormattersHelper giúp đảm bảo tính nhất quán trong việc validate và format dữ liệu đầu vào trên toàn ứng dụng.
class InputFormattersHelper {
  InputFormattersHelper._();

  /// Tạo formatter cho số nguyên hoặc số thập phân với giới hạn min/max và độ dài.
  /// Sử dụng regex để chỉ cho phép nhập số, sau đó kiểm tra phạm vi giá trị hợp lệ.
  static List<TextInputFormatter> inputFormatterNumber({
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNumber),
      NumericalRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  /// Tạo formatter cho số nguyên dương (không bao gồm 0) với giới hạn min/max.
  /// Đảm bảo người dùng chỉ có thể nhập số từ 1 trở lên, hữu ích cho số lượng, ID, v.v.
  static List<TextInputFormatter> inputFormatterIntegerNumberNotZero({
    int min = 1,
    required int max,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNumberNotZero),
      NumericalIntegerRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
    ];
  }

  /// Tạo formatter cho số thập phân âm với 2 chữ số sau dấu phẩy.
  /// Cho phép nhập số âm và kiểm tra phạm vi giá trị, phù hợp cho nhiệt độ, tọa độ, v.v.
  static List<TextInputFormatter> inputFormatterNegativeDecimal({
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNegativeDoubleXX),
      NumericalRangeFormatterNegative(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  /// Tạo formatter cho số thập phân dương với 2 chữ số sau dấu phẩy.
  /// Sử dụng cho các giá trị như tiền tệ, phần trăm, hoặc các phép đo cần độ chính xác cao.
  static List<TextInputFormatter> inputFormatterDecimal({
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexDoubleXX),
      NumericalRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  /// Tạo formatter cho số điện thoại.
  /// Tự động format số điện thoại theo định dạng chuẩn trong khi người dùng nhập.
  static List<TextInputFormatter> inputFormatterPhoneNumbber() {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexPhoneNumbber),
      PhoneNumbberFormatter(),
    ];
  }

  /// Tạo formatter thay thế ký tự trong quá trình nhập liệu.
  /// Hữu ích để tự động chuyển đổi ký tự (ví dụ: dấu chấm thành dấu phẩy).
  static List<TextInputFormatter> inputFormatteReplace({
    required String from,
    required String replace,
    required int limitLength,
  }) {
    return [
      FilteringTextInputFormatter.allow(ConstantsRegex.regexNegativeDoubleXX),
      TextReplaceFormatter(from, replace),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  /// Tạo formatter cho ngày tháng theo định dạng dd/MM/yyyy.
  /// Tự động thêm dấu "/" khi người dùng nhập đủ số ký tự cho ngày và tháng.
  static List<TextInputFormatter> inputFormatteDate() {
    return [
      DateTextFormatter(),
      LengthLimitingTextInputFormatter(10),
    ];
  }

  /// Tạo formatter cho text thông thường với giới hạn độ dài.
  /// Sử dụng cho các trường nhập text đơn giản như tên, địa chỉ, ghi chú.
  static List<TextInputFormatter> inputFormatterText({
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      TextFormatter(maxLenght: limitLength),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }

  /// Tạo formatter cho email với validation.
  /// Kiểm tra định dạng email hợp lệ trong quá trình nhập liệu.
  static List<TextInputFormatter> inputFormatterTextValidationEmail({
    int? limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      TextEmailFormatter(),
    ];
  }

  /// Tạo formatter tùy chỉnh với regex, phạm vi giá trị và độ dài riêng.
  /// Cho phép tạo formatter linh hoạt cho các trường hợp đặc biệt không được cover bởi các method khác.
  static List<TextInputFormatter> inputFormatterCustom({
    required Pattern regex,
    required double min,
    required double max,
    required int limitLength,
    bool? isShowSnackbar,
    String? message,
  }) {
    return [
      FilteringTextInputFormatter.allow(regex),
      NumericalRangeFormatter(
        min: min,
        max: max,
        isShowSnackbar: isShowSnackbar ?? false,
        message: message,
      ),
      LengthLimitingTextInputFormatter(limitLength),
    ];
  }
}
