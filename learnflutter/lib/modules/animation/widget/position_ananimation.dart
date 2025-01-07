import 'package:flutter/material.dart';

class PositionedTransitionWidget extends StatefulWidget {
  const PositionedTransitionWidget({super.key});

  @override
  State<PositionedTransitionWidget> createState() => _PositionedTransitionWidgetState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _PositionedTransitionWidgetState extends State<PositionedTransitionWidget> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double smallLogo = 100;
    const double bigLogo = 200;
    // _controller.repeat(reverse: true);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final Size biggest = constraints.biggest;
        return Stack(
          children: <Widget>[
            PositionedTransition(
              rect: RelativeRectTween(
                begin: RelativeRect.fromSize(
                  const Rect.fromLTWH(0, 0, smallLogo, smallLogo),
                  biggest,
                ),
                end: RelativeRect.fromSize(
                  Rect.fromLTWH(biggest.width - bigLogo, biggest.height - bigLogo, bigLogo, bigLogo),
                  biggest,
                ),
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticInOut,
              )),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: FlutterLogo(),
              ),
            ),
          ],
        );
      },
    );
  }
}
