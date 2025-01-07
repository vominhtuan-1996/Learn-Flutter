import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DragWidget extends StatefulWidget {
  const DragWidget({super.key});

  @override
  State<DragWidget> createState() => _DragWidgetState();
}

class _DragWidgetState extends State<DragWidget> {
  double x = 0, y = 0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: RawGestureDetector(
        gestures: {
          AllowMultipleHorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleHorizontalDragGestureRecognizer>(
            () => AllowMultipleHorizontalDragGestureRecognizer(),
            (AllowMultipleHorizontalDragGestureRecognizer instance) {
              instance
                ..onUpdate = (details) {
                  x += details.delta.dx;
                  setState(() {});
                };
            },
          )
        },
        child: RawGestureDetector(
          gestures: {
            AllowMultipleVerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleVerticalDragGestureRecognizer>(
              () => AllowMultipleVerticalDragGestureRecognizer(),
              (AllowMultipleVerticalDragGestureRecognizer instance) {
                instance
                  ..onUpdate = (details) {
                    y += details.delta.dy;
                    setState(() {});
                  };
              },
            )
          },
          child: Container(
            width: 100,
            height: 100,
            color: Colors.lightBlue,
            child: Icon(
              Icons.games,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class AllowMultipleVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}

class AllowMultipleHorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
