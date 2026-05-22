# AppTreeView

Component hiển thị **cây dữ liệu phân cấp** (folder, menu, danh mục…), bao bọc thư viện [`animated_tree_view`](https://pub.dev/packages/animated_tree_view) với UI default và API gọn hơn.

## Import

```dart
import 'package:animated_tree_view/animated_tree_view.dart'; // cần cho TreeNode
import 'package:learnflutter/shared/components/tree_view/tree_view.dart';
```

## Tạo dữ liệu

```dart
final tree = TreeNode.root()
  ..addAll([
    TreeNode(key: 'docs')
      ..addAll([
        TreeNode(key: 'intro.md'),
        TreeNode(key: 'usage.md'),
      ]),
    TreeNode(key: 'lib')..add(TreeNode(key: 'main.dart')),
    TreeNode(key: 'README.md'),
  ]);
```

Có thể attach **data** kèm node: `TreeNode<MyModel>(key: 'x', data: model)`.

> ⚠️ **Lưu ý quan trọng về `key`**
> `key` **không được chứa dấu `.`** — `.` là `PATH_SEPARATOR` của `animated_tree_view`,
> nếu chứa sẽ throw assertion `Key should not contain the PATH_SEPARATOR '.'`.
> Nếu cần hiển thị tên có dấu chấm (vd `intro.md`), hãy lưu vào `data` hoặc dùng
> `itemBuilder` custom rồi tự format:
>
> ```dart
> TreeNode<String>(key: 'intro_md', data: 'intro.md')
> // builder: Text(node.data ?? node.key)
> ```

## Cách dùng cơ bản

```dart
AppTreeView(
  tree: tree,
  expandAllOnReady: true,
  onItemTap: (node) => debugPrint('tap ${node.key}'),
);
```

## Custom builder

```dart
AppTreeView(
  tree: tree,
  itemBuilder: (context, node) {
    final isLeaf = node.children.isEmpty;
    return ListTile(
      leading: Icon(isLeaf ? Icons.description : Icons.folder),
      title: Text(node.key),
      subtitle: Text('Level ${node.level}'),
    );
  },
);
```

## Điều khiển bằng controller

```dart
TreeViewController? controller;

AppTreeView(
  tree: tree,
  onControllerReady: (c) => controller = c,
);

// expand / collapse từ code:
controller?.expandAllChildren(tree);
controller?.collapseNode(tree);
```

## Tham số

| Tham số | Loại | Mặc định | Mô tả |
|---|---|---|---|
| `tree` | `TreeNode<T>` | `required` | Cây dữ liệu (root). |
| `itemBuilder` | `Widget Function(ctx, node)?` | `null` | Custom widget cho mỗi node. Mặc định: `ListTile` icon folder/file. |
| `onItemTap` | `ValueChanged<TreeNode<T>>?` | `null` | Callback khi tap node. |
| `onControllerReady` | `ValueChanged<TreeViewController>?` | `null` | Nhận controller khi tree ready. |
| `indicatorStyle` | `TreeIndicatorStyle` | `.upDown` | Icon expand/collapse: `upDown` / `rightDown` / `plusMinus` / `none`. |
| `indicatorColor` | `Color?` | `Color(0xFF6B7280)` | Màu icon indicator. |
| `indentation` | `Indentation?` | `IndentStyle.squareJoint` mảnh, xám | Style đường nối phân cấp. |
| `expandAllOnReady` | `bool` | `false` | Tự expand toàn bộ khi tree ready. |
| `showRootNode` | `bool` | `true` | Có hiển thị node root không. |
| `padding` | `EdgeInsetsGeometry` | `EdgeInsets.all(8)` | Padding xung quanh. |

## Modes của `TreeIndicatorStyle`

| Style | Hiển thị |
|---|---|
| `upDown` | ▲ / ▼ |
| `rightDown` | ▶ / ▼ |
| `plusMinus` | + / − |
| `none` | Không có icon indicator |

## Demo

Vào màn hình **Test Screen** → mục **Tree Node View** để xem 6 tab test case trực quan:
1. Default
2. Expand all on ready
3. So sánh 4 kiểu indicator
4. Custom UI (badge màu theo leaf/folder)
5. `onItemTap` + ẩn root
6. Điều khiển bằng controller (expand/collapse từ ngoài)
