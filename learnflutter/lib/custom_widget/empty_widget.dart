import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_assets.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/custom_widget/app_text.dart';
import 'package:learnflutter/core/utils/image_helper.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ImageHelper.loadFromAsset(AppAssets.icEmpty),
        AppText(message ?? 'Không tìm thấy kết quả phù hợp',
            color: getThemeBloc(context).state.tokens.colors.onSurface),
      ],
    );
  }
}
