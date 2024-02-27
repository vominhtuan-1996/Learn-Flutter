import 'package:flutter/material.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/common_button.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/extended_fab.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/fab_button.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/icon_button.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/segmented_button.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

enum MaterialButtonType {
  commonbutton,
  fab,
  extendedfab,
  iconbutton,
  segmentedbutton,
}

class MaterialButton3 extends StatefulWidget {
  const MaterialButton3({
    super.key,
    required this.type,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.lableText,
    required this.borderRadius,
    this.borderColor = Colors.transparent,
    this.backgoundColor = Colors.transparent,
    this.shadowColor = Colors.transparent,
    this.prefixIcon,
    this.suffixIcon,
    this.labelTextStyle,
    this.prefixColor = Colors.transparent,
    this.suffixColor = Colors.transparent,
    this.shadowOffset = const Offset(0.6, -2),
    this.fabIcon,
    this.fabIconColor = Colors.transparent,
  });
  final MaterialButtonType type;
  final String? lableText;
  final TextStyle? labelTextStyle;
  final void Function()? onTap;
  final void Function()? onDoubleTap;
  final void Function()? onLongPress;

  final double borderRadius;
  final Color borderColor;
  final Color backgoundColor;
  final Color shadowColor;
  final Color prefixColor;
  final Color suffixColor;
  final IconData? fabIcon;
  final Color fabIconColor;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Offset shadowOffset;
  @override
  State<MaterialButton3> createState() => _MaterialButtonState();
}

class _MaterialButtonState extends State<MaterialButton3> {
  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    switch (widget.type) {
      case MaterialButtonType.commonbutton:
        child = CommonButton(widget: widget);
        break;
      case MaterialButtonType.fab:
        child = FabButton(widget: widget);
        break;
      case MaterialButtonType.extendedfab:
        child = ExtendedFAB(widget: widget);
        break;
      case MaterialButtonType.iconbutton:
        child = MaterialIconButton3(widget: widget);
        break;
      case MaterialButtonType.segmentedbutton:
        child = SegmentedButton3(widget: widget);
        break;
      default:
    }
    return child;
  }
}
