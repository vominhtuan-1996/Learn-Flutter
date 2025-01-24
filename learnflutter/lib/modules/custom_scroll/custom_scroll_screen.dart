import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

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
              ..setMaxExtent(context.mediaQuery.size.height / 4)
              ..setMinExtent(0)
              ..setChild(
                Text(
                  'class CustomSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate',
                  style: context.textTheme.headlineLarge,
                ),
              ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: List.generate(30, (index) {
                return Container(
                  height: 40,
                  width: context.mediaQuery.size.width,
                  color: Colors.primaries[index % Colors.primaries.length],
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
            child: child,
          ),
        ),
      );
    });
  }

  SizedBox buildRow({required double itemMaxWidth, required double itemMaxHeight, required double t, required Widget child}) {
    return SizedBox(
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

  void setChild(Widget newChild) {
    child = newChild;
  }

  Widget child = Container();

  @override
  double maxExtent = 0;

  @override
  double minExtent = 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
