import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/custom_widget/keyboard_avoiding.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

enum TypeDialog {
  none,
  error,
  warning,
  success,
  custom,
}

/// Contain all the dialog functions of the app
class DialogUtils {
  DialogUtils._();

  static Widget widgetIconsDialogWithType(TypeDialog type) {
    Widget temp = Container();
    switch (type) {
      case TypeDialog.error:
        temp = Icon(Icons.error);
        break;
      case TypeDialog.warning:
        temp = Icon(Icons.warning);
        break;
      case TypeDialog.success:
        temp = Icon(Icons.check);
        break;
      case TypeDialog.custom:
        temp = Container(
          color: Colors.red,
        );
        break;
      case TypeDialog.none:
        temp = Container(
          color: Colors.red,
        );
        break;
      default:
    }
    return temp;
  }

  static Widget widgetContentDialogWithType({TypeDialog type = TypeDialog.custom, String? content, Widget? contentWidget}) {
    Widget temp = Container();
    switch (type) {
      case TypeDialog.error:
      case TypeDialog.success:
      case TypeDialog.warning:
      case TypeDialog.none:
        temp = Text(content ?? '');
        break;
      case TypeDialog.custom:
        temp = contentWidget ?? temp;
        break;
      default:
    }
    return temp;
  }

  static Future<void> dialogBuilder({
    required BuildContext context,
    TypeDialog type = TypeDialog.none,
    String title = 'Basic dialog title',
    String content = 'Basic dialog content',
    Widget? contentWidget,
    List<Widget>? actions,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: widgetIconsDialogWithType(type),
          title: Text(title),
          content: widgetContentDialogWithType(type: type, content: content, contentWidget: contentWidget),
          actions: actions ??
              <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Disable'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Disable'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Disable'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Enable'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
        );
      },
    );
  }

  static Future<void> showBasicDialog({
    required BuildContext context,
    String title = 'Basic dialog title',
    String content = 'Basic dialog content',
    List<Widget>? actions,
    Widget? contentWidget,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(title),
          content: Column(
            children: [Text(content), contentWidget ?? Container()],
          ),
          actions: actions ??
              <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Action 1'),
                  onPressed: () {
                    dismissPopup(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Action 2'),
                  onPressed: () {
                    dismissPopup(context);
                  },
                ),
              ],
        );
      },
    );
  }

  static Future<void> showDialogWithHeroIcon({
    required BuildContext context,
    TypeDialog type = TypeDialog.none,
    String? title,
    String content = '',
    Widget? contentWidget,
    List<Widget>? actions,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 4),
          scrollable: true,
          icon: type == TypeDialog.none ? null : widgetIconsDialogWithType(type),
          title: title != null ? Text(title) : null,
          content: Column(
            children: [Text(content), contentWidget ?? Container()],
          ),
          actions: actions ??
              <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Action 1'),
                  onPressed: () {
                    dismissPopup(context);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: context.textTheme.labelLarge,
                  ),
                  child: const Text('Action 2'),
                  onPressed: () {
                    dismissPopup(context);
                  },
                ),
              ],
        );
      },
    );
  }

  static dismissPopup(BuildContext context) {
    UtilsHelper.pop(context);
  }

  static void updateHeight(double height, StreamController stream) {
    // your logic //
    //------------//
    stream.sink.add(height);
  }

  static Future<void> showBottomSheet({
    required BuildContext context,
    double elevation = 0,
    Color? color,
    double? height,
    double? width,
    Widget contentWidget = const Center(
      child: Text('Nothing'),
    ),
    bool isScrollControlled = true,
    bool isDismissible = true,
    double borderRadiusVertical = 16.0,
  }) async {
    StreamController<double> stream = StreamController();
    double position;
    await showModalBottomSheet<void>(
      elevation: elevation,
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      // constraints: BoxConstraints.expand(
      //   height: context.mediaQuery.size.height,
      //   width: context.mediaQuery.size.width,
      // ),
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: stream.stream,
          initialData: height,
          builder: (context, snapshot) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                position = MediaQuery.of(context).size.height - details.globalPosition.dy;
                if (position <= 35.0) {
                  Navigator.pop(context);
                } else {
                  stream.add(position);
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: DeviceDimension.padding,
                  left: DeviceDimension.padding,
                  right: DeviceDimension.padding,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadiusVertical)),
                  color: color ?? Colors.white,
                ),
                height: (snapshot.data as double),
                width: width ?? context.mediaQuery.size.width - DeviceDimension.padding * 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      height: DeviceDimension.padding / 3,
                    ),
                    Container(
                      height: 4,
                      width: context.mediaQuery.size.width / 8,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(child: contentWidget)
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> openDraggableBottomSheet({
    required BuildContext context,
    required Widget child,
  }) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          snapSizes: const [0.30, 0.50, 0.70, 0.9],
          snap: true,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: child,
            );
          },
        );
      },
    );
    // inserting overlay entry
    overlayState.insert(overlayEntry);
  }

  static Future<void> showActionSheet({
    required BuildContext context,
    String title = 'Thông báo',
    Widget content = const Text('Nothing'),
    String titleCancleAction = 'Cancle',
  }) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => KeyboardAvoiding(
        duration: const Duration(milliseconds: 600),
        child: CupertinoActionSheet(
          title: Text(title),
          message: content,
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              titleCancleAction,
              style: context.textTheme.titleMedium?.copyWith(color: Colors.blue),
            ),
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              /// This parameter indicates the action would be a default
              /// default behavior, turns the action's text to bold text.
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Default Action'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Action'),
            ),
            CupertinoActionSheetAction(
              /// This parameter indicates the action would perform
              /// a destructive action such as delete or exit and turns
              /// the action's text color to red.
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Destructive Action'),
            ),
          ],
        ),
      ),
    );
  }
}
