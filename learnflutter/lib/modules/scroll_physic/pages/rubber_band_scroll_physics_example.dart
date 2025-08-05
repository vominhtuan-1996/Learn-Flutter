import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/rubber_band_scroll_physics.dart';

class RubberBandScrollPhysicsExample extends StatefulWidget {
  /// Example of using [RubberBandScrollPhysics] to create a rubber band effect when scrolling.
  const RubberBandScrollPhysicsExample({super.key});

  @override
  State<RubberBandScrollPhysicsExample> createState() => _RubberBandScrollPhysicsExampleState();
}

class _RubberBandScrollPhysicsExampleState extends State<RubberBandScrollPhysicsExample> {
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
        physics: const RubberBandScrollPhysics(),
      ),
    );
  }
}
