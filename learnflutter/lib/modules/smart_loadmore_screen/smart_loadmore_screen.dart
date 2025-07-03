import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/smart_loadmore/smart_loadmore_list.dart';
import 'package:learnflutter/custom_widget/smart_refresh/lib/src/indicator/waterdrop_header.dart';
import 'package:learnflutter/custom_widget/smart_refresh/lib/src/smart_refresher.dart';

class SmartLoadmoreScreen extends StatelessWidget {
  SmartLoadmoreScreen({super.key});
  RefreshController _refreshController = RefreshController(initialRefresh: true);

  Future<List<String>> fetchItems(int offset, int limit) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate network
    return List.generate(limit, (i) => 'Item ${offset + i}');
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        header: WaterDropHeader(),
        onRefresh: () async {
          fetchItems(0, 0);
        },
        child: SmartLoadMoreList<String>(
          fetchItems: fetchItems,
          itemBuilder: (context, item, index) => ListTile(title: Text(item)).animate(),
        ),
        onLoading: () async {
          //monitor fetch data from network
          await Future.delayed(Duration(milliseconds: 1000));

          _refreshController.loadComplete();
        },
      ),
    );
  }
}
