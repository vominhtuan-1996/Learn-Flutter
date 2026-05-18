import 'package:flutter/material.dart';

/// [PaginationController] quản lý trạng thái phân trang cho danh sách dữ liệu kiểu [T].
/// Hỗ trợ điều khiển [PageController], quản lý danh sách items, trạng thái loading và tự động load thêm dữ liệu.
class PaginationController<T> extends ChangeNotifier {
  /// Danh sách các item đã load
  final items = <T>[];

  /// Điều khiển PageView
  final PageController pageController = PageController();

  /// Chỉ mục trang hiện tại
  int currentIndex = 0;

  /// Trạng thái đang tải dữ liệu
  bool loading = false;

  /// Trạng thái còn dữ liệu để tải hay không
  bool hasMore = true;

  /// Callback để thực hiện tải dữ liệu từ API hoặc Local
  final Future<List<T>> Function(int page) onLoad;

  PaginationController({
    required this.onLoad,
  });

  /// Hàm tải thêm dữ liệu
  Future<void> loadMore() async {
    if (loading || !hasMore) return;

    loading = true;
    notifyListeners();

    try {
      final result = await onLoad(currentIndex);

      if (result.isEmpty) {
        hasMore = false;
      } else {
        items.addAll(result);
      }
    } catch (e) {
      debugPrint('PaginationController Error: $e');
      hasMore = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Gắn listener vào PageController để theo dõi sự kiện cuộn
  void attach() {
    pageController.addListener(_onScroll);
  }

  /// Xử lý sự kiện cuộn để xác định khi nào cần load thêm
  void _onScroll() {
    if (!pageController.hasClients) return;
    
    final page = pageController.page ?? 0;
    currentIndex = page.round();

    // Tự động load trước khi đến 2 item cuối cùng (Preload)
    if (page >= items.length - 2) {
      loadMore();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
