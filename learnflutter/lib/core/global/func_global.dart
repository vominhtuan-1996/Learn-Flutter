import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/component/bottom_sheet/cubit/bottom_sheet_cubit.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';
import 'package:path_provider/path_provider.dart';

SettingThemeCubit getThemeBloc(BuildContext context) {
  return BlocProvider.of<SettingThemeCubit>(context);
}

BaseLoadingCubit getLoadingCubit(BuildContext context) {
  return BlocProvider.of<BaseLoadingCubit>(context);
}

BottomSheetCubit getBottomSheetCubit(BuildContext context) {
  return BlocProvider.of<BottomSheetCubit>(context);
}

void showLoading({BuildContext? context, String? message}) {
  getLoadingCubit(context ?? UtilsHelper.navigatorKey.currentContext!).showLoading(
    message: message,
    func: () {
      print('object');
    },
  );
}

void dismissLoading(BuildContext? context) {
  getLoadingCubit(context!).dissmissLoading();
}

void updateHeightBottomSheet(BuildContext? context, double? newHeight) {
  getBottomSheetCubit(context!).updateHeight(newHeight: newHeight);
}

Future<String> downLoadFolder() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/DownLoadFile'; // 3
  Directory(filePath).create(recursive: true).then(
    (value) {
      print(value.path);
    },
  );
  return filePath;
}

dynamic math(expression) {
  if (!isValidMathExpression(expression)) {
    throw FormatException("Phép tính không hợp lệ");
  }
  return _evaluateExpression(expression);
}

bool isValidMathExpression(dynamic expression) {
  // Convert the expression to a string if it is not already
  String expr = expression.toString();

  // Regular expression to check for valid characters and structure
  final validCharacters = RegExp(r'^[0-9+\-*/().\s]+$');
  if (!validCharacters.hasMatch(expr)) {
    return false;
  }

  // Check for balanced parentheses
  int parenthesesCount = 0;
  for (int i = 0; i < expr.length; i++) {
    if (expr[i] == '(') {
      parenthesesCount++;
    } else if (expr[i] == ')') {
      parenthesesCount--;
      if (parenthesesCount < 0) {
        return false;
      }
    }
  }
  if (parenthesesCount != 0) {
    return false;
  }

  // Check for division by zero
  try {
    double result = _evaluateExpression(expr);
    if (result.isInfinite || result.isNaN) {
      return false;
    }
  } catch (e) {
    return false;
  }

  return true;
}

double _evaluateExpression(String expression) {
  // Remove spaces
  expression = expression.replaceAll(' ', '');

  // Handle parentheses
  while (expression.contains('(')) {
    int start = expression.lastIndexOf('(');
    int end = expression.indexOf(')', start);
    if (end == -1) {
      throw FormatException("Unmatched parentheses");
    }
    String subExpression = expression.substring(start + 1, end);
    double subResult = _evaluateExpression(subExpression);
    expression = expression.replaceRange(start, end + 1, subResult.toString());
  }

  // Evaluate multiplication and division
  final mulDivPattern = RegExp(r'(\d+(\.\d+)?)([*/])(\d+(\.\d+)?)');
  while (mulDivPattern.hasMatch(expression)) {
    expression = expression.replaceAllMapped(mulDivPattern, (match) {
      double left = double.parse(match.group(1)!);
      String operator = match.group(3)!;
      double right = double.parse(match.group(4)!);
      double result;
      if (operator == '*') {
        result = left * right;
      } else {
        if (right == 0) {
          throw FormatException("Division by zero");
        }
        result = left / right;
      }
      return result.toString();
    });
  }

  // Evaluate addition and subtraction
  final addSubPattern = RegExp(r'(\d+(\.\d+)?)([+\-])(\d+(\.\d+)?)');
  while (addSubPattern.hasMatch(expression)) {
    expression = expression.replaceAllMapped(addSubPattern, (match) {
      double left = double.parse(match.group(1)!);
      String operator = match.group(3)!;
      double right = double.parse(match.group(4)!);
      double result;
      if (operator == '+') {
        result = left + right;
      } else {
        result = left - right;
      }
      return result.toString();
    });
  }

  return double.parse(expression);
}
