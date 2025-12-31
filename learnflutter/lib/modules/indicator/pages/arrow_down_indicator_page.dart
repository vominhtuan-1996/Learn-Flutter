import 'dart:async';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/indicator/extendsion/arrow_down_refresh_Indicator.dart';

class ArrowDownIndicatorPage extends StatefulWidget {
  final IndicatorController? controller;

  const ArrowDownIndicatorPage({
    super.key,
    this.controller,
  });

  @override
  State<ArrowDownIndicatorPage> createState() => _ArrowDownIndicatorPageState();
}

class _ArrowDownIndicatorPageState extends State<ArrowDownIndicatorPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: ArrowRefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
        },
        sizeArrowDown: Size(48, 48),
        arrowColor: Colors.grey,
        indicatorHeight: 40,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 30,
          itemBuilder: (_, index) => ListTile(title: Text("Item $index")),
        ),
      ),
    );
  }
}
