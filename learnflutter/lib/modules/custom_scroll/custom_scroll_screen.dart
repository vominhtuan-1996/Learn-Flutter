import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/src/app_colors.dart';
import 'package:learnflutter/src/extension.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

class CustomScrollScreen extends StatefulWidget {
  const CustomScrollScreen({super.key});
  @override
  State<CustomScrollScreen> createState() => CustomScrollScreenState();
}

class CustomScrollScreenState extends State<CustomScrollScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      isLoading: false,
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: CustomSliverPersistentHeaderDelegate()
              ..setMaxExtent(context.mediaQuery.size.height / 10)
              ..setMinExtent(0),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: List.generate(30, (index) {
                return Container(
                  height: 40,
                  width: context.mediaQuery.size.width,
                  color: Colors.amberAccent[100 * (index % 9)], // Colors.amberAccent.withOpacity(1 - (index / 100)),
                  child: Text(index.toString()),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(builder: (_, constraints) {
      final t = shrinkOffset / maxExtent;
      final width = constraints.maxWidth;
      final itemMaxWidth = width;
      // print(lerpDouble(itemMaxWidth, itemMaxWidth * .3, t));
      // double scaleText = lerpDouble(itemMaxWidth, itemMaxWidth * .3, t) ?? 1;
      double xFactor = -.4;
      return SizedBox(
        height: maxExtent,
        child: Align(
          alignment: Alignment.lerp(Alignment.centerLeft, Alignment(xFactor, .0), t)!..x,
          child: buildRow(
            itemMaxHeight: maxExtent,
            itemMaxWidth: itemMaxWidth,
            t: t,
            child: Text(
              'CustomSliverPersistent',
              style: context.textTheme.headlineLarge,
            ),
          ),
        ),
      );
      // return SizedBox(
      //   height: maxExtent,
      //   child: SingleChildScrollView(
      //     child: Column(
      //       children: List.generate(50, (index) {
      //         return Container(
      //           width: double.infinity,
      //           child: Align(
      //             alignment: Alignment.lerp(Alignment.center, Alignment(xFactor, -.2), t)!..x,
      //             child: buildRow(color: Colors.red[100 * (index % 9)] ?? Colors.blue, itemMaxWidth: itemMaxWidth, t: t),
      //           ),
      //         );
      //       }),
      //     ),
      //   ),
      // );
      // return ColoredBox(
      //   color: Colors.cyanAccent.withOpacity(.3),
      //   child: Stack(
      //     children: [
      //       Align(
      //         alignment: Alignment.lerp(Alignment.center, Alignment(xFactor, -.2), t)!..x,
      //         child: buildRow(color: Colors.black, itemMaxWidth: itemMaxWidth, t: t),
      //       ),
      //       Align(
      //         alignment: Alignment.lerp(Alignment.centerRight, Alignment(xFactor, -1), t)!,
      //         child: buildRow(color: Colors.red, itemMaxWidth: itemMaxWidth, t: t),
      //       ),
      //       Align(
      //         alignment: Alignment.lerp(Alignment.centerLeft, Alignment(xFactor, -.30), t)!,
      //         child: buildRow(color: Colors.amber, itemMaxWidth: itemMaxWidth, t: t),
      //       ),
      //       // Align(
      //       //   alignment: Alignment.lerp(Alignment.centerLeft, Alignment(xFactor, .1), t)!,
      //       //   child: buildRow(color: Colors.greenAccent, itemMaxWidth: itemMaxWidth, t: t),
      //       // ),
      //       Align(
      //         alignment: Alignment.lerp(Alignment.centerLeft, Alignment(xFactor, .2), t)!,
      //         child: buildRow(color: Colors.deepPurple, itemMaxWidth: itemMaxWidth, t: t),
      //       ),
      //     ],
      //   ),
      // );
    });
  }

  Container buildRow({required double itemMaxWidth, required double itemMaxHeight, required double t, required Widget child}) {
    return Container(
      width: lerpDouble(itemMaxWidth, itemMaxWidth * .3, t),
      height: lerpDouble(itemMaxHeight, itemMaxHeight * .3, t),
      child: child,
    );
  }

  void setMaxExtent(double max) {
    maxExtent = max;
  }

  void setMinExtent(double min) {
    minExtent = min;
  }

  @override
  double maxExtent = 0;

  @override
  double minExtent = 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
