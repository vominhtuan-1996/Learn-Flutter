import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/app/app_local_translate.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/core/utils/extension/extension_widget.dart';

/// AlertDialogType định nghĩa các loại thông báo khác nhau trong hệ thống.
/// Việc phân loại này giúp người dùng nhanh chóng nhận diện tính chất của thông báo qua màu sắc và biểu tượng.
/// Nó hỗ trợ các trạng thái từ thông tin bình thường đến các cảnh báo nguy hiểm hoặc lỗi hệ thống.
enum AlertDialogType { success, error, warning, info }

/// AppAlertDialog là một widget tùy chỉnh cung cấp giao diện hộp thoại nhất quán cho toàn bộ ứng dụng.
/// Nó được thiết kế để hiển thị các thông báo quan trọng và yêu cầu xác nhận từ người dùng.
/// Widget hỗ trợ nhiều loại thông báo khác nhau và cho phép tùy chỉnh các hành động phản hồi.
class AppAlertDialog extends StatefulWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;
  final AlertDialogType type;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.type = AlertDialogType.info,
  });

  @override
  State<StatefulWidget> createState() => AppAlertDialogState();
}

class AppAlertDialogState extends State<AppAlertDialog> {
  /// Phương thức build thực hiện việc xây dựng giao diện người dùng cho hộp thoại.
  /// Nó sử dụng LayoutBuilder để đảm bảo kích thước hộp thoại phù hợp với nhiều loại màn hình khác nhau.
  /// Giao diện bao gồm phần tiêu đề, nội dung chi tiết và các nút hành động được sắp xếp hợp lý.
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: context.mediaQuery.size.width,
        maxHeight: context.mediaQuery.size.height,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: Container(
              width: constraints.maxWidth * 0.8,
              height: constraints.maxHeight * 0.4,
              decoration: AppBoxDecoration.boxDecorationBorderRadius(
                borderRadiusValue: 8,
                colorBackground: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: context.textTheme.titleLarge?.copyWith(
                              color: widget.type == AlertDialogType.success
                                  ? Colors.black
                                  : widget.type == AlertDialogType.error
                                      ? Colors.red
                                      : widget.type == AlertDialogType.warning
                                          ? Colors.orange
                                          : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ).paddingOnly(
                      left: 8,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        AppLocaleTranslate.description.getString(context),
                        style: context.textTheme.bodyMedium?.copyWith()),
                  ).paddingOnly(
                    left: 16,
                  ),
                  // .background(Colors.red),

                  /// Content
                  Expanded(
                    child: Text(
                      widget.content,
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ).paddingSymmetric(horizontal: 16),
                  ),

                  /// Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onCancel != null)
                        TextButton(
                          onPressed: widget.onCancel,
                          child: Text(widget.cancelText ??
                              AppLocaleTranslate.cancel.getString(context)),
                        ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: widget.onConfirm,
                        child: Text(widget.confirmText ??
                            AppLocaleTranslate.confirm.getString(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ).paddingSymmetric(horizontal: DeviceDimension.padding).center(),
          );
        },
      ),
    );
  }
}
