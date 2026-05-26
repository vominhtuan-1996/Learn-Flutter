import 'viewport_context.dart';
import 'viewport_item.dart';
import 'viewport_transform.dart';

/// Trình điều phối chạy tuần tự các transform để tính ra trạng thái cuối cùng của một Item.
class ViewportPipeline {
  final List<ViewportTransform> transforms;

  ViewportPipeline({this.transforms = const []});

  /// Tính toán trạng thái cuối cùng [TransformState] cho một [ViewportItem] cụ thể.
  TransformState evaluate(
    ViewportItem item,
    ViewportContext context,
  ) {
    final state = TransformState();

    // Chạy qua chuỗi các transform theo thứ tự.
    for (final transform in transforms) {
      transform.apply(
        state,
        item,
        context,
      );
    }

    return state;
  }
}
