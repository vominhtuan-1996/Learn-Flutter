import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// [Photo3DViewer] — full 360° rotation với inertia sau khi thả tay.
///
/// - Pan drag: xoay tự do theo X/Y (không clamp)
/// - Thả tay: inertia tiếp tục quay rồi giảm dần (friction)
/// - Double-tap: reset về vị trí ban đầu (spring back)
/// - Glare overlay: RadialGradient CustomPainter, smooth, không rebuild widget
/// - ValueNotifier + RepaintBoundary: chỉ repaint Transform + glare, image cached
class Photo3DViewer extends StatefulWidget {
  final String imagePath;
  final bool isNetworkImage;
  final double width;
  final double height;

  const Photo3DViewer({
    super.key,
    required this.imagePath,
    this.isNetworkImage = false,
    this.width = 300,
    this.height = 400,
  });

  @override
  State<Photo3DViewer> createState() => _Photo3DViewerState();
}

/// Holds accumulated rotation angles (radians) — unclamped, free 360°.
typedef _Angles = ({double x, double y});

class _Photo3DViewerState extends State<Photo3DViewer>
    with TickerProviderStateMixin {
  final _notifier = ValueNotifier<_Angles>((x: 0, y: 0));

  // Inertia
  late final Ticker _ticker;
  double _velX = 0, _velY = 0; // radians/ms
  DateTime? _lastTime;
  static const _friction = 0.92;

  // Spring-back to zero (double-tap)
  late final AnimationController _springCtrl;
  late Animation<_Angles> _springAnim;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker(_onTick);

    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _springAnim = _buildSpringAnim((x: 0, y: 0));
    _springCtrl.addListener(() => _notifier.value = _springAnim.value);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _springCtrl.dispose();
    _notifier.dispose();
    super.dispose();
  }

  // ── Inertia ticker ────────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    final dt = _lastTime == null ? 16.0 : now.difference(_lastTime!).inMilliseconds.toDouble();
    _lastTime = now;

    _velX *= _friction;
    _velY *= _friction;

    final cur = _notifier.value;
    _notifier.value = (x: cur.x + _velX * dt, y: cur.y + _velY * dt);

    if (_velX.abs() < 0.00005 && _velY.abs() < 0.00005) {
      _ticker.stop();
      _lastTime = null;
    }
  }

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _onPanUpdate(DragUpdateDetails d, BoxConstraints c) {
    if (_springCtrl.isAnimating) _springCtrl.stop();
    if (_ticker.isActive) _ticker.stop();

    // Convert pixel delta → radians (full drag across widget = ~2π)
    final dX = d.delta.dy / c.maxHeight * 2 * pi;
    final dY = d.delta.dx / c.maxWidth  * 2 * pi;

    final now = DateTime.now();
    final dt = (_lastTime == null ? 16.0 : now.difference(_lastTime!).inMilliseconds.toDouble())
        .clamp(1.0, 50.0);
    _lastTime = now;

    _velX = dX / dt;
    _velY = dY / dt;

    final cur = _notifier.value;
    _notifier.value = (x: cur.x + dX, y: cur.y + dY);
  }

  void _onPanEnd(DragEndDetails _) {
    _lastTime = null;
    if (_velX.abs() > 0.00005 || _velY.abs() > 0.00005) {
      _ticker.start();
    }
  }

  void _onDoubleTap() {
    _ticker.stop();
    _springCtrl.stop();
    _velX = _velY = 0;
    _springAnim = _buildSpringAnim(_notifier.value);
    _springCtrl.forward(from: 0);
  }

  Animation<_Angles> _buildSpringAnim(_Angles from) {
    return _AnglesTween(begin: from, end: (x: 0, y: 0))
        .animate(CurvedAnimation(parent: _springCtrl, curve: Curves.easeOutBack));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return GestureDetector(
        onPanUpdate: (d) => _onPanUpdate(d, constraints),
        onPanEnd: _onPanEnd,
        onDoubleTap: _onDoubleTap,
        child: Center(
          child: ListenableBuilder(
            listenable: _notifier,
            builder: (_, child) {
              final a = _notifier.value;
              return Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateX(a.x)
                  ..rotateY(a.y),
                child: _buildCard(a, child!),
              );
            },
            child: _buildImageLayer(),
          ),
        ),
      );
    });
  }

  Widget _buildImageLayer() => RepaintBoundary(
    child: widget.isNetworkImage
        ? Image.network(widget.imagePath, fit: BoxFit.cover)
        : Image.file(File(widget.imagePath), fit: BoxFit.cover),
  );

  Widget _buildCard(_Angles a, Widget imageChild) {
    // Normalize angles to -1..1 for shadow + glare direction
    final nx = sin(a.y).clamp(-1.0, 1.0); // left-right tilt feel
    final ny = sin(a.x).clamp(-1.0, 1.0); // up-down tilt feel

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 32,
            offset: Offset(nx * 28, ny * 28),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(fit: StackFit.expand, children: [
          imageChild,
          RepaintBoundary(child: _GlareOverlay(notifier: _notifier)),
          // Border
          IgnorePointer(child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24, width: 1),
            ),
          )),
        ]),
      ),
    );
  }
}

// ── Tween for _Angles ─────────────────────────────────────────────────────

class _AnglesTween extends Tween<_Angles> {
  _AnglesTween({required super.begin, required super.end});

  @override
  _Angles lerp(double t) => (
    x: begin!.x + (end!.x - begin!.x) * t,
    y: begin!.y + (end!.y - begin!.y) * t,
  );
}

// ── Glare overlay ─────────────────────────────────────────────────────────

class _GlareOverlay extends StatelessWidget {
  const _GlareOverlay({required this.notifier});
  final ValueNotifier<_Angles> notifier;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: notifier,
    builder: (_, __) => CustomPaint(
      painter: _GlarePainter(notifier.value),
    ),
  );
}

class _GlarePainter extends CustomPainter {
  const _GlarePainter(this.angles);
  final _Angles angles;

  @override
  void paint(Canvas canvas, Size size) {
    final nx = sin(angles.y); // -1..1
    final ny = sin(angles.x); // -1..1

    final cx = size.width  * (0.5 - nx * 0.4);
    final cy = size.height * (0.5 - ny * 0.4);
    final radius = size.longestSide * 0.85;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.32),
          Colors.white.withOpacity(0.07),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_GlarePainter old) =>
      old.angles.x != angles.x || old.angles.y != angles.y;
}
