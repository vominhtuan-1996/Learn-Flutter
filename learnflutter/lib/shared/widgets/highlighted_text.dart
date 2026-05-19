import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';

class HighlightedText extends StatelessWidget {
  final String message;
  final Map<String, TextStyle> highlights; // mỗi từ highlight có style riêng
  final TextStyle? style;

  const HighlightedText({
    super.key,
    required this.message,
    required this.highlights,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle normalStyle = style ?? AppTextStyles.themeBodyMedium;

    if (message.isEmpty || highlights.isEmpty) {
      return Text(message, style: normalStyle);
    }

    // Tạo regex từ tất cả highlight
    final pattern = RegExp(
      highlights.keys.map(RegExp.escape).join('|'),
      caseSensitive: false,
    );

    final spans = <TextSpan>[];
    int start = 0;

    for (final match in pattern.allMatches(message)) {
      // đoạn trước highlight
      if (match.start > start) {
        spans.add(TextSpan(
          text: message.substring(start, match.start),
          style: normalStyle,
        ));
      }

      final matchedText = message.substring(match.start, match.end);

      // Lấy style đúng (so sánh ignoreCase)
      final key = highlights.keys.firstWhere(
        (k) => k.toLowerCase() == matchedText.toLowerCase(),
        orElse: () => "",
      );

      final highlightStyle = highlights[key] ?? normalStyle;

      // đoạn highlight
      spans.add(TextSpan(
        text: matchedText,
        style: highlightStyle,
      ));
      start = match.end;
    }

    // phần còn lại
    if (start < message.length) {
      spans.add(TextSpan(
        text: message.substring(start),
        style: normalStyle,
      ));
    }

    return Text.rich(TextSpan(children: spans));
  }
}
