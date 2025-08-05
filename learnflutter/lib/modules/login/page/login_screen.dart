import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/sliver_appbar/notification_handler.dart';
import 'package:learnflutter/custom_widget/sliver_appbar_delegate.dart';

class LoginScreenTemp extends StatefulWidget {
  const LoginScreenTemp({super.key});

  @override
  State<LoginScreenTemp> createState() => _LoginScreenTempState();
}

class _LoginScreenTempState extends State<LoginScreenTemp> {
  bool isLoading = true;
  late double minExtent;
  late double maxExtent;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    minExtent = kToolbarHeight + MediaQuery.paddingOf(context).top;
    maxExtent = Platform.isAndroid ? 216 : 356;
    maxExtent = maxExtent - 40;
    return BaseLoading(
      child: AppBarScrollHandler(
        minExtent: minExtent,
        maxExtent: maxExtent,
        controller: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverAppBarDelegate(
                minExtent: minExtent,
                maxExtent: maxExtent,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                  height: 750,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        DeviceDimension.horizontalSize(50),
                      ),
                    ),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text('cc'),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
