import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

/// Lớp CustomSearchBar là thành phần tìm kiếm được thiết kế riêng, không sử dụng SearchAnchor của Material.
/// Nó bao gồm một ô nhập liệu với thiết kế bo góc, đổ bóng nhẹ và hỗ trợ hiển thị gợi ý.
class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final List<dynamic>? suggestions;
  final Widget Function(BuildContext, dynamic)? suggestionBuilder;
  final bool isLoading;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Tìm kiếm...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.suggestions,
    this.suggestionBuilder,
    this.isLoading = false,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container chính của thanh tìm kiếm với hiệu ứng đổ bóng và bo góc.
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.grey[200]!,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(Icons.search,
                  color: _isFocused ? AppColors.primary : Colors.grey),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.close, size: 20, color: Colors.grey),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onClear?.call();
                        setState(() {});
                      },
                    )
                  : (widget.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CupertinoActivityIndicator(radius: 8),
                        )
                      : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // Hiển thị danh sách gợi ý ngay bên dưới ô nhập liệu khi có kết quả.
        if (widget.suggestions != null &&
            widget.suggestions!.isNotEmpty &&
            _isFocused)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints:
                BoxConstraints(maxHeight: context.mediaQuery.size.height * 0.4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.suggestions!.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      _focusNode.unfocus();
                      widget.suggestionBuilder
                          ?.call(context, widget.suggestions![index]);
                    },
                    child: widget.suggestionBuilder
                            ?.call(context, widget.suggestions![index]) ??
                        Container(),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
