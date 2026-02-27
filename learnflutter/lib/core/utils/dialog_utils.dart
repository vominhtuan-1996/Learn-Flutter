import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/shared/widgets/bottom_sheet/cubit/bottom_sheet_cubit.dart';
import 'package:learnflutter/shared/widgets/bottom_sheet/page/bottom_sheet.dart';
import 'package:learnflutter/shared/widgets/bottom_sheet/state/bottom_sheet_state.dart';
import 'package:learnflutter/features/scroll_physic/extension/scroll_physics/nobounce_scroll_physics.dart';
import 'package:learnflutter/core/debound.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/features/material/component/metarial_radio_button/radio_item_model.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/shared/widgets/keyboard_avoiding.dart';
import 'package:learnflutter/core/utils/image_helper.dart';
import 'package:learnflutter/core/utils/utils_helper.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

/// TypeDialog định nghĩa các loại hộp thoại thông báo khác nhau trong hệ thống.
/// Mỗi loại sẽ gắn liền với một biểu tượng và màu sắc đặc trưng để người dùng dễ dàng nhận diện tính chất của thông báo.
enum TypeDialog {
  none,
  error,
  warning,
  success,
  custom,
}

/// DialogUtils chứa tập hợp các hàm tiện ích để hiển thị các loại hộp thoại, thông báo dưới và trang tính hành động.
/// Mục tiêu của lớp này là chuẩn hóa giao diện người dùng cho các thông báo và tương tác tạm thời.
class DialogUtils {
  DialogUtils._();

  /// Trả về widget biểu tượng phản ánh đúng loại hộp thoại được chọn.
  static Widget widgetIconsDialogWithType(TypeDialog type) {
    Widget temp = Container();
    switch (type) {
      case TypeDialog.error:
        temp = const Icon(Icons.error, color: Colors.red);
        break;
      case TypeDialog.warning:
        temp = const Icon(Icons.warning, color: Colors.orange);
        break;
      case TypeDialog.success:
        temp = const Icon(Icons.check_circle, color: Colors.green);
        break;
      case TypeDialog.custom:
      case TypeDialog.none:
        temp = const SizedBox.shrink();
        break;
    }
    return temp;
  }

  /// Khởi tạo widget nội dung dựa trên loại hộp thoại hoặc sử dụng widget tùy chỉnh được cung cấp.
  static Widget widgetContentDialogWithType({TypeDialog type = TypeDialog.custom, String? content, Widget? contentWidget}) {
    if (type == TypeDialog.custom) {
      return contentWidget ?? const SizedBox.shrink();
    }
    return Text(content ?? '', textAlign: TextAlign.center);
  }

  /// Xây dựng một hộp thoại cảnh báo cơ bản với tiêu đề, nội dung và các nút hành động.
  /// Phương thức này hỗ trợ việc hiển thị nhanh các thông báo lỗi, thành công hoặc cảnh báo chuẩn hóa.
  static Future<void> dialogBuilder({
    required BuildContext context,
    TypeDialog type = TypeDialog.none,
    String title = 'Thông báo',
    String content = '',
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
        );
      },
    );
  }

  /// Hiển thị một hộp thoại cơ bản với hiệu ứng thu phóng (ScaleTransition).
  /// Phương thức này sử dụng showGeneralDialog để có toàn quyền kiểm soát hiệu ứng và lớp phủ.
  static Future<void> showBasicDialog({
    required BuildContext context,
    String title = 'Thông báo',
    String content = '',
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
              scrollable: true,
              content: Column(
                children: [Text(content), contentWidget ?? Container()],
              ),
              actions: actions ??
                  <Widget>[
                    TextButton(
                      onPressed: () => dismissPopup(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => dismissPopup(context),
                      child: const Text('Xác nhận'),
                    ),
                  ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    );
  }

  /// Hiển thị một hộp thoại toàn màn hình (Full Dialog) hỗ trợ nội dung tùy chỉnh và các nút hành động.
  /// Tương tự như showBasicDialog, nó cung cấp một lớp phủ mờ và hiệu ứng xuất hiện mượt mà.
  static Future<void> showFullDialog({
    required BuildContext context,
    String title = 'Thông báo',
    String content = '',
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
              scrollable: true,
              content: Column(
                children: [contentWidget ?? Container()],
              ),
              actions: actions,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    );
  }

  /// Hiển thị hộp thoại với biểu tượng đặc trưng (Error, Success, Warning) ở phía trên tiêu đề.
  /// Kiểu này đặc biệt hiệu quả để gây chú ý của người dùng vào trạng thái quan trọng của hành động.
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
                  onPressed: () => dismissPopup(context),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => dismissPopup(context),
                  child: const Text('Đồng ý'),
                ),
              ],
        );
      },
    );
  }

  /// Đóng bất kỳ lớp phủ nào đang hiển thị (hộp thoại hoặc snackbar) và thực thi callback sau khi đóng.
  /// Nó tự động xử lý việc ẩn các thông báo Snackbar đang hiển thị để tránh xung đột giao diện.
  static dismissPopup(
    BuildContext context, {
    Function()? complete,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
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

  /// Cập nhật kích thước (thường là chiều cao) của một thành phần giao diện thông qua StreamController.
  static void updateHeight(double height, StreamController stream) {
    stream.sink.add(height);
  }

  /// Hiển thị một BottomSheet tùy chỉnh với khả năng thay đổi chiều cao động thông qua thao tác kéo.
  /// Nó sử dụng StreamBuilder để cập nhật giao diện ngay lập tức khi người dùng thực hiện hành động kéo lên/xuống.
  static Future<void> showBottomSheet({
    required BuildContext context,
    double elevation = 0,
    Color? color,
    double height = 300,
    double? width,
    Widget contentWidget = const Center(
      child: Text('Không có nội dung'),
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
                    onTap: () => Navigator.pop(context),
                    onHorizontalDragUpdate: (details) {
                      debugPrint(details.globalPosition.dx.toString());
                    },
                    onVerticalDragUpdate: (details) {
                      position = context.mediaQuery.size.height - details.globalPosition.dy;
                      if (position <= 35.0) {
                        Navigator.pop(context);
                      } else {
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

  /// Mở một DraggableScrollableSheet có thể kéo dãn để xem thêm nội dung.
  /// Rất phù hợp cho các danh sách dài hoặc các biểu mẫu cần nhiều không gian hiển thị linh hoạt.
  static Future<void> openDraggableBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    Color backgroundColor = Colors.white,

    /// Tỉ lệ chiều cao tối thiểu so với màn hình
    double minSize = 0.1,

    /// Tỉ lệ chiều cao tối đa so với màn hình
    double maxSize = 0.9,

    /// Tỉ lệ chiều cao ban đầu khi vừa hiển thị
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
        duration: const Duration(milliseconds: 300),
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
                physics: const NoBounceScrollPhysics(),
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

  /// Hiển thị một ActionSheet phong cách iOS cho người dùng chọn lựa các hành động nhanh.
  /// Nó tích hợp khả năng tránh bàn phím (KeyboardAvoiding) để đảm bảo giao diện luôn hiển thị rõ ràng.
  static Future<void> showActionSheet({
    required BuildContext context,
    String title = 'Thông báo',
    Widget content = const Text('Không có nội dung'),
    String titleCancleAction = 'Hủy',
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
            onPressed: () => Navigator.pop(context),
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

  /// Đường dẫn thư mục tải tệp xuống mặc định của ứng dụng.
  /// Nó tạo một thư mục 'DownLoadFile' bên trong bộ nhớ đệm (cache) để lưu trữ các tệp tạm thời.
  Future<String> downLoadFolder() async {
    Directory appDocumentsDirectory = await getApplicationCacheDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/DownLoadFile';
    Directory(filePath).create(recursive: true).then(
      (value) {
        debugPrint(value.path);
      },
    );
    return filePath;
  }

  /// Hiển thị hộp thoại theo dõi tiến trình tải tệp xuống.
  /// Nó bao gồm một thanh tiến trình vòng tròn và con số phần trăm, tự động mở tệp khi quá trình hoàn tất.
  static Future<void> showDownload({
    required BuildContext contextDialog,
    String title = 'Đang tải tệp...',
    String content = '',
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
                    const Duration(milliseconds: 500),
                    () {
                      if (context.mounted) {
                        dismissPopup(context, complete: () {
                          if (snapshot.data != null) {
                            OpenFile.open(snapshot.data as String);
                          }
                        });
                      }
                    },
                  );
                },
              );
            }
            return ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: StreamBuilder<double>(
                    stream: stream.stream,
                    initialData: 0.0,
                    builder: (context, snapshot) {
                      final progress = snapshot.data ?? 0.0;
                      final isCompleted = progress == 1.0;

                      return Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isCompleted ? 'Hoàn tất' : title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24.0),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: isCompleted
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 60,
                                      key: ValueKey('completed'),
                                    )
                                  : SizedBox(
                                      key: const ValueKey('progress'),
                                      width: 80,
                                      height: 80,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 8,
                                            backgroundColor: Colors.grey.shade300,
                                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                          ),
                                          Center(
                                            child: Text(
                                              '${(progress * 100).toStringAsFixed(0)}%',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24.0),
                            if (!isCompleted)
                              const Text(
                                'Vui lòng đợi trong giây lát...',
                                style: TextStyle(fontSize: 14),
                              ),
                          ],
                        ),
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
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
    );
  }

  /// Mô phỏng quá trình tải lên danh sách tệp đính kèm.
  /// Phương thức này tạo độ trễ giả lập để minh họa luồng xử lý và báo cáo tiến trình qua Stream.
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

  /// Hiển thị hộp thoại theo dõi tiến trình tải danh sách tệp lên máy chủ.
  /// Nó bao gồm một thanh tiến trình tuyến tính (LinearProgressIndicator) và trạng thái tệp hiện tại đang xử lý.
  static Future<void> showUploadProgress({
    required BuildContext contextDialog,
    required List uploadList,
    required Future<void> Function(StreamController<int> stream) function,
  }) async {
    StreamController<int> stream = StreamController();
    late Future<void> future = function(stream);
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
                        dismissPopup(context);
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
                    final currentIdx = snapshot.data ?? 0;
                    final title = currentIdx < uploadList.length ? (uploadList[currentIdx] as RadioItemModel).title : '';
                    return AlertDialog(
                      icon: Center(
                        child: Text(
                          title,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                      scrollable: true,
                      content: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Container(
                              key: const ValueKey<int>(0),
                              padding: EdgeInsets.symmetric(
                                vertical: DeviceDimension.padding / 2,
                              ),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: uploadList.isEmpty ? 0 : (currentIdx / (uploadList.length - 1)),
                                semanticsLabel: 'Linear',
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Text('${currentIdx + 1} / ${uploadList.length}'),
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
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    );
  }

  /// Hiển thị một cửa sổ hội thoại với hiệu ứng hoạt họa loading tùy chỉnh.
  /// Nó sử dụng bốn dấu chấm xoay (fourRotatingDots) và có thể chuyển sang biểu tượng thành công sau khi hoàn tất.
  static Future<void> showLoadingAnimation({
    required BuildContext contextDialog,
    String title = 'Thông báo',
    String content = 'Đang xử lý...',
    List<Widget>? actions,
    Widget? contentWidget,
  }) async {
    StreamController<double> stream = StreamController();
    late Future<void> future = Future.delayed(const Duration(seconds: 10));
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
                                    key: const ValueKey<int>(0),
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
                                      key: const ValueKey<int>(1),
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
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    );
  }

  // void _updateHeight(double newHeight) {
  //   setState(() {
  //     _currentHeight = max(0, newHeight);
  //   });
  // }

  /// Hiển thị một BottomSheet tùy chỉnh dạng Snackbar, cho phép kéo thả để thay đổi kích thước.
  /// Đây là một cách tiếp cận nâng cao tích hợp Bloc để quản lý trạng thái chiều cao của BottomSheet.
  static void showCustomModalBottomSheet({
    required BuildContext context,
    required Widget child,
    double initialSize = 0.86,
    Color? backgroundColor,
  }) async {
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
                  heightBottomSheet = DeviceDimension.appBar;
                }
                updateHeightBottomSheet(context, heightBottomSheet);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(36 * initialSize), topRight: Radius.circular(36 * initialSize)),
                  border: const Border.symmetric(
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
      duration: const Duration(days: 1),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Hiển thị một thoại chứa nội dung tùy chỉnh với khả năng cấu hình việc đóng khi chạm ra ngoài.
  /// Nó cho phép truyền vào một danh sách các nút hành động (actions) và widget nội dung (contentWidget).
  static Future<void> showContentDialog({
    required BuildContext context,
    List<Widget>? actions,
    Widget? contentWidget,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierLabel: "title",
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.3, end: 1.0).animate(animation),
            child: AlertDialog(
                backgroundColor: AppColors.greyBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(DeviceDimension.padding / 2))),
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                scrollable: true,
                content: Column(
                  children: [contentWidget ?? Container()],
                ),
                actions: actions),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox.shrink(),
    );
  }
}
