import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learnflutter/shared/widgets/shimmer/widget/shimmer_loading_widget.dart';

/* ============================================================================
 * 🛠 WIDGET MAINTENANCE RULES & FUTURE DIRECTIONS (Quy tắc bảo trì Widget)
 * ============================================================================
 * 
 * 1. QUẢN LÝ TIMER (Timer Lifecycle Management):
 *    - QUY TẮC: TUYỆT ĐỐI KHÔNG quên cancel `Timer` trong hàm `dispose()`. 
 *      Nếu người dùng thoát màn hình khi danh sách đang load, Timer chạy ngầm 
 *      sẽ gây crash app do gọi `setState` trên một widget đã bị unmount.
 * 
 * 2. KIỂM SOÁT LUỒNG DỮ LIỆU (Data Flow Control):
 *    - QUY TẮC: Khi dữ liệu đầu vào (`fullData`) thay đổi qua `didUpdateWidget`, 
 *      cần cancel timer cũ và reset lại index để tránh việc chèn dữ liệu chồng chéo.
 * 
 * 3. TÙY BIẾN HIỆU ỨNG (Animation Customization):
 *    - ĐỊNH HƯỚO: Bổ sung các tham số `insertionDelay` và `animationCurve` vào 
 *      Constructor để cho phép các màn hình khác nhau có tốc độ xuất hiện khác nhau.
 * 
 * 4. HIỆU NĂNG DANH SÁCH LỚN (Large List Performance):
 *    - CẢNH BÁO: `AnimatedList` phù hợp với danh sách vừa phải. Với hàng nghìn 
 *      phần tử, việc chèn từng mục một sẽ gây áp lực lên Main Thread.
 *    - ĐỊNH HƯỚNG: Sử dụng `SliverAnimatedList` kết hợp với `CustomScrollView` 
 *      để tối ưu hóa bộ nhớ cho các danh sách dài.
 * ============================================================================
 */

typedef ItemBuilder<T> = Widget Function(
    BuildContext context, int index, Animation<double> animation);

class ListViewAnimated<T> extends StatefulWidget {
  const ListViewAnimated({super.key, required this.fullData, this.itemBuilder});
  final List<dynamic> fullData;
  final ItemBuilder<T>? itemBuilder;
  @override
  _ListViewAnimatedState createState() => _ListViewAnimatedState();
}

class _ListViewAnimatedState extends State<ListViewAnimated> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<dynamic> _items = [];
  // final List<String> _fullData = List.generate(10, (i) => 'Item ${i + 1}');
  int _currentIndex = 0;
  Timer? _insertTimer;

  @override
  void initState() {
    super.initState();
    _startInsertingItems();
  }

  @override
  void dispose() {
    _insertTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ListViewAnimated oldWidget) {
    if (widget.fullData != oldWidget.fullData) {
      _insertTimer?.cancel();
      _items.clear();
      _currentIndex = 0;
      _startInsertingItems();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _startInsertingItems() {
    _insertTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentIndex >= widget.fullData.length) {
        timer.cancel();
        return;
      }
      final newItem = widget.fullData[_currentIndex++];
      _items.insert(_currentIndex - 1, newItem);
      _listKey.currentState?.insertItem(_currentIndex - 1);
    });
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0), // Start from right
        end: Offset(0.0, 0.0), // Slide to normal
      ).animate(CurvedAnimation(parent: animation, curve: Curves.decelerate)),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: ListTile(
          title: Text(_items[index]['title'] ?? 'No Title'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      itemBuilder: widget.itemBuilder ?? _buildItem,
    );
  }
}
