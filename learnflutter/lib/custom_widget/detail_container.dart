

import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_assets.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/core/global/func_global.dart';
import 'package:learnflutter/core/utils/extension/extension_widget.dart';
import 'package:learnflutter/core/utils/image_helper.dart';
import 'package:learnflutter/custom_widget/app_text.dart';
import 'package:learnflutter/custom_widget/tap.dart';
import 'package:learnflutter/shared/widgets/enable_widget.dart';

class DetailContainer extends StatelessWidget {
  const DetailContainer({
    super.key,
    this.title = '',
    this.enable = true,
    this.requiredMark = false,
    this.child,
    this.onTap,
    this.onLongTap,
    this.minHeight,
    this.alignment,
    this.padding,
  });

  final String title;
  final bool enable;
  final bool requiredMark;
  final Widget? child;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final double? minHeight;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;

  factory DetailContainer.icon({
    String title = '',
    bool enable = true,
    Widget? child,
    VoidCallback? onTap,
    VoidCallback? onTapRightIcon,
    VoidCallback? onLongTap,
    double? minHeight,
    AlignmentGeometry? alignment,
    required String rightIcon,
    bool requiredMark = false,
    EdgeInsetsGeometry? padding,
  }) {
    return DetailContainer(
      padding: padding,
      title: title,
      enable: enable,
      onTap: onTap,
      onLongTap: onLongTap,
      minHeight: minHeight,
      alignment: alignment,
      requiredMark: requiredMark,
      child: Row(
        children: [
          Expanded(child: child ?? const SizedBox.shrink()),
          Builder(builder: (context) {
            return ImageHelper.loadFromAsset(
              rightIcon,
              width: minHeight == null ? DeviceDimension.icon25 : null,
              tintColor: enable ? getThemeBloc(context).state.tokens.colors.onSurface : getThemeBloc(context).state.tokens.colors.onSurface,
            ).onTap(
              onTapRightIcon,
            );
          }), 
        ],
      ),
    );
  }

  factory DetailContainer.arrowDown({
    String title = '',
    bool enable = true,
    Widget? child,
    VoidCallback? onTap,
    VoidCallback? onTapRightIcon,
    double? minHeight,
    AlignmentGeometry? alignment,
    bool requiredMark = false,
    String? rightIcon,
    EdgeInsetsGeometry? padding,
  }) {
    return DetailContainer.icon(
      onTapRightIcon: onTapRightIcon,
      title: title,
      enable: enable,
      onTap: onTap,
      minHeight: minHeight,
      alignment: alignment,
      rightIcon: rightIcon ?? AppAssets.iconHomeRefresh ,
      requiredMark: requiredMark,
      padding: padding,
      child: child,
    );
  }

  factory DetailContainer.calendar({
    String title = '',
    bool enable = true,
    Widget? child,
    VoidCallback? onTap,
    double? minHeight,
    AlignmentGeometry? alignment,
    bool requiredMark = false,
  }) {
    return DetailContainer.icon(
      title: title,
      enable: enable,
      onTap: onTap,
      minHeight: minHeight,
      alignment: alignment,
      rightIcon: AppAssets.iconHomeWalletInactive,
      requiredMark: requiredMark,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = enable ? getThemeBloc(context).state.tokens.colors.primary : getThemeBloc(context).state.tokens.colors.onPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min, 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: DeviceDimension.padding / 4),
            child: AppText(
              title,
              requiredMark: requiredMark,
              style: getThemeBloc(context).state.tokens.texts.bodyMedium.toTextStyle(getThemeBloc(context).state.tokens.colors.onSurface),
            ),
          ),
        EnableWidget(
          enable: enable,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(width: 0.8, color: borderColor),
            borderRadius: BorderRadius.circular(DeviceDimension.padding / 8),
          ),
          child: Builder(builder: (context) {
            if (onTap != null) {
              return Tap(
                onTap: onTap,
                onLongTap: onLongTap,
                child: Container(alignment: alignment, padding: padding , width: double.infinity, child: child),
              );
            }
            return Container(alignment: alignment, padding: padding , width: double.infinity, child: child);
          }),
        ),
      ],
    );
  }
}
