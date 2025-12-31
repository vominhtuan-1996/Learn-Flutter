import 'package:flutter/material.dart';
import 'package:learnflutter/component/app_dialog/app_dialog.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

class AppDialogManager {
  static BuildContext get _context => UtilsHelper.navigatorKey.currentContext!;

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
              confirmText: 'Xác nhận',
              cancelText: 'Hủy',
              onConfirm: () {
                Navigator.pop(context);
                // Xử lý tiếp
              },
              onCancel: () => Navigator.pop(context),
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

  static void info(String content, {String title = 'Thông báo'}) {
    show(type: AlertDialogType.info, title: title, content: content);
  }

  static void success(String content, {String title = 'Thành công'}) {
    show(type: AlertDialogType.success, title: title, content: content);
  }

  static void error(String content, {String title = 'Lỗi'}) {
    show(type: AlertDialogType.error, title: title, content: content);
  }
}
