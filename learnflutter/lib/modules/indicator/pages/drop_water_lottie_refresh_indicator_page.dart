import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/indicator/extendsion/drop_water_lottie_refresh_indicator.dart';
import 'package:learnflutter/modules/indicator/extendsion/fetch_more_indicator.dart';
import 'package:learnflutter/modules/indicator/widget/example_list.dart';

class DropWaterLottieRefreshIndicatorPage extends StatefulWidget {
  const DropWaterLottieRefreshIndicatorPage({super.key});

  @override
  State<DropWaterLottieRefreshIndicatorPage> createState() => _DropWaterLottieRefreshIndicatorPageState();
}

class _DropWaterLottieRefreshIndicatorPageState extends State<DropWaterLottieRefreshIndicatorPage> {
  int _itemsCount = 10;

  Future<void> _fetchMore() async {
    // Simulate fetch time
    await Future<void>.delayed(const Duration(seconds: 2));
    // make sure that the widget is still mounted.
    if (!mounted) return;
    // Add more fake elements
    setState(() {
      _itemsCount += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: DropWaterLottieRefreshIndicator(
        lottieAsset: 'assets/lottie/refresh_water_drop.json',
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2));
        },
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
        ),
      ),
    );
  }
}
