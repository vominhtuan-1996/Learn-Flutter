import 'package:flutter/material.dart';

class RippleAnimationWidget extends StatefulWidget {
  const RippleAnimationWidget({super.key});
  @override
  State<RippleAnimationWidget> createState() => RippleAnimationWidgetState();
}

class RippleAnimationWidgetState extends State<RippleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 1500),
    );
    // ..repeat();

    _colorAnimation = ColorTween(begin: Colors.grey[400], end: Colors.red).animate(_controller);

    _sizeAnimation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 50, end: 30),
          weight: 50,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: 30, end: 50),
          weight: 50,
        )
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: const Cubic(0.4, 0.0, 0.2, 1.0)),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(50 * _controller.value),
            _buildContainer(100 * _controller.value),
            _buildContainer(150 * _controller.value),
            _buildContainer(200 * _controller.value),
            _buildContainer(250 * _controller.value),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return ClipOval(
      child: Container(
        width: radius,
        height: radius / 2,
        color: _colorAnimation.value?.withOpacity(1 - _controller.value),
        // decoration: BoxDecoration(
        //   shape: BoxShape.circle,
        //   color: _colorAnimation.value?.withOpacity(1 - _controller.value),
        // ),
      ),
    );
  }
}
