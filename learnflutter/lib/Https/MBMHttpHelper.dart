// ignore_for_file: file_names, prefer_typing_uninitialized_variables, unused_local_variable, non_constant_identifier_names, avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:learnflutter/Menu/Model/ModelMenu.dart';

final dio = Dio();
void configureDio() {
  // Set default configs
  dio.options.baseUrl = 'https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/file%20(4).json';
  dio.options.connectTimeout = const Duration(seconds: 5);
  dio.options.receiveTimeout = const Duration(seconds: 3);

  // Or create `Dio` with a `BaseOptions` instance.
  final options = BaseOptions(
    baseUrl: 'https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/file%20(4).json',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  );
  final anotherDio = Dio(options);
}

Future<Result> handleDataResponseResult(Map<String, dynamic> json) async {
  Map<String, dynamic> result = json['responseResult'];
  var res = Result.fromJson(result);
  return res;
}

class ResponseResult {
  var responseResult;
  ResponseResult({
    required responseResult,
  });

  factory ResponseResult.fromJson(Map<String, dynamic> json) {
    return ResponseResult(responseResult: json['responseResult']);
  }
}

class Result {
  var errorCode;
  var message;
  Map<String, dynamic> result;
  Result({required this.errorCode, required this.message, required this.result});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(errorCode: json['errorCode'], message: json['message'], result: json['result']);
  }
}

Future<ModelMenu> getHttp() async {
  var menuModel;
  final response = await dio.get('https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/menus_json.json');
  if (response.statusCode == 200) {
    var menus;
    await handleDataResponseResult(jsonDecode(response.data)).then((value) => {
          if (value.errorCode == 0) {menus = ModelMenu.fromJson((value.result))}
        });
    return menus;
  }
  return menuModel;
}

Future<List> getListCategories() async {
  var menuModel;
  final response = await dio.get('https://raw.githubusercontent.com/vominhtuan-1996/APITest/main/menu_flutter/menus_json.json');
  if (response.statusCode == 200) {
    var menus;
    await handleDataResponseResult(jsonDecode(response.data)).then((value) => {
          if (value.errorCode == 0) {menus = ModelMenu.fromJson((value.result))}
        });
    return menus.categories;
  }
  return menuModel.categories;
}

Future<dynamic> postdataTelegram(String message) async {
  final body = {
    "chat_id": "-720215949",
    "text": message,
  };
  final response = await dio.post('https://api.telegram.org/bot5296962866:AAEhBcpidAR1Fs2autI86D2Eff7fmwPI3ZI/sendMessage', data: body);
  return response;
}
