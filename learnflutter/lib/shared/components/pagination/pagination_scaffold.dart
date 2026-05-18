import 'package:flutter/material.dart';
import 'pagination_controller.dart';

/// [BasePaginationScaffold] là một Widget khung hỗ trợ hiển thị danh sách dạng phân trang (PageView).
/// Bao gồm 3 phần chính: Header, Content (PageView), và Footer.
class BasePaginationScaffold<T> extends StatefulWidget {
  /// Controller quản lý dữ liệu và trạng thái phân trang
  final PaginationController<T> controller;

  /// Builder cho phần Header, nhận vào chỉ mục hiện tại
  final Widget Function(
    BuildContext context,
    int index,
  ) headerBuilder;

  /// Builder cho từng item trong nội dung chính (PageView)
  final Widget Function(
    BuildContext context,
    T item,
    int index,
  ) contentBuilder;

  /// Builder cho phần Footer, nhận vào chỉ mục hiện tại
  final Widget Function(
    BuildContext context,
    int index,
  ) footerBuilder;

  /// Hướng cuộn của PageView (Mặc định là dọc - Vertical feed)
  final Axis scrollDirection;

  const BasePaginationScaffold({
    super.key,
    required this.controller,
    required this.headerBuilder,
    required this.contentBuilder,
    required this.footerBuilder,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<BasePaginationScaffold<T>> createState() =>
      _BasePaginationScaffoldState<T>();
}

class _BasePaginationScaffoldState<T> extends State<BasePaginationScaffold<T>> {
  @override
  void initState() {
    super.initState();
    // Gắn listener và bắt đầu tải dữ liệu lần đầu
    widget.controller.attach();
    widget.controller.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final current = widget.controller.currentIndex;

        return Column(
          children: [
            // HEADER: Thường dùng để hiển thị tiêu đề, tabs hoặc trạng thái thu gọn
            widget.headerBuilder(
              context,
              current,
            ),

            // CONTENT: Nội dung chính sử dụng PageView.builder để tối ưu hiệu năng
            Expanded(
              child: PageView.builder(
                scrollDirection: widget.scrollDirection,
                controller: widget.controller.pageController,
                itemCount: widget.controller.items.length,
                itemBuilder: (context, index) {
                  final item = widget.controller.items[index];

                  return widget.contentBuilder(
                    context,
                    item,
                    index,
                  );
                },
              ),
            ),

            // FOOTER: Thường dùng để hiển thị chỉ báo trang (indicator) hoặc các nút hành động
            widget.footerBuilder(
              context,
              current,
            ),
          ],
        );
      },
    );
  }
}
