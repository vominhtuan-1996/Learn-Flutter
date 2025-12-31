import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:learnflutter/modules/indicator/shape/home_refresh_shape.dart';

class HomeRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double indicatorHeight;
  final IndicatorController? controller;
  const HomeRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.indicatorHeight = 80.0,
    this.controller,
  });

  @override
  State<HomeRefreshIndicator> createState() => _HomeRefreshIndicatorState();
}

class _HomeRefreshIndicatorState extends State<HomeRefreshIndicator> with TickerProviderStateMixin {
  late AnimationController _doneController;
  late AnimationController _bounceController;
  @override
  void initState() {
    super.initState();
    _doneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _doneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      controller: widget.controller,
      offsetToArmed: widget.indicatorHeight,
      onRefresh: () async {
        await widget.onRefresh();
        await _doneController.forward(from: 0.0); // chạy hiệu ứng done
      },
      autoRebuild: false,
      child: widget.child,
      builder: (BuildContext context, Widget child, IndicatorController controller) {
        return Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? _) {
                return SizedBox(
                  height: controller.value * widget.indicatorHeight,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) {
                            final progress =
                                Curves.easeOut.transform(controller.value.clamp(0.0, 1.0));
                            final state = controller.state;
                            double arrowProgress = progress;
                            if (controller.state == IndicatorState.idle &&
                                controller.value == 0.0) {
                              _bounceController.forward(from: 0.0);
                            }
                            return HomeRefreshShape(
                              size: Size.square(28),
                              progress: arrowProgress,
                              state: state,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            AnimatedBuilder(
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0.0, controller.value * widget.indicatorHeight),
                  child: child,
                );
              },
              animation: controller,
            ),
          ],
        );
      },
    );
  }
}
