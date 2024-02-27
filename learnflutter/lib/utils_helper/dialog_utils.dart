import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2021),
          lastDate: DateTime(2022),
        );
      },
    );
  }

  static Future<void> showDatimePicker({void Function(DateTime?)? onComplete}) async {
    final RestorableDateTime _selectedDate = RestorableDateTime(DateTime(2021, 7, 25));
    late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
      onComplete: onComplete,
      onPresent: (NavigatorState navigator, Object? arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: _selectedDate.value.millisecondsSinceEpoch,
        );
      },
    );
    _restorableDatePickerRouteFuture.present();
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

  static dismissPopup(BuildContext context) {
    UtilsHelper.pop(context);
  }

  static Future<void> showActionSheet({
    required BuildContext context,
    String title = 'Thông báo',
    Widget content = const Text('Nothing'),
    String titleCancleAction = 'Cancle',
  }) async {
    showCupertinoModalPopup<void>(
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
          // actions: <CupertinoActionSheetAction>[
          //   CupertinoActionSheetAction(
          //     /// This parameter indicates the action would be a default
          //     /// default behavior, turns the action's text to bold text.
          //     isDefaultAction: true,
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: const Text('Default Action'),
          //   ),
          //   CupertinoActionSheetAction(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: const Text('Action'),
          //   ),
          //   CupertinoActionSheetAction(
          //     /// This parameter indicates the action would perform
          //     /// a destructive action such as delete or exit and turns
          //     /// the action's text color to red.
          //     isDestructiveAction: true,
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: const Text('Destructive Action'),
          //   ),
          // ],
        ),
      ),
    );
  }
}
