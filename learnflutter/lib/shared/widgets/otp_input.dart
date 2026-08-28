import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/app/theme/app_colors.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';

enum OtpInputStyle { box, underline }

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final OtpInputStyle style;

  const OtpInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscure = false,
    this.style = OtpInputStyle.box,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // paste: distribute chars across fields
      final chars = value.split('');
      for (int i = 0; i < widget.length && i < chars.length; i++) {
        _controllers[index + i < widget.length ? index + i : widget.length - 1]
            .text = chars[i];
      }
      final next = (index + chars.length).clamp(0, widget.length - 1);
      FocusScope.of(context).requestFocus(_focusNodes[next]);
    } else if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
    }

    widget.onChanged?.call(_value);
    if (_value.length == widget.length) {
      widget.onCompleted?.call(_value);
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
      widget.onChanged?.call(_value);
    }
  }

  InputDecoration _decoration(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    if (widget.style == OtpInputStyle.box) {
      return InputDecoration(
        counterText: '',
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: isFocused,
        fillColor: AppColors.primary.withOpacity(0.05),
      );
    }
    return InputDecoration(
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightGrey, width: 2),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Container(
          width: 48,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Focus(
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                _onBackspace(i);
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              obscureText: widget.obscure,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: AppTextStyles.textStyleManrope(
                AppColors.primaryText,
                20,
                FontWeight.w700,
              ),
              decoration: _decoration(i),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}
