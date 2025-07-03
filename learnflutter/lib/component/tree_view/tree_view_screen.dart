import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/component/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/modules/material/component/metarial_radio_button/radio_item_model.dart';

class TreeViewScreen extends StatefulWidget {
  const TreeViewScreen({super.key});
  @override
  State<TreeViewScreen> createState() => TreeViewScreenState();
}

class TreeViewScreenState extends State<TreeViewScreen> {
  TreeViewController? _controller;
  bool showSnackBar = false;
  bool expandChildrenOnReady = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final sampleTree = TreeNode.root()
    ..addAll([
      TreeNode(key: "0A")..add(TreeNode(key: "0A1A")),
      TreeNode(key: "0C")
        ..addAll([
          TreeNode(key: "0C1A"),
          TreeNode(key: "0C1B"),
          TreeNode(key: "0C1C")
            ..addAll([
              TreeNode(key: "0C1C2A")
                ..addAll([
                  TreeNode(key: "0C1C2A3A")
                    ..addAll([
                      TreeNode(key: "0C1C2A3A4A")
                        ..addAll([
                          TreeNode(key: "0C1C2A3A4A5A"),
                          TreeNode(key: "0C1C2A3A4A5B"),
                          TreeNode(key: "0C1C2A3A4A5C"),
                        ]),
                      TreeNode(key: "0C1C2A3A4B"),
                      TreeNode(key: "0C1C2A3A4C"),
                    ]),
                  TreeNode(key: "0C1C2A3B")
                    ..addAll([
                      TreeNode(key: "0C1C2A3B4A"),
                      TreeNode(key: "0C1C2A3B4B"),
                      TreeNode(key: "0C1C2A3B4C")
                        ..addAll([
                          TreeNode(key: "0C1C2A3B4C5A"),
                          TreeNode(key: "0C1C2A3B4C5B"),
                          TreeNode(key: "0C1C2A3B4C5C"),
                        ]),
                    ]),
                  TreeNode(key: "0C1C2A3C")
                    ..addAll([
                      TreeNode(key: "0C1C2A3C4A"),
                      TreeNode(key: "0C1C2A3C4B")
                        ..addAll([
                          TreeNode(key: "0C1C2A3C4B5A"),
                          TreeNode(key: "0C1C2A3C4B5B"),
                          TreeNode(key: "0C1C2A3C4B5C"),
                        ]),
                      TreeNode(key: "0C1C2A3C4C"),
                    ]),
                ]),
            ]),
        ]),
      TreeNode(key: "0D"),
      TreeNode(key: "0E"),
    ]);

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: sampleTree.expansionNotifier,
        builder: (context, isExpanded, _) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (sampleTree.isExpanded) {
                _controller?.collapseNode(sampleTree);
              } else {
                _controller?.expandAllChildren(sampleTree);
              }
            },
            label: isExpanded
                ? const Text("Collapse all")
                : const Text("Expand all"),
          );
        },
      ),
      child: TreeView.simple(
        tree: sampleTree,
        showRootNode: true,
        expansionIndicatorBuilder: (context, node) {
          return ChevronIndicator.upDown(
            tree: node,
            curve: Curves.decelerate,
            padding: EdgeInsets.all(8),
          );
        },
        // expansionIndicatorBuilder: (context, node) => ChevronIndicator.rightDown(
        //   curve: Curves.decelerate,
        //   tree: node,
        //   // color: Colors.blue[700],
        //   padding: EdgeInsets.all(8),
        // ),
        indentation: Indentation(
            style: IndentStyle.roundJoint, thickness: 2, color: Colors.red),
        onItemTap: (item) {
          if (kDebugMode) print("Item tapped: ${item.key}");

          if (showSnackBar) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Item tapped: ${item.key}"),
                duration: const Duration(milliseconds: 750),
              ),
            );
          }
        },
        onTreeReady: (controller) {
          _controller = controller;
          if (expandChildrenOnReady) controller.expandAllChildren(sampleTree);
        },
        builder: (context, node) => AnimatedTapButtonBuilder(
          background: Colors.white,
          padding: EdgeInsets.zero,
          child: Card(
            color: Colors.grey,
            child: ListTile(
              title: Text("Item ${node.level}-${node.key}"),
              subtitle: Text('Level ${node.level}'),
            ),
          ),
        ),
      ),
    );
  }
}
