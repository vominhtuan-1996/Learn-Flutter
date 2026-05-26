import 'package:flutter/material.dart';

import '../core/render_layer.dart';

/// Render text lên canvas — hữu ích cho HUD / debug / branding overlay.
class TextLayer extends RenderLayer {
  TextLayer({
    required this.text,
    this.style = const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(16),
    this.textAlign = TextAlign.center,
  });

  String text;
  TextStyle style;
  Alignment alignment;
  EdgeInsets padding;
  TextAlign textAlign;

  @override
  void update(double dt) {}

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    )..layout(maxWidth: size.width - padding.horizontal);

    final available = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );
    final dx = available.left + (available.width - tp.width) * ((alignment.x + 1) / 2);
    final dy = available.top + (available.height - tp.height) * ((alignment.y + 1) / 2);
    tp.paint(canvas, Offset(dx, dy));
  }
}
