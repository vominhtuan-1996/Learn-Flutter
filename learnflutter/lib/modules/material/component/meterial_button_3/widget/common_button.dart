import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/material_button_3.dart';

class CommonButton extends StatelessWidget {
  //Common buttons prompt most actions in a UI
  const CommonButton({
    super.key,
    required this.widget,
  });

  final MaterialButton3 widget;

  @override
  Widget build(BuildContext context) {
    double opacityDisible = 0.3;
    double opacity = 1;
    return AbsorbPointer(
      absorbing: widget.disible,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: widget.borderColor.withOpacity(widget.disible ? opacityDisible : opacity)),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withOpacity(0.3),
                spreadRadius: (widget.shadowOffset != Offset.zero) ? 1 : 0,
                blurRadius: (widget.shadowOffset != Offset.zero) ? 2 : 0,
                offset: widget.shadowOffset,
              ),
            ],
            color: widget.backgoundColor.withOpacity(widget.disible ? opacityDisible : opacity),
          ),
          child: Row(
            children: [
              (widget.prefixIcon != null)
                  ? Icon(
                      widget.prefixIcon,
                      color: widget.prefixColor,
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.all(DeviceDimension.padding / 2),
                child: Text(
                  widget.lableText ?? '',
                  style: widget.labelTextStyle,
                  textAlign: widget.textAlign,
                ),
              ),
              (widget.suffixIcon != null)
                  ? Icon(
                      widget.suffixIcon,
                      color: widget.suffixColor,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
