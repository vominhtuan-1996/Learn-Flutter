import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/app/app_colors.dart';

class LayoutMarkerPin extends StatelessWidget {
  LayoutMarkerPin({
    super.key,
    required this.heigtContainerViewPin,
    required this.heigtOvalView,
    required this.heigtCircleView,
    required this.heigtCylinderView,
    required this.isMoving,
  });

  final double heigtContainerViewPin;
  final double heigtOvalView;
  final double heigtCircleView;
  final double heigtCylinderView;
  final bool isMoving;
  late AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: heigtContainerViewPin / 2 - heigtOvalView / 2,
          child: ClipOval(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: isMoving ? heigtCircleView * 0.6 : heigtCircleView * 0.8,
              height: heigtOvalView,
              color: isMoving ? Colors.black45 : Colors.black45.withOpacity(0.4),
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
              height: heigtContainerViewPin / 2,
              color: Colors.transparent,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    AnimatedContainer(
                      // animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
                      duration: const Duration(milliseconds: 100),
                      height: heigtCircleView,
                      width: heigtCircleView,
                      decoration: AppBoxDecoration.boxDecorationCircleColorPrimary,
                    ),
                    Container(
                      color: Colors.transparent,
                      width: heigtContainerViewPin / 24,
                      height: heigtCylinderView,
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: heigtCylinderView / 2.5,
                              color: AppColors.primary,
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              height: isMoving ? 0 : heigtCylinderView - heigtCylinderView / 2.5,
                              color: AppColors.primary,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ],
    );
  }
}