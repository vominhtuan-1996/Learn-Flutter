import 'package:flutter/material.dart';

class DropWaterRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const DropWaterRefresh({required this.child, required this.onRefresh, super.key});

  @override
  State<DropWaterRefresh> createState() => _DropWaterRefreshState();
}

class _DropWaterRefreshState extends State<DropWaterRefresh> with SingleTickerProviderStateMixin {
  double _pullExtent = 0.0;
  bool _refreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    await widget.onRefresh();
    setState(() {
      _refreshing = false;
      _pullExtent = 0.0;
    });
  }

  bool _onNotification(ScrollNotification notification) {
    if (_refreshing) return false;

    if (notification is OverscrollNotification && notification.overscroll < 100) {
      setState(() {
        _pullExtent += notification.overscroll;
        _pullExtent = _pullExtent.clamp(0.0, 150.0);
      });
    }

    if (notification is ScrollEndNotification && _pullExtent >= 80.0) {
      _handleRefresh();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onNotification,
          child: widget.child,
        ),
        if (_pullExtent > 0 || _refreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: DropWaterPainter(pullExtent: _pullExtent),
              child: SizedBox(height: 80),
            ),
          ),
      ],
    );
  }
}

class DropWaterPainter extends CustomPainter {
  final double pullExtent;

  DropWaterPainter({required this.pullExtent});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    final double dropRadius = pullExtent / 2;
    final Offset center = Offset(size.width / 2, pullExtent);

    canvas.drawCircle(center, dropRadius, paint);
  }

  @override
  bool shouldRepaint(covariant DropWaterPainter oldDelegate) {
    return oldDelegate.pullExtent != pullExtent;
  }
}

