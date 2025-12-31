import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/custom_widget/ripple_override.dart';
import 'package:learnflutter/custom_widget/zoom_tap_effect.dart';
import 'package:learnflutter/modules/scroll_physic/extension/scroll_physics/snapping_scroll_physics.dart';
import 'package:learnflutter/utils_helper/extension/extension_widget.dart';

class SnappingScrollPhysicsExample extends StatefulWidget {
  const SnappingScrollPhysicsExample({super.key});

  @override
  State<SnappingScrollPhysicsExample> createState() => _SnappingScrollPhysicsExampleState();
}

class _SnappingScrollPhysicsExampleState extends State<SnappingScrollPhysicsExample> {
  double heightItem =
      DeviceDimension.screenHeight - DeviceDimension.padding * 2 - DeviceDimension.appBar;
  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return RippleOverride(
            effect: RippleEffectType.zoom,
            enableHaptic: true,
            // onTap: () {
            //   // Handle item tap
            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped item $index')));
            // },
            child: Container(
              color: Colors.primaries[index % Colors.primaries.length],
              height: heightItem -
                  DeviceDimension.statusBarHeight(context), // Set the height for each item
            )
                .paddingSymmetric(
                    horizontal: DeviceDimension.padding, vertical: DeviceDimension.padding)
                .center(),
          );
        },
        itemCount: 50,
        physics: SnappingScrollPhysics(
            itemDimension: DeviceDimension.screenHeight - DeviceDimension.padding),
      ),
    );
  }
}
