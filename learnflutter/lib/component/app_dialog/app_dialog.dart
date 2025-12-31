import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';

enum AlertDialogType { success, error, warning, info }

class AppAlertDialog extends StatefulWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;
  final AlertDialogType type;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.type = AlertDialogType.info,
  });

  @override
  State<StatefulWidget> createState() => AppAlertDialogState();
}

class AppAlertDialogState extends State<AppAlertDialog> {
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
                    child: Text('Description', style: context.textTheme.bodyMedium?.copyWith()),
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
                          child: Text(widget.cancelText),
                        ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: widget.onConfirm,
                        child: Text(widget.confirmText),
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
