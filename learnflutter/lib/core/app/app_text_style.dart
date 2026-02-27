import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/core/app/app_colors.dart';

import '../global/var_global.dart';

/// Lớp AppTextStyles tập trung định nghĩa tất cả các phong cách chữ (Typography) được sử dụng trong toàn bộ ứng dụng.
/// Chúng tôi sử dụng các font chữ từ Google Fonts như Manrope và Inter để mang lại vẻ ngoài hiện đại và dễ đọc.
/// Các biến tĩnh này tương ứng với các mức độ phân cấp nội dung từ tiêu đề lớn (Display) đến nội dung chi tiết (Body).
/// Việc chuẩn hóa này giúp duy trì sự đồng nhất về trải nghiệm đọc của người dùng trên mọi thành phần giao diện.
class AppTextStyles {
  // textTheme
  static TextStyle themeDisplayLarge =
      textStyleManrope(AppColors.primaryText, 57, FontWeight.w400);
  static TextStyle themeDisplayMedium =
      textStyleManrope(AppColors.primaryText, 45, FontWeight.w400);
  static TextStyle themeDisplaySmall =
      textStyleManrope(AppColors.primaryText, 36, FontWeight.w400);

  static TextStyle themeHeadlineLarge =
      textStyleManrope(AppColors.primaryText, 32, FontWeight.w400);
  static TextStyle themeHeadlineMedium =
      textStyleManrope(AppColors.primaryText, 28, FontWeight.w400);
  static TextStyle themeHeadlineSmall =
      textStyleManrope(AppColors.primaryText, 24, FontWeight.w400);

  static TextStyle themeTitleLarge =
      textStyleManrope(AppColors.primaryText, 22, FontWeight.w400);
  static TextStyle themeTitleMedium =
      textStyleManrope(AppColors.primaryText, 16, FontWeight.w400);
  static TextStyle themeTitleSmall =
      textStyleManrope(AppColors.primaryText, 14, FontWeight.w400);

  static TextStyle themeBodyLarge =
      textStyleManrope(AppColors.primaryText, 16, FontWeight.w400);
  static TextStyle themeBodyMedium =
      textStyleManrope(AppColors.primaryText, 14, FontWeight.w400);
  static TextStyle themeBodySmall =
      textStyleManrope(AppColors.primaryText, 12, FontWeight.w400);

  static TextStyle themeLabelLarge =
      textStyleManrope(AppColors.primaryText, 14, FontWeight.w400);
  static TextStyle themeLabelMedium =
      textStyleManrope(AppColors.primaryText, 12, FontWeight.w400);
  static TextStyle themeLabelSmall =
      textStyleManrope(AppColors.primaryText, 11, FontWeight.w400);

  /// Phương thức textStyleManrope tạo ra một kiểu chữ sử dụng bộ font Manrope phổ biến với các tùy chỉnh linh hoạt.
  /// Nó tự động xử lý các thông số như màu sắc, kích thước và độ đậm nhạt của chữ dựa trên các tham số đầu vào.
  /// Đây là bộ font chủ đạo mang lại cảm giác thân thiện và chuyên nghiệp cho các thành phần giao diện chính.
  static TextStyle textStyleManrope(Color color, double fontSize,
      [FontWeight fontWe = FontWeight.w500,
      FontStyle fontStyle = FontStyle.normal]) {
    return textStyle(
        color, fontSize, GoogleFonts.manrope().fontFamily, fontWe, fontStyle);
  }

  /// Phương thức textStyleInter hỗ trợ việc định nghĩa các kiểu chữ sử dụng font Inter sắc nét và tinh tế.
  /// Bộ font này thường được ưu tiên cho các khối nội dung nhỏ hoặc các nhãn thông tin yêu cầu độ rõ nét cao.
  /// Bằng cách tách biệt các phương thức này, chúng tôi dễ dàng quản lý việc chuyển đổi giữa các bộ font chữ khác nhau.
  static TextStyle textStyleInter(Color color, double fontSize,
      [FontWeight fontWe = FontWeight.w500,
      FontStyle fontStyle = FontStyle.normal]) {
    return textStyle(
        color, fontSize, GoogleFonts.inter().fontFamily, fontWe, fontStyle);
  }

  /// Phương thức textStyle là hàm nền tảng chịu trách nhiệm khởi tạo đối tượng TextStyle với đầy đủ các thuộc tính cấu hình.
  /// Nó tích hợp cơ chế tỉ lệ chữ (textScale) để đảm bảo văn bản luôn hiển thị cân đối trên các kích thước màn hình khác nhau.
  /// Mọi yêu cầu về phong cách chữ trong ứng dụng cuối cùng đều đi qua hàm này để đảm bảo tính hệ thống và kiểm soát tốt nhất.
  static TextStyle textStyle(Color color, double fontSize, String? fontFamily,
      [FontWeight fontWe = FontWeight.w500,
      FontStyle fontStyle = FontStyle.normal]) {
    return TextStyle(
        fontFamily: fontFamily,
        color: color,
        fontSize: fontSize * textScale,
        fontWeight: fontWe,
        fontStyle: fontStyle);
  }
}
