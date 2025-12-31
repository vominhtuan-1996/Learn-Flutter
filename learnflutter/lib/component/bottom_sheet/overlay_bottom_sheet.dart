import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

class BottomSheetOverlay {
  static OverlayEntry? _entry;
  static late AnimationController _controller;
  static late Animation<Offset> _animation;

  static void show(
    BuildContext context, {
    required Widget Function() builder,
    double initialHeight = 300,
    double minHeight = 250,
    double maxHeight = 600,
    bool barrierDismissible = true,
  }) {
    assert(minHeight > 0, 'chiều cao tối thiểu phải lớn hơn 0');
    assert(maxHeight > minHeight, 'chiều cao tối đa phải lớn hơn chiều cao tối thiểu');
    assert(initialHeight >= minHeight && initialHeight <= maxHeight,
        'chiều cao lần đầu phải nằm giữa chiều cao tối thiểu và tối đa');
    assert(maxHeight <= MediaQuery.of(context).size.height * 0.9,
        'chiều cao tối đa không được lớn hơn 9/10 chiều cao màn hình');
    if (_entry != null) return;

    final overlay = Overlay.of(context);
    final vsync = Navigator.of(context);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    final maxAllowedHeight = context.mediaQuery.size.height * 0.9;
    final clampedMaxHeight = maxHeight.clamp(minHeight, maxAllowedHeight);

    _entry = OverlayEntry(
      builder: (context) => _BottomSheetWidget(
        builder: builder,
        initialHeight: initialHeight.clamp(minHeight, clampedMaxHeight),
        minHeight: minHeight,
        maxHeight: maxHeight,
        barrierDismissible: barrierDismissible,
      ),
    );

    overlay.insert(_entry!);
    _controller.forward();
  }

  static void hide() async {
    await _controller.reverse();
    _entry?.remove();
    _entry = null;
    _controller.dispose();
  }
}

class _BottomSheetWidget extends StatefulWidget {
  final double initialHeight;
  final double minHeight;
  final double maxHeight;
  final Widget Function() builder;
  final bool barrierDismissible;

  const _BottomSheetWidget({
    required this.builder,
    required this.initialHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.barrierDismissible,
  });

  @override
  State<_BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<_BottomSheetWidget> with TickerProviderStateMixin {
  late double _height;
  late ScrollController _scrollController;
  bool _isDragging = false;
  double _dragStartY = 0;
  double _dragCurrentHeight = 0;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight.clamp(widget.minHeight, widget.maxHeight);
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_isDragging) {
          final offset = _scrollController.offset;
          final delta = offset - _lastOffset;
          _lastOffset = offset;

          setState(() {
            _height = (_height - delta).clamp(widget.minHeight, widget.maxHeight);
          });

          // Prevent scrolling if height not maxed out
          if (_height < widget.maxHeight && delta > 0) {
            // Kéo xuống: tăng height, chặn scroll
            setState(() {
              _height = (_height + delta).clamp(widget.minHeight, widget.maxHeight);
            });

            // _scrollController.jumpTo(0); // chặn scroll, vì đang tăng height
          } else if (_height >= widget.maxHeight) {
            // Cho phép scroll bình thường
            _lastOffset = _scrollController.offset;
          }
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartY = details.globalPosition.dy;
    _dragCurrentHeight = _height;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dragOffset = details.globalPosition.dy - _dragStartY;
    final isDraggingDown = dragOffset > 0;
    final isAtTop = !_scrollController.hasClients ||
        (_scrollController.hasClients && _scrollController.offset <= 0);

    if (isAtTop || !isDraggingDown) {
      final newHeight = _dragCurrentHeight - dragOffset;
      setState(() {
        _height = newHeight.clamp(widget.minHeight, widget.maxHeight);
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;

    if (_height < widget.minHeight + 50) {
      BottomSheetOverlay.hide();
    } else {
      setState(() {
        _height = _height.clamp(widget.minHeight, widget.maxHeight);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.barrierDismissible ? BottomSheetOverlay.hide : null,
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: BottomSheetOverlay._animation,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: _height, end: _height),
                duration: const Duration(milliseconds: 250),
                curve: Curves.decelerate,
                builder: (context, height, _) {
                  return Material(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      height: height,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const ClampingScrollPhysics(),
                              child: widget.builder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
