import 'dart:math';
import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:learnflutter/modules/indicator/shape/arrow_down_shape.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ArrowRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double indicatorHeight;
  final Color arrowColor;
  final IndicatorController? controller;
  final Size sizeArrowDown;
  const ArrowRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.indicatorHeight = 80.0,
    this.arrowColor = Colors.grey,
    this.controller,
    this.sizeArrowDown = const Size(24, 24), // Kích thước mũi tên
  });

  @override
  State<ArrowRefreshIndicator> createState() => _ArrowRefreshIndicatorState();
}

class _ArrowRefreshIndicatorState extends State<ArrowRefreshIndicator> with TickerProviderStateMixin {
  late AnimationController _doneController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
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

    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
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
                            final progress = Curves.easeOut.transform(controller.value.clamp(0.0, 1.0));
                            final state = controller.state;
                            double arrowProgress = progress;
                            if (controller.state == IndicatorState.idle && controller.value == 0.0) {
                              _bounceController.forward(from: 0.0);
                            }
                            if (state == IndicatorState.loading) {
                              return Center(
                                child: LoadingAnimationWidget.fourRotatingDots(
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              );
                            }
                            return ArrowDownShape(
                              progress: arrowProgress,
                              state: state,
                              color: widget.arrowColor,
                              size: widget.sizeArrowDown,
                              bounce: _bounceAnimation.value, // 👈 thêm dòng này
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
