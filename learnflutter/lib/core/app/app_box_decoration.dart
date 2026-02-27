import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';

/// Lớp AppBoxDecoration là nơi chứa các định nghĩa tập trung về kiểu dáng khung hình (BoxDecoration) được sử dụng rộng rãi trong toàn bộ ứng dụng.
/// Nó cung cấp các phương thức tĩnh để tạo ra các hiệu ứng hình ảnh như góc bo tròn, viền hoặc hình dạng hình học cụ thể cho các widget.
/// Việc sử dụng lớp này giúp đảm bảo tính nhất quán về mặt giao diện và dễ dàng thay đổi thiết kế tổng thể chỉ bằng cách cập nhật một nơi duy nhất.
/// Các thuộc tính này được tối ưu hóa để làm việc mượt mà với hệ thống màu sắc chủ đạo của ứng dụng thông qua AppColors.
class AppBoxDecoration {
  static BoxDecoration boxDecorationCircleColorPrimary =
      boxDecorationCircle(AppColors.primary);
  static BoxDecoration boxDecorationRectangleColorPrimary =
      boxDecorationRectangle(AppColors.primary);
  static BoxDecoration boxDecorationGreyBorder =
      boxDecorationBorder(4, 1, AppColors.background_02);

  /// Phương thức boxDecorationCircle tạo ra một trang trí hình tròn với màu sắc tùy chỉnh được truyền vào.
  /// Đây là một cách nhanh chóng để tạo ra các thành phần giao diện dạng hình tròn như avatar hoặc các điểm nhấn thông báo.
  /// Nó giúp giảm bớt việc lặp lại mã nguồn khi cần định nghĩa các hình khối cơ bản trong quá trình phát triển UI.
  static BoxDecoration boxDecorationCircle(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    );
  }

  /// Phương thức boxDecorationRectangle hỗ trợ việc tạo ra các khung hình chữ nhật cơ bản với màu sắc nhất định.
  /// Nó thường được sử dụng làm nền cho các khối nội dung lớn hoặc các thành phần giao diện dạng thẻ (card) đơn giản.
  /// Thiết lập mặc định này giúp lập trình viên tập trung vào logic hiển thị mà không cần lo lắng về các tham số trang trí vụn vặt.
  static BoxDecoration boxDecorationRectangle(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.rectangle,
    );
  }

  /// Phương thức boxDecorationRadius cho phép tạo ra các khung có góc bo tròn đều nhau (circular radius) kết hợp với màu nền.
  /// Đây là kiểu trang trí phổ biến nhất trong các thiết kế hiện đại, giúp giao diện trở nên mềm mại và thân thiện hơn với người dùng.
  /// Bạn có thể dễ dàng điều chỉnh độ cong của góc để phù hợp với từng ngữ cảnh cụ thể như nút bấm hay khung nhập liệu.
  static BoxDecoration boxDecorationRadius(
      double borderRadiusValue, Color colors) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadiusValue), color: colors);
  }

  /// Phương thức boxDecorationBorder cung cấp khả năng tạo ra khung có cả góc bo tròn và đường viền bao quanh (border).
  /// Nó rất hữu ích khi cần tạo ra các thành phần giao diện nổi bật hoặc các khung phân tách rõ rệt giữa các khối nội dung.
  /// Lập trình viên có thể linh hoạt kiểm soát độ dày của viền và màu sắc để đạt được hiệu ứng thị giác mong muốn.
  static BoxDecoration boxDecorationBorder(
      double borderRadiusValue, double borderWidth, Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      border: Border.all(width: borderWidth, color: color),
    );
  }

  /// Phương thức boxDecorationBorderRadius là phiên bản nâng cao cho phép tùy chỉnh sâu hơn các thuộc tính của khung hình.
  /// Nó hỗ trợ việc thiết lập màu nền trong suốt, màu viền và độ bo góc một cách độc lập hoặc thông qua các tham số mặc định.
  /// Phương thức này mang lại sự linh hoạt tối đa khi thiết kế các widget phức tạp yêu cầu sự kết hợp tinh tế giữa viền và nền.
  static BoxDecoration boxDecorationBorderRadius({
    required double borderRadiusValue,
    double? borderWidth,
    Color? colorBorder,
    Color? colorBackground,
  }) {
    return BoxDecoration(
      color: colorBackground ?? Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadiusValue),
      border: Border.all(
          width: borderWidth ?? 0, color: colorBorder ?? Colors.transparent),
    );
  }
}

/// Lớp AppShadowBox chuyên trách quản lý các hiệu ứng đổ bóng cho các thành phần giao diện trong ứng dụng.
/// Nó giúp tạo ra cảm giác về chiều sâu và phân cấp các lớp giao diện, làm cho các thành phần quan trọng trở nên nổi bật hơn.
/// Các hằng số bóng đổ được định nghĩa sẵn theo các mức độ từ nhẹ đến đậm để phù hợp với nhiều phong cách thiết kế khác nhau.
/// Việc chuẩn hóa các thông số đổ bóng giúp duy trì trải nghiệm người dùng đồng nhất và chuyên nghiệp trên mọi màn hình.
class AppShadowBox {
  static BoxShadow boxShadowPrimary =
      boxShadow(AppColors.primaryText.withOpacity(0.8), 1, 4);
  static BoxShadow shadowLight =
      boxShadow(AppColors.black.withOpacity(0.3), 0, 3, Offset(0, 2));
  static BoxShadow shadowSuperLight =
      boxShadow(AppColors.grey.withOpacity(0.2), -0.5, 0.5, Offset(0, 1.5));

  /// Phương thức boxShadow là một hàm tiện ích để tạo ra đối tượng BoxShadow với các tham số về màu sắc, độ lan tỏa và độ mờ.
  /// Nó đơn giản hóa việc tạo bóng cho các widget bằng cách chấp nhận các giá trị cơ bản và tự động xử lý các tham số tùy chọn.
  /// Sử dụng phương thức này giúp mã nguồn trở nên sạch sẽ và dễ đọc hơn khi thực hiện các thiết kế giao diện phức tạp.
  static BoxShadow boxShadow(
      Color colors, double spreadRadius, double blurRadius,
      [Offset? offset = const Offset(0, 0)]) {
    return BoxShadow(
        color: colors,
        spreadRadius: spreadRadius,
        blurRadius: blurRadius,
        offset: offset!);
  }
}
