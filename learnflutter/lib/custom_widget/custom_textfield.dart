import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/app/app_colors.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onTextChange,
    this.onFocusChange,
    required this.hintText,
    this.hintStyle,
    this.textStyle,
    this.focusTextStyle,
    required this.secureText,
    this.autoFocus,
    this.containerDecoration,
    this.focusContainerDecoration,
    required this.textAlign,
    required this.keyboardType,
    required this.borderRadius,
    this.paddingContainer,
    this.maxLine,
    this.maxLenght,
    this.minLines,
    this.inputFormatters,
    required this.textCapitalization,
    this.enabled,
    required this.isShowCounterText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
  TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onTextChange;
  final ValueChanged<bool>? onFocusChange;
  final String hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final TextStyle? focusTextStyle;
  final bool secureText;
  final bool? autoFocus;
  final BoxDecoration? containerDecoration;
  final BoxDecoration? focusContainerDecoration;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final double borderRadius;
  final EdgeInsetsGeometry? paddingContainer;
  final int? maxLine;
  final int? maxLenght;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool? enabled;
  final bool isShowCounterText;
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode focusNode = FocusNode();
  bool focus = false;

  void _focusChange() {
    setState(() {
      focus = focusNode.hasFocus;
    });
    if (widget.onFocusChange != null) widget.onFocusChange!(focusNode.hasFocus);
  }

  @override
  void initState() {
    widget.controller ??= TextEditingController();

    focusNode.addListener(_focusChange);
    super.initState();
  }

  @override
  void dispose() {
    focusNode.removeListener(_focusChange);
    super.dispose();
  }

  BoxDecoration getDecoration() {
    if (focus) {
      return widget.focusContainerDecoration ??
          widget.containerDecoration ??
          BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(width: 1, color: AppColors.primary),
          );
    }

    return widget.containerDecoration ??
        BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(width: 1, color: Colors.transparent),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.paddingContainer ?? const EdgeInsets.symmetric(horizontal: 8),
      decoration: getDecoration(),
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.prefixIcon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: widget.prefixIcon!,
              ),
            Expanded(
              child: TextField(
                maxLength: widget.maxLenght,
                controller: widget.controller,
                textAlign: widget.textAlign,
                onChanged: widget.onTextChange,
                textCapitalization: widget.textCapitalization,
                style: focus ? (widget.focusTextStyle ?? widget.textStyle) : widget.textStyle,
                obscureText: widget.secureText,
                enableSuggestions: !widget.secureText,
                autocorrect: !widget.secureText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                decoration: InputDecoration(
                  counterText: widget.isShowCounterText ? null : '',
                  counterStyle: const TextStyle(color: AppColors.primary),
                  isCollapsed: true,
                  hintText: widget.hintText,
                  hintStyle: widget.hintStyle,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  prefixIconConstraints: const BoxConstraints(maxWidth: 20, maxHeight: 20),
                ),
                maxLines: widget.maxLine,
                minLines: widget.minLines,
                onTapOutside: (event) {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                },
              ),
            ),
            if (widget.suffixIcon != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.controller?.text = '';
                    });
                  },
                  child: widget.suffixIcon!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
