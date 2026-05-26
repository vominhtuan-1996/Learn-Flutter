import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Signature builder cho phép custom hoàn toàn toolbar trên keyboard.
/// [length] là số ký tự hiện tại, [maxLength] là giới hạn (null nếu không giới hạn).
typedef KeyboardToolbarBuilder = Widget Function(
  BuildContext context,
  int length,
  int? maxLength,
  VoidCallback onDone,
);

/// Signature builder cho counter text hiển thị bên phải toolbar.
typedef KeyboardCounterBuilder = String Function(int length, int? maxLength);

/// TextField hiển thị toolbar phía trên bàn phím khi focus,
/// toolbar có counter ký tự ở bên phải + nút Done bên trái (mặc định).
///
/// Component này expose đầy đủ param như [TextField] gốc để dễ tuỳ biến.
class KeyboardTextField extends StatefulWidget {
  const KeyboardTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.scrollPadding = const EdgeInsets.all(20),
    this.scrollPhysics,
    this.contentInsertionConfiguration,
    // Toolbar custom params
    this.showToolbar = true,
    this.toolbarBuilder,
    this.counterBuilder,
    this.doneLabel = 'Done',
    this.doneStyle,
    this.counterStyle,
    this.toolbarBackgroundColor = const Color(0xFFD1D5DB),
    this.toolbarHeight = 44,
    this.toolbarPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.toolbarBorder,
    this.toolbarLeading,
    this.toolbarCenter,
    this.dismissOnDone = true,
  });

  // Standard TextField params
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final Color? cursorColor;
  final double cursorWidth;
  final Radius? cursorRadius;
  final EdgeInsets scrollPadding;
  final ScrollPhysics? scrollPhysics;
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  // Toolbar params
  final bool showToolbar;
  final KeyboardToolbarBuilder? toolbarBuilder;
  final KeyboardCounterBuilder? counterBuilder;
  final String doneLabel;
  final TextStyle? doneStyle;
  final TextStyle? counterStyle;
  final Color toolbarBackgroundColor;
  final double toolbarHeight;
  final EdgeInsetsGeometry toolbarPadding;
  final Border? toolbarBorder;
  final Widget? toolbarLeading;
  final Widget? toolbarCenter;
  final bool dismissOnDone;

  @override
  State<KeyboardTextField> createState() => _KeyboardTextFieldState();
}

class _KeyboardTextFieldState extends State<KeyboardTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  OverlayEntry? _overlay;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant KeyboardTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      if (_ownsFocusNode) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _removeToolbar();
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!widget.showToolbar) return;
    if (_focusNode.hasFocus) {
      _showToolbar();
    } else {
      _removeToolbar();
    }
  }

  void _showToolbar() {
    if (_overlay != null) return;
    _overlay = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  void _removeToolbar() {
    _overlay?.remove();
    _overlay = null;
  }

  Widget _buildOverlay(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomInset,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final length = _controller.text.characters.length;
            if (widget.toolbarBuilder != null) {
              return widget.toolbarBuilder!(
                context,
                length,
                widget.maxLength,
                _handleDone,
              );
            }
            return _DefaultToolbar(
              length: length,
              maxLength: widget.maxLength,
              doneLabel: widget.doneLabel,
              doneStyle: widget.doneStyle,
              counterStyle: widget.counterStyle,
              backgroundColor: widget.toolbarBackgroundColor,
              height: widget.toolbarHeight,
              padding: widget.toolbarPadding,
              border: widget.toolbarBorder,
              leading: widget.toolbarLeading,
              center: widget.toolbarCenter,
              counterBuilder: widget.counterBuilder,
              onDone: _handleDone,
            );
          },
        ),
      ),
    );
  }

  void _handleDone() {
    if (widget.dismissOnDone) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorColor: widget.cursorColor,
      cursorWidth: widget.cursorWidth,
      cursorRadius: widget.cursorRadius,
      scrollPadding: widget.scrollPadding,
      scrollPhysics: widget.scrollPhysics,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
    );
  }
}

class _DefaultToolbar extends StatelessWidget {
  const _DefaultToolbar({
    required this.length,
    required this.maxLength,
    required this.doneLabel,
    required this.backgroundColor,
    required this.height,
    required this.padding,
    required this.onDone,
    this.doneStyle,
    this.counterStyle,
    this.border,
    this.leading,
    this.center,
    this.counterBuilder,
  });

  final int length;
  final int? maxLength;
  final String doneLabel;
  final TextStyle? doneStyle;
  final TextStyle? counterStyle;
  final Color backgroundColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final Border? border;
  final Widget? leading;
  final Widget? center;
  final VoidCallback onDone;
  final KeyboardCounterBuilder? counterBuilder;

  @override
  Widget build(BuildContext context) {
    final counterText = counterBuilder != null
        ? counterBuilder!(length, maxLength)
        : (maxLength != null ? '$length/$maxLength' : '$length');

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border ??
            const Border(
              top: BorderSide(color: Color(0x33000000), width: 0.5),
            ),
      ),
      child: Row(
        children: [
          leading ??
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onDone,
                child: Text(
                  doneLabel,
                  style: doneStyle ??
                      const TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                ),
              ),
          Expanded(child: Center(child: center ?? const SizedBox.shrink())),
          Text(
            counterText,
            style: counterStyle ??
                const TextStyle(
                  color: Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}
