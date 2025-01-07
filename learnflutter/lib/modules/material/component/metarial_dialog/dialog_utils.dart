import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/debound.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/core/https/MBMHttpHelper.dart';
import 'package:learnflutter/custom_widget/keyboard_avoiding.dart';
import 'package:learnflutter/utils_helper/extension/extension_string.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: 'Label',
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.3, end: 1.0).animate(animation),
            child: AlertDialog(
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
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 300), // DURATION FOR ANIMATION
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Text('');
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

  static dismissPopup(
    BuildContext context, {
    Function()? complete,
  }) {
    UtilsHelper.pop(context);
    if (complete != null) {
      Debounce().runAfter(
        action: complete,
        rate: 500,
      );
    }
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
    double height = 300,
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
      sheetAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.decelerate,
      ),
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: stream.stream,
          initialData: height,
          builder: (context, snapshot) {
            return Container(
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
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      position = context.mediaQuery.size.height - details.globalPosition.dy;
                      if (position <= 35.0) {
                        Navigator.pop(context);
                      } else {
                        stream.add(position);
                      }
                    },
                    child: SizedBox(
                      height: DeviceDimension.padding / 3,
                    ),
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
    String titleCancleAction = 'Huỷ',
    List<CupertinoActionSheetAction>? actions,
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
          actions: actions,
        ),
      ),
    );
  }

  Future<String> downLoadFolder() async {
    Directory appDocumentsDirectory = await getApplicationCacheDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/DownLoadFile'; // 3
    Directory(filePath).create(recursive: true).then(
      (value) {
        print(value.path);
      },
    );
    return filePath;
  }

  static Future<void> showDownload({
    required BuildContext contextDialog,
    String title = 'Basic dialog title',
    String content = 'Basic dialog content',
    List<Widget>? actions,
    Widget? contentWidget,
    required String savePath,
  }) async {
    StreamController<double> stream = StreamController();
    late Future<String?> future = downloadFile(savePath, stream);
    await showGeneralDialog(
      context: contextDialog,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: 'Label',
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        child = FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await Future.delayed(
                  Duration(milliseconds: 300),
                  () {
                    if (context.mounted) {
                      dismissPopup(context, complete: () {
                        OpenFile.open(snapshot.data as String);
                      });
                    }
                  },
                );
              });
            }
            return Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.3, end: 1.0).animate(animation),
                child: AlertDialog(
                  scrollable: true,
                  // title: Text(title),
                  content: StreamBuilder(
                    initialData: 0.0,
                    stream: stream.stream,
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2, horizontal: DeviceDimension.padding / 2),
                            child: LinearProgressIndicator(
                              minHeight: 5,
                              value: snapshot.data,
                              semanticsLabel: 'Liner',
                              borderRadius: BorderRadius.all(Radius.circular(DeviceDimension.padding / 2)),
                            ),
                          ),
                          Text('${((snapshot.data ?? 0.0) * 100).toStringAsFixed(0)} %'),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
          future: future,
        );
        return child;
      },
      transitionDuration: Duration(milliseconds: 300), // DURATION FOR ANIMATION
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Text('');
      },
    );
  }

  static Future<String> downloadFile(String savePath, StreamController<double> stream) async {
    String path = '$savePath/${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      final resut = await dio.download(
        'https://sampletestfile.com/wp-content/uploads/2023/08/11.5-MB.png',
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            stream.sink.add((received / total));
          }
        },
      );
      if (resut.statusCode == 0) {
        stream.close();
        return path;
      }
    } catch (e) {
      print(e);
    }
    return path;
  }
}
