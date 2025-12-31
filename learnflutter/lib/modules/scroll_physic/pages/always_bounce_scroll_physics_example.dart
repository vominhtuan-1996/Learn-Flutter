import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';

class AlwaysBounceScrollPhysicsExample extends StatefulWidget {
  const AlwaysBounceScrollPhysicsExample({super.key});

  @override
  State<AlwaysBounceScrollPhysicsExample> createState() => _AlwaysBounceScrollPhysicsExampleState();
}

class _AlwaysBounceScrollPhysicsExampleState extends State<AlwaysBounceScrollPhysicsExample> {
  final ScrollController _controller = ScrollController();
  double _offset = 0;

  int _lastHapticIndex = -1;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final offset = _controller.offset;
      setState(() {
        _offset = offset;
      });

      // Trigger haptic every 200px scroll (custom logic)
      final index = (offset / 200).floor();
      if (index != _lastHapticIndex) {
        _lastHapticIndex = index;
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/slier_appbar_bgr.webp',
              height: DeviceDimension.screenHeight -
                  DeviceDimension.appBar -
                  DeviceDimension.statusBarHeight(context) +
                  DeviceDimension.padding,
              fit: BoxFit.cover,
            ),
          ),
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              // ✅ Hide default glow
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
              itemCount: 50,
              physics: const AlwaysScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }
}
