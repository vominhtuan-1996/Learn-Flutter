import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/shared/components/tree_view/tree_view.dart';

/// Màn hình test trực quan [AppTreeView] với nhiều cấu hình.
class TreeViewTestScreen extends StatefulWidget {
  const TreeViewTestScreen({super.key});

  @override
  State<TreeViewTestScreen> createState() => _TreeViewTestScreenState();
}

class _TreeViewTestScreenState extends State<TreeViewTestScreen> {
  String? _lastTapped;
  TreeViewController? _externalController;
  late final TreeNode _externalTree;

  @override
  void initState() {
    super.initState();
    _externalTree = _sampleTree();
  }

  /// Tạo 1 sample tree mới (mỗi tab dùng cây riêng để tránh state share).
  ///
  /// Lưu ý: key của [TreeNode] **không được chứa dấu `.`** vì `.` là
  /// PATH_SEPARATOR của animated_tree_view. Dùng `_` thay cho `.`.
  TreeNode _sampleTree() => TreeNode.root()
    ..addAll([
      TreeNode(key: 'docs')
        ..addAll([
          TreeNode(key: 'intro_md'),
          TreeNode(key: 'guide')
            ..addAll([
              TreeNode(key: 'install_md'),
              TreeNode(key: 'usage_md'),
            ]),
        ]),
      TreeNode(key: 'lib')
        ..addAll([
          TreeNode(key: 'main_dart'),
          TreeNode(key: 'widgets')
            ..addAll([
              TreeNode(key: 'button_dart'),
              TreeNode(key: 'card_dart'),
            ]),
        ]),
      TreeNode(key: 'README_md'),
    ]);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          title: const Text('AppTreeView — Test cases'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF6B7280),
            indicatorColor: const Color(0xFF2563EB),
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: '1. Default'),
              Tab(text: '2. Expand all'),
              Tab(text: '3. Indicators'),
              Tab(text: '4. Custom UI'),
              Tab(text: '5. Tap + hide root'),
              Tab(text: '6. Controller'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _wrap(
              desc: 'Cấu hình tối giản — chỉ truyền `tree`.',
              child: AppTreeView(tree: _sampleTree()),
            ),
            _wrap(
              desc: '`expandAllOnReady: true` — mở hết khi vừa build.',
              child: AppTreeView(
                tree: _sampleTree(),
                expandAllOnReady: true,
              ),
            ),
            _buildIndicatorsTab(),
            _wrap(
              desc:
                  '`itemBuilder` custom — leaf hiện badge xanh lá, folder badge xanh dương.',
              child: AppTreeView(
                tree: _sampleTree(),
                expandAllOnReady: true,
                indicatorStyle: TreeIndicatorStyle.rightDown,
                indentation: const Indentation(
                  style: IndentStyle.roundJoint,
                  thickness: 1.5,
                  color: Color(0xFF93C5FD),
                ),
                itemBuilder: (context, node) {
                  final isLeaf = node.children.isEmpty;
                  final color = isLeaf
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF2563EB);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLeaf
                              ? Icons.description_outlined
                              : Icons.folder_outlined,
                          size: 18,
                          color: color,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            node.key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        Text(
                          'L${node.level}',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildTapTab(),
            _buildControllerTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorsTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Color(0xFF2563EB),
              unselectedLabelColor: Color(0xFF6B7280),
              indicatorColor: Color(0xFF2563EB),
              tabs: [
                Tab(text: 'upDown'),
                Tab(text: 'rightDown'),
                Tab(text: 'plusMinus'),
                Tab(text: 'none'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                AppTreeView(
                    tree: _sampleTree(),
                    expandAllOnReady: true,
                    indicatorStyle: TreeIndicatorStyle.upDown),
                AppTreeView(
                    tree: _sampleTree(),
                    expandAllOnReady: true,
                    indicatorStyle: TreeIndicatorStyle.rightDown),
                AppTreeView(
                    tree: _sampleTree(),
                    expandAllOnReady: true,
                    indicatorStyle: TreeIndicatorStyle.plusMinus,
                    indicatorColor: const Color(0xFFEA580C)),
                AppTreeView(
                    tree: _sampleTree(),
                    expandAllOnReady: true,
                    indicatorStyle: TreeIndicatorStyle.none),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTapTab() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Text(
            _lastTapped == null
                ? 'Tap vào 1 node…'
                : 'Đã tap: $_lastTapped',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: AppTreeView(
            tree: _sampleTree(),
            showRootNode: false,
            expandAllOnReady: true,
            onItemTap: (node) => setState(() => _lastTapped = node.key),
          ),
        ),
      ],
    );
  }

  Widget _buildControllerTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _externalController?.expandAllChildren(_externalTree),
                  icon: const Icon(Icons.unfold_more_rounded, size: 18),
                  label: const Text('Expand all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _externalController?.collapseNode(_externalTree),
                  icon: const Icon(Icons.unfold_less_rounded, size: 18),
                  label: const Text('Collapse all'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AppTreeView(
            tree: _externalTree,
            onControllerReady: (c) => _externalController = c,
          ),
        ),
      ],
    );
  }

  Widget _wrap({required String desc, required Widget child}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Text(desc,
              style: const TextStyle(fontSize: 12, color: Color(0xFF374151))),
        ),
        Expanded(child: child),
      ],
    );
  }
}
