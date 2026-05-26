/// Lưu trữ thông tin định vị của một Item cụ thể bên trong danh sách (Sliver/List).
class ViewportItem {
  /// Vị trí thứ tự của item trong danh sách.
  final int index;

  /// Tọa độ bắt đầu của item so với tổng chiều dài của trục cuộn.
  final double itemOffset;

  /// Kích thước chiều dài của item trên trục cuộn.
  final double itemExtent;

  ViewportItem({
    required this.index,
    required this.itemOffset,
    required this.itemExtent,
  });
}
