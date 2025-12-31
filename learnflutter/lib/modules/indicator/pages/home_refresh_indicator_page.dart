import 'dart:async';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/indicator/extendsion/home_refresh_indicator.dart';
import 'package:learnflutter/modules/loadmore/extension/pullup_loadmore_wrapper.dart';

class HomeRefreshIndicatorPage extends StatefulWidget {
  final IndicatorController? controller;

  const HomeRefreshIndicatorPage({
    super.key,
    this.controller,
  });

  @override
  State<HomeRefreshIndicatorPage> createState() => _HomeRefreshIndicatorPageState();
}

class _HomeRefreshIndicatorPageState extends State<HomeRefreshIndicatorPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  List<int> listGenarate = List.generate(30, (i) => i).toList();
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: HomeRefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 6));
          },
          indicatorHeight: 40,
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(listGenarate.length, (i) => ListTile(title: Text('Item $i'))),
            ),
          )
          // PullUpLoadMoreWrapper(
          //   hasMore: true,
          //   onLoadMore: () {
          //     listGenarate.addAll(List.generate(listGenarate.length, (i) => i));
          //     return Future<void>.delayed(const Duration(seconds: 2));
          //   },
          //   children: List.generate(listGenarate.length, (i) => ListTile(title: Text('Item $i'))),
          // ),
          ),
    );
  }
}
