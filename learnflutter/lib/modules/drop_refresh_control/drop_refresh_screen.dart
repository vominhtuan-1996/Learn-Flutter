import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/custom_widget/refresh_control.dart/refresh_drop_control.dart';

class DropRefreshScreen extends StatelessWidget {
  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 2)); // mô phỏng load data
  }

  late ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: Stack(
        children: [
          DropWaterRefresh(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              itemCount: 300,
              itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              shape: CircleBorder(),
              onPressed: () {
                _scrollController.animateTo(0.0,
                    duration: Duration(milliseconds: 600),
                    curve: Curves.decelerate); // Cuộn lên đầu danh sách
              },
              child: Icon(Icons.arrow_upward_outlined, size: 30, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
