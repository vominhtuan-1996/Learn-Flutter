import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_assets.dart';
import 'package:learnflutter/core/utils/extension/extension_string.dart';
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
            color: context.theme.labelColor),
      ],
    );
  }
}
