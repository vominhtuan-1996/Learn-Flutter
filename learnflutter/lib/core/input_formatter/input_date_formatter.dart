import 'package:flutter/services.dart';
import 'package:learnflutter/src/extension.dart';

class DateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > oldValue.text.length && newValue.text.isNotEmpty && oldValue.text.isNotEmpty) {
      if (RegExp('[^0-9/]').hasMatch(newValue.text)) return oldValue;
      if (newValue.text.length > 10) return oldValue;
      if (newValue.text.length == 2 || newValue.text.length == 5) {
        String mount = newValue.text.substring(2).replaceAll('/', '');
        if (mount.isNotEmpty) {
          if (mount.toInt < 13) {
            return TextEditingValue(
              text: '${newValue.text}/',
              selection: TextSelection.collapsed(
                offset: newValue.selection.end + 1,
              ),
            );
          } else {
            return TextEditingValue(
              text: oldValue.text,
            );
          }
        } else {
          if (newValue.text.toInt < 32) {
            return TextEditingValue(
              text: '${newValue.text}/',
              selection: TextSelection.collapsed(
                offset: newValue.selection.end + 1,
              ),
            );
          } else {
            return TextEditingValue(
              text: oldValue.text,
            );
          }
        }
      } else if (newValue.text.length == 3 && newValue.text[2] != '/') {
        return TextEditingValue(
          text: '${newValue.text.substring(0, 2)}/${newValue.text.substring(2)}',
          selection: TextSelection.collapsed(
            offset: newValue.selection.end + 1,
          ),
        );
      } else if (newValue.text.length == 6 && newValue.text[5] != '/') {
        return TextEditingValue(
          text: '${newValue.text.substring(0, 5)}/${newValue.text.substring(5)}',
          selection: TextSelection.collapsed(
            offset: newValue.selection.end + 1,
          ),
        );
      } else {
        if (newValue.text[6].toInt < 3) {
          return TextEditingValue(
            text: newValue.text,
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        } else {
          return TextEditingValue(
            text: oldValue.text,
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    } else if (newValue.text.length == 1 && oldValue.text.isEmpty && RegExp('[^0-9]').hasMatch(newValue.text)) {
      return oldValue;
    }
    return newValue;
  }
}
