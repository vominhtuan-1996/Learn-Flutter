// ignore: file_names
// ignore_for_file: prefer_initializing_formals, unnecessary_null_comparison, must_be_immutable

import 'package:flutter/material.dart';

/// param bắt buộc :
///
enum AttriButedString {
  attriButedChar,
  attriButedText,
  attriButedRange,
  attriButedCustom,
}

/// type[attriButedChar] {[messagem],[charHighlight],[ignoreCase]}
/// type[attriButedText] {[messagem],[texthighlight],[ignoreCase]}
/// type[attriButedRange] {[messagem],[start],[end]}
/// type[attriButedCustom] {[listAttributedCustom]}
///
class AttributedStringWidget extends StatelessWidget {
  const AttributedStringWidget({
    super.key,
    this.listAttributedCustom,
    this.texthighlight,
    this.message,
    this.typeAttriButed = AttriButedString.attriButedChar,
    this.charHighlight,
    this.style,
    this.highlightStyle,
    this.ignoreCase,
    this.highlightColor = Colors.black,
    this.start,
    this.end,
  });
  final String? message;
  final bool? ignoreCase;
  final AttriButedString typeAttriButed;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final Color highlightColor;
  // Text

  final String? texthighlight;

  // Char
  final String? charHighlight;

  // Range
  final int? start;
  final int? end;

  // Custom
  final List<InlineSpan>? listAttributedCustom;

  factory AttributedStringWidget.charecter({
    required String message,
    required String charHighlight,
    TextStyle? style,
    TextStyle? highlightStyle,
    Color highlightColor = Colors.black,
    bool ignoreCase = true,
  }) {
    AttributedStringWidget widget = AttributedStringWidget(
      message: message,
      charHighlight: charHighlight,
      typeAttriButed: AttriButedString.attriButedChar,
      style: style,
      highlightStyle: highlightStyle,
      highlightColor: highlightColor,
      ignoreCase: ignoreCase,
    );
    return widget;
  }

  factory AttributedStringWidget.text({
    required String message,
    required String texthighlight,
    TextStyle? style,
    TextStyle? highlightStyle,
    Color highlightColor = Colors.black,
    bool ignoreCase = true,
  }) {
    AttributedStringWidget widget = AttributedStringWidget(
      message: message,
      texthighlight: texthighlight,
      typeAttriButed: AttriButedString.attriButedText,
      style: style,
      highlightStyle: highlightStyle,
      highlightColor: highlightColor,
      ignoreCase: ignoreCase,
    );
    return widget;
  }

  factory AttributedStringWidget.range({
    required String message,
    required int start,
    required int end,
    TextStyle? style,
    TextStyle? highlightStyle,
    Color highlightColor = Colors.black,
    bool ignoreCase = true,
  }) {
    AttributedStringWidget widget = AttributedStringWidget(
      message: message,
      start: start,
      end: end,
      typeAttriButed: AttriButedString.attriButedRange,
      style: style,
      highlightStyle: highlightStyle,
      highlightColor: highlightColor,
      ignoreCase: ignoreCase,
    );
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return widgetAttriButedWithType(
        textHighlight: texthighlight ?? "",
        type: typeAttriButed,
        message: message ?? "",
        charHighlight: charHighlight ?? "",
        style: style ?? const TextStyle(color: Colors.blue),
        highlightStyle: highlightStyle ?? const TextStyle(color: Colors.red),
        highlightColor: highlightColor,
        ignoreCase: ignoreCase ?? true,
        start: start,
        end: end,
        listAttributedCustom: listAttributedCustom);
  }
}

Widget widgetAttriButedWithType({
  required AttriButedString type,
  required String message,
  required String charHighlight,
  required String textHighlight,
  required TextStyle style,
  required TextStyle highlightStyle,
  required Color highlightColor,
  required bool ignoreCase,
  int? start,
  int? end,
  List<InlineSpan>? listAttributedCustom,
}) {
  Widget attriButedWiget;
  switch (type) {
    case AttriButedString.attriButedChar:
      attriButedWiget = HighlightAtributedChar(
        charHighlight: charHighlight,
        highlightColor: highlightColor,
        highlightStyle: highlightStyle,
        ignoreCase: ignoreCase,
        message: message,
        style: style,
      );
      break;
    case AttriButedString.attriButedText:
      attriButedWiget = HighlightAttriButedText(
        texthighlight: textHighlight,
        highlightColor: highlightColor,
        highlightStyle: highlightStyle,
        ignoreCase: ignoreCase,
        message: message,
        style: style,
      );
      break;
    case AttriButedString.attriButedRange:
      attriButedWiget = HighlightAttriButedRange(
        start: start,
        end: end,
        highlightColor: highlightColor,
        highlightStyle: highlightStyle,
        ignoreCase: ignoreCase,
        message: message,
        style: style,
      );
      break;
    case AttriButedString.attriButedCustom:
      attriButedWiget = HighlightAttriButedCustom(
        listAttributed: listAttributedCustom!,
      );
      break;
  }
  return attriButedWiget;
}

class HighlightAtributedChar extends StatelessWidget {
  final String message;
  final String charHighlight;
  final TextStyle style;
  final TextStyle highlightStyle;
  final Color highlightColor;
  final bool ignoreCase;

  const HighlightAtributedChar({
    super.key,
    required this.message,
    required this.charHighlight,
    required this.style,
    required this.highlightStyle,
    required this.highlightColor,
    required this.ignoreCase,
  });

  @override
  Widget build(BuildContext context) {
    final text = message;
    if ((charHighlight.isEmpty) || text.isEmpty) {
      return Text(text, style: style);
    }

    var sourceText = ignoreCase ? text.toLowerCase() : text;
    var targetHighlight = ignoreCase ? charHighlight.toLowerCase() : charHighlight;

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight = sourceText.indexOf(targetHighlight, start);
      if (indexOfHighlight < 0) {
        // no highlight
        spans.add(_normalSpan(text.substring(start)));
        break;
      }
      if (indexOfHighlight > start) {
        // normal text before highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
      }
      start = indexOfHighlight + charHighlight.length;
      spans.add(_highlightSpan(text.substring(indexOfHighlight, start)));
    } while (true);

    return Text.rich(TextSpan(children: spans));
  }

  TextSpan _highlightSpan(String content) {
    return TextSpan(text: content, style: highlightStyle);
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(text: content, style: style);
  }
}

class HighlightAttriButedText extends StatelessWidget {
  final String message;
  final String texthighlight;
  final TextStyle style;
  final TextStyle highlightStyle;
  final Color highlightColor;
  final bool ignoreCase;

  const HighlightAttriButedText({
    super.key,
    required this.message,
    required this.texthighlight,
    required this.style,
    required this.highlightStyle,
    required this.highlightColor,
    required this.ignoreCase,
  });

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> listAttributed = [];
    List parts = [];
    if (message != null && texthighlight != null) {
      int idx = message.indexOf(texthighlight);
      if (idx >= 0) {
        parts = [message.substring(0, idx), texthighlight, message.substring(idx + texthighlight.length)];
        List.generate(
          parts.length,
          (index) {
            final text = TextSpan(text: parts[index], style: parts[index] == texthighlight ? highlightStyle : style);
            listAttributed.add(text);
          },
        );
      } else {
        print('faild');
      }
    }
    return Text.rich(TextSpan(children: listAttributed));
  }
}

class HighlightAttriButedRange extends StatelessWidget {
  final String message;
  final TextStyle style;
  final TextStyle highlightStyle;
  final Color highlightColor;
  final bool ignoreCase;
  final int? start;
  final int? end;
  const HighlightAttriButedRange({
    super.key,
    required this.message,
    required this.style,
    required this.highlightStyle,
    required this.highlightColor,
    required this.ignoreCase,
    this.start,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> listAttributed = [];
    listAttributed = [];
    List.generate(
      message.length,
      (index) {
        InlineSpan text = const TextSpan(text: '');
        if (index >= start! && index <= end!) {
          text = TextSpan(
            text: message[index],
            style: highlightStyle,
          );
          listAttributed.add(text);
        } else {
          text = TextSpan(
            text: message[index],
            style: style,
          );
          listAttributed.add(text);
        }
      },
    );

    // listAttributed.removeWhere((e) => listCharInRangetemp.contains(e));
    return Text.rich(TextSpan(children: listAttributed));
  }
}

class HighlightAttriButedCustom extends StatelessWidget {
  HighlightAttriButedCustom({
    super.key,
    required this.listAttributed,
  });
  List<InlineSpan> listAttributed;
  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: listAttributed));
  }
}
