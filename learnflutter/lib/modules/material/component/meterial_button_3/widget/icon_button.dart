import 'package:flutter/material.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';

class MaterialIconButton3 extends StatelessWidget {
  //Extended floating action buttons (extended FABs) help people take primary actions
  const MaterialIconButton3({
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
        child: GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          onLongPress: widget.onLongPress,
          child: Padding(
            padding: EdgeInsets.all(DeviceDimension.padding / 2),
            child: Icon(
              widget.fabIcon,
              color: widget.fabIconColor,
            ),
          ),
        ),
      ),
    );
  }
}
