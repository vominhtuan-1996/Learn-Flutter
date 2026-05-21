import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:lottie/lottie.dart';

class DropWaterLottieRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double indicatorSize;
  final String lottieAsset; // Đường dẫn Lottie JSON

  const DropWaterLottieRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.lottieAsset,
    this.indicatorSize = 100,
  });

  @override
  State<DropWaterLottieRefreshIndicator> createState() => _DropWaterLottieRefreshIndicatorState();
}

class _DropWaterLottieRefreshIndicatorState extends State<DropWaterLottieRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  bool _playSplash = false;

  @override
  void initState() {
    super.initState();
    // _lottieController = AnimationController(vsync: this);
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 👈 Bắt buộc
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await widget.onRefresh();

    // Bật hiệu ứng Lottie sau khi refresh
    setState(() => _playSplash = true);
    await _lottieController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _playSplash = false);
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      offsetToArmed: widget.indicatorSize,
      onRefresh: _handleRefresh,
      builder: (context, child, controller) {
        final progress = controller.value.clamp(0.0, 1.0);
        final eased = Curves.easeOutBack.transform(progress);

        return Stack(
          children: [
            SizedBox(
              height: eased * widget.indicatorSize,
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Lottie.asset(
                    widget.lottieAsset,
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                    },
                    width: 80,
                    height: 80,
                  )),
            ),
            Transform.translate(
              offset: Offset(0.0, controller.value * widget.indicatorSize),
              child: child,
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}
