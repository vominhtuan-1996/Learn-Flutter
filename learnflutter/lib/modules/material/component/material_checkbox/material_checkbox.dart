import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/core/app/app_colors.dart';

class MaterialCheckBox extends StatefulWidget {
  MaterialCheckBox({
    super.key,
    required this.isChecked,
    required this.onChangedCheck,
    required this.fillColor,
    this.checkedColor = AppColors.primary,
    this.borderColor = Colors.black,
    this.borderRadius = 2,
    this.scale = 1.5,
    this.side,
    required this.disible,
  });
  final ValueChanged<bool?>? onChangedCheck;
  late bool isChecked;
  final Color checkedColor;
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;
  final BorderSide? side;
  final double scale;
  final bool disible;

  @override
  State<MaterialCheckBox> createState() => MaterialCheckBoxState();
}

class MaterialCheckBoxState extends State<MaterialCheckBox> {
  double opacityDisible = 0.3;
  double opacity = 1;
  double sizeMaterial = 18;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color getColor(Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return widget.fillColor..withOpacity(widget.disible ? opacityDisible : opacity);
    }
    if (states.contains(WidgetState.disabled)) {
      return widget.fillColor.withOpacity(widget.disible ? opacityDisible : opacity);
    }
    return Colors.white.withOpacity(widget.disible ? opacityDisible : opacity);
  }

  OutlinedBorder shapeBorder(double borderRadius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: sizeMaterial * widget.scale, maxWidth: sizeMaterial * widget.scale),
      child: AbsorbPointer(
          absorbing: widget.disible,
          child: Stack(
            children: [
              Container(
                decoration: AppBoxDecoration.boxDecorationBorderRadius(
                  borderRadiusValue: widget.borderRadius * widget.scale,
                  borderWidth: widget.scale,
                  colorBorder: widget.borderColor,
                  colorBackground: widget.disible ? Colors.grey.withOpacity(opacityDisible) : Colors.transparent,
                ),
              ),
              Transform.scale(
                scale: widget.scale - 0.1,
                child: Checkbox(
                  shape: shapeBorder(widget.borderRadius),
                  side: BorderSide(
                    color: widget.isChecked ? widget.fillColor.withOpacity(widget.disible ? opacityDisible : opacity) : widget.borderColor.withOpacity(widget.disible ? opacityDisible : opacity),
                    width: 0,
                  ),
                  checkColor: widget.checkedColor.withOpacity(widget.disible ? opacityDisible : opacity),
                  fillColor: WidgetStateProperty.resolveWith(getColor),
                  value: widget.isChecked,
                  onChanged: (value) {
                    setState(() {
                      widget.isChecked = value ?? false;
                    });
                    widget.onChangedCheck;
                  },
                ),
              ),
            ],
          )),
    );
  }
}
