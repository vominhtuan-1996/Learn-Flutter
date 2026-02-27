import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/shared/widgets/app_dialog/app_dialog.dart';
import 'package:learnflutter/shared/widgets/app_dialog/app_update_patch_dialog.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';

/// AppDialogManager chịu trách nhiệm quản lý việc hiển thị các hộp thoại trong ứng dụng.
/// Nó cung cấp một giao diện lập trình đơn giản để kích hoạt các loại thông báo khác nhau như thông báo lỗi, thành công hoặc thông tin.
/// Lớp này sử dụng navigatorKey để có thể hiển thị hộp thoại từ bất kỳ đâu trong ứng dụng mà không cần truyền BuildContext thủ công.
class AppDialogManager {
  static BuildContext get _context => UtilsHelper.navigatorKey.currentContext!;

  /// Phương thức show thực hiện việc hiển thị một hộp thoại tổng quát với các hiệu ứng chuyển cảnh tùy chỉnh.
  /// Nó tích hợp AppAlertDialog để đảm bảo giao diện nhất quán và hỗ trợ các tính năng như chặn tương tác nền.
  /// Các tham số cho phép cấu hình linh hoạt từ tiêu đề, nội dung đến các hàm gọi lại khi người dùng xác nhận hoặc hủy bỏ.
  static void show({
    required AlertDialogType type,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showGeneralDialog(
      context: _context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: 'Label',
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.3, end: 1.0).animate(animation),
            child: AppAlertDialog(
              title: title,
              content: content,
              type: type,
              confirmText: confirmText ?? AppLocaleTranslate.confirm.getString(_context),
              cancelText: cancelText ?? AppLocaleTranslate.cancel.getString(_context),
              onConfirm: () {
                Navigator.pop(context);
                onConfirm?.call();
              },
              onCancel: onCancel != null
                  ? () {
                      Navigator.pop(context);
                      onCancel();
                    }
                  : () => Navigator.pop(context),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300), // DURATION FOR ANIMATION
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Text('');
      },
    );
  }

  /// Hiển thị một hộp thoại thông tin để thông báo các sự kiện thông thường cho người dùng.
  /// Thường được sử dụng để cung cấp gợi ý hoặc trạng thái xử lý không gây nguy hiểm.
  static void info(String content, {String? title}) {
    show(type: AlertDialogType.info, title: title ?? AppLocaleTranslate.info.getString(_context), content: content);
  }

  /// Hiển thị hộp thoại thông báo thành công sau khi một tác vụ được hoàn thành đúng mong đợi.
  /// Màu sắc và biểu tượng thường chuyển sang tông xanh lá để tạo cảm giác an tâm và tích cực.
  static void success(String content, {String? title}) {
    show(type: AlertDialogType.success, title: title ?? AppLocaleTranslate.success.getString(_context), content: content);
  }

  /// Hiển thị hộp thoại cảnh báo lỗi khi có sự cố xảy ra trong quá trình vận hành ứng dụng.
  /// Nó giúp người dùng nhận diện vấn đề ngay lập tức thông qua các chỉ thị màu đỏ và tiêu đề rõ ràng.
  static void error(String content, {String? title}) {
    show(type: AlertDialogType.error, title: title ?? AppLocaleTranslate.error.getString(_context), content: content);
  }

  /// [showUpdatePatch] hiển thị hộp thoại cập nhật bản vá phong cách hiện đại.
  /// Phương thức này cho phép hiển thị các thay đổi quan trọng kèm theo thanh tiến trình tải xuống.
  /// Nó sử dụng [showGeneralDialog] để tạo ra hiệu ứng mượt mà và làm mờ nền hiệu quả.
  static void showUpdatePatch({
    required String version,
    required List<String> changelog,
    required VoidCallback onUpdate,
    double progress = 0.0,
    bool isDownloading = false,
    bool showSimulator = false,
    bool autoSimulate = false,
  }) {
    showGeneralDialog(
      context: _context,
      barrierDismissible: false, // !isDownloading, // Không cho phép đóng nếu đang tải
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeInOutBack.transform(anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: AppUpdatePatchDialog(
              version: version,
              changelog: changelog,
              onUpdate: onUpdate,
              progress: progress,
              isDownloading: isDownloading,
              showSimulator: showSimulator,
              autoSimulate: autoSimulate,
            ),
          ),
        );
      },
    );
  }
}
