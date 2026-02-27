// ignore: file_names
// ignore_for_file: prefer_initializing_formals, unnecessary_null_comparison, must_be_immutable

import 'package:flutter/material.dart';

/// AttriButedString định nghĩa các phương thức làm nổi bật chuỗi ký tự khác nhau.
/// Việc phân loại này cho phép linh hoạt trong việc đánh dấu văn bản theo ký tự, từ hoặc phạm vi chỉ mục.
/// Nó giúp lập trình viên dễ dàng áp dụng các hiệu ứng thị giác khác nhau cho các phần cụ thể của nội dung.
enum AttriButedString {
  attriButedChar,
  attriButedText,
  attriButedRange,
  attriButedCustom,
}

/// AttributedStringWidget là một thành phần giao diện mạnh mẽ hỗ trợ hiển thị văn bản có định dạng.
/// Nó cung cấp khả năng làm nổi bật các từ khóa hoặc ký tự cụ thể trong một đoạn văn bản lớn.
/// Widget hỗ trợ nhiều chế độ làm nổi bật khác nhau thông qua các factory constructor chuyên dụng.
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

  /// Nội dung văn bản gốc cần được xử lý định dạng.
  final String? message;

  /// Cờ xác định có bỏ qua phân biệt chữ hoa chữ thường khi làm nổi bật hay không.
  final bool? ignoreCase;

  /// Loại cơ chế định dạng chuỗi được áp dụng cho widget hiện tại.
  final AttriButedString typeAttriButed;

  /// Kiểu dáng văn bản mặc định cho các phần không được làm nổi bật.
  final TextStyle? style;

  /// Kiểu dáng văn bản đặc biệt dành riêng cho phần được làm nổi bật.
  final TextStyle? highlightStyle;

  /// Màu sắc làm nổi bật mặc định nếu không cấu hình highlightStyle.
  final Color highlightColor;

  /// Chuỗi con hoặc đoạn văn bản cần tìm kiếm để làm nổi bật.
  final String? texthighlight;

  /// Ký tự cụ thể cần được làm nổi bật trong toàn bộ văn bản.
  final String? charHighlight;

  /// Chỉ số bắt đầu của phạm vi văn bản cần làm nổi bật.
  final int? start;

  /// Chỉ số kết thúc của phạm vi văn bản cần làm nổi bật.
  final int? end;

  /// Danh sách các InlineSpan tùy chỉnh cho phép xây dựng các cấu trúc văn bản phức tạp.
  final List<InlineSpan>? listAttributedCustom;

  /// Tạo một widget làm nổi bật theo ký tự cụ thể.
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

  /// Tạo một widget làm nổi bật theo một đoạn văn bản (chuỗi con).
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

  /// Tạo một widget làm nổi bật văn bản trong một phạm vi chỉ mục [start, end].
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

/// Hàm trợ giúp để khởi tạo widget xử lý định dạng văn bản dựa trên loại được yêu cầu.
/// Nó đóng vai trò như một bộ điều phối để chuyển đổi các tham số đầu vào thành widget hiển thị tương ứng.
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

/// HighlightAtributedChar xử lý việc làm nổi bật tất cả các ký tự cụ thể xuất hiện trong chuỗi văn bản.
/// Thuật toán tìm kiếm đệ quy đảm bảo mọi ký tự trùng khớp đều được áp dụng kiểu dáng định dạng yêu cầu.
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
    var targetHighlight =
        ignoreCase ? charHighlight.toLowerCase() : charHighlight;

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

/// HighlightAttriButedText cung cấp khả năng làm nổi bật một cụm từ hoặc chuỗi ký tự liền mạch.
/// Nó hữu dụng trong trường hợp hiển thị kết quả tìm kiếm hoặc nhấn mạnh các khái niệm chính trong văn bản.
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
      int idx = ignoreCase
          ? message.toLowerCase().indexOf(texthighlight.toLowerCase())
          : message.indexOf(texthighlight);

      if (idx >= 0) {
        parts = [
          message.substring(0, idx),
          message.substring(idx, idx + texthighlight.length),
          message.substring(idx + texthighlight.length),
        ];
        for (var index = 0; index < parts.length; index++) {
          final text = TextSpan(
            text: parts[index],
            style: index == 1 ? highlightStyle : style,
          );
          listAttributed.add(text);
        }
      } else {
        listAttributed.add(TextSpan(text: message, style: style));
      }
    }
    return Text.rich(TextSpan(children: listAttributed));
  }
}

/// HighlightAttriButedRange cho phép làm nổi bật văn bản dựa trên vị trí bắt đầu và kết thúc cụ thể.
/// Đây là phương thức định dạng chính xác nhất khi biết rõ tọa độ của phần văn bản cần nhấn mạnh.
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

    return Text.rich(TextSpan(children: listAttributed));
  }
}

/// HighlightAttriButedCustom cho phép hiển thị các InlineSpan đã được xây dựng sẵn từ bên ngoài.
/// Widget này cung cấp sự linh hoạt tối đa cho các trường hợp định dạng cực kỳ phức tạp hoặc đa dạng.
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
