import 'package:flutter/cupertino.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';

mixin ComponentMaterialDetail {
  Widget headerContentView({required BuildContext context, String? title, String? description}) {
    return Container(
        padding: EdgeInsets.all(DeviceDimension.padding),
        color: context.theme.colorScheme.onSecondaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? "",
              style: context.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            Text(
              description ?? "",
              style: context.textTheme.bodyMedium,
            ),
          ],
        ));
  }
}
