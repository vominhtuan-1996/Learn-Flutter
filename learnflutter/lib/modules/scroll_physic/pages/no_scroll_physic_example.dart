import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/no_scroll_physics.dart';

class NoScrollPhysicExample extends StatefulWidget {
  const NoScrollPhysicExample({super.key});

  @override
  State<NoScrollPhysicExample> createState() => _NoScrollPhysicExampleState();
}

class _NoScrollPhysicExampleState extends State<NoScrollPhysicExample> {
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
          physics: const NoScrollPhysics()),
    );
  }
}
