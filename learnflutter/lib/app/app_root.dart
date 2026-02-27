import 'dart:async';

import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/app/intro_splash.dart';
import 'package:learnflutter/features/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/features/setting/state/setting_state.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';

/// Lớp AppRootStrings đóng vai trò là một kho lưu trữ tập trung dành riêng cho các hằng số cấu hình của widget AppRoot trong toàn bộ hệ thống.
/// Việc tập trung các giá trị như đường dẫn hình ảnh và thông số thời gian tại đây giúp đội ngũ phát triển dễ dàng quản lý và thay đổi tài nguyên mà không cần phải can thiệp sâu vào các lớp xử lý logic hiển thị phức tạp.
/// Cấu trúc này không chỉ giúp mã nguồn trở nên sạch sẽ và dễ bảo trì hơn mà còn hỗ trợ quá trình bản địa hóa tài nguyên một cách nhanh chóng khi cần thiết.
/// Đây là một kỹ thuật tổ chức mã nguồn quan trọng nhằm tách biệt rõ ràng giữa các giá trị cấu hình tĩnh và các thành phần giao diện động của ứng dụng.
class AppRootStrings {
  /// Thuộc tính backgroundImage quy định đường dẫn asset dẫn tới tệp tin hình ảnh được sử dụng làm nền cho màn hình khởi động của ứng dụng.
  /// Hình ảnh này được lựa chọn kỹ lưỡng để tạo ra một bối cảnh nhất quán và chuyên nghiệp ngay từ những giây đầu tiên người dùng mở ứng dụng lên.
  /// Việc sử dụng một hằng số tĩnh giúp hệ thống có thể truy cập tài nguyên một cách nhanh chóng và tránh được các lỗi chính tả khi tham chiếu thủ công ở nhiều nơi.
  static const String backgroundImage = 'assets/images/background_mobi.png';

  /// Thuộc tính splashGifPath được cấu hình để trỏ tới tệp tin GIF chứa các hiệu ứng hoạt hóa đặc trưng của thương hiệu trong giai đoạn chào mừng.
  /// Hiệu ứng GIF này giúp tạo ra một ấn tượng thị giác sống động và thu hút sự chú ý của người dùng trong khi các dịch vụ nền đang âm thầm khởi tạo.
  /// Đây là thành phần quan trọng để làm giảm cảm giác chờ đợi và mang lại trải nghiệm tương tác mượt mà ngay từ bước bắt đầu của vòng đời ứng dụng.
  static const String splashGifPath = 'assets/images/launch_tcss_v7.gif';

  /// Hằng số splashDurationSeconds quy định tổng thời gian tính bằng giây mà màn hình chào sẽ hiển thị nội dung hoạt họa trước khi chuyển cảnh.
  /// Khoảng thời gian này được tính toán dựa trên độ dài của tệp GIF và thời gian cần thiết tối thiểu để các tài nguyên hệ thống cơ bản sẵn sàng hoạt động.
  /// Việc quy định thời gian cụ thể giúp lập trình viên kiểm soát chính xác tốc độ dòng chảy của ứng dụng và đảm bảo không có sự ngắt quãng đột ngột nào xảy ra.
  static const int splashDurationSeconds = 14;
}

/// Lớp AppRoot thực hiện nhiệm vụ quản lý toàn bộ luồng khởi tạo ban đầu và điều phối cơ chế điều hướng chính khi ứng dụng Flutter bắt đầu khởi động.
/// Thành phần này chịu trách nhiệm hiển thị màn hình chào với hiệu ứng GIF sinh động để xây dựng ấn tượng tốt đẹp với người dùng ngay từ cái nhìn đầu tiên.
/// Bên cạnh việc hiển thị giao diện, AppRoot còn đóng vai trò như một bộ điều phối để chuẩn bị các thông số kích thước màn hình và đồng bộ hóa các tác vụ khởi chạy ngầm.
/// Sau khi các hiệu ứng kết thúc và dữ liệu đã sẵn sàng, lớp này sẽ tự động dẫn dắt người dùng tiến vào các tầng chức năng sâu hơn của hệ thống một cách an toàn.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    /// Cơ chế Completer được thiết lập tại đây nhằm mục đích điều phối việc đồng bộ tuyệt đối giữa thời gian chạy hiệu ứng hoạt họa và tiến trình khởi tạo dữ liệu của ứng dụng.
    /// Nó đảm bảo rằng việc chuyển đổi sang màn hình tiếp theo chỉ được phép xảy ra khi cả hiệu ứng chào mừng đã hoàn tất và các dịch vụ nền đã ở trạng thái sẵn sàng.
    /// Phương pháp đồng bộ này giúp loại bỏ hoàn toàn các hiện tượng giật lag hoặc lỗi hiển thị dữ liệu chưa hoàn chỉnh khi người dùng mới truy cập vào hệ thống.
    /// Đây là một giải pháp xử lý bất đồng bộ hiệu quả để duy trì tính ổn định và sự chuyên nghiệp cho toàn bộ luồng trải nghiệm khởi đầu của sản phẩm.
    final Completer<void> initCompleter = Completer<void>();

    return SafeArea(
      bottom: false,
      top: false,
      child: BlocBuilder<SettingThemeCubit, SettingThemeState>(
        builder: (context, state) {
          /// Phương thức initValue thuộc lớp DeviceDimension được triệu gọi tại đây để cập nhật các thông số kích thước vật lý của màn hình theo ngữ cảnh thiết bị hiện tại.
          /// Việc xác định chính xác các chỉ số này là điều kiện tiên quyết để đảm bảo các thành phần giao diện sau đó có thể hiển thị một cách cân đối trên mọi loại thiết bị.
          /// Do phương thức này được đặt trong hàm build, nó cho phép ứng dụng phản hồi linh hoạt với các thay đổi về hướng xoay hoặc thay đổi kích thước cửa sổ của người dùng.
          /// Đây là nền tảng quan trọng giúp xây dựng một giao diện thích ứng thông minh và mang lại trải nghiệm người dùng đồng nhất trên nhiều nền tảng khác động.
          DeviceDimension().initValue(context);

          return FlutterSplashScreen.gif(
            backgroundImage: Image.asset(AppRootStrings.backgroundImage),
            onInit: () async {
              debugPrint(AppLocaleTranslate.splashInitialized.getString(context));
              await Future.delayed(
                const Duration(seconds: AppRootStrings.splashDurationSeconds),
              );
              initCompleter.complete();
            },
            onEnd: () async {
              debugPrint(AppLocaleTranslate.splashAnimationEnded.getString(context));
              await initCompleter.future;
            },
            nextScreen: const IntroSplash(),
            gifPath: AppRootStrings.splashGifPath,
            gifWidth: context.mediaQuery.size.width,
            gifHeight: context.mediaQuery.size.height,
          );
        },
      ),
    );
  }
}
