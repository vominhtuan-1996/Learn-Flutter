import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';

class ReloadButtonWidget extends StatefulWidget {
  ReloadButtonWidget({super.key, this.isRotate = false, this.icon = Icons.favorite_sharp});
  late bool isRotate;
  final IconData icon;
  @override
  State<ReloadButtonWidget> createState() => ReloadButtonWidgetState();
}

class ReloadButtonWidgetState extends State<ReloadButtonWidget> with SingleTickerProviderStateMixin {
  bool isFav = false;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          widget.isRotate = false;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          isFav = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRotate) {
      _animationController.repeat(reverse: true);
      _animationController.duration = const Duration(milliseconds: 600);
    }

    _colorAnimation = ColorTween(begin: Colors.grey[400], end: Colors.red).animate(_animationController);

    if (widget.isRotate) {
      _sizeAnimation = Tween<double>(begin: 0, end: 1).animate(
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
    return Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppColors.primary),
          color: AppColors.primary,
        ),
        width: 100,
        alignment: Alignment.topCenter,
        child: RotationTransition(
          turns: _sizeAnimation,
          child: IconButton(
            icon: const Icon(
              Icons.abc,
              size: 40,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                widget.isRotate = true;
              });
            },
          ),
        ));
  }
}
