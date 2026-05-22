import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

/// Style hiển thị icon expand/collapse trước mỗi node.
enum TreeIndicatorStyle {
  /// Mũi tên xuống / lên (▼ / ▲).
  upDown,

  /// Mũi tên phải / xuống (▶ / ▼).
  rightDown,

  /// Dấu cộng / trừ (+ / −).
  plusMinus,

  /// Không hiển thị indicator.
  none,
}

/// Component hiển thị cây dữ liệu phân cấp.
///
/// Bao bọc [TreeView.simple] với các default hợp lý và slot tuỳ chỉnh:
/// - [tree] : dữ liệu (`TreeNode.root()..addAll([...])`).
/// - [itemBuilder] : custom widget cho mỗi node. Mặc định: [ListTile] hiển thị key + level.
/// - [indicatorStyle] : icon expand/collapse.
/// - [indentation] : style đường nối phân cấp.
/// - [expandAllOnReady] : tự expand toàn bộ khi build xong.
/// - [showRootNode] : có hiển thị node root hay không.
/// - [onItemTap] / [onControllerReady] : callbacks.
///
/// Ví dụ:
/// ```dart
/// final tree = TreeNode.root()
///   ..addAll([
///     TreeNode(key: 'A')..add(TreeNode(key: 'A1')),
///     TreeNode(key: 'B'),
///   ]);
///
/// AppTreeView(
///   tree: tree,
///   expandAllOnReady: true,
///   onItemTap: (n) => debugPrint('tap ${n.key}'),
/// );
/// ```
class AppTreeView<T> extends StatefulWidget {
  const AppTreeView({
    super.key,
    required this.tree,
    this.itemBuilder,
    this.onItemTap,
    this.onControllerReady,
    this.indicatorStyle = TreeIndicatorStyle.upDown,
    this.indicatorColor,
    this.indentation,
    this.expandAllOnReady = false,
    this.showRootNode = true,
    this.padding = const EdgeInsets.all(8),
  });

  /// Cây dữ liệu. Tạo bằng `TreeNode.root()..addAll([...])`.
  final TreeNode<T> tree;

  /// Custom widget cho mỗi node. Nếu null dùng default [ListTile].
  final Widget Function(BuildContext context, TreeNode<T> node)? itemBuilder;

  /// Callback khi tap vào node.
  final ValueChanged<TreeNode<T>>? onItemTap;

  /// Lấy [TreeViewController] (dùng để expand/collapse theo code).
  final ValueChanged<TreeViewController>? onControllerReady;

  /// Style icon expand/collapse.
  final TreeIndicatorStyle indicatorStyle;

  /// Màu của icon indicator (chỉ áp dụng khi không phải `none`).
  final Color? indicatorColor;

  /// Style đường nối phân cấp. Default: `IndentStyle.squareJoint` mảnh, xám.
  final Indentation? indentation;

  /// Tự động expand toàn bộ khi tree ready.
  final bool expandAllOnReady;

  /// Hiển thị node root hay không.
  final bool showRootNode;

  /// Padding bao quanh.
  final EdgeInsetsGeometry padding;

  @override
  State<AppTreeView<T>> createState() => _AppTreeViewState<T>();
}

class _AppTreeViewState<T> extends State<AppTreeView<T>> {
  ExpansionIndicator _buildIndicator(BuildContext context, ITreeNode node) {
    final color = widget.indicatorColor ?? const Color(0xFF6B7280);
    switch (widget.indicatorStyle) {
      case TreeIndicatorStyle.upDown:
        return ChevronIndicator.upDown(
          tree: node,
          curve: Curves.decelerate,
          padding: const EdgeInsets.all(8),
          color: color,
        );
      case TreeIndicatorStyle.rightDown:
        return ChevronIndicator.rightDown(
          tree: node,
          curve: Curves.decelerate,
          padding: const EdgeInsets.all(8),
          color: color,
        );
      case TreeIndicatorStyle.plusMinus:
        return PlusMinusIndicator(
          tree: node,
          padding: const EdgeInsets.all(8),
          color: color,
        );
      case TreeIndicatorStyle.none:
        return NoExpansionIndicator(tree: node);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: TreeView.simple(
        tree: widget.tree,
        showRootNode: widget.showRootNode,
        expansionIndicatorBuilder: _buildIndicator,
        indentation: widget.indentation ??
            const Indentation(
              style: IndentStyle.squareJoint,
              thickness: 1,
              color: Color(0xFFD1D5DB),
            ),
        onItemTap: (node) => widget.onItemTap?.call(node),
        onTreeReady: (controller) {
          widget.onControllerReady?.call(controller);
          if (widget.expandAllOnReady) {
            controller.expandAllChildren(widget.tree);
          }
        },
        builder: (context, node) =>
            widget.itemBuilder?.call(context, node) ??
            _DefaultTile(node: node),
      ),
    );
  }
}

class _DefaultTile<T> extends StatelessWidget {
  const _DefaultTile({required this.node});

  final TreeNode<T> node;

  @override
  Widget build(BuildContext context) {
    final hasChildren = node.children.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          hasChildren ? Icons.folder_outlined : Icons.insert_drive_file_outlined,
          color: hasChildren ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
          size: 20,
        ),
        title: Text(
          node.key,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Level ${node.level}${hasChildren ? ' · ${node.children.length} con' : ''}',
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ),
    );
  }
}
