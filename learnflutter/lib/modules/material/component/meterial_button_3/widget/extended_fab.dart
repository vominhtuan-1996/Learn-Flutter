import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';

class ExtendedFAB extends StatelessWidget {
  //Extended floating action buttons (extended FABs) help people take primary actions
  const ExtendedFAB({
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
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        child: Row(
          children: [
            if (widget.prefixIcon != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DeviceDimension.padding / 2),
                child: Icon(
                  widget.prefixIcon,
                  color: widget.prefixColor,
                ),
              )
            else
              Container(),
            Expanded(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: DeviceDimension.padding / 2),
              child: Text(
                widget.lableText ?? '',
                style: widget.labelTextStyle,
                textAlign: TextAlign.left,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
