import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/common_button.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/extended_fab.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/fab_button.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/icon_button.dart';
import 'package:learnflutter/modules/material/component/meterial_button_3/widget/segmented_button.dart';
import 'package:learnflutter/app/app_colors.dart';

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
    this.textAlign = TextAlign.center,
    this.disible = false,
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
  final TextAlign? textAlign;
  final bool disible;

  factory MaterialButton3.icon({
    required VoidCallback? onPressed,
    final double borderRadius = 16.0,
    required final IconData fabIcon,
    IconAlignment iconAlignment = IconAlignment.start,
    final Color backgoundColor = AppColors.primary,
    final Color fabIconColor = AppColors.primaryText,
    final Color shadowColor = Colors.transparent,
    final Offset shadowOffset = Offset.zero,
  }) {
    return MaterialButton3(
      type: MaterialButtonType.iconbutton,
      borderRadius: borderRadius,
      fabIcon: fabIcon,
      onTap: onPressed,
      backgoundColor: backgoundColor,
      fabIconColor: fabIconColor,
      shadowColor: shadowColor,
      shadowOffset: shadowOffset,
    );
  }

  factory MaterialButton3.extended({
    required VoidCallback? onPressed,
    final double borderRadius = 16.0,
    required final IconData prefixIcon,
    final Color prefixColor = AppColors.primaryText,
    IconAlignment iconAlignment = IconAlignment.start,
    final Color backgoundColor = AppColors.primary,
    final Color shadowColor = Colors.transparent,
    final Offset shadowOffset = Offset.zero,
    required final String lableText,
    final TextStyle? labelTextStyle,
  }) {
    return MaterialButton3(
      type: MaterialButtonType.extendedfab,
      borderRadius: borderRadius,
      prefixIcon: prefixIcon,
      prefixColor: prefixColor,
      onTap: onPressed,
      backgoundColor: backgoundColor,
      shadowColor: shadowColor,
      shadowOffset: shadowOffset,
      lableText: lableText,
      labelTextStyle: labelTextStyle,
    );
  }

  factory MaterialButton3.common({
    required VoidCallback? onPressed,
    final double borderRadius = 16.0,
    required final IconData prefixIcon,
    final Color backgoundColor = AppColors.primary,
    final Color shadowColor = Colors.transparent,
    final Offset shadowOffset = Offset.zero,
    required final String lableText,
    final TextStyle? labelTextStyle,
  }) {
    return MaterialButton3(
      type: MaterialButtonType.commonbutton,
      borderRadius: borderRadius,
      onTap: onPressed,
      backgoundColor: backgoundColor,
      shadowColor: shadowColor,
      shadowOffset: shadowOffset,
      lableText: lableText,
      labelTextStyle: labelTextStyle,
    );
  }

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
