import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/slow_down_scroll_physics.dart';

class SlowDownScrollPhysicsExample extends StatefulWidget {
  /// Example of using [SlowDownScrollPhysics] to slow down the scroll speed in a ListView.
  const SlowDownScrollPhysicsExample({super.key});

  @override
  State<SlowDownScrollPhysicsExample> createState() => _SlowDownScrollPhysicsExampleState();
}

class _SlowDownScrollPhysicsExampleState extends State<SlowDownScrollPhysicsExample> {
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
        itemCount: 50,
        physics: const SlowDownScrollPhysics(),
      ),
    );
  }
}
