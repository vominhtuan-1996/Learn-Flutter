import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/base_loading_screen/state/base_loading_state.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/helpper/utills_helpper.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/matix/matix_screen.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

class PageLoadingScreen extends StatefulWidget {
  PageLoadingScreen({
    super.key,
    this.isVisible = true,
    this.message = 'Loading...Loading...Loading...',
    this.styleMessage = const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
  });
  bool isVisible;
  String message;
  TextStyle? styleMessage;
  @override
  State<PageLoadingScreen> createState() => _PageLoadingScreenState();
}

class _PageLoadingScreenState extends State<PageLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BaseLoadingCubit>(
      create: (context) => BaseLoadingCubit(BaseLoadingState(isLoading: true)),
      child: BlocBuilder<BaseLoadingCubit, BaseLoadingState>(
        builder: (context, state) {
          return BaseLoading(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Đang cập nhật dữ liệu',
                style: context.textTheme.headlineMedium,
                overflow: TextOverflow.clip,
              ),
            ),
            isLoading: state.isLoading ?? false,
            message: state.message,
            child: Center(
              child: ElevatedButton(
                  onPressed: () {
                    context.read<BaseLoadingCubit>().showLoading();
                  },
                  child: Text('Loading')),
            ),
          );
        },
      ),
    );
  }
}
