import 'package:flutter/material.dart';
import 'package:learnflutter/base_loading_screen/base_loading.dart';

class IconAnimationWidget extends StatefulWidget {
  const IconAnimationWidget({super.key, this.isRotate = false, this.icon = Icons.favorite_sharp});
  final bool isRotate;
  final IconData icon;
  @override
  State<IconAnimationWidget> createState() => IconAnimationWidgetState();
}

class IconAnimationWidgetState extends State<IconAnimationWidget> with SingleTickerProviderStateMixin {
  bool isFav = false;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    if (widget.isRotate) {
      _animationController.repeat(reverse: true);
      _animationController.duration = Duration(milliseconds: 600);
    }

    _colorAnimation = ColorTween(begin: Colors.grey[400], end: Colors.red).animate(_animationController);

    if (widget.isRotate) {
      _sizeAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
    } else {
      _sizeAnimation = TweenSequence(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween(begin: 30, end: 50),
            weight: 50,
          ),
          TweenSequenceItem<double>(
            tween: Tween(begin: 50, end: 30),
            weight: 50,
          )
        ],
      ).animate(_animationController);
    }

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isFav = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          isFav = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isRotate
        ? Container(
            alignment: Alignment.topCenter,
            child: RotationTransition(
              turns: _sizeAnimation,
              child: IconButton(
                icon: Icon(
                  Icons.notifications_on_rounded,
                  size: 60,
                  color: Colors.red,
                ),
                onPressed: () {},
              ),
            ))
        : AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    isFav ? _animationController.reverse() : _animationController.forward();
                  },
                  icon: Icon(
                    widget.icon,
                    color: _colorAnimation.value,
                    size: _sizeAnimation.value,
                  ));
            },
          );
  }
}
