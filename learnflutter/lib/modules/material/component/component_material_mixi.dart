import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_loading_widget.dart';

mixin ComponentMaterialDetail {
  Widget headerContentView({required BuildContext context, String? title, String? description}) {
    return Container(
        padding: EdgeInsets.all(DeviceDimension.padding),
        color: context.theme.colorScheme.onSecondaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoading(
              isLoading: true,
              child: Container(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    title ?? "",
                    style: context.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: DeviceDimension.padding,
            ),
            ShimmerLoading(
              isLoading: true,
              child: Container(
                color: Colors.black,
                child: Text(
                  description ?? "",
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ));
  }
}
