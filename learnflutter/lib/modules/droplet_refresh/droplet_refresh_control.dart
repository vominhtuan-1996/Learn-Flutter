import 'dart:math';

import 'package:flutter/material.dart';
import 'package:learnflutter/modules/droplet_refresh/droplet_paint.dart';

typedef RefreshCallback = Future<void> Function();

class WaterDropRefresh extends StatefulWidget {
  final RefreshCallback onRefresh;
  final Widget child;
  final double triggerDistance;

  const WaterDropRefresh({
    Key? key,
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 100.0,
  }) : super(key: key);

  @override
  State<WaterDropRefresh> createState() => _WaterDropRefreshState();
}

class _WaterDropRefreshState extends State<WaterDropRefresh>
    with SingleTickerProviderStateMixin {
  double _pullDistance = 0.0;
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Lắng nghe scroll update để tính khoảng kéo
        if (!_refreshing &&
            notification is ScrollUpdateNotification &&
            notification.metrics.axis == Axis.vertical &&
            notification.metrics.pixels < 0) {
          setState(() {
            _pullDistance = -notification.metrics.pixels;
          });

          if (_pullDistance >= widget.triggerDistance) {
            _startRefresh();
          }
        }

        // Reset khi người dùng thả tay
        if (notification is ScrollEndNotification && !_refreshing) {
          setState(() {
            _pullDistance = 0.0;
          });
        }

        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_pullDistance > 0 || _refreshing)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: DropPainter(progress: _pullProgress()),
                size: Size(50, 50),
              ),
            ),
        ],
      ),
    );
  }

  double _pullProgress() {
    final raw = (_pullDistance / widget.triggerDistance).clamp(0.0, 1.0);
    // Dùng hàm cos để làm hiệu ứng easing mềm mại hơn
    final eased = (1 - cos(raw * pi)) / 2;
    return eased;
  }

  Future<void> _startRefresh() async {
    setState(() => _refreshing = true);
    await widget.onRefresh();
    setState(() {
      _refreshing = false;
      _pullDistance = 0.0;
    });
  }
}
