import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/reversed_scroll_physics.dart';

class ReversedScrollPhysicsExample extends StatefulWidget {
  const ReversedScrollPhysicsExample({super.key});

  @override
  State<ReversedScrollPhysicsExample> createState() => _ReversedScrollPhysicsExampleState();
}

class _ReversedScrollPhysicsExampleState extends State<ReversedScrollPhysicsExample> {
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
        physics: const ReversedScrollPhysics(),
      ),
    );
  }
}
