import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/core/debound.dart';
import 'package:learnflutter/core/device_dimension.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/src/app_colors.dart';

class MaterialTextField extends StatefulWidget {
  MaterialTextField({
    super.key,
    this.onChanged,
    this.controller,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.minLines,
    this.hintText,
    this.focusedBorderColor,
    this.decorationBorderColor,
    this.helperText,
    this.counterText,
    this.onFocusChange,
    this.helperStyle,
    this.counterStyle,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.onPrefixIconIconPressed,
    this.onSuffixIconPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconColor,
    this.suffixIconColor,
    this.cursorColor,
    this.enabledBorderColor,
    this.disabledBorderColor,
    this.readOnly,
    this.enabled,
  });
  final void Function(String)? onChanged;
  final ValueChanged<bool>? onFocusChange;
  final void Function()? onPrefixIconIconPressed;
  final void Function()? onSuffixIconPressed;
  TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final String? hintText;
  final Color? focusedBorderColor;
  final Color? decorationBorderColor;
  final String? helperText;
  final TextStyle? helperStyle;
  final String? counterText;
  final TextStyle? counterStyle;

  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final IconData? prefixIcon;
  final IconData? suffixIcon;

  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final Color? cursorColor;
  final Color? enabledBorderColor;
  final Color? disabledBorderColor;
  final bool? readOnly;
  final bool? enabled;

  @override
  State<MaterialTextField> createState() => _MaterialTextFieldState();
}

class _MaterialTextFieldState extends State<MaterialTextField> {
  final FocusNode focusNode = FocusNode();
  bool focus = false;
  final boxConstraintZero = const BoxConstraints(
    maxWidth: 0,
    maxHeight: 0,
  );
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
    Debounce().removeTimer();
    focusNode.removeListener(_focusChange);
    super.dispose();
  }

  void dismissKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(borderSide: BorderSide(color: widget.decorationBorderColor ?? Colors.red));
    OutlineInputBorder focusedBorder = OutlineInputBorder(borderSide: BorderSide(color: widget.focusedBorderColor ?? Colors.teal));
    OutlineInputBorder enabledBorder = OutlineInputBorder(borderSide: BorderSide(color: widget.enabledBorderColor ?? Colors.teal));
    OutlineInputBorder disabledBorder = OutlineInputBorder(borderSide: BorderSide(color: widget.disabledBorderColor ?? Colors.teal));
    return Padding(
      padding: EdgeInsets.all(DeviceDimension.padding / 2),
      child: TextField(
        enabled: widget.enabled,
        readOnly: widget.readOnly ?? false,
        focusNode: focusNode,
        onChanged: widget.onChanged,
        onTapOutside: (event) async {
          if (mounted) {
            Debounce().runAfter(rate: 500, action: dismissKeyboard);
          }
        },
        controller: widget.controller,
        inputFormatters: widget.inputFormatters,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        cursorColor: widget.cursorColor ?? Colors.grey,
        decoration: InputDecoration(
          enabledBorder: enabledBorder,
          disabledBorder: disabledBorder,
          border: border,
          focusedBorder: focusedBorder,
          helperText: widget.helperText,
          helperStyle: widget.helperStyle,
          counterText: widget.counterText,
          counterStyle: widget.counterStyle,
          hintText: widget.hintText,
          hintStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.grey.withOpacity(0.7)),
          labelText: widget.hintText,
          labelStyle: context.textTheme.bodyMedium?.copyWith(color: Colors.grey.withOpacity(0.7)),
          fillColor: context.theme.inputDecorationTheme.fillColor,
          contentPadding: EdgeInsets.symmetric(horizontal: DeviceDimension.padding / 2, vertical: DeviceDimension.padding / 4),
          prefixIconConstraints: widget.prefixIconConstraints ?? boxConstraintZero,
          suffixIconConstraints: widget.suffixIconConstraints ?? boxConstraintZero,
          prefixIconColor: widget.prefixIconColor,
          suffixIconColor: widget.suffixIconColor,
          prefixIcon: (widget.prefixIcon != null)
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: DeviceDimension.padding / 4),
                  child: GestureDetector(
                    onTap: widget.onPrefixIconIconPressed,
                    child: ConstrainedBox(
                        constraints: widget.prefixIconConstraints ?? boxConstraintZero,
                        child: Icon(
                          widget.prefixIcon,
                        )),
                  ),
                )
              : Container(),
          suffixIcon: (widget.suffixIcon != null)
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: DeviceDimension.padding / 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.controller = TextEditingController(text: '');
                      });
                      if (widget.onSuffixIconPressed != null) {
                        widget.onSuffixIconPressed;
                      }
                    },
                    child: ConstrainedBox(constraints: widget.suffixIconConstraints ?? boxConstraintZero, child: Icon(widget.suffixIcon)),
                  ),
                )
              : Container(
                  width: 0,
                ),
        ),
      ),
    );
  }
}
