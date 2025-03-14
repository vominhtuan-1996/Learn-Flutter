/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/5 下午2:37
 */

import 'dart:async';
import 'package:flutter/material.dart' hide RefreshIndicatorState, RefreshIndicator;
import 'package:flutter/foundation.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/custom_widget/smart_refresh/lib/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

/// QQ ios refresh  header effect
class WaterDropHeader extends RefreshIndicator {
  /// refreshing content
  final Widget? refresh;

  /// complete content
  final Widget? complete;

  /// failed content
  final Widget? failed;

  /// idle Icon center in waterCircle
  final Widget idleIcon;

  /// waterDrop color,default grey
  final Color waterDropColor;

  const WaterDropHeader({
    super.key,
    this.refresh,
    this.complete,
    super.completeDuration = const Duration(milliseconds: 200),
    this.failed,
    this.waterDropColor = Colors.grey,
    this.idleIcon = const Icon(
      Icons.autorenew,
      size: 15,
      color: Colors.white,
    ),
  }) : super(height: 60.0, refreshStyle: RefreshStyle.UnFollow);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WaterDropHeaderState();
  }
}

class _WaterDropHeaderState extends RefreshIndicatorState<WaterDropHeader> with TickerProviderStateMixin {
  AnimationController? _animationController;
  late AnimationController _dismissCtl;

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    final double realOffset = offset - 44.0; //55.0 mean circleHeight(24) + originH (20) in Painter
    // when readyTorefresh
    if (!_animationController!.isAnimating) _animationController!.value = realOffset;
  }

  @override
  Future<void> readyToRefresh() {
    // TODO: implement readyToRefresh
    _dismissCtl.animateTo(0.0);
    return _animationController!.animateTo(0.0);
  }

  @override
  void initState() {
    // TODO: implement initState
    _dismissCtl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: 1.0);
    _animationController = AnimationController(vsync: this, lowerBound: 0.0, upperBound: 50.0, duration: const Duration(milliseconds: 400));
    super.initState();
  }

  @override
  bool needReverseAll() {
    // TODO: implement needReverseAll
    return false;
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    // TODO: implement buildContent
    Widget? child;
    if (mode == RefreshStatus.refreshing) {
      child = widget.refresh ??
          SizedBox(
            width: 25.0,
            height: 25.0,
            child: defaultTargetPlatform == TargetPlatform.iOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator(strokeWidth: 2.0),
          );
    } else if (mode == RefreshStatus.completed) {
      child = Container();
      // widget.complete ??
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         const Icon(
      //           Icons.done,
      //           color: Colors.grey,
      //         ),
      //         Container(
      //           width: 15.0,
      //         ),
      //         Text(
      //           (RefreshLocalizations.of(context)?.currentLocalization ?? EnRefreshString()).refreshCompleteText!,
      //           style: TextStyle(color: Colors.grey),
      //         )
      //       ],
      //     );
    } else if (mode == RefreshStatus.failed) {
      child = Container();
      widget.failed ??
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.close,
                color: Colors.grey,
              ),
              Container(
                width: 15.0,
              ),
              Text((RefreshLocalizations.of(context)?.currentLocalization ?? EnRefreshString()).refreshFailedText!, style: const TextStyle(color: Colors.grey))
            ],
          );
    } else if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      return FadeTransition(
          opacity: _dismissCtl,
          child: SizedBox(
            height: 60,
            child: Stack(
              children: <Widget>[
                RotatedBox(
                  quarterTurns: Scrollable.of(context).axisDirection == AxisDirection.up ? 10 : 0,
                  child: CustomPaint(
                    painter: _QqPainter(
                      color: widget.waterDropColor,
                      listener: _animationController,
                    ),
                    child: Container(
                      height: 60,
                    ),
                  ),
                ),
                Container(
                  alignment: Scrollable.of(context).axisDirection == AxisDirection.up ? Alignment.bottomCenter : Alignment.topCenter,
                  margin: Scrollable.of(context).axisDirection == AxisDirection.up ? EdgeInsets.only(bottom: DeviceDimension.padding / 2) : EdgeInsets.only(top: DeviceDimension.padding / 2),
                  child: widget.idleIcon,
                )
              ],
            ),
          ));
    }
    return SizedBox(
      height: 60.0,
      child: Center(
        child: child,
      ),
    );
  }

  @override
  void resetValue() {
    // TODO: implement resetValue
    _animationController!.reset();
    _dismissCtl.value = 1;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _dismissCtl.dispose();
    _animationController!.dispose();
    super.dispose();
  }
}

class _QqPainter extends CustomPainter {
  final Color? color;
  final Animation<double>? listener;

  double get value => listener!.value;
  final Paint painter = Paint();

  _QqPainter({this.color, this.listener}) : super(repaint: listener);

  @override
  void paint(Canvas canvas, Size size) {
    const double originH = 20.0;
    final double middleW = size.width / 2;

    const double circleSize = 12.0;

    const double scaleRatio = 0.1;

    final double offset = value;

    painter.color = color!;
    canvas.drawCircle(Offset(middleW, originH), circleSize, painter);
    Path path = Path();
    path.moveTo(middleW - circleSize, originH);

    //drawleft
    path.cubicTo(middleW - circleSize, originH, middleW - circleSize + value * scaleRatio, originH + offset / 5, middleW - circleSize + value * scaleRatio * 2, originH + offset);
    path.lineTo(middleW + circleSize - value * scaleRatio * 2, originH + offset);
    //draw right
    path.cubicTo(middleW + circleSize - value * scaleRatio * 2, originH + offset, middleW + circleSize - value * scaleRatio, originH + offset / 5, middleW + circleSize, originH);
    //draw upper circle
    path.moveTo(middleW - circleSize, originH);
    path.arcToPoint(Offset(middleW + circleSize, originH), radius: const Radius.circular(circleSize));

    //draw lowwer circle
    path.moveTo(middleW + circleSize - value * scaleRatio * 2, originH + offset);
    path.arcToPoint(Offset(middleW - circleSize + value * scaleRatio * 2, originH + offset), radius: Radius.circular(value * scaleRatio));
    path.close();
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate != this;
  }
}
