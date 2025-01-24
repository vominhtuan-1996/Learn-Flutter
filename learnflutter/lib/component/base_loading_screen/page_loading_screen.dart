import 'dart:async';

import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/global/func_global.dart';

class PageLoadingScreen extends StatefulWidget {
  const PageLoadingScreen({
    super.key,
    this.isVisible = true,
    this.message = 'Loading...Loading...Loading...',
    this.styleMessage = const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
  });
  final bool isVisible;
  final String message;
  final TextStyle? styleMessage;
  @override
  State<PageLoadingScreen> createState() => _PageLoadingScreenState();
}

class _PageLoadingScreenState extends State<PageLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final loadingCubit = getLoadingCubit(context);
    return BaseLoading(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Đang cập nhật dữ liệu',
          style: context.textTheme.headlineMedium,
          overflow: TextOverflow.clip,
        ),
      ),
      child: Center(
        child: ElevatedButton(
            onPressed: () {
              loadingCubit.showLoading(
                func: () {
                  print('object');
                },
              );
              Timer(const Duration(seconds: 12), () {
                loadingCubit.dissmissLoading();
              });
            },
            child: const Text('Loading')),
      ),
    );
  }
}
