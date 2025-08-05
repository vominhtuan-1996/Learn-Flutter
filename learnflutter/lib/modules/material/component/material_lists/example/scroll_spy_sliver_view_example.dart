import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/scroll_spy_sliver_view.dart';

class ScrollSpySliverViewExample extends StatelessWidget {
  const ScrollSpySliverViewExample();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scroll Spy Sliver View Example"),
      ),
      body: ScrollSpySliverView(
        sections: [
          ScrollSpySection(
            title: "Giới thiệu",
            content: Text("Nội dung giới thiệu...\n" * 5),
          ),
          ScrollSpySection(
            title: "Tính năng",
            content: Text("Chi tiết tính năng...\n" * 8),
          ),
          ScrollSpySection(
            title: "Đánh giá",
            content: Text("Khách hàng đánh giá...\n" * 6),
          ),
          ScrollSpySection(
            title: "Giá cả",
            content: Text("Bảng giá sản phẩm...\n" * 5),
          ),
        ],
      ),
    );
  }
}
