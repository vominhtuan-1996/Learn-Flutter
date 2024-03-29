import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/custom_widget/smart_refresh/lib/pull_to_refresh.dart';
import 'package:learnflutter/modules/shimmer/shimmer_utils/shimmer_utils.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_loading_widget.dart';
import 'package:learnflutter/modules/shimmer/widget/shimmer_widget.dart';

class SmartRefreshScreen extends StatefulWidget {
  const SmartRefreshScreen({super.key});
  @override
  State<SmartRefreshScreen> createState() => SmartRefreshScreenState();
}

class SmartRefreshScreenState extends State<SmartRefreshScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshFailed();
    // _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    items.add((items.length + 1).toString());
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: Shimmer(
        linearGradient: ShimmerUtils.shimmerGradient,
        child: SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  items.length,
                  (index) => ShimmerLoading(
                    isLoading: true,
                    child: SizedBox(
                      height: 100,
                      child: Card(
                        child: Center(
                          child: Text(items[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
