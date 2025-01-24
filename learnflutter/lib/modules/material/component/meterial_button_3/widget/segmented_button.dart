import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/common_button.dart';

class SegmentedButton3 extends StatelessWidget {
  // Segmented buttons help people select options, switch views, or sort elements
  const SegmentedButton3({
    super.key,
    required this.widget,
  });

  final MaterialButton3 widget;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: widget.borderColor),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor.withOpacity(0.3),
              spreadRadius: (widget.shadowOffset != Offset.zero) ? 1 : 0,
              blurRadius: (widget.shadowOffset != Offset.zero) ? 2 : 0,
              offset: widget.shadowOffset,
            ),
          ],
          color: widget.backgoundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: CommonButton(widget: widget),
            ),
            Expanded(
              flex: 1,
              child: CommonButton(widget: widget),
            ),
            Expanded(
              flex: 1,
              child: CommonButton(widget: widget),
            ),
          ],
        ));
  }
}
