import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/bottom_sheet/cubit/bottom_sheet_cubit.dart';
import 'package:learnflutter/component/bottom_sheet/page/bottom_sheet.dart';
import 'package:learnflutter/component/bottom_sheet/state/bottom_sheet_state.dart';
import 'package:learnflutter/component/scroll_physics/nobounce_scroll_physics.dart';
import 'package:learnflutter/core/debound.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/custom_widget/keyboard_avoiding.dart';
import 'package:learnflutter/utils_helper/image_helper.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

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
        temp = const Icon(Icons.error);
        break;
      case TypeDialog.warning:
        temp = const Icon(Icons.warning);
        break;
      case TypeDialog.success:
        temp = const Icon(Icons.check);
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
              insetPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // contentPadding: EdgeInsets.zero,
              scrollable: true,
              // title: Text(title),
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
      transitionDuration: const Duration(milliseconds: 300), // DURATION FOR ANIMATION
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Text('');
      },
    );
  }

  static Future<void> showFullDialog({
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
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                // contentPadding: EdgeInsets.zero,
                scrollable: true,
                // title: Text(title),
                content: Column(
                  children: [contentWidget ?? Container()],
                ),
                actions: actions
                // <Widget>[
                //   TextButton(
                //     style: TextButton.styleFrom(
                //       textStyle: context.textTheme.labelLarge,
                //     ),
                //     child: const Text('Action 1'),
                //     onPressed: () {
                //       dismissPopup(context);
                //     },
                //   ),
                //   TextButton(
                //     style: TextButton.styleFrom(
                //       textStyle: context.textTheme.labelLarge,
                //     ),
                //     child: const Text('Action 2'),
                //     onPressed: () {
                //       dismissPopup(context);
                //     },
                //   ),
                // ],
                ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300), // DURATION FOR ANIMATION
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
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Check if a SnackBar is currently being displayed and hide it
    if (scaffoldMessenger.mounted) {
      scaffoldMessenger.hideCurrentSnackBar();
    }
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
    bool showDrag = true,
    RoundedRectangleBorder? shape,
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
      // showDragHandle: true,
      enableDrag: true,
      shape: shape,
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
              height: snapshot.data,
              width: width ?? context.mediaQuery.size.width - DeviceDimension.padding * 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    onHorizontalDragUpdate: (details) {
                      print(details.globalPosition.dx);
                    },
                    onVerticalDragUpdate: (details) {
                      position = context.mediaQuery.size.height - details.globalPosition.dy;
                      print(position);
                      if (position <= 35.0) {
                        Navigator.pop(context);
                      } else {
                        print(details.globalPosition.dy);
                        updateHeight(position, stream);
                      }
                    },
                    child: SizedBox(
                      height: DeviceDimension.padding / 3,
                    ),
                  ),
                  if (showDrag)
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
    bool isScrollControlled = true,
    Color backgroundColor = Colors.white,

    /// Minimum height as a fraction of the screen height
    double minSize = 0.1,

    /// Maximum height as a fraction of the screen height
    double maxSize = 0.9,

    /// Initial height as a fraction of the screen height
    double initialSize = 0.86,
  }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      barrierColor: Colors.transparent,
      sheetAnimationStyle: AnimationStyle(
        duration: Duration(milliseconds: 300),
        curve: Curves.decelerate,
      ),
      isDismissible: false,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: initialSize,
          minChildSize: minSize,
          maxChildSize: maxSize,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(48 * initialSize), topRight: Radius.circular(48 * initialSize)),
              ),
              child: SingleChildScrollView(
                physics: NoBounceScrollPhysics(),
                controller: scrollController,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: DeviceDimension.padding / 4, bottom: DeviceDimension.padding / 2),
                      child: Container(
                        height: 6,
                        width: context.mediaQuery.size.width / 7,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      height: context.mediaQuery.size.height * initialSize,
                      color: backgroundColor,
                      child: child,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    late Future<String?> future = UtilsHelper.downloadFile(savePath, stream);
    await showGeneralDialog(
      context: contextDialog,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: 'Label',
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        child = FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) async {
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                    () {
                      if (context.mounted) {
                        dismissPopup(context, complete: () {
                          OpenFile.open(snapshot.data as String);
                        });
                      }
                    },
                  );
                },
              );
            }
            return Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.3, end: 1.0).animate(animation),
                child: StreamBuilder(
                  stream: stream.stream,
                  initialData: 0.0,
                  builder: (context, snapshot) {
                    return AlertDialog(
                      scrollable: true,
                      content: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: snapshot.data != 1
                                ? Container(
                                    key: ValueKey<int>(0),
                                    padding: EdgeInsets.symmetric(
                                      vertical: DeviceDimension.padding / 2,
                                    ),
                                    child: LinearProgressIndicator(
                                      minHeight: 8,
                                      value: snapshot.data,
                                      semanticsLabel: 'Linear',
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: DeviceDimension.padding / 2,
                                    ),
                                    child: FadeTransition(
                                      key: ValueKey<int>(1),
                                      opacity: Tween<double>(begin: 0.3, end: snapshot.data).animate(animation),
                                      child: ImageHelper.loadFromAsset('assets/icons/ic_popup_success.svg'),
                                    ),
                                  ),
                          ),
                          Text('${((snapshot.data ?? 0.0) * 100).toStringAsFixed(0)} %'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
          future: future,
        );
        return child;
      },
      transitionDuration: const Duration(milliseconds: 300), // DURATION FOR ANIMATION
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Text('');
      },
    );
  }

  static Future<void> uploadFile(List uploadList, StreamController<int> stream) async {
    int index = 0;
    await Future.forEach(uploadList, (element) async {
      await Future.delayed(
        const Duration(seconds: 2),
        () {
          stream.sink.add(index);
        },
      );
      index++;
    });
  }

  static Future<void> showUploadProgress({
    required BuildContext contextDialog,
    required List uploadList,
    required Future<void> Function(StreamController<int> stream) function,
  }) async {
    StreamController<int> stream = StreamController();
    late Future<void> future = function(stream);
    // late Future<String?> future = UtilsHelper.downloadFile(savePath, stream);
    await showGeneralDialog(
      context: contextDialog,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: 'Label',
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        child = FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) async {
                  await Future.delayed(
                    const Duration(milliseconds: 300),
                    () {
                      if (context.mounted) {
                        dismissPopup(context, complete: () {
                          // OpenFile.open(snapshot.data as String);
                        });
                      }
                    },
                  );
                },
              );
            }
            return Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.3, end: 1.0).animate(animation),
                child: StreamBuilder<int>(
                  stream: stream.stream,
                  initialData: 0,
                  builder: (context, snapshot) {
                    return AlertDialog(
                      icon: Center(
                          child: Text(
                        (uploadList[snapshot.data ?? 0] as RadioItemModel).title,
                        style: context.textTheme.bodyMedium,
                      )),
                      scrollable: true,
                      content: Column(
                        children: [
                          AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: Container(
                                key: ValueKey<int>(0),
                                padding: EdgeInsets.symmetric(
                                  vertical: DeviceDimension.padding / 2,
                                ),
                                child: LinearProgressIndicator(
                                  minHeight: 8,
                                  value: math((snapshot.data! / (uploadList.length - 1)).toString()),
                                  semanticsLabel: 'Linear',
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )),
                          Text('${(snapshot.data ?? 0.0) + 1} / ${uploadList.length}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
          future: future,
        );
        return child;
      },
      transitionDuration: const Duration(milliseconds: 300), // DURATION FOR ANIMATION
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Text('');
      },
    );
  }

  static Future<void> showLoadingAnimation({
    required BuildContext contextDialog,
    String title = 'Basic dialog title',
    String content = 'Basic dialog content',
    List<Widget>? actions,
    Widget? contentWidget,
  }) async {
    StreamController<double> stream = StreamController();
    late Future<void> future = Future.delayed(Duration(seconds: 10));
    await showGeneralDialog(
      context: contextDialog,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierLabel: 'Label',
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        child = FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) async {
                  await Future.delayed(
                    const Duration(milliseconds: 500),
                    () {
                      if (context.mounted) {
                        dismissPopup(context, complete: () {});
                      }
                    },
                  );
                },
              );
            }
            return Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.3, end: 1.0).animate(animation),
                child: StreamBuilder(
                  stream: stream.stream,
                  initialData: 0.0,
                  builder: (context, snapshot) {
                    return AlertDialog(
                      backgroundColor: Colors.transparent,
                      scrollable: true,
                      content: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: snapshot.data != 1
                                ? Container(
                                    key: ValueKey<int>(0),
                                    padding: EdgeInsets.symmetric(
                                      vertical: DeviceDimension.padding / 2,
                                    ),
                                    child: LoadingAnimationWidget.fourRotatingDots(
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: DeviceDimension.padding / 2,
                                    ),
                                    child: FadeTransition(
                                      key: ValueKey<int>(1),
                                      opacity: Tween<double>(begin: 0.3, end: snapshot.data).animate(animation),
                                      child: ImageHelper.loadFromAsset('assets/icons/ic_popup_success.svg'),
                                    ),
                                  ),
                          ),
                          Text(
                            content,
                            style: context.textStyleBodyMedium.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
          future: future,
        );
        return child;
      },
      transitionDuration: const Duration(milliseconds: 300), // DURATION FOR ANIMATION
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Text('');
      },
    );
  }

  // void _updateHeight(double newHeight) {
  //   setState(() {
  //     _currentHeight = max(0, newHeight);
  //   });
  // }

  static void showCustomModalBottomSheet({
    required BuildContext context,
    required Widget child,
    double initialSize = 0.86,
    Color? backgroundColor,
  }) async {
    // final PageController _pageController = PageController(
    //   viewportFraction: 0.65,
    // );
    double heightBottomSheet = context.mediaQuery.size.height * initialSize;
    double heightDropAction = (6 + DeviceDimension.padding / 4 + DeviceDimension.padding / 2 + 2);
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      content: BlocProvider(
        create: (context) => BottomSheetCubit(BottomSheetState(height: heightBottomSheet)),
        child: BlocBuilder<BottomSheetCubit, BottomSheetState>(
          buildWhen: (previous, current) => previous.height != current.height,
          builder: (context, state) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                heightBottomSheet -= details.primaryDelta ?? 0.0;
                if (heightBottomSheet <= DeviceDimension.appBar) {
                  // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  heightBottomSheet = DeviceDimension.appBar;
                }
                updateHeightBottomSheet(context, heightBottomSheet);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(36 * initialSize), topRight: Radius.circular(36 * initialSize)),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(-2, 1), blurRadius: 1),
                  ],
                ),
                height: state.height ?? heightBottomSheet,
                child: Builder(
                  builder: (context) {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            updateHeightBottomSheet(context, DeviceDimension.appBar);
                            // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: DeviceDimension.padding / 4, bottom: DeviceDimension.padding / 2),
                            child: Container(
                              height: 6,
                              width: context.mediaQuery.size.width / 7,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(3)),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        VMTBottomSheet(heightBottomSheet: (state.height ?? heightBottomSheet) - heightDropAction, child: child),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      duration: Duration(days: 1),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
