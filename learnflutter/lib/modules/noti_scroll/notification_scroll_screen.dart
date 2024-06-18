import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';

class NotificationScrollScreen extends StatefulWidget {
  NotificationScrollScreen({super.key});
  final _scrollController = ScrollController();
  @override
  State<NotificationScrollScreen> createState() => _NotificationScrollScreenState();
}

class _NotificationScrollScreenState extends State<NotificationScrollScreen> {
  void _scrollToTop() {
    widget._scrollController.animateTo(
      0.0, // Vị trí đầu danh sách
      duration: Duration(milliseconds: 500), // Thời gian cuộn
      curve: Curves.easeInOut, // Hiệu ứng cuộn
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollStartNotification) {
                // ... Xử lý khi bắt đầu cuộn
                print('start');
              } else if (scrollNotification is ScrollUpdateNotification) {
                if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                  _scrollToTop();
                }
                // ... Xử lý khi đang cuộn
                print('doing');
              } else if (scrollNotification is ScrollEndNotification) {
                // ... Xử lý khi kết thúc cuộn
                print('end');
              }
              return true;
            },
            child: ListView.builder(
              controller: widget._scrollController,
              itemBuilder: (context, index) {
                return Container(
                  child: Text(index.toString()),
                );
              },
              itemCount: 500,
            ),
          );
        },
      ),
    );
    ;
  }
}
