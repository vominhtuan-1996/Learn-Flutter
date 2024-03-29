import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/base_loading_screen/state/base_loading_state.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
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
              loadingCubit.showLoading();
            },
            child: const Text('Loading')),
      ),
    );
  }
}
