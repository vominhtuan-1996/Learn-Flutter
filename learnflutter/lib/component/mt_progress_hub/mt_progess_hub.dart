import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MTProgressHub {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, {String? message}) {
    if (_currentOverlay != null) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _currentOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(dismissible: false, color: Colors.black54),
          Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.white,
              size: 50.0,
            ),
          ),
        ],
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
