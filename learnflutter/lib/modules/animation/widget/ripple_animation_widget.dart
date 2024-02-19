import 'package:flutter/material.dart';

class RippleAnimationWidget extends StatefulWidget {
  const RippleAnimationWidget({super.key});
  @override
  State<RippleAnimationWidget> createState() => RippleAnimationWidgetState();
}

class RippleAnimationWidgetState extends State<RippleAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(milliseconds: 1500),
    )..repeat();

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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(50 * _controller.value),
            _buildContainer(100 * _controller.value),
            _buildContainer(150 * _controller.value),
            _buildContainer(200 * _controller.value),
            _buildContainer(250 * _controller.value),
            Align(
                child: Icon(
              Icons.phone_android,
              size: _sizeAnimation.value,
            )),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colorAnimation.value?.withOpacity(1 - _controller.value),
      ),
    );
  }
}
