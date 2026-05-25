import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

import 'transformer_factory.dart';
import 'transformer_type.dart';

// Re-export để consumer chỉ cần import file này.
export 'transformer_factory.dart' show transformerFor;
export 'transformer_type.dart';
export 'transformers/transformers.dart';

/// Component bọc sẵn [TransformerPageView] với API gọn nhẹ chỉ cần chọn
/// [TransformerType] + builder.
///
/// ```dart
/// TransformerPage(
///   type: TransformerType.coverFlow,
///   itemCount: items.length,
///   itemBuilder: (_, i) => MyCard(items[i]),
///   loop: true,
///   onPageChanged: (i) => print('page $i'),
/// )
/// ```
class TransformerPage extends StatelessWidget {
  const TransformerPage({
    super.key,
    required this.type,
    required this.itemCount,
    required this.itemBuilder,
    this.loop = false,
    this.controller,
    this.onPageChanged,
    this.scrollDirection = Axis.horizontal,
    this.physics,
  });

  /// Hiệu ứng chuyển trang.
  final TransformerType type;

  /// Số trang.
  final int itemCount;

  /// Builder render từng trang.
  final IndexedWidgetBuilder itemBuilder;

  /// Loop vô hạn.
  final bool loop;

  /// Controller tuỳ chọn — dùng [IndexController] để jump tới trang bất kỳ.
  final IndexController? controller;

  /// Callback khi trang đổi.
  final ValueChanged<int?>? onPageChanged;

  /// Hướng cuộn.
  final Axis scrollDirection;

  /// Physics tuỳ chỉnh.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return TransformerPageView(
      loop: loop,
      transformer: transformerFor(type),
      itemCount: itemCount,
      controller: controller,
      onPageChanged: onPageChanged,
      scrollDirection: scrollDirection,
      physics: physics,
      itemBuilder: itemBuilder,
    );
  }
}
