import 'package:flutter/material.dart';

/// Lớp DeviceDimension là một công cụ hỗ trợ quan trọng trong việc quản lý kích thước và tỷ lệ hiển thị trên nhiều loại thiết bị khác nhau.
/// Nó cung cấp các thông số về chiều rộng, chiều cao của màn hình cũng như các giá trị đo lường chuẩn được tính toán theo tỷ lệ thiết kế.
/// Việc sử dụng lớp này giúp giao diện ứng dụng luôn giữ được sự cân đối và đồng nhất dù chạy trên điện thoại nhỏ hay máy tính bảng lớn.
/// Đây là giải pháp cốt lõi để hiện thực hóa thiết kế đáp ứng (responsive design) một cách chuyên nghiệp và hiệu quả nhất.
class DeviceDimension {
  static final DeviceDimension _instance = DeviceDimension._internal();

  factory DeviceDimension() => _instance;

  DeviceDimension._internal();

  bool _isInit = true;

  /// Kích thước màn hình gốc được sử dụng trong bản thiết kế Figma để làm căn cứ tính toán tỷ lệ.
  static const Size rootSize = Size(414, 896);

  static late final double screenWidth;
  static late final double screenHeight;

  static late final double _widthScale;
  static late final double _heightScale;
  static late final double _defaultScale;
  static double? _keyBoard;

  /// Thuộc tính textScale cung cấp tỷ lệ font chữ phù hợp giúp văn bản hiển thị rõ ràng và thẩm mỹ trên mọi mật độ điểm ảnh.
  /// Nó được tính toán dựa trên chiều cao thực tế của màn hình so với bản thiết kế gốc để đảm bảo chữ không bị quá lớn hay quá nhỏ.
  /// Cơ chế giới hạn tỷ lệ từ 1.0 đến 1.5 giúp duy trì tính ổn định của layout và tránh các lỗi hiển thị văn bản tràn khung.
  static double get textScale => _heightScale >= 1.5
      ? 1.5
      : _heightScale <= 1
          ? 1
          : _heightScale;

  static double get padding => screenWidth * 0.05;

  static double get keyBoard => _keyBoard ?? 0;
  static bool isKeyBoardSizeInitialized = false;

  static double get appBar => verticalSize(70);

  static double get radius6 => horizontalSize(6);
  static double get radius8 => horizontalSize(8);

  static double get icon15 => horizontalSize(15);
  static double get icon25 => horizontalSize(25);
  static double get icon45 => horizontalSize(45);

  static double get h45 => verticalSize(45);
  static double get h50 => verticalSize(50);
  static double get h55 => verticalSize(55);
  static double get h60 => verticalSize(60);

  static double get backArrow => defaultSize(22);
  static double get scrollbarIndicator => defaultSize(4.5);

  /// Phương thức initValue chịu trách nhiệm khởi tạo các giá trị đo lường cơ bản dựa trên thông tin thực tế từ BuildContext.
  /// Nó chỉ thực hiện việc tính toán tỷ lệ một lần duy nhất khi ứng dụng bắt đầu để tối ưu hóa hiệu năng hệ thống.
  /// Sau khi khởi tạo, các thông số về chiều rộng và chiều cao sẽ được lưu trữ để sử dụng xuyên suốt trong quá trình render UI.
  /// Đây là bước bắt buộc phải thực hiện trước khi có thể sử dụng các hàm tiện ích khác của lớp DeviceDimension.
  void initValue(BuildContext context) {
    if (!_isInit) return;
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    _widthScale = screenWidth / rootSize.width;
    _heightScale = screenHeight / rootSize.height;
    _defaultScale = (_widthScale + _heightScale) / 2;

    _isInit = false;
  }

  /// Phương thức setKeyBoardSize giúp cập nhật kích thước bàn phím khi nó xuất hiện hoặc ẩn đi trên màn hình thiết bị.
  /// Nó kiểm tra sự thay đổi kích thước để đảm bảo rằng các thành phần giao diện phía trên có thể co giãn một cách hợp lý nhất.
  /// Dữ liệu này cực kỳ hữu ích cho việc xử lý các form nhập liệu phức tạp mà không bị bàn phím che khuất các trường quan trọng.
  void setKeyBoardSize(double? size) {
    final isSizeChange = size != null && _keyBoard != size;
    if (isSizeChange) {
      _keyBoard = size;
    }
  }

  /// Phương thức normalize thực hiện việc tính toán lại giá trị của một số cụ thể theo tỷ lệ màn hình thực tế của người dùng.
  /// Bạn có thể lựa chọn tỷ lệ theo chiều rộng hoặc chiều cao để đảm bảo widget luôn hiển thị chuẩn so với ý đồ thiết kế ban đầu.
  /// Đây là hàm lõi làm nền tảng cho việc tạo ra các widget có khả năng tự động điều chỉnh kích thước tinh tế và thông minh.
  static double normalize(double num, [int follow = 0]) {
    if (follow == 0) {
      return num * _widthScale;
    }
    return num * _heightScale;
  }

  /// Hàm horizontalSize giúp tính toán kích thước theo chiều ngang của thiết bị để duy trì tỷ lệ về chiều rộng cho các thành phần UI.
  static double horizontalSize(double num) {
    return normalize(num);
  }

  /// Hàm verticalSize hỗ trợ việc xác định kích thước theo chiều dọc, thường được dùng cho các khoảng cách lề hoặc chiều cao của widget.
  static double verticalSize(double num) {
    return normalize(num, 1);
  }

  /// Hàm defaultSize thực hiện việc tính toán kích thước dựa trên tỷ lệ trung bình giữa chiều rộng và chiều cao màn hình.
  /// Cách tiếp cận này giúp các yếu tố như biểu tượng (icon) hoặc phông chữ giữ được hình dáng cân đối trên nhiều tỉ lệ màn hình khác nhau.
  /// Nó mang lại sự ổn định và hài hòa cho tổng thể giao diện người dùng mà không phụ thuộc quá nhiều vào một chiều duy nhất.
  static double defaultSize(double num) {
    return _defaultScale * num;
  }

  /// Phương thức viewInsets trả về các khoảng đệm hệ thống cần thiết như thanh trạng thái hoặc vùng an toàn của các thiết bị có tai thỏ.
  /// Nó trích xuất dữ liệu trực tiếp từ MediaQuery để cung cấp thông tin chính xác nhất về các vùng không thể hiển thị nội dung.
  /// Điều này giúp lập trình viên thiết kế giao diện tránh bị đè lấp bởi các thành phần hệ thống vốn có của từng nền tảng khác nhau.
  static EdgeInsets viewInsets(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  /// Phương thức possibleViewHeight tính toán chiều cao khả dụng thực tế cho phần nội dung sau khi đã trừ đi các thanh công cụ và vùng an toàn.
  /// Nó hỗ trợ linh hoạt cả hai trường hợp có hoặc không có thanh tiêu đề (AppBar) để đưa ra con số chính xác nhất cho việc trình bày UI.
  /// Kết quả trả về giúp xác định kích thước lý tưởng cho các danh sách dài hoặc các thành phần cần chiếm trọn không gian trống của màn hình.
  static double possibleViewHeight(BuildContext context,
      [bool hasAppbar = true]) {
    if (!hasAppbar)
      return DeviceDimension.screenHeight - statusBarHeight(context);
    return DeviceDimension.screenHeight -
        DeviceDimension.appBar -
        statusBarHeight(context);
  }

  /// Hàm statusBarHeight cung cấp thông tin về chiều cao của thanh trạng thái hệ thống ngay tại thời điểm thực thi.
  static double statusBarHeight(BuildContext context) {
    return DeviceDimension.viewInsets(context).top;
  }

  /// Phương thức getSizeView thực hiện việc đo lường kích thước thực tế của một Widget hiện diện trên giao diện thông qua GlobalKey.
  /// Nó giúp lập trình viên lấy được thông tin chính xác về Pixel của bất kỳ thành phần nào để phục vụ cho các tính toán giao diện phức tạp.
  static Size getSizeView(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    return renderBox.size;
  }

  /// Phương thức getOffsetView xác định tọa độ tuyệt đối của một Widget trên toàn bộ không gian màn hình thiết bị.
  /// Thông tin về vị trí này rất quan trọng khi cần hiển thị các menu phụ, hiệu ứng chuyển cảnh hoặc các thành phần giao diện nổi khác.
  static Offset getOffsetView(GlobalKey key) {
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }
}
