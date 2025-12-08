import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

class HighlightedText extends StatelessWidget {
  final String message;
  final String texthighlight;
  final TextStyle? style;
  final TextStyle highlightStyle;

  const HighlightedText({
    super.key,
    required this.message,
    required this.texthighlight,
    this.style,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> listAttributed = [];

    // Sử dụng style mặc định nếu không truyền vào
    final TextStyle normalStyle = style ?? context.theme.textTheme.bodyMedium!.copyWith(color: context.theme.colorScheme.onPrimary);

    if (message.isNotEmpty && texthighlight.isNotEmpty) {
      String lowerMessage = message.toLowerCase();
      String lowerHighlight = texthighlight.toLowerCase(); 
      int idx = lowerMessage.indexOf(lowerHighlight);

      if (idx >= 0 && lowerMessage != lowerHighlight) {
        // Cắt message thành 3 phần: trước, highlight, sau
        final parts = [
          message.substring(0, idx),
          message.substring(idx, idx + texthighlight.length),
          message.substring(idx + texthighlight.length),
        ];
        for (int i = 0; i < parts.length; i++) {
          listAttributed.add(TextSpan(
            text: parts[i],
            style: i == 1 ? highlightStyle : normalStyle,
          ));
        }
      } else {
        // Không tìm thấy highlight hoặc highlight == message
        listAttributed.add(TextSpan(text: message, style: normalStyle));
      }
    } else {
      // Trường hợp message hoặc texthighlight rỗng
      listAttributed.add(TextSpan(text: message, style: normalStyle));
    }
    return Text.rich(TextSpan(children: listAttributed));
  }
}
