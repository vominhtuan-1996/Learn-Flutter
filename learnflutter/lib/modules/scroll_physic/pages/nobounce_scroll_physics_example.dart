import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/nobounce_scroll_physics.dart';

class NoBounceScrollPhysicsExample extends StatefulWidget {
  /// Example of using [NoBounceScrollPhysics] to disable bounce effect in a ListView.
  const NoBounceScrollPhysicsExample({super.key});

  @override
  State<NoBounceScrollPhysicsExample> createState() => _NoBounceScrollPhysicsExampleState();
}

class _NoBounceScrollPhysicsExampleState extends State<NoBounceScrollPhysicsExample> {
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
        physics: const NoBounceScrollPhysics(),
      ),
    );
  }
}
