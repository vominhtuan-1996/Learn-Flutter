import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/silver_animation_list_wrapper.dart';

class SliverAnimationListWrapperExample extends StatefulWidget {
  const SliverAnimationListWrapperExample({super.key});
  @override
  State<SliverAnimationListWrapperExample> createState() => _SliverAnimationListWrapperExampleState();
}

class _SliverAnimationListWrapperExampleState extends State<SliverAnimationListWrapperExample> {
  List<String> items = List.generate(10, (i) => 'Item #$i');
  int nextIndex = 10;

  Future<List<String>> _loadMore() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(5, (i) => 'Item #${nextIndex + i}')..forEach((e) => nextIndex++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reusable SliverAnimatedList')),
      body: SliverAnimatedListWrapper<String>(
        initialItems: items,
        onLoadMore: _loadMore,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            nextIndex = 10;
            items = List.generate(10, (i) => 'Refreshed Item #$i');
          });
        },
        itemBuilder: (context, item, index, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: ListTile(
              title: Text(item),
              tileColor: index.isEven ? Colors.grey[200] : Colors.white,
            ),
          );
        },
        enableDelete: true,
      ),
    );
  }
}
