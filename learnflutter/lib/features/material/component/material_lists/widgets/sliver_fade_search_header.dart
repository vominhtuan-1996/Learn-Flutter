import 'package:flutter/material.dart';

class FadeSearchHeader extends StatefulWidget {
  final ScrollController scrollController;
  final String hintText;
  final double fadeStartOffset;

  const FadeSearchHeader({
    super.key,
    required this.scrollController,
    this.hintText = 'Tìm kiếm...',
    this.fadeStartOffset = 100,
  });

  @override
  State<FadeSearchHeader> createState() => _FadeSearchHeaderState();
}

class _FadeSearchHeaderState extends State<FadeSearchHeader> {
  bool _showSearchIcon = false;
  bool _forceShowSearchBar = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  void _handleScroll() {
    final offset = widget.scrollController.offset;
    final shouldShowIcon = offset > widget.fadeStartOffset && !_forceShowSearchBar;

    if (shouldShowIcon != _showSearchIcon) {
      setState(() {
        _showSearchIcon = shouldShowIcon;
      });
    }
  }

  void _toggleSearchBar() {
    setState(() {
      _forceShowSearchBar = !_forceShowSearchBar;
      if (_forceShowSearchBar) {
        _showSearchIcon = false;
        widget.scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          _focusNode.requestFocus();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = widget.scrollController.hasClients ? widget.scrollController.offset : 0.0;
    final progress = (offset / widget.fadeStartOffset).clamp(0.0, 1.0);
    final opacity = _forceShowSearchBar ? 1.0 : (1.0 - progress);
    final scale = 1.0 - (0.3 * progress);
    final headerHeight = 100 - (40 * progress);

    return SliverAppBar(
        pinned: true,
        title: const Text('Fade Search Demo'),
        actions: [
          if (_showSearchIcon)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleSearchBar,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(headerHeight),
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12 + (12 * (1 - progress)), // padding top/bottom giảm dần
              ),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 48 + (12 * (1 - progress)), // Chiều cao TextField co rút
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
